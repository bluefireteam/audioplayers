import 'package:audioplayers/src/uri_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UriCoder', () {
    test(
      'Encode Special Character',
      () {
        const uri = '/coins_non_ascii_и.wav';
        final encoded = UriCoder.encodeOnce(uri);
        expect(encoded, '/coins_non_ascii_%D0%B8.wav');
      },
    );
    test(
      'Encode Space',
      () {
        const uri = '/coins .wav';
        final encoded = UriCoder.encodeOnce(uri);
        expect(encoded, '/coins%20.wav');
      },
    );
    test(
      'Already encoded Character',
      () {
        const uri = 'https://myurl/audio%2F_music.mp4?alt=media&token=abc';
        final encoded = UriCoder.encodeOnce(uri);
        expect(encoded, uri);
      },
    );
    test(
      'Encoded and decoded are the same',
      () {
        const uri = 'https://myurl/audio';
        final encoded = UriCoder.encodeOnce(uri);
        expect(encoded, uri);
      },
    );
  });
}
