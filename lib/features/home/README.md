# features/home/

Entry screen of the app and **tool registry**: the single place that needs
to change when a new tool is added to Music Tools.

This feature has no `domain/` or `data/` layer of its own — it only
composes and links to the other features' presentation layers, so it is
`presentation/`-only.

| Folder | Purpose |
|---|---|
| `presentation/view/` | `HomeScreen`, listing the available tools. |
| `presentation/viewmodel/` | Exposes the list of registered tools to the view (populated once at least two tools exist, see [docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)). |
