import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../models/peer.dart';
import '../models/transfer_task.dart';

// Bir peer'a dosya gönderme akışı: önce /prepare ile izin ister,
// kabul edilirse /receive/<session> ile ham baytları stream eder.
class TransferClient {
  final String myId;
  final String myName;
  bool _disposed = false;

  final _updatesController = StreamController<TransferTask>.broadcast();
  Stream<TransferTask> get transferUpdates => _updatesController.stream;

  TransferClient({required this.myId, required this.myName});

  // dispose() cagirildiktan sonra hala devam eden bir gonderim buraya
  // ulasabilir; kapatilmis bir stream'e ekleme yapmak uygulamayi cokertir.
  void _addUpdate(TransferTask task) {
    if (_disposed) return;
    _updatesController.add(task);
  }

  Future<void> sendFile(Peer peer, File file) async {
    final fileName = file.uri.pathSegments.last;
    final fileSize = await file.length();
    final sessionId = const Uuid().v4();

    final task = TransferTask(
      id: sessionId,
      fileName: fileName,
      fileSize: fileSize,
      direction: TransferDirection.send,
      peer: peer,
      status: TransferStatus.awaitingApproval,
    );
    _addUpdate(task);

    final client = HttpClient();
    try {
      final accepted = await _prepare(client, peer, task);
      if (!accepted) {
        task.status = TransferStatus.rejected;
        _addUpdate(task);
        return;
      }

      task.status = TransferStatus.inProgress;
      _addUpdate(task);
      await _upload(client, peer, task, file);

      task.status = TransferStatus.completed;
      _addUpdate(task);
    } catch (e) {
      task.status = TransferStatus.failed;
      task.errorMessage = '$e';
      _addUpdate(task);
    } finally {
      client.close();
    }
  }

  Future<bool> _prepare(HttpClient client, Peer peer, TransferTask task) async {
    final request = await client.postUrl(
      Uri.http('${peer.host}:${peer.port}', '/prepare'),
    );
    request.headers.contentType = ContentType.json;
    final bodyBytes = utf8.encode(jsonEncode({
      'senderId': myId,
      'senderName': myName,
      'fileName': task.fileName,
      'fileSize': task.fileSize,
      'sessionId': task.id,
    }));
    request.headers.contentLength = bodyBytes.length;
    request.add(bodyBytes);

    final response = await request.close();
    final body = await utf8.decodeStream(response);
    return jsonDecode(body)['accepted'] == true;
  }

  Future<void> _upload(
    HttpClient client,
    Peer peer,
    TransferTask task,
    File file,
  ) async {
    final request = await client.postUrl(
      Uri.http('${peer.host}:${peer.port}', '/receive/${task.id}'),
    );
    request.contentLength = task.fileSize;

    int sent = 0;
    final progressStream = file.openRead().map((chunk) {
      sent += chunk.length;
      task.progressBytes = sent;
      _addUpdate(task);
      return chunk;
    });
    await request.addStream(progressStream);
    await request.close();
  }

  void dispose() {
    _disposed = true;
    _updatesController.close();
  }
}
