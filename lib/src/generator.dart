import 'dart:io';
import 'config.dart';
import 'cli.dart' as cli;

class RaizGenerator {
  final ProjectConfig config;

  RaizGenerator(this.config);

  String get _dir {
    final base = config.path ?? Directory.current.path;
    return '$base\\${config.name}';
  }

  // ─── Public API ────────────────────────────────────────────────

  Future<void> generate() async {
    cli.banner();
    print('  ${cli.dim('Profile:')} ${config.profile.id}  '
        '${cli.dim('·')}  '
        '${cli.dim('Seed:')} ${config.seedColor}  '
        '${cli.dim('·')}  '
        '${cli.dim('Dark:')} ${config.darkTheme ? 'yes' : 'no'}\n');

    await _step('Scaffolding Flutter project', _flutterCreate);
    await _step('pubspec.yaml', _modifyPubspec);
    await _step('lib/main.dart', _writeMain);
    await _step('.github/workflows/flutter.yml', _writeCI);
    await _step('test/models_test.dart', _writeTests);
    await _step('README.md', _writeReadme);

    if (config.profile != RaizProfile.basic) {
      await _step('lib/theme/app_theme.dart', _writeTheme);
      await _step('lib/models/item.dart', _writeModel);
      await _step('lib/providers/app_provider.dart', _writeProvider);
      await _step('lib/router.dart', _writeRouter);
      await _step('lib/screens/home_screen.dart', _writeHomeScreen);
      await _step('lib/screens/second_screen.dart', _writeSecondScreen);
    }

    if (config.profile == RaizProfile.store) {
      await _step('lib/models/product.dart', _writeProduct);
      await _step('lib/providers/cart_provider.dart', _writeCartProvider);
      await _step('lib/screens/product_screen.dart', _writeProductScreen);
      await _step('lib/screens/cart_screen.dart', _writeCartScreen);
    }

    if (!config.skipInstall) {
      await _step('flutter pub get', _pubGet);
    }
    await _step('flutter analyze', _analyze);
    if (!config.skipGit) {
      await _step('git init + commit', _setupGit);
    }

    _printSummary();
  }

  // ─── Step wrapper ──────────────────────────────────────────────

  Future<void> _step(String label, Future<void> Function() fn) async {
    cli.step(label);
    try {
      await fn();
      cli.success(label);
    } catch (e) {
      cli.fail('$label: $e');
      rethrow;
    }
  }

  // ─── flutter create ────────────────────────────────────────────

  Future<void> _flutterCreate() async {
    final target = config.path ?? Directory.current.path;
    final args = ['create', '--org', config.org, config.name];
    if (config.description != null) {
      args.addAll(['--description', config.description!]);
    }
    final r = await Process.run('flutter', args,
        workingDirectory: target, runInShell: true);
    if (r.exitCode != 0) throw Exception(r.stderr);
  }

  // ─── pubspec ───────────────────────────────────────────────────

  Future<void> _modifyPubspec() async {
    final f = File('$_dir\\pubspec.yaml');
    var c = await f.readAsString();
    c = c.replaceFirst(RegExp(r'sdk: .+'), 'sdk: ^3.6.0');

    if (!c.contains('flutter_lints')) {
      c = c.replaceFirst(
          RegExp(r'dev_dependencies:'),
          'dev_dependencies:\n  flutter_lints: ^5.0.0');
    }

    if (config.profile != RaizProfile.basic) {
      if (!c.contains('provider:')) {
        c = c.replaceFirst(
            RegExp(r'dev_dependencies:'),
            'dependencies:\n  provider: ^6.1.2\n  go_router: ^14.8.0\n\ndev_dependencies:');
      }
    }

    await f.writeAsString(c);
  }

  // ─── main.dart ─────────────────────────────────────────────────

