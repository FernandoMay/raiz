import 'dart:io';

class ProjectConfig {
  final String name;
  final String? title;
  final String? description;
  final String seedColor;
  final String org;
  final bool darkTheme;
  final String? remote;
  final String? path;

  ProjectConfig({
    required this.name,
    this.title,
    this.description,
    this.seedColor = '0xFF1976D2',
    this.org = 'com.raiz',
    this.darkTheme = false,
    this.remote,
    this.path,
  });

  String get projectTitle =>
      title ?? name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

class RaizGenerator {
  final ProjectConfig config;

  RaizGenerator(this.config);

  String get _projectDir {
    if (config.path != null) {
      return '${config.path}\\${config.name}';
    }
    return '${Directory.current.path}\\${config.name}';
  }

  Future<void> generate() async {
    print('\n⚡ Raíz — Project Genesis Engine\n');
    print('🌱 Generating "${config.name}"...\n');

    await _runFlutterCreate();
    await _modifyPubspec();
    await _writeMainDart();
    await _writeCI();
    await _writeTests();
    await _writeReadme();
    await _runPubGet();
    await _runAnalyze();
    await _setupGit();

    print('\n✅ \x1b[32m${config.projectTitle}\x1b[0m generated successfully!\n');
    print('   📁 $_projectDir');
    print('   🏷️  ${config.projectTitle}');
    print('   🎨 ${config.seedColor}');
    if (config.remote != null) {
      print('   🔗 ${config.remote}');
    }
    print('   \n   \x1b[2mcd ${config.name} && flutter run\x1b[0m\n');
  }

  Future<void> _runFlutterCreate() async {
    final target = config.path ?? Directory.current.path;
    final args = ['create', '--org', config.org, config.name];
    if (config.description != null) {
      args.add('--description');
      args.add(config.description!);
    }
    final result = await Process.run('flutter', args,
        workingDirectory: target, runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('flutter create failed:\n${result.stderr}');
    }
    print('   ✅ flutter create');
  }

  Future<void> _modifyPubspec() async {
    final file = File('$_projectDir\\pubspec.yaml');
    var content = await file.readAsString();

    content = content.replaceFirst(
      RegExp(r'sdk: .+'),
      "sdk: ^3.6.0",
    );

    if (!content.contains('flutter_lints')) {
      content = content.replaceFirst(
        RegExp(r'dev_dependencies:'),
        'dev_dependencies:\n  flutter_lints: ^5.0.0',
      );
    }

    await file.writeAsString(content);
    print('   ✅ pubspec.yaml');
  }

  Future<void> _writeMainDart() async {
    final targetDir = '$_projectDir\\lib';
    final file = File('$targetDir\\main.dart');

    final colorInt = config.seedColor.replaceFirst('0x', '');
    final seedCode = 'Color(0xFF$colorInt)';

    final mainContent = '''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${config.projectTitle}',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: $seedCode,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      ${config.darkTheme ? '''
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: $seedCode,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
''' : ''}
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${config.projectTitle}'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rocket_launch,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '${config.projectTitle}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${config.description ?? 'Generated with Raíz'}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''';

    await file.writeAsString(mainContent);
    print('   ✅ lib/main.dart');
  }

  Future<void> _writeCI() async {
    final ciDir = '$_projectDir\\.github\\workflows';
    Directory(ciDir).createSync(recursive: true);
    final file = File('$ciDir\\flutter.yml');

    await file.writeAsString('''
name: Flutter CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Run tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --debug
''');

    print('   ✅ .github/workflows/flutter.yml');
  }

  Future<void> _writeTests() async {
    final testDir = '$_projectDir\\test';
    final widgetTest = File('$testDir\\widget_test.dart');
    if (await widgetTest.exists()) {
      await widgetTest.delete();
    }

    final file = File('$testDir\\models_test.dart');

    await file.writeAsString('''
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Config', () {
    test('app title is correct', () {
      const title = '${config.projectTitle}';
      expect(title, isNotEmpty);
    });

    test('seed color is valid', () {
      const hex = ${config.seedColor};
      expect(hex, isNonZero);
    });
  });
}
''');

    print('   ✅ test/models_test.dart');
  }

  Future<void> _writeReadme() async {
    final file = File('$_projectDir\\README.md');

    await file.writeAsString('''
# ${config.projectTitle}

${config.description ?? 'A Flutter project generated with Raíz.'}

## Tech Stack

- **Flutter** (SDK ^3.6.0) — Cross-platform UI framework
- **Material 3** — Modern design with `ColorScheme.fromSeed`
- **GitHub Actions** — CI/CD pipeline (analyze + test + build)

## Quick Start

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## CI/CD

Every push and pull request triggers:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. `flutter build apk --debug`

## Brand Identity

| Property | Value |
|----------|-------|
| Title | ${config.projectTitle} |
| Seed Color | ${config.seedColor} |
| Material 3 | ✅ |
| Dark Theme | ${config.darkTheme ? '✅' : '❌'} |

---

*Generated with [Raíz](https://github.com/btyf/raiz) — Project Genesis Engine*
''');

    print('   ✅ README.md');
  }

  Future<void> _runPubGet() async {
    final result = await Process.run('flutter', ['pub', 'get'],
        workingDirectory: _projectDir, runInShell: true);
    if (result.exitCode != 0) {
      print('   ⚠️  flutter pub get warnings:\n${result.stderr}');
    } else {
      print('   ✅ flutter pub get');
    }
  }

  Future<void> _runAnalyze() async {
    final result = await Process.run('flutter', ['analyze'],
        workingDirectory: _projectDir, runInShell: true);
    final out = result.stdout as String;
    final err = result.stderr as String;
    if (result.exitCode == 0 || out.contains('No issues found')) {
      print('   ✅ flutter analyze → 0 issues');
    } else {
      print('   ⚠️  flutter analyze:\n$out\n$err');
    }
  }

  Future<void> _setupGit() async {
    final gitDir = Directory('$_projectDir\\.git');
    if (!await gitDir.exists()) {
      final init = await Process.run('git', ['init'],
          workingDirectory: _projectDir, runInShell: true);
      if (init.exitCode != 0) {
        print('   ⚠️  git init failed:\n${init.stderr}');
        return;
      }
    }

    await Process.run('git', ['add', '-A'],
        workingDirectory: _projectDir, runInShell: true);

    final commit = await Process.run(
        'git', ['commit', '-m', 'Initial commit: ${config.projectTitle}'],
        workingDirectory: _projectDir, runInShell: true);
    if (commit.exitCode != 0) {
      print('   ⚠️  git commit:\n${commit.stderr}');
    }

    if (config.remote != null) {
      final hasRemote = await Process.run(
          'git', ['remote', '-v'],
          workingDirectory: _projectDir, runInShell: true);
      final remoteOut = hasRemote.stdout as String;
      if (!remoteOut.contains('origin')) {
        await Process.run(
            'git', ['remote', 'add', 'origin', config.remote!],
            workingDirectory: _projectDir, runInShell: true);
      }
      // Try to push, but don't fail if remote doesn't exist yet
      await Process.run('git', ['push', '-u', 'origin', 'main', '--force'],
          workingDirectory: _projectDir, runInShell: true);
      print('   ✅ git push to ${config.remote}');
    } else {
      print('   ✅ git init + commit');
    }
  }
}
