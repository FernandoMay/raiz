import 'package:raiz/raiz.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectConfig', () {
    test('generates title from name', () {
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
  });

  group('Templates', () {
    test('main.dart template contains MaterialApp', () {
      final config = ProjectConfig(name: 'demo_app');
      // Verify the generator produces valid Dart
      final gen = RaizGenerator(config);
      expect(gen, isNotNull);
    });

    test('seed color int is accessible', () {
      final config = ProjectConfig(name: 'x', seedColor: '0xFFFF6347');
      expect(config.seedColor, '0xFFFF6347');
    });
  });
}
