# Music Tools

A Flutter toolbox for musicians, starting with a **chromatic tuner** and a
**metronome**, built to grow with more tools over time — no backend, 100%
on-device.

This project doubles as a portfolio piece: the priority is a codebase that
is clean, documented, and easy to extend, not feature count.

## Features

| Tool | Status |
|---|---|
| 🎼 Metronome — configurable BPM, beat pattern, accented first beat | Planned |
| 🎸 Tuner — microphone pitch detection, note + cents offset | Planned |
| ➕ More tools | Roadmap |

## Architecture

MVVM, organized feature-first, with [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
implementing the View↔ViewModel binding. Full rationale and diagrams in
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md); architecture decisions are
recorded in [docs/adr/](docs/adr/).

```
lib/
├── app/                # MaterialApp, theme, root widget
├── core/                # constants, errors, utils — shared, feature-agnostic
├── shared/              # widgets shared across features
└── features/
    ├── home/            # entry screen / tool registry
    ├── tuner/            # domain/, data/, presentation/{view,viewmodel}
    └── metronome/        # domain/, data/, presentation/{view,viewmodel}
```

## Tech stack

- [Flutter](https://flutter.dev) / Dart
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) for state management (ViewModel layer)
- `flutter_test` for unit and widget tests

## Getting started

### Prerequisites

- Flutter SDK (see [pubspec.yaml](pubspec.yaml) for the exact Dart SDK
  constraint)
- A connected device, simulator/emulator, or a desktop/web target enabled

### Install & run

```bash
flutter pub get
flutter run
```

### Quality checks

```bash
flutter analyze   # static analysis — public_member_api_docs is enforced,
                   # so every public API must carry a doc comment
flutter test       # unit + widget tests
```

## Project status

Currently at the **walking skeleton** stage: the MVVM folder structure,
dependencies, and app shell are in place and run, but the Tuner and
Metronome features themselves are not implemented yet. See
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for what goes where, and each
feature's own `README.md` (e.g. [lib/features/metronome/README.md](lib/features/metronome/README.md))
for its planned scope.

## Roadmap

- [x] MVVM project skeleton, dependencies, documentation
- [ ] Metronome feature (domain → data → presentation)
- [ ] Tuner feature (domain → data → presentation)
- [ ] Unit tests for both ViewModels
- [ ] CI (GitHub Actions: `flutter analyze` + `flutter test`)

## License

Not yet decided.
