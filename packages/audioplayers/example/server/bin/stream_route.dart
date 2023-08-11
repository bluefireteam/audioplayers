import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class StreamRoute {
  static const timesRadioUrl = 'https://timesradio.wireless.radio/stream';

  final mpegStreamController = StreamController<List<int>>.broadcast();

  StreamRoute() {
    init();
  }

  Future<void> init() async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(timesRadioUrl));
    final response = await request.close();
    mpegStreamController.addStream(response.listenAndBuffer());
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
