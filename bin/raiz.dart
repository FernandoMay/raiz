import 'dart:io';
import 'package:args/args.dart';
import 'package:raiz/raiz.dart';

const String version = '1.0.0';

void main(List<String> args) {
  final parser = ArgParser()
    ..addCommand('create')
    ..addCommand('version')
    ..addOption('seed-color',
        abbr: 'c',
        defaultsTo: '0xFF1976D2',
        help: 'ColorScheme.fromSeed hex color (e.g. 0xFF2E7D32)')
    ..addOption('title',
        abbr: 't',
        help: 'Project display title (defaults from project name)')
    ..addOption('description',
        abbr: 'd',
        defaultsTo: 'A Flutter project generated with Raíz.',
        help: 'Project description')
    ..addOption('org',
        abbr: 'o',
        defaultsTo: 'com.raiz',
        help: 'Organization identifier for flutter create')
    ..addFlag('dark',
        abbr: 'k',
        defaultsTo: false,
        help: 'Include dark theme support')
    ..addOption('remote',
        abbr: 'r', help: 'Git remote URL to push after generation')
    ..addOption('path',
        abbr: 'p',
        help: 'Parent directory for the new project (defaults to current dir)')
    ..addFlag('help', abbr: 'h', defaultsTo: false, help: 'Show usage');

  final results = parser.parse(args);

  if (results.command?.name == 'version' || results['version'] == true) {
    print(version);
    return;
  }

  if (results['help'] == true || args.isEmpty || results.command == null) {
    _printUsage(parser);
    return;
  }

  final command = results.command!;
  if (command.name != 'create') {
    _printUsage(parser);
    return;
  }

  final rest = command.rest;
  if (rest.isEmpty) {
    print('❌ Error: project name is required.\n');
    _printUsage(parser);
    return;
  }

  final name = rest.first;
  final config = ProjectConfig(
    name: name,
    title: command['title'] as String?,
    description: command['description'] as String?,
    seedColor: command['seed-color'] as String,
    org: command['org'] as String,
    darkTheme: command['dark'] as bool,
    remote: command['remote'] as String?,
    path: command['path'] as String?,
  );

  final generator = RaizGenerator(config);
  generator.generate().catchError((e) {
    print('\n❌ Error: $e');
    exit(1);
  });
}

void _printUsage(ArgParser parser) {
  print('''
\x1b[36m  ╔══════════════════════════════════════╗
  ║           RAÍZ v$version              ║
  ║   Project Genesis Engine               ║
  ╚══════════════════════════════════════╝\x1b[0m

Generate production-ready Flutter projects with one command.

\x1b[33mUsage:\x1b[0m
  dart run raiz create <project_name> [options]

\x1b[33mOptions:\x1b[0m
${parser.usage}

\x1b[33mExamples:\x1b[0m
  dart run raiz create my_app
  dart run raiz create my_app -c 0xFF2E7D32 -t "My App" -d "My description"
  dart run raiz create my_app -k -r https://github.com/user/my_app.git
  dart run raiz create my_app -p ../projects -o com.company

\x1b[33mWhat you get:\x1b[0m
  ✅ Flutter project with Material 3 + ColorScheme.fromSeed
  ✅ CI/CD (GitHub Actions — analyze + test + build)
  ✅ Model tests scaffold
  ✅ Branded README
  ✅ Git init + commit (+ optional push to remote)
  ✅ flutter analyze → 0 issues

\x1b[2mNext Stop China · We Empower · Raíz\x1b[0m
''');
}
