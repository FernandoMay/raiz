import 'dart:io';

/// ANSI color codes for terminal output.
class Style {
  static String get reset => _ansi('0');
  static String get bold => _ansi('1');
  static String get dim => _ansi('2');
  static String get green => _ansi('32');
  static String get cyan => _ansi('36');
  static String get yellow => _ansi('33');
  static String get red => _ansi('31');
  static String get magenta => _ansi('35');

  static String _ansi(String code) {
    try {
      return stdout.hasTerminal ? '\x1b[$code' 'm' : '';
    } catch (_) {
      return '';
    }
  }

  static String greenText(String s) => '$green$s$reset';
  static String cyanText(String s) => '$cyan$s$reset';
  static String yellowText(String s) => '$yellow$s$reset';
  static String redText(String s) => '$red$s$reset';
  static String dimText(String s) => '$dim$s$reset';
  static String boldText(String s) => '$bold$s$reset';
  static String magentaText(String s) => '$magenta$s$reset';

  static String checkMark = greenText('✅');
  static String crossMark = redText('❌');
  static String bullet = cyanText('•');
}

/// Simple progress display.
void step(String s) {
  print('   ${Style.bullet} $s');
}

void success(String s) {
  print('   ${Style.checkMark} $s');
}

void fail(String s) {
  print('   ${Style.crossMark} $s');
}

// ─── Convenience top-level functions ─────────────────────────────

String red(String s) => Style.redText(s);
String green(String s) => Style.greenText(s);
String cyan(String s) => Style.cyanText(s);
String yellow(String s) => Style.yellowText(s);
String bold(String s) => Style.boldText(s);
String dim(String s) => Style.dimText(s);
String magenta(String s) => Style.magentaText(s);

void banner() {
  print('''
${Style.cyanText('  ╔══════════════════════════════════════╗')}
${Style.cyanText('  ║')}          ${Style.boldText('RAÍZ')} v1.0.0            ${Style.cyanText('║')}
${Style.cyanText('  ║')}   ${Style.dimText('Project Genesis Engine')}     ${Style.cyanText('║')}
${Style.cyanText('  ╚══════════════════════════════════════╝')}
''');
}

void usage() {
  print('''
${Style.boldText('Usage:')}
  dart run raiz create <project_name> [options]

${Style.boldText('Options:')}
  -c, --seed-color     ColorScheme.fromSeed hex (default: 0xFF1976D2)
  -t, --title          Project display title (defaults from name)
  -d, --description    Project description
  -p, --profile        Template profile: ${Style.dimText('basic')}, complete, store (default: basic)
  -o, --org            Org identifier (default: com.raiz)
  -k, --dark           Include dark theme
  -r, --remote         Git remote URL to push
  -w, --path           Parent directory (defaults to current dir)
      --no-git         Skip git init
      --no-install     Skip flutter pub get
  -h, --help           Show this help

${Style.boldText('Profiles:')}
  ${Style.cyanText('basic')}     Simple Material 3 app with CI/CD + tests
  ${Style.cyanText('complete')} Full app with go_router, Provider, theme file
  ${Style.cyanText('store')}    E-commerce scaffold with cart + products + checkout

${Style.boldText('Examples:')}
  dart run raiz create my_app
  dart run raiz create my_app -c 0xFF2E7D32 -t "My App"
  dart run raiz create my_app -p complete -k -r https://github.com/u/r.git
  dart run raiz create my_store -p store -c 0xFFFF6347

${Style.dimText('Next Stop China · We Empower · Raíz')}
''');
}
