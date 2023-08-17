// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class StreamRoute {
  static const timesRadioUrl = 'https://timesradio.wireless.radio/stream';
  static const mpegRecordPath = 'public/files/live_streams/mpeg-record.bin';

  final mpegStreamController = StreamController<List<int>>.broadcast();

  StreamRoute({bool isLiveMode = false, bool isRecordMode = false})
      : assert(!isRecordMode || isLiveMode) {
    if (isRecordMode) {
      recordLiveStream();
    }
    if (isLiveMode) {
      playLiveStream();
    } else {
      playLocalStream();
    }
  }

  Future<void> recordLiveStream() async {
    const recordingTime = Duration(seconds: 10);
    // Save lists of bytes in a file, where each first four bytes indicate the
    // length of its following list.
    final recordOutput = File(mpegRecordPath);
    final fileBytes = <int>[];
    final mpegSub = mpegStreamController.stream.listen((bytes) async {
      fileBytes.addAll([...int32ToBytes(bytes.length), ...bytes]);
    });
    Future.delayed(recordingTime).then((value) async {
      print('Recording finished');
      await mpegSub.cancel();
      await recordOutput.writeAsBytes(
        fileBytes,
        flush: true,
      );
    });
  }

  Uint8List int32ToBytes(int value) =>
      Uint8List(4)..buffer.asInt32List()[0] = value;

  int bytesToInt32(List<int> bytes) =>
      Uint8List.fromList(bytes).buffer.asInt32List()[0];

  Future<void> playLiveStream() async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(timesRadioUrl));
    final response = await request.close();
    mpegStreamController.addStream(response);
  }

  Future<void> playLocalStream() async {
    final recordInput = File(mpegRecordPath);
    final streamReader = ChunkedStreamReader(recordInput.openRead());
    final fileSize = await recordInput.length();
    var position = 0;
    final mpegBytes = <List<int>>[];
    while (position < fileSize) {
      final chunkLength = bytesToInt32(await streamReader.readChunk(4));
      final chunk = await streamReader.readChunk(chunkLength);
      position += chunkLength + 4;
      mpegBytes.add(chunk);
    }
    var mpegBytesPosition = 0;
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      mpegStreamController.add(mpegBytes[mpegBytesPosition]);
      mpegBytesPosition++;
      if (mpegBytesPosition >= mpegBytes.length) {
        mpegBytesPosition = 0;
      }
    });
  }

  Router get router {
    final router = Router();
    router.get('/wav', (Request request) async {
      final range = request.headers['range'];
      const contentType = {'Content-Type': 'audio/wav'};
      final file = File('public/files/audio/laser.wav');
      if (range != null) {
        final fileSize = await file.length();

        final parts = range.replaceFirst('bytes=', '').split('-');
        final start = int.parse(parts[0]);
        final end = int.tryParse(parts[1]) ?? fileSize - 1;

        if (start >= fileSize) {
          return Response(
            416,
            body: 'Requested range not satisfiable\n$start >= $fileSize',
          );
        }

        final streamReader = ChunkedStreamReader<int>(file.openRead());
        final chunkLength = end - start + 1;
        final head = {
          'Content-Range': 'bytes $start-$end/$fileSize',
          'Accept-Ranges': 'bytes',
          'Content-Length': '$chunkLength',
          ...contentType,
        };
        if (start > 0) {
          await streamReader.readChunk(start);
        }
        final res = Response.ok(
          await streamReader.readChunk(chunkLength),
          headers: head,
        );
        return res;
      } else {
        final bytes = await file.readAsBytes();
        final fileSize = bytes.length;
        final head = {
          'Content-Length': '$fileSize',
          ...contentType,
        };
        final res = Response.ok(
          bytes.toList(),
          headers: head,
        );
        return res;
      }
    });

    router.get('/mpeg', (Request request) async {
      const contentType = {'Content-Type': 'audio/mpeg'};

      final head = {
        'Accept-Ranges': 'bytes',
        ...contentType,
      };
      final res = Response.ok(
        mpegStreamController.stream,
        headers: head,
      );
      return res;
    });
    return router;
  }

  Handler get pipeline {
    return const Pipeline().addHandler(router);
  }
}
