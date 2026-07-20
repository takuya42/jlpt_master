import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_master/features/remote_config/presentation/startup_gate.dart';

void main() {
  group('isNewerVersion', () {
    test('requires an update when Remote Config is newer', () {
      expect(isNewerVersion('1.1.0', '1.0.9'), isTrue);
    });

    test('does not require an update for equal or older versions', () {
      expect(isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(isNewerVersion('1.9.9', '2.0.0'), isFalse);
    });

    test('compares versions with a different number of components', () {
      expect(isNewerVersion('1.0.1', '1.0'), isTrue);
      expect(isNewerVersion('1.0', '1.0.0'), isFalse);
    });
  });
}
