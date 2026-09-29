# Music Tools

A Flutter toolbox for musicians, starting with a **chromatic tuner** and a
**metronome**, built to grow with more tools over time — no backend, 100%
on-device.


## Features

| Tool | Status |
|---|---|
| 🎼 Metronome — configurable BPM, beat pattern, accented first beat | Available |
| 🎸 Tuner — microphone pitch detection, note + cents offset | Available |
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
- [record](https://pub.dev/packages/record) for microphone audio capture (tuner)
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

Both the **Metronome** and **Tuner** features are implemented end-to-end
(domain → data → presentation, with unit and widget tests). See
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for what goes where, and each
feature's own `README.md` (e.g.
[lib/features/tuner/README.md](lib/features/tuner/README.md)) for its
scope and known limitations.

## Roadmap

- [x] MVVM project skeleton, dependencies, documentation
- [x] Metronome feature (domain → data → presentation, unit + widget tests)
- [x] Tuner feature (domain → data → presentation, unit + widget tests)
- [ ] CI (GitHub Actions: `flutter analyze` + `flutter test`)
- [ ] A third tool, to prove out the extensibility mechanism with more than two entries

## License

Not yet decided.