  Future<void> _writeMain() async {
    final seed = config.seedColorLiteral;
    final title = config.projectTitle;
    final desc = config.description ?? 'Built with Raíz';
    final dark = config.darkTheme;

    final isBasic = config.profile == RaizProfile.basic;

    final imports = StringBuffer();
    final providers = StringBuffer();
    final homeWidget = StringBuffer();

    if (!isBasic) {
      imports.writeln("import 'package:provider/provider.dart';");
      imports.writeln("import 'router.dart';");
      imports.writeln("import 'providers/app_provider.dart';");

      providers.writeln('runApp(');
      providers.writeln('  MultiProvider(');
      providers.writeln('    providers: [');

      if (config.profile == RaizProfile.store) {
        providers.writeln("import 'providers/cart_provider.dart';");
        providers.writeln("import 'models/product.dart';");
        // This import was already added above, adjust
      }

      homeWidget.writeln('class MyHomePage extends StatelessWidget {');
      homeWidget.writeln('  const MyHomePage({super.key});');
      homeWidget.writeln();
      homeWidget.writeln('  @override');
      homeWidget.writeln('  Widget build(BuildContext context) {');
      homeWidget.writeln('    return const AppRouter();');
      homeWidget.writeln('  }');
      homeWidget.writeln('}');
    } else {
      homeWidget.writeln('class MyHomePage extends StatelessWidget {');
      homeWidget.writeln('  const MyHomePage({super.key});');
      homeWidget.writeln();
      homeWidget.writeln('  @override');
      homeWidget.writeln('  Widget build(BuildContext context) {');
      homeWidget.writeln('    final theme = Theme.of(context);');
      homeWidget.writeln('    return Scaffold(');
      homeWidget.writeln("      appBar: AppBar(");
      homeWidget.writeln("        title: Text('$title'),");
      homeWidget.writeln("        centerTitle: true,");
      homeWidget.writeln('      ),');
      homeWidget.writeln('      body: Center(');
      homeWidget.writeln('        child: Padding(');
      homeWidget.writeln('          padding: const EdgeInsets.all(24.0),');
      homeWidget.writeln('          child: Column(');
      homeWidget.writeln('            mainAxisAlignment: MainAxisAlignment.center,');
      homeWidget.writeln('            children: [');
      homeWidget.writeln('              Icon(Icons.rocket_launch, size: 64,');
      homeWidget.writeln('                  color: theme.colorScheme.primary),');
      homeWidget.writeln('              const SizedBox(height: 16),');
      homeWidget.writeln("              Text('$title',");
      homeWidget.writeln('                  style: theme.textTheme.headlineMedium?.copyWith(');
      homeWidget.writeln('                      fontWeight: FontWeight.bold,');
      homeWidget.writeln('                      color: theme.colorScheme.primary)),');
      homeWidget.writeln('              const SizedBox(height: 8),');
      homeWidget.writeln("              Text('$desc',");
      homeWidget.writeln('                  textAlign: TextAlign.center,');
      homeWidget.writeln('                  style: theme.textTheme.bodyLarge?.copyWith(');
      homeWidget.writeln('                      color: theme.colorScheme.onSurfaceVariant)),');
      homeWidget.writeln('            ],');
      homeWidget.writeln('          ),');
      homeWidget.writeln('        ),');
      homeWidget.writeln('      ),');
      homeWidget.writeln('    );');
      homeWidget.writeln('  }');
      homeWidget.writeln('}');
    }

    final mainContent = '''
${imports.toString()}
import 'package:flutter/material.dart';

void main() {
  ${isBasic ? "runApp(const MyApp());" : '''
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ${config.profile == RaizProfile.store ? "ChangeNotifierProvider(create: (_) => CartProvider())," : ''}
      ],
      child: const MyApp(),
    ),
  );
'''}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$title',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: $seed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      ${dark ? '''
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: $seed,
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

