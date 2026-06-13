import 'package:raiz/src/config.dart';
import 'package:raiz/src/generator.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectConfig', () {
    test('generates title from snake_case name', () {
      final config = ProjectConfig(name: 'my_cool_app');
      expect(config.projectTitle, 'My Cool App');
    });

    test('uses custom title when provided', () {
      final config = ProjectConfig(name: 'app', title: 'Custom Title');
      expect(config.projectTitle, 'Custom Title');
    });

    test('default seed color is blue', () {
      final config = ProjectConfig(name: 'test');
      expect(config.seedColor, '0xFF1976D2');
    });

    test('default org is com.raiz', () {
      final config = ProjectConfig(name: 'test');
      expect(config.org, 'com.raiz');
    });

    test('dark theme defaults to false', () {
      final config = ProjectConfig(name: 'test');
      expect(config.darkTheme, false);
    });

    test('profile defaults to basic', () {
      final config = ProjectConfig(name: 'test');
      expect(config.profile, RaizProfile.basic);
    });

    test('seed color literal removes 0x prefix', () {
      final config = ProjectConfig(name: 'test', seedColor: '0xFF2E7D32');
      expect(config.seedColorLiteral, 'Color(0xFF2E7D32)');
    });

    test('skip flags default to false', () {
      final config = ProjectConfig(name: 'test');
      expect(config.skipGit, false);
      expect(config.skipInstall, false);
    });
  });

  group('RaizProfile', () {
    test('fromString returns basic for unknown', () {
      expect(RaizProfile.fromString('nope'), RaizProfile.basic);
    });

    test('fromString returns complete', () {
      expect(RaizProfile.fromString('complete'), RaizProfile.complete);
    });

    test('fromString returns store', () {
      expect(RaizProfile.fromString('store'), RaizProfile.store);
    });

    test('fromString is case insensitive', () {
      expect(RaizProfile.fromString('COMPLETE'), RaizProfile.complete);
      expect(RaizProfile.fromString('Store'), RaizProfile.store);
    });
  });

  group('Generator', () {
    test('constructs with basic config', () {
      final config = ProjectConfig(name: 'test_app');
      final gen = RaizGenerator(config);
      expect(gen, isNotNull);
    });
  });
}
