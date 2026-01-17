import 'package:flutter_test/flutter_test.dart';
import 'package:base32/base32.dart';

void main() {
  group('Base32 Tests', () {
    test('Encode string to base32', () {
      final encoded = base32.encodeString('foobar');
      expect(encoded, 'MZXW6YTBOI======');
    });

    test('Decode base32 to string', () {
      final decoded = base32.decodeAsString('MZXW6YTBOI======');
      expect(decoded, 'foobar');
    });

    test('Encode hex string to base32', () {
      final encoded = base32.encodeHexString('48656c6c6f21deadbeef');
      expect(encoded, 'JBSWY3DPEHPK3PXP');
    });

    test('Decode base32 to hex string', () {
      final decoded = base32.decodeAsHexString('JBSWY3DPEHPK3PXP');
      expect(decoded, '48656c6c6f21deadbeef');
    });
  });
}
