<h1 align="center">🌱 Raíz — Project Genesis Engine</h1>

<p align="center">
  <em>Generate production-ready Flutter projects in one command.<br>
  Material 3 · CI/CD · Tests · Brand Identity</em>
</p>

<p align="center">
  <a href="#features">Features</a> ·
  <a href="#quick-start">Quick Start</a> ·
  <a href="#usage">Usage</a> ·
  <a href="#examples">Examples</a> ·
  <a href="#the-vision">The Vision</a>
</p>

---

## Features

- **One-command generation** — `dart run raiz create my_app` creates a Flutter project with everything
- **Material 3 + ColorScheme.fromSeed** — Every project gets modern design with your chosen brand color
- **CI/CD built-in** — GitHub Actions workflow (analyze + test + build APK)
- **Model tests scaffold** — Unit tests ready to extend
- **Branded README** — Professional documentation generated automatically
- **Dark theme support** — Optional `--dark` flag for theme mode system
- **Git init + remote push** — Automatically initializes git, commits, and optionally pushes to your remote

## Quick Start

```bash
# Generate a new project
dart run raiz create my_app

# Or from any directory:
dart run /path/to/raiz create my_app -c 0xFF2E7D32 -t "My App"
```

## Usage

```bash
dart run raiz create <project_name> [options]

Options:
  -c, --seed-color     ColorScheme.fromSeed hex (default: 0xFF1976D2)
  -t, --title          Project display title
  -d, --description    Project description
  -o, --org            Org identifier (default: com.raiz)
  -k, --dark           Include dark theme
  -r, --remote         Git remote URL to push after generation
  -p, --path           Parent directory (defaults to current dir)
  -h, --help           Show usage
```

## Examples

```bash
# Minimal
dart run raiz create my_app

# Full spec: agriculture app with dark theme, remote, description
dart run raiz create timi_farmer \
  -c 0xFF2E7D32 \
  -t "TIMI" \
  -d "Smart agriculture assistant for Mexican farmers" \
  -k \
  -r https://github.com/user/timi_farmer.git

# E-commerce app
dart run raiz create hypesneakers \
  -c 0xFF7C4DFF \
  -t "HypeSneakers" \
  -d "Exclusive sneaker marketplace"

# Food delivery app
dart run raiz create wholesome_foods \
  -c 0xFFFF6347 \
  -t "WholesomeFoods" \
  -d "Fast food ordering app" \
  -k
```

## What You Get

For every project, Raíz generates:

```
my_app/
├── .github/workflows/
│   └── flutter.yml          # CI/CD pipeline
├── lib/
│   └── main.dart            # Material 3 + ColorScheme.fromSeed
├── test/
│   └── models_test.dart     # Unit tests
├── pubspec.yaml             # SDK ^3.6.0 + flutter_lints
├── README.md                # Branded documentation
└── ...                      # Standard Flutter scaffold
```

## The Vision

Raíz was born from building **54 production-ready Flutter projects** from scratch — each requiring the same foundation: Material 3 branding, CI/CD, tests, documentation. 

This tool encodes every lesson learned into a single command. It's the **root** from which new projects grow — consistent, professional, and ready for market.

Built for the **Next Stop China** International Sci-Tech Innovation Competition (Hengqin, Nov 2026) — empowering Hispanic and Lusophone innovators to bring their ideas to life with professional-grade software foundations.

---

<p align="center">
  <sub>Made with ❤️ for We Empower · AIESEC · Next Stop China</sub><br>
  <sub>© 2026 Raíz. All rights reserved.</sub>
</p>
