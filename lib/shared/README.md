# shared/

Presentation-layer building blocks reused by more than one feature (e.g. a
gauge widget used by both the tuner and a future outil, a themed button).

Anything placed here must stay UI-only: no business logic, no direct
dependency on a single feature's domain layer. A widget used by exactly one
feature belongs in that feature's own `presentation/view/` folder instead —
see [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md).
