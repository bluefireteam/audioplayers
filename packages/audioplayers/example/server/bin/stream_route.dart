import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class StreamRoute {
  static const timesRadioUrl = 'https://timesradio.wireless.radio/stream';
  static const mpegRecordUrl = 'public/files/audio/mpeg-record.bin';
  static const _isLiveMode = false;
  static const _isRecordMode = false;

  final mpegStreamController = StreamController<List<int>>.broadcast();

  StreamRoute() : assert(!_isRecordMode || _isLiveMode) {
    if (_isRecordMode) {
      recordLiveStream();
    }
    if (_isLiveMode) {
      playLiveStream();
    } else {
      playLocalStream();
    }
  }

  Future<void> recordLiveStream() async {
    // Save lists of bytes in a file, where each first byte indicates the
    // length of its following list.
    final recordOutput = File(mpegRecordUrl);
    if (recordOutput.existsSync()) {
      await recordOutput.delete();
    }
    var time = DateTime.now();
    mpegStreamController.stream.listen((bytes) async {
      final now = DateTime.now();
      print(now.difference(time));
      time = now;
      await recordOutput.writeAsBytes(
        [bytes.length, ...bytes],
        flush: true,
        mode: FileMode.append,
      );
    });
  }

  Future<void> playLiveStream() async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(timesRadioUrl));
    final response = await request.close();
    mpegStreamController.addStream(response);
  }

  Future<void> playLocalStream() async {
    final recordInput = File(mpegRecordUrl);
    final streamReader = ChunkedStreamReader(recordInput.openRead());
    final fileSize = await recordInput.length();
    var position = 0;
    final mpegBytes = <List<int>>[];
    while (position < fileSize) {
      final chunkLength = (await streamReader.readChunk(1))[0];
      final chunk = await streamReader.readChunk(chunkLength);
      position += chunkLength + 1;
      mpegBytes.add(chunk);
    }
    var mpegBytesPosition = 0;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
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
