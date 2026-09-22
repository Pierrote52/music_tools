# 1. MVVM architecture with Riverpod as the View↔ViewModel binding

## Status

Accepted — 2026-09-22

## Context

Music Tools is a portfolio project with no backend, starting with two
independent tools (Tuner, Metronome) and an explicit intent to add more
tools later. The goals driving this decision:

- Code must be easy to read and navigate for someone unfamiliar with the
  project (a recruiter skimming the repo).
- Business logic must be unit-testable without a device microphone, audio
  output, or widget tree.
- Adding a new tool later should not require editing existing features.

## Decision

Adopt **MVVM**, organized **feature-first** (see
[ARCHITECTURE.md](../ARCHITECTURE.md)), with
[flutter_riverpod](https://pub.dev/packages/flutter_riverpod) implementing
the View↔ViewModel binding:

- ViewModel = a Riverpod `Notifier`/`AsyncNotifier` exposing an immutable
  state object and command methods.
- Domain interfaces (not concrete implementations) are what a ViewModel
  depends on, so tests can override providers with fakes.

Alternatives considered:

| Option | Reason not chosen |
|---|---|
| `provider` + `ChangeNotifier` | Simpler mental model, but weaker compile-time safety and a less current standard than Riverpod for new Flutter projects. |
| `flutter_bloc` | Excellent separation of concerns, but more boilerplate (events + states) than needed for two initial, fairly simple tools. |
| Hand-rolled `ChangeNotifier` + `InheritedWidget` | No external dependency, but reinvents dependency-injection/override machinery Riverpod already provides for testing. |

## Consequences

- Every feature needs a `ProviderScope` ancestor (set up once, in `main.dart`).
- ViewModels and Views take on a consistent, predictable shape across
  features, which should make the codebase easy to extend by example.
- Testing a ViewModel means constructing a `ProviderContainer` with
  overridden `data/` providers, rather than instantiating the class
  directly — a small amount of Riverpod-specific test setup in exchange for
  not touching real hardware in unit tests.
