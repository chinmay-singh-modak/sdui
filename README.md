# flutter_sdui_kit

[![pub package](https://img.shields.io/pub/v/flutter_sdui_kit.svg)](https://pub.dev/packages/flutter_sdui_kit)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A **server-driven UI** framework for Flutter. Your server sends JSON → the SDK renders native widgets. Ship UI changes instantly — no app-store release.

---

## Quick Start

### 1. Install

```yaml
# pubspec.yaml
dependencies:
  flutter_sdui_kit: ^0.1.1
```

### 2. Render a screen (3 lines)

```dart
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

// That's it. Pass the JSON string from your API.
SduiWidget(json: serverResponseJson)
```

### 3. Handle actions + pass data

```dart
// Create an action handler.
final navKey = GlobalKey<NavigatorState>();
final actions = ActionHandler(navigatorKey: navKey);
actions.register('navigate', (context, action, payload) {
  actions.navigatorOf(context).pushNamed(payload['route'] as String);
});

// Render with data for templates and visibility conditions.
SduiWidget(
  json: serverJson,
  actionHandler: actions,
  data: {
    'user': {'name': 'Alice', 'is_premium': true},
    'cart': {'count': 3},
  },
)
```

That's the complete setup. Everything below is reference.

---

## How It Works

```
Server JSON  →  SduiWidget  →  Flutter Widgets
```

1. Server sends a JSON response with a `body` node tree
2. `SduiWidget` parses it, resolves `{{templates}}`, evaluates `visible_if` conditions
3. Each node's `type` maps to a builder function that returns a Flutter widget
4. User interactions fire actions back to your registered handlers

---

## JSON Protocol

> **Framework-agnostic.** The same JSON works with any client SDK (Flutter, SwiftUI, Compose, React Native) that implements the protocol.

### Screen Envelope

```json
{
  "screen": "home",
  "version": 1,
  "cache_ttl": 300,
  "theme": { "primary": "#6C63FF", "background": "#FFFFFF", "text": "#1A1A2E" },
  "body": { ... }
}
```

### Node Structure

Every UI element is a **node**:

```json
{
  "type": "text",
  "props": { "content": "Hello, {{user.name}}!", "visible_if": "user.is_premium" },
  "action": { "type": "navigate", "payload": { "route": "/profile" } },
  "children": []
}
```

| Field | Type | Description |
|---|---|---|
| `type` | `string` | Component type (e.g. `text`, `column`, `button`) |
| `props` | `object` | Properties for the component |
| `action` | `object?` | Action fired on user interaction |
| `children` | `node[]` | Child nodes |

---

## Built-in Components (23 types)

### Layout

| Type | Key Props |
|---|---|
| `column` | `spacing`, `cross_alignment`, `main_alignment`, `scroll` |
| `row` | `spacing`, `cross_alignment`, `main_alignment`, `scroll` |
| `padding` | `all`, `horizontal`, `vertical`, `left`, `right`, `top`, `bottom` |
| `sizedbox` | `width`, `height` |
| `container` | `background`, `corner_radius`, `width`, `height`, `padding` |
| `scroll` | `direction` (`horizontal` / `vertical`) |
| `safe_area` | `top`, `bottom`, `left`, `right` |
| `expanded` | `flex`, `fit` (`tight` / `loose`) |
| `center` | — |
| `aspect_ratio` | `ratio` |
| `constrained_box` | `min_width`, `max_width`, `min_height`, `max_height` |

### Content

| Type | Key Props |
|---|---|
| `text` | `content`, `style` (`heading`/`subheading`/`body`/`caption`), `color`, `max_lines`, `text_align` |
| `image` | `url`, `aspect_ratio`, `corner_radius`, `fit` |
| `button` | `label`, `variant` (`primary`/`outline`/`text`), `full_width`, `background`, `text_color`, `corner_radius` |
| `icon` | `name`, `size`, `color` |
| `card` | `corner_radius`, `background`, `elevation`, `width` |
| `list` | `direction`, `spacing`, `padding`, `height`, `width` |
| `divider` | `color`, `thickness` |

### Form

| Type | Key Props | Auto-fires |
|---|---|---|
| `text_input` | `placeholder`, `value`, `field`, `max_lines`, `obscure` | `input_changed` |
| `checkbox` | `checked`, `label`, `field`, `size`, `active_color` | `input_changed` |
| `switch` | `value`, `label`, `field`, `active_color` | `input_changed` |
| `dropdown` | `options [{label,value}]`, `selected`, `placeholder`, `field` | `input_changed` |

### Interaction

| Type | Key Props |
|---|---|
| `gesture` | `behavior` (`opaque`/`translucent`/`defer`); requires `action` on node |

**Flex children:** Any child node can have `"flex": <int>` in its props to be wrapped in `Expanded` inside a `column`/`row`. Add `"flex_fit": "loose"` for `Flexible` instead.

---

## Data Binding

Use `{{path}}` in any string prop. Pass a `data` map to resolve:

```dart
SduiWidget(
  json: serverJson,
  data: {'user': {'name': 'John'}, 'cart': {'count': 3}},
)
```

```json
{ "type": "text", "props": { "content": "Hello {{user.name}}! {{cart.count}} items." } }
```

→ **Hello John! 3 items.**

---

## Conditional Visibility

Add `visible_if` to any node's `props`:

```json
{ "type": "text", "props": { "content": "VIP only", "visible_if": "user.is_premium" } }
```

Supported: `truthy`, `!negation`, `==`, `!=`, `>`, `<`, `>=`, `<=`, `&&`, `||`

```json
"visible_if": "user.role == admin && cart.count > 0"
```

---

## Action Handling

```dart
final navKey = GlobalKey<NavigatorState>();
final actions = ActionHandler(navigatorKey: navKey);

actions.register('navigate', (context, action, payload) {
  // navigatorOf() tries Navigator.of(context) first, then falls back
  // to the navigatorKey — works even inside MaterialApp(builder:).
  actions.navigatorOf(context).pushNamed(payload['route'] as String);
});

actions.register('api_call', (context, action, payload) async {
  await http.post(Uri.parse(payload['endpoint'] as String));
});

actions.onUnhandled = (context, action, payload) {
  debugPrint('Unknown action: ${action.type}');
};
```

Form components auto-fire `input_changed` with `{"field": "...", "value": ...}`.

---

## Error Handling

```dart
SduiWidget(
  json: serverJson,

  // Called for every error (parse, render, expression).
  // Send to Crashlytics / Sentry / your logger.
  onError: (error) => logger.warning('${error.type}: ${error.message}'),

  // Replaces individual broken nodes (siblings keep rendering).
  errorWidgetBuilder: (error) => Text('Error in ${error.nodeType}'),

  // Shown when JSON is null, empty, or fails to parse entirely.
  fallback: CircularProgressIndicator(),
)
```

Errors never crash the tree. A broken node becomes `SizedBox.shrink()` (or your `errorWidgetBuilder`), and its siblings render normally.

---

## Custom Components

```dart
final registry = createDefaultRegistry();

registry.register('rating_stars', (node, context) {
  final filled = node.props['filled'] as int? ?? 0;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) => Text(i < filled ? '★' : '☆')),
  );
});

SduiWidget(json: serverJson, registry: registry)
```

Server sends: `{ "type": "rating_stars", "props": { "filled": 4 } }`

---

## State Management

`SduiWidget` is a plain `StatelessWidget`. It has **zero opinions** about state management. It takes `json` and `data` as inputs — whenever those change, the UI updates. This works with everything:

### setState (simplest)

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  String? _json;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _fetchScreen();
  }

  Future<void> _fetchScreen() async {
    final response = await http.get(Uri.parse('https://api.example.com/screen/home'));
    setState(() => _json = response.body);
  }

  @override
  Widget build(BuildContext context) {
    final actions = ActionHandler();
    actions.register('navigate', (ctx, a, p) {
      Navigator.pushNamed(ctx, p['route'] as String);
    });
    actions.register('input_changed', (ctx, a, p) {
      setState(() => _data = {..._data, p['field']: p['value']});
    });

    return SduiWidget(
      json: _json,
      actionHandler: actions,
      data: _data,
      fallback: Center(child: Text('Loading...')),
    );
  }
}
```

### Riverpod

```dart
final screenProvider = FutureProvider<String>((ref) async {
  final response = await http.get(Uri.parse('https://api.example.com/screen/home'));
  return response.body;
});

final formDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenAsync = ref.watch(screenProvider);
    final formData = ref.watch(formDataProvider);

    final actions = ActionHandler();
    actions.register('navigate', (ctx, a, p) {
      Navigator.pushNamed(ctx, p['route'] as String);
    });
    actions.register('input_changed', (ctx, a, p) {
      ref.read(formDataProvider.notifier).state = {
        ...ref.read(formDataProvider),
        p['field']: p['value'],
      };
    });

    return screenAsync.when(
      data: (json) => SduiWidget(json: json, actionHandler: actions, data: formData),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
```

### Bloc / Cubit

```dart
class ScreenCubit extends Cubit<ScreenState> {
  ScreenCubit() : super(ScreenLoading());

  Future<void> load() async {
    final response = await http.get(Uri.parse('https://api.example.com/screen/home'));
    emit(ScreenLoaded(json: response.body));
  }
}

// In widget:
BlocBuilder<ScreenCubit, ScreenState>(
  builder: (context, state) {
    if (state is ScreenLoaded) {
      return SduiWidget(json: state.json, actionHandler: actions);
    }
    return CircularProgressIndicator();
  },
)
```

### GetX / Provider / MobX / etc.

Same pattern — feed `json` and `data` from your store. `SduiWidget` rebuilds when its inputs change. No wrappers, no adapters, no lock-in.

### Sharing data across nested SduiWidgets

```dart
SduiDataProvider(
  data: {'user': {'name': 'Alice'}},
  child: SduiWidget(json: screenJson),
)
```

Local `data` on `SduiWidget` overrides ancestor `SduiDataProvider` data for the same keys.

---

## Layout Safety

The SDK handles common infinite-layout pitfalls automatically:

| Pattern | How it's handled |
|---|---|
| Column in Column | `mainAxisSize: MainAxisSize.min` — no unbounded assertion |
| Column in ScrollView | Same — Column sizes to content |
| List in Column | `shrinkWrap: true` + `NeverScrollableScrollPhysics` |
| Horizontal list in Column | Server sends `height` prop, SDK wraps in `SizedBox` |
| Expanded outside Flex | Renderer error boundary catches and replaces with fallback |
| Bad builder throws | Error boundary catches per-node, siblings keep rendering |

---

## Architecture

```
Server JSON  →  SduiScreen (model)  →  SduiRenderer  →  Flutter Widgets
                     ↓                       ↓
                SduiNode tree         ComponentRegistry
                                      TemplateResolver
                                      ExpressionEvaluator
                                      ActionHandler
```

| Concept | What it does |
|---|---|
| **SduiNode** | Recursive tree: `type`, `props`, `children`, `action` |
| **ComponentRegistry** | Maps type string → builder function |
| **ActionHandler** | Maps action type → callback |
| **TemplateResolver** | `{{path}}` → value from data map |
| **ExpressionEvaluator** | `visible_if` → boolean |
| **SduiRenderer** | Walks tree, resolves templates/conditions, calls builders, catches errors |

---

## Implementing for Other Platforms

The JSON protocol is platform-agnostic. To build an SDK for SwiftUI / Compose / React Native:

1. Parse the screen envelope into native models
2. Build a component registry (type → native view builder)
3. Build an action handler (action type → callback)
4. Implement template resolution (regex `{{path}}`)
5. Implement expression evaluation (`visible_if`)
6. Walk the node tree: resolve → check visibility → build

Same JSON, any platform.

---

## API Reference

### SduiWidget

| Property | Type | Default | Description |
|---|---|---|---|
| `json` | `String?` | **required** | JSON string from server |
| `registry` | `ComponentRegistry?` | built-in (23 types) | Component builders |
| `actionHandler` | `ActionHandler?` | no-op | Action dispatcher |
| `data` | `Map<String, dynamic>` | `{}` | Data for templates + conditions |
| `fallback` | `Widget` | `SizedBox.shrink()` | Shown when JSON is null/empty/invalid |
| `onError` | `SduiErrorCallback?` | — | Called for every error |
| `errorWidgetBuilder` | `SduiErrorWidgetBuilder?` | — | Replacement widget for broken nodes |

### ComponentRegistry

| Method | Description |
|---|---|
| `register(type, builder)` | Add a builder |
| `registerAll(map)` | Add multiple builders |
| `unregister(type)` | Remove a builder |
| `setFallback(builder)` | Override fallback for unknown types |
| `has(type)` / `resolve(type)` | Check / get builder |

### ActionHandler

| Method | Description |
|---|---|
| `register(type, handler)` | Add a handler |
| `registerAll(map)` | Add multiple handlers |
| `handle(context, action)` | Dispatch an action |
| `navigatorOf(context)` | Safe navigator lookup (context → navigatorKey fallback) |
| `navigatorKey` | Optional `GlobalKey<NavigatorState>` for fallback navigation |
| `onUnhandled` | Catch-all for unknown types |

### SduiError

| Property | Type |
|---|---|
| `type` | `SduiErrorType` (parse, render, unknownComponent, expression) |
| `message` | `String` |
| `nodeType` | `String?` |
| `exception` | `Object?` |
| `stackTrace` | `StackTrace?` |

---

## License

MIT — see [LICENSE](LICENSE).