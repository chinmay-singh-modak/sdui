# Changelog

## 0.3.0

### Breaking Changes

- **`ActionTypeHandler`** signature changed from `(SduiAction, Map<String, dynamic>)` to `(BuildContext, SduiAction, Map<String, dynamic>)`.
- **`ActionCallback`** signature changed from `(SduiAction)` to `(BuildContext, SduiAction)`.
- **`ActionHandler.handle()`** now requires `BuildContext` as its first argument.
- **`ActionHandler.onUnhandled`** callback now receives `BuildContext` as its first argument.

### Why

Action handlers previously had no access to the widget tree's `BuildContext`. This made it impossible to call `Navigator.of(context)`, show dialogs, or use any API that requires a context. Components now capture `BuildContext` from their `build()` method and forward it through the callback chain.

### Migration Guide

```dart
// Before (0.2.x)
handler.register('navigate', (action, payload) {
  // no context available — navigation hacks needed
});

// After (0.3.0)
handler.register('navigate', (context, action, payload) {
  Navigator.of(context).pushNamed(payload['route'] as String);
});
```

### Improvements

- Button, gesture, and card builders use `Builder` widget to provide live `BuildContext` to action callbacks.
- Form builders (text input, checkbox, switch, dropdown) pass `BuildContext` through `onChanged`/`onSubmitted` callbacks.

## 0.2.1

### Bug Fixes

- **Fixed:** `buttonBuilder` crashed with `BoxConstraints forces an infinite width` when a `full_width: true` button was placed inside a `Row` or other unconstrained parent. Replaced `Center` + `SizedBox(width: infinity)` with layout-safe `Align` widget.
- Updated example to use `flex: 1` on buttons inside a `Row` for proper space distribution.

## 0.2.0

### New Components

- `expanded` — JSON-side Expanded/Flexible wrapper with `flex` and `fit` props
- `center` — Center wrapper
- `safe_area` — SafeArea wrapper with per-edge control
- `aspect_ratio` — AspectRatio wrapper
- `constrained_box` — ConstrainedBox with min/max width/height

### Layout Safety

- Column/Row now use `mainAxisSize: MainAxisSize.min` — no more unbounded axis crashes
- Column/Row support `scroll` prop to auto-wrap in SingleChildScrollView
- Per-child `flex` / `flex_fit` props on any child in a Column/Row (replaces blind Expanded wrapping)
- List builder uses `ListView.builder` with `shrinkWrap: true` + `NeverScrollableScrollPhysics`
- Horizontal lists accept `height`/`width` props for cross-axis sizing
- `LayoutErrorBoundary`, `SduiConstraints`, `ConstraintGuard` layout helpers

### Error Handling

- `SduiError` — structured error with type, message, nodeType, exception, stackTrace
- `SduiErrorType` enum — parse, render, unknownComponent, expression
- `onError` callback on SduiWidget — receives every error during rendering
- `errorWidgetBuilder` on SduiWidget — replaces broken nodes with custom widgets
- `fallback` widget (renamed from `errorWidget`) — shown when JSON is null/empty/invalid
- Renderer error boundary: broken nodes become `SizedBox.shrink()`, siblings keep rendering
- Expression evaluator wrapped in try-catch — bad `visible_if` hides node instead of crashing

### API Changes

- **Breaking:** `SduiWidget` no longer accepts `screen:` parameter — use `json:` only
- **Breaking:** `errorWidget` renamed to `fallback`
- `SduiWidget.json` is now `required` (nullable `String?`)
- Exported `sdui_error.dart` and `layout_helpers.dart` from barrel file

### Documentation

- Complete README rewrite with Quick Start, JSON Protocol, all 23 components, state management examples (setState, Riverpod, Bloc, GetX), layout safety guide, architecture diagram, API reference
- Comprehensive doc comments on all public builders

### Tests

- 158 total tests (45 unit + 79 widget + 34 edge case)
- Widget tests for all 23 component types
- Edge case tests: infinite layouts, empty data, error resilience, state management patterns

## 0.1.1

Initial public release.

### Core

- `SduiNode` — recursive JSON-to-model tree parser
- `SduiScreen` — top-level screen model with theme + metadata
- `SduiAction` — declarative action model (navigate, api_call, etc.)
- `SduiTheme` — server-side colour overrides
- `SduiRenderer` — walks the node tree and builds a Flutter widget tree
- `ComponentRegistry` — extensible map of `type` → builder functions
- `ActionHandler` — dispatcher for user-interaction actions
- `SduiWidget` — drop-in StatelessWidget that renders from JSON or model

### Data Binding

- `TemplateResolver` — `{{user.name}}` placeholder resolution in strings
- `ExpressionEvaluator` — condition engine for `visible_if` expressions
- `SduiDataProvider` — InheritedWidget to flow data context down the tree

### Built-in Components

- **Layout:** `column`, `row`, `padding`, `sizedbox`, `container`, `scroll`
- **Content:** `text`, `image`, `button`, `icon`
- **Composite:** `card`, `list`, `divider`
- **Form:** `text_input`, `checkbox`, `switch`, `dropdown`
- **Interaction:** `gesture`

### Utilities

- `StyleParser` — hex→Color, EdgeInsets, TextStyle, alignment resolvers

## 0.1.0+1

Updated Home page and github repository