${homeWidget.toString()}
''';

    await File('$_dir\\lib\\main.dart').writeAsString(mainContent);
  }

  // ─── CI/CD ─────────────────────────────────────────────────────

  Future<void> _writeCI() async {
    final dir = Directory('$_dir\\.github\\workflows');
    dir.createSync(recursive: true);
    await File('${dir.path}\\flutter.yml').writeAsString('''
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
  }

  // ─── Tests ─────────────────────────────────────────────────────

  Future<void> _writeTests() async {
    final testDir = '$_dir\\test';
    final old = File('$testDir\\widget_test.dart');
    if (await old.exists()) await old.delete();

    final title = config.projectTitle;
    final seed = config.seedColor;

    await File('$testDir\\models_test.dart').writeAsString('''
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$title', () {
    test('app title is correct', () {
      const title = '$title';
      expect(title, isNotEmpty);
    });

    test('seed color is valid', () {
      const hex = $seed;
      expect(hex, isNonZero);
    });
  });
}
''');
  }

  // ─── README ────────────────────────────────────────────────────

  Future<void> _writeReadme() async {
    final desc = config.description ?? 'A Flutter project generated with Raíz.';
    final profileDesc = switch (config.profile) {
      RaizProfile.basic => 'Basic',
      RaizProfile.complete => 'Complete',
      RaizProfile.store => 'Store (E-commerce)',
    };

    await File('$_dir\\README.md').writeAsString('''
# ${config.projectTitle}

$desc

## Tech Stack

- **Flutter** (SDK ^3.6.0) — Cross-platform UI framework
- **Material 3** — Modern design with `ColorScheme.fromSeed`
- **GitHub Actions** — CI/CD pipeline (analyze + test + build)
${config.profile != RaizProfile.basic ? '- **Provider** — State management\n- **go_router** — Declarative routing\n' : ''}
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
| Profile | $profileDesc |
| Material 3 | ✅ |
| Dark Theme | ${config.darkTheme ? '✅' : '❌'} |

---

*Generated with [Raíz](https://github.com/FernandoMay/raiz) — Project Genesis Engine*
''');
  }

  // ─── Non-basic: theme ──────────────────────────────────────────

  Future<void> _writeTheme() async {
    final seed = config.seedColorLiteral;
    Directory('$_dir\\lib\\theme').createSync(recursive: true);
    await File('$_dir\\lib\\theme\\app_theme.dart').writeAsString('''
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: $seed,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: $seed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
''');
  }

  // ─── Non-basic: model ──────────────────────────────────────────

  Future<void> _writeModel() async {
    Directory('$_dir\\lib\\models').createSync(recursive: true);
    await File('$_dir\\lib\\models\\item.dart').writeAsString('''
class Item {
  final String id;
  final String name;
  final String description;
  final double price;

  const Item({
    required this.id,
    required this.name,
    this.description = '',
    this.price = 0.0,
  });

  Item copyWith({String? id, String? name, String? description, double? price}) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );
}
''');
  }

  // ─── Non-basic: provider ──────────────────────────────────────

  Future<void> _writeProvider() async {
    Directory('$_dir\\lib\\providers').createSync(recursive: true);
    await File('$_dir\\lib\\providers\\app_provider.dart').writeAsString('''
import 'package:flutter/foundation.dart';

class AppProvider extends ChangeNotifier {
  int _counter = 0;
  bool _isLoading = false;

  int get counter => _counter;
  bool get isLoading => _isLoading;

  void increment() {
    _counter++;
    notifyListeners();
  }

  void setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
''');
  }

  // ─── Non-basic: router ────────────────────────────────────────

  Future<void> _writeRouter() async {
    await File('$_dir\\lib\\router.dart').writeAsString('''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '${config.projectTitle}',
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/second',
            builder: (_, __) => const SecondScreen(),
          ),
        ],
      ),
    );
  }
}
''');
  }

  // ─── Non-basic: screens ───────────────────────────────────────

  Future<void> _writeHomeScreen() async {
    Directory('$_dir\\lib\\screens').createSync(recursive: true);
    final title = config.projectTitle;
    await File('$_dir\\lib\\screens\\home_screen.dart').writeAsString('''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'second_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('$title'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch, size: 64,
                  color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('$title',
                  style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary)),
              const SizedBox(height: 24),
              Consumer<AppProvider>(
                builder: (context, prov, _) => Text(
                  'Count: \${prov.counter}',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.read<AppProvider>().increment(),
                icon: const Icon(Icons.add),
                label: const Text('Increment'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SecondScreen())),
                child: const Text('Go to Second Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''');
  }

  Future<void> _writeSecondScreen() async {
    await File('$_dir\\lib\\screens\\second_screen.dart').writeAsString('''
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore, size: 64,
                  color: theme.colorScheme.secondary),
              const SizedBox(height: 16),
              Text('Second Screen',
                  style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''');
  }

  // ─── Store: product model ─────────────────────────────────────

  Future<void> _writeProduct() async {
    await File('$_dir\\lib\\models\\product.dart').writeAsString('''
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  const Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.imageUrl = '',
    this.category = '',
  });

  Product copyWith({
    String? id, String? name, String? description, double? price,
    String? imageUrl, String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}
''');
  }

  // ─── Store: cart provider ─────────────────────────────────────

  Future<void> _writeCartProvider() async {
    await File('$_dir\\lib\\providers\\cart_provider.dart').writeAsString('''
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => Map.unmodifiable(_items);
  int get itemCount => _items.values.fold(0, (s, i) => s + i.quantity);
  double get subtotal => _items.values.fold(0.0, (s, i) => s + i.total);

  void addProduct(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id] = _items[product.id]!.copyWith(
        quantity: _items[product.id]!.quantity + quantity,
      );
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
''');
  }

  // ─── Store: product screen ────────────────────────────────────

  Future<void> _writeProductScreen() async {
    await File('$_dir\\lib\\screens\\product_screen.dart').writeAsString('''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductScreen extends StatelessWidget {
  final Product product;
  const ProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.inventory_2, size: 80,
                    color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 24),
            Text(product.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('\$\${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary)),
            const SizedBox(height: 16),
            Text(product.description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<CartProvider>().addProduct(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('\${product.name} added to cart')),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
''');
  }

  // ─── Store: cart screen ───────────────────────────────────────

  Future<void> _writeCartScreen() async {
    await File('$_dir\\lib\\screens\\cart_screen.dart').writeAsString('''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64,
                      color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: theme.textTheme.titleLarge),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: cart.items.values.map((item) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text('\${item.quantity}',
                              style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer)),
                        ),
                        title: Text(item.product.name),
                        subtitle: Text('\$\${item.total.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => cart.removeProduct(item.product.id),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:',
                              style: theme.textTheme.titleMedium),
                          Text('\$\${cart.subtotal.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
''');
  }

  // ─── Pub get ───────────────────────────────────────────────────

  Future<void> _pubGet() async {
    final r = await Process.run('flutter', ['pub', 'get'],
        workingDirectory: _dir, runInShell: true);
    if (r.exitCode != 0) throw Exception(r.stderr);
  }

  // ─── Analyze ───────────────────────────────────────────────────

  Future<void> _analyze() async {
    final r = await Process.run('flutter', ['analyze'],
        workingDirectory: _dir, runInShell: true);
    final out = r.stdout as String;
    if (r.exitCode != 0 && !out.contains('No issues found')) {
      cli.fail('flutter analyze:\n$out');
    }
  }

  // ─── Git ───────────────────────────────────────────────────────

  Future<void> _setupGit() async {
    if (!await Directory('$_dir\\.git').exists()) {
      final r = await Process.run('git', ['init'],
          workingDirectory: _dir, runInShell: true);
      if (r.exitCode != 0) throw Exception(r.stderr);
    }

    await Process.run('git', ['add', '-A'],
        workingDirectory: _dir, runInShell: true);
    await Process.run(
        'git', ['commit', '-m', 'Initial commit: ${config.projectTitle}'],
        workingDirectory: _dir, runInShell: true);

    if (config.remote != null) {
      final r = await Process.run('git', ['remote', '-v'],
          workingDirectory: _dir, runInShell: true);
      if (!(r.stdout as String).contains('origin')) {
        await Process.run('git', ['remote', 'add', 'origin', config.remote!],
            workingDirectory: _dir, runInShell: true);
      }
      await Process.run('git', ['push', '-u', 'origin', 'main', '--force'],
          workingDirectory: _dir, runInShell: true);
    }
  }

  // ─── Summary ───────────────────────────────────────────────────

  void _printSummary() {
    print('');
    print('  ${cli.green('╔══════════════════════════════════════╗')}');
    print('  ${cli.green('║')}  ✅ ${config.projectTitle} generated!  ${cli.green('║')}');
    print('  ${cli.green('╚══════════════════════════════════════╝')}');
    print('');
    print('  ${cli.bold('📁')}  $_dir');
    print('  ${cli.bold('🏷️')}   ${config.projectTitle}');
    print('  ${cli.bold('🎨')}  ${config.seedColor}');
    print('  ${cli.bold('📦')}  ${config.profile.id}');
    if (config.remote != null) {
      print('  ${cli.bold('🔗')}  ${config.remote}');
    }
    print('');
    print('  ${cli.dim('cd ${config.name} && flutter run')}');
    print('');
  }
}
