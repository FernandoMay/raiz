import 'dart:io';
import 'package:args/args.dart';
import 'package:raiz/src/config.dart';
import 'package:raiz/src/generator.dart';
import 'package:raiz/src/cli.dart' as cli;

const String version = '1.0.0';

void main(List<String> args) {
  final parser = ArgParser()
    ..addCommand('create')
    ..addOption('seed-color',
        abbr: 'c',
        defaultsTo: '0xFF1976D2',
        help: 'ColorScheme.fromSeed hex color (e.g. 0xFF2E7D32)')
    ..addOption('title',
        abbr: 't', help: 'Project display title (defaults from name)')
    ..addOption('description',
        abbr: 'd', help: 'Project description')
    ..addOption('profile',
        abbr: 'p',
        defaultsTo: 'basic',
        help: 'Template profile: basic, complete, store')
    ..addOption('org',
        abbr: 'o',
        defaultsTo: 'com.raiz',
        help: 'Organization identifier')
    ..addFlag('dark',
        abbr: 'k', defaultsTo: false, help: 'Include dark theme')
    ..addOption('remote',
        abbr: 'r', help: 'Git remote URL to push')
    ..addOption('path',
        abbr: 'w', help: 'Parent directory (defaults to current)')
    ..addFlag('no-git',
        defaultsTo: false, help: 'Skip git init')
    ..addFlag('no-install',
        defaultsTo: false, help: 'Skip flutter pub get')
    ..addFlag('help', abbr: 'h', defaultsTo: false, help: 'Show help');

  final results = parser.parse(args);

  if (results['help'] == true || results.command == null) {
    cli.usage();
    return;
  }

  final cmd = results.command!;
  if (cmd.name != 'create') {
    cli.usage();
    return;
  }

  final rest = cmd.rest;
  if (rest.isEmpty) {
    print('${cli.red('❌ Error:')} project name is required.\n');
    cli.usage();
    return;
  }

  final name = rest.first;

  // Validate profile
  RaizProfile profile;
  try {
    profile = RaizProfile.fromString(cmd['profile'] as String);
  } catch (_) {
    print('${cli.red('❌ Error:')} invalid profile "${cmd['profile']}". '
        'Use: basic, complete, store\n');
    return;
  }

  // Validate seed color
  final seedRaw = cmd['seed-color'] as String;
  final seedColor = seedRaw.startsWith('0x') || seedRaw.startsWith('#')
      ? seedRaw
      : '0xFF$seedRaw';

  // Build description for non-basic profiles
  String? description = cmd['description'] as String?;
  if (description == null && profile != RaizProfile.basic) {
    description = switch (profile) {
      RaizProfile.complete => 'A full-featured Flutter app with routing and state management.',
      RaizProfile.store => 'An e-commerce Flutter app with cart and checkout.',
      _ => null,
    };
  }

  final config = ProjectConfig(
    name: name,
    title: cmd['title'] as String?,
    description: description,
    seedColor: seedColor,
    org: cmd['org'] as String,
    darkTheme: cmd['dark'] as bool,
    remote: cmd['remote'] as String?,
    path: cmd['path'] as String?,
    profile: profile,
    skipGit: cmd['no-git'] as bool,
    skipInstall: cmd['no-install'] as bool,
  );

  final generator = RaizGenerator(config);
  generator.generate().catchError((e) {
    print('\n${cli.red('❌ Raíz failed:')} $e');
    exit(1);
  });
}
