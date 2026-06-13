/// Template profile for generated projects.
enum RaizProfile {
  /// Simple app with Material 3, CI/CD, tests
  basic('basic', 'Simple Material 3 app with CI/CD'),

  /// Full app with routing, state management, theme
  complete('complete',
      'Full app with go_router + Provider + theme file'),

  /// E-commerce scaffold with cart, products, checkout
  store('store', 'E-commerce app with cart + products + checkout');

  final String id;
  final String description;
  const RaizProfile(this.id, this.description);

  static RaizProfile fromString(String s) {
    return switch (s.toLowerCase()) {
      'complete' => complete,
      'store' => store,
      _ => basic,
    };
  }
}

/// Configuration for a single project generation.
class ProjectConfig {
  final String name;
  final String? title;
  final String? description;
  final String seedColor;
  final String org;
  final bool darkTheme;
  final String? remote;
  final String? path;
  final RaizProfile profile;
  final bool skipGit;
  final bool skipInstall;

  ProjectConfig({
    required this.name,
    this.title,
    this.description,
    this.seedColor = '0xFF1976D2',
    this.org = 'com.raiz',
    this.darkTheme = false,
    this.remote,
    this.path,
    this.profile = RaizProfile.basic,
    this.skipGit = false,
    this.skipInstall = false,
  });

  /// Human-readable project title.
  String get projectTitle =>
      title ??
      name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  /// Dart Color literal for the seed color.
  /// Strips 0x, 0xFF, # prefixes and adds 0xFF.
  String get seedColorLiteral {
    var raw = seedColor
        .replaceAll(RegExp(r'^0x', caseSensitive: false), '')
        .replaceAll('#', '');
    if (raw.length > 6) raw = raw.substring(raw.length - 6);
    return 'Color(0xFF$raw)';
  }
}
