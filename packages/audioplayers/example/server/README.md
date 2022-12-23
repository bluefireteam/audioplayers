A simple HTTP server to provide audio sources using [package:shelf](https://pub.dev/packages/shelf).
This server listens to loop-back (localhost, 127.0.0.1).

To run this server locally, run as follows:

```bash
$ dart run bin/server.dart
```

Environment variables:

- `LATENCY`: the timeout until the server should respond in milliseconds, default: `0`.
- `PORT`: the port the server should listen on, default: `8080`.
- `LOG_REQUESTS`: log the network requests, default: `false`.
