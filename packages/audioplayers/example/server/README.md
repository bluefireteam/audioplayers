A simple Dart HTTP server using [package:shelf](https://pub.dev/packages/shelf).

- Listens on "any IP" (0.0.0.0) instead of loop-back (localhost, 127.0.0.1) to
  allow remote connections.
- Defaults to listening on port `8080`, but this can be configured by setting
  the `PORT` environment variable. (This is also the convention used by
  [Cloud Run](https://cloud.google.com/run).)
- Includes `Dockerfile` for easy containerization

To run this server locally, run as follows:

```bash
$ dart run bin/server.dart
```

To deploy on [Cloud Run](https://cloud.google.com/run), click here

[![Run on Google Cloud](https://deploy.cloud.run/button.svg)](https://deploy.cloud.run/?git_repo=https://github.com/dart-lang/samples.git&dir=server/simple)

or follow
[these instructions](https://cloud.google.com/run/docs/quickstarts/build-and-deploy/other).
