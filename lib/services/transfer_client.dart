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

  final _updatesController = StreamController<TransferTask>.broadcast();
  Stream<TransferTask> get transferUpdates => _updatesController.stream;

  TransferClient({required this.myId, required this.myName});

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
    _updatesController.add(task);

    final client = HttpClient();
    try {
      final accepted = await _prepare(client, peer, task);
      if (!accepted) {
        task.status = TransferStatus.rejected;
        _updatesController.add(task);
        return;
      }

      task.status = TransferStatus.inProgress;
      _updatesController.add(task);
      await _upload(client, peer, task, file);

      task.status = TransferStatus.completed;
      _updatesController.add(task);
    } catch (e) {
      task.status = TransferStatus.failed;
      task.errorMessage = '$e';
      _updatesController.add(task);
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
      _updatesController.add(task);
      return chunk;
    });
    await request.addStream(progressStream);
    await request.close();
  }

  void dispose() {
    _updatesController.close();
  }
}
