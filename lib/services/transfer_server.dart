import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/peer.dart';
import '../models/transfer_task.dart';
import '../utils/constants.dart';
import 'settings_service.dart';

// Gelen dosya transferlerini kabul eden HTTP sunucusu.
// İki aşamalı akış:
//   POST /prepare           -> kullanıcıya kabul/red sorulur (Completer ile beklenir)
//   POST /receive/<session> -> kabul edildiyse ham dosya baytları alınır
class TransferServer {
  final String myId;
  final String myName;
  final String myPlatform;
  final SettingsService _settings = SettingsService();

  HttpServer? _server;
  bool _stopped = false;

  final Map<String, Completer<bool>> _pendingApprovals = {};
  final Map<String, TransferTask> _tasks = {};

  final _incomingController = StreamController<TransferTask>.broadcast();
  final _updatesController = StreamController<TransferTask>.broadcast();

  // Yeni bir istek (kabul/red sorulması gereken) geldiğinde yayınlanır.
  Stream<TransferTask> get incomingRequests => _incomingController.stream;
  // İlerleme/durum güncellemeleri (hem prepare-sonrası hem transfer sırasında).
  Stream<TransferTask> get transferUpdates => _updatesController.stream;

  // stop() cagirildiktan sonra hala devam eden bir istek buraya ulasabilir;
  // kapatilmis bir stream'e ekleme yapmak uygulamayi cokertir.
  void _addIncoming(TransferTask task) {
    if (_stopped) return;
    _incomingController.add(task);
  }

  void _addUpdate(TransferTask task) {
    if (_stopped) return;
    _updatesController.add(task);
  }

  TransferServer({
    required this.myId,
    required this.myName,
    required this.myPlatform,
  });

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, kTransferHttpPort);
    _server!.listen(_handleRequest);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      if (request.method == 'GET' && request.uri.path == '/api/whoami') {
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({
          'id': myId,
          'name': myName,
          'platform': myPlatform,
        }));
        await request.response.close();
      } else if (request.method == 'POST' && request.uri.path == '/prepare') {
        await _handlePrepare(request);
      } else if (request.method == 'POST' &&
          request.uri.path.startsWith('/receive/')) {
        final sessionId = request.uri.path.substring('/receive/'.length);
        await _handleReceive(request, sessionId);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      }
    } catch (e) {
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write(jsonEncode({'ok': false, 'error': '$e'}));
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> _handlePrepare(HttpRequest request) async {
    final body = jsonDecode(await utf8.decodeStream(request));
    final String sessionId = body['sessionId'] as String;
    final String senderId = body['senderId'] as String;
    final String senderName = body['senderName'] as String;
    final String fileName = body['fileName'] as String;
    final int fileSize = body['fileSize'] as int;

    final peer = Peer(
      id: senderId,
      displayName: senderName,
      host: request.connectionInfo?.remoteAddress.address ?? '',
      port: kTransferHttpPort,
      platform: 'unknown',
      lastSeen: DateTime.now(),
    );

    final task = TransferTask(
      id: sessionId,
      fileName: fileName,
      fileSize: fileSize,
      direction: TransferDirection.receive,
      peer: peer,
      status: TransferStatus.awaitingApproval,
    );
    _tasks[sessionId] = task;

    final completer = Completer<bool>();
    _pendingApprovals[sessionId] = completer;
    _addIncoming(task);

    final accepted = await completer.future.timeout(
      kTransferApprovalTimeout,
      onTimeout: () => false,
    );

    _pendingApprovals.remove(sessionId);
    if (!accepted) {
      task.status = TransferStatus.rejected;
      _addUpdate(task);
      _tasks.remove(sessionId);
    }

    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({'accepted': accepted}));
    await request.response.close();
  }

  // UI'daki kabul/red dialoğu bu metodu çağırır.
  void respondToRequest(String sessionId, bool accepted) {
    final completer = _pendingApprovals[sessionId];
    if (completer != null && !completer.isCompleted) {
      completer.complete(accepted);
    }
  }

  Future<void> _handleReceive(HttpRequest request, String sessionId) async {
    final task = _tasks[sessionId];
    if (task == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    task.status = TransferStatus.inProgress;
    _addUpdate(task);

    final saveDir = await _resolveSaveDirectory();
    final file = File('${saveDir.path}${Platform.pathSeparator}${task.fileName}');
    final sink = file.openWrite();

    try {
      await for (final chunk in request) {
        sink.add(chunk);
        task.progressBytes += chunk.length;
        _addUpdate(task);
      }
      await sink.close();
      task.status = TransferStatus.completed;
      _addUpdate(task);

      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'ok': true}));
      await request.response.close();
    } catch (e) {
      await sink.close();
      task.status = TransferStatus.failed;
      task.errorMessage = '$e';
      _addUpdate(task);

      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(jsonEncode({'ok': false, 'error': '$e'}));
      await request.response.close();
    } finally {
      _tasks.remove(sessionId);
    }
  }

  Future<Directory> _resolveSaveDirectory() async {
    if (Platform.isWindows) {
      final customPath = await _settings.getSaveDirectory();
      if (customPath != null && await Directory(customPath).exists()) {
        return Directory(customPath);
      }
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    }
    return getApplicationDocumentsDirectory();
  }

  Future<void> stop() async {
    _stopped = true;
    await _server?.close(force: true);
    _server = null;
    await _incomingController.close();
    await _updatesController.close();
  }
}
