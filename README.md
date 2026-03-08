# flutter_sdui_kit

[![pub package](https://img.shields.io/pub/v/flutter_sdui_kit.svg)](https://pub.dev/packages/flutter_sdui_kit)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A **server-driven UI** framework for Flutter. Ship UI changes instantly — no app-store release required.

Your server sends a JSON schema describing *what* to render; the SDK turns it into native Flutter widgets on the client.

---

## Table of Contents

- [Why SDUI?](#why-sdui)
- [SDUI JSON Protocol](#sdui-json-protocol)
  - [Screen Envelope](#screen-envelope)
  - [Node Structure](#node-structure)
  - [Actions](#actions)
  - [Built-in Component Types](#built-in-component-types)
- [Getting Started](#getting-started)
  - [Install](#install)
  - [Basic Usage](#basic-usage)
- [Data Binding & Templates](#data-binding--templates)
- [Conditional Visibility](#conditional-visibility)
- [Action Handling](#action-handling)
- [Custom Components](#custom-components)
- [Architecture](#architecture)
- [Implementing for Other Platforms](#implementing-for-other-platforms)
- [API Reference](#api-reference)

---

## Why SDUI?

| Problem | SDUI Solution |
|---|---|
| A/B tests require new releases | Server sends variant A or B — same binary |
| Layout bug on production | Fix the JSON, users see it instantly |
| Feature flags for UI | `visible_if` expressions, resolved client-side |
| Consistent UI across platforms | One JSON schema, N client SDKs |

---

## SDUI JSON Protocol

> **This protocol is framework-agnostic.** Any client SDK (Flutter, SwiftUI, Jetpack Compose, React Native) can implement it by following the same node/action/props contract described here.

### Screen Envelope

Every response from your SDUI API is a **screen envelope**:

```json
{
  "screen": "home",
  "version": 1,
  "cache_ttl": 300,
  "theme": {
    "primary": "#6C63FF",
    "background": "#FFFFFF",
    "text": "#1A1A2E"
  },
  "body": { … }
}
```

| Field | Type | Description |
|---|---|---|
| `screen` | `string` | Screen identifier (routing, analytics, caching) |
| `version` | `int` | Schema version for client-side migration gates |
| `cache_ttl` | `int` | Seconds this response may be cached locally |
| `theme` | `object?` | Colour overrides — `primary`, `background`, `text` + any extras |
| `body` | `node` | The root component node |

### Node Structure

Every node follows the same shape:

```json
{
  "type": "text",
  "props": {
    "content": "Hello, {{user.name}}!",
    "style": "heading",
    "visible_if": "user.is_premium"
  },
  "action": {
    "type": "navigate",
    "payload": { "route": "/profile" }
  },
  "children": []
}
```

| Field | Type | Description |
|---|---|---|
| `type` | `string` | Component type identifier |
| `props` | `object` | Arbitrary key-value properties for the component |
| `action` | `object?` | Action to fire on user interaction |
| `children` | `node[]` | Ordered child nodes |

### Actions

```json
{
  "type": "navigate",
  "payload": { "route": "/shop" }
}
```

The `type` string is resolved by the client's action handler registry. Common types:

| Action Type | Typical Payload |
|---|---|
| `navigate` | `{ "route": "/path" }` |
| `api_call` | `{ "endpoint": "/api/…", "method": "POST", "body": {…} }` |
| `open_sheet` | `{ "screen": "filter_sheet" }` |
| `input_changed` | `{ "field": "email", "value": "…" }` *(auto-fired by form components)* |

### Built-in Component Types

#### Layout

| Type | Key Props |
|---|---|
| `column` | `spacing`, `cross_alignment`, `main_alignment` |
| `row` | `spacing`, `cross_alignment`, `main_alignment`, `alignment` |
| `padding` | `all`, `horizontal`, `vertical`, `left`, `right`, `top`, `bottom` |
| `sizedbox` | `width`, `height` |
| `container` | `background`, `corner_radius`, `width`, `height`, `padding` |
| `scroll` | `direction` (`"horizontal"` / `"vertical"`) |

#### Content

| Type | Key Props |
|---|---|
| `text` | `content`, `style` (`heading`/`subheading`/`body`/`caption`), `color`, `max_lines`, `text_align` |
| `image` | `url`, `aspect_ratio`, `corner_radius`, `fit` |
| `button` | `label`, `variant` (`primary`/`outline`/`text`), `full_width`, `background`, `text_color`, `corner_radius` |
| `icon` | `name`, `size`, `color` |

#### Composite

| Type | Key Props |
|---|---|
| `card` | `corner_radius`, `background`, `elevation`, `width` |
| `list` | `direction`, `spacing`, `padding` |
| `divider` | `color`, `thickness` |

#### Form

| Type | Key Props |
|---|---|
| `text_input` | `placeholder`, `value`, `field`, `max_lines`, `obscure`, `border_color`, `corner_radius` |
| `checkbox` | `checked`, `label`, `field`, `size`, `active_color` |
| `switch` | `value`, `label`, `field`, `active_color` |
| `dropdown` | `options` (`[{label, value}]`), `selected`, `placeholder`, `field` |

#### Interaction

| Type | Key Props |
|---|---|
| `gesture` | `behavior` (`"opaque"` / `"translucent"` / `"defer"`); requires `action` on the node |

---

## Getting Started

### Install

```yaml
dependencies:
  flutter_sdui_kit: ^0.1.0
```

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

class MyScreen extends StatelessWidget {
  final String serverJson; // JSON from your API

  const MyScreen({super.key, required this.serverJson});

  @override
  Widget build(BuildContext context) {
    return SduiWidget(json: serverJson);
  }
}
```

That's it. The `SduiWidget` parses the JSON, builds the widget tree using the built-in component registry, and renders it.

---

## Data Binding & Templates

Use `{{path.to.value}}` in any string prop. Provide a `data` map to resolve them:

```dart
SduiWidget(
  json: serverJson,
  data: {
    'user': {'name': 'John', 'is_premium': true},
    'cart': {'count': 3},
  },
)
```

Server JSON:

```json
{ "type": "text", "props": { "content": "Hello, {{user.name}}! You have {{cart.count}} items." } }
```

Renders: **Hello, John! You have 3 items.**

You can also wrap the widget tree with `SduiDataProvider` to flow data from higher up:

```dart
SduiDataProvider(
  data: {'user': {'name': 'Alice'}},
  child: SduiWidget(json: screenJson),
)
```

---

## Conditional Visibility

Add `visible_if` to any node's `props`:

```json
{
  "type": "text",
  "props": {
    "content": "Premium exclusive!",
    "visible_if": "user.is_premium"
  }
}
```

Supported expressions:

| Expression | Example |
|---|---|
| Truthy | `"user.is_premium"` |
| Negation | `"!cart.is_empty"` |
| Equality | `"user.role == admin"` |
| Inequality | `"user.role != guest"` |
| Numeric | `"cart.count > 0"`, `"cart.count >= 5"` |
| AND | `"user.is_premium && cart.count > 0"` |
| OR | `"user.role == admin \|\| user.is_staff"` |

---

## Action Handling

Register handlers for action types your server sends:

```dart
final actions = ActionHandler();

actions.register('navigate', (action, payload) {
  Navigator.pushNamed(context, payload['route'] as String);
});

actions.register('api_call', (action, payload) async {
  await http.post(Uri.parse(payload['endpoint'] as String));
});

// Catch-all for unregistered action types
actions.onUnhandled = (action, payload) {
  debugPrint('Unhandled: ${action.type}');
};

SduiWidget(
  json: serverJson,
  actionHandler: actions,
)
```

Form components (`text_input`, `checkbox`, `switch`, `dropdown`) automatically fire `input_changed` actions with `{ "field": "…", "value": … }`.

---

## Custom Components

Register your own component builders to extend the kit:

```dart
final registry = createDefaultRegistry();

registry.register('rating_stars', (node, context) {
  final count = node.props['count'] as int? ?? 5;
  final filled = node.props['filled'] as int? ?? 0;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(count, (i) => Text(
      i < filled ? '★' : '☆',
      style: TextStyle(
        fontSize: 20,
        color: context.theme?.primary ?? const Color(0xFFFFD700),
      ),
    )),
  );
});

SduiWidget(
  json: serverJson,
  registry: registry,
)
```

Your server can now send:

```json
{ "type": "rating_stars", "props": { "count": 5, "filled": 4 } }
```

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  Server JSON                                                 │
│  { screen, version, cache_ttl, theme, body }                 │
└──────────────────┬───────────────────────────────────────────┘
                   │ parse
┌──────────────────▼───────────────────────────────────────────┐
│  Models                                                      │
│  SduiScreen → SduiNode tree → SduiAction, SduiTheme          │
└──────────────────┬───────────────────────────────────────────┘
                   │ render
┌──────────────────▼───────────────────────────────────────────┐
│  SduiRenderer                                                │
│  ┌─────────────────┐  ┌──────────────┐  ┌─────────────────┐ │
│  │ ComponentRegistry│  │TemplateResolv│  │ExpressionEvaluat│ │
│  │ type → builder   │  │ {{path}} → v │  │ visible_if      │ │
│  └────────┬────────┘  └──────────────┘  └─────────────────┘ │
│           │ build                                            │
│  ┌────────▼────────┐                                         │
│  │ ComponentBuilder │ ← receives SduiNode + SduiContext       │
│  └────────┬────────┘                                         │
└───────────┼──────────────────────────────────────────────────┘
            │
┌───────────▼──────────────────────────────────────────────────┐
│  Flutter Widget Tree                                         │
│  Text, Column, Row, Image, GestureDetector, …                │
└──────────────────────────────────────────────────────────────┘
```

**Key abstractions (framework-agnostic):**

| Concept | Responsibility |
|---|---|
| **Node** | Recursive data model with `type`, `props`, `children`, `action` |
| **Component Registry** | Maps `type` strings to platform-native builder functions |
| **Action Handler** | Dispatches `action.type` to registered callbacks |
| **Template Resolver** | Interpolates `{{path}}` placeholders against a data map |
| **Expression Evaluator** | Evaluates `visible_if` boolean expressions |
| **Renderer** | Walks the node tree, resolves templates/conditions, calls builders |

Any platform SDK (SwiftUI, Compose, React Native) can implement these same six abstractions to render the identical JSON protocol.

---

## Implementing for Other Platforms

The JSON protocol is designed to be **platform-agnostic**. To build an SDK for another framework:

1. **Parse** the screen envelope into your platform's model objects (`Screen`, `Node`, `Action`, `Theme`).
2. **Build a Component Registry** — a dictionary of `type` → native view builder.
3. **Build an Action Handler** — a dictionary of `action.type` → callback.
4. **Implement a Template Resolver** — regex replace `{{path}}` with data map lookups.
5. **Implement an Expression Evaluator** — parse `visible_if` strings into booleans.
6. **Walk the tree** — for each node, resolve templates → check visibility → look up builder → render.

The `props` contract per component type (documented above) stays the same across all platforms.

---

## API Reference

### SduiWidget

| Property | Type | Default | Description |
|---|---|---|---|
| `json` | `String?` | — | Raw JSON string (mutually exclusive with `screen`) |
| `screen` | `SduiScreen?` | — | Pre-parsed model (mutually exclusive with `json`) |
| `registry` | `ComponentRegistry?` | built-in | Component builder registry |
| `actionHandler` | `ActionHandler?` | no-op | Action dispatcher |
| `data` | `Map<String, dynamic>` | `{}` | Data context for templates and conditions |
| `errorWidget` | `Widget` | `SizedBox.shrink()` | Fallback when JSON fails to parse |

### ComponentRegistry

| Method | Description |
|---|---|
| `register(type, builder)` | Register a single builder |
| `registerAll(map)` | Register multiple builders |
| `unregister(type)` | Remove a builder |
| `setFallback(builder)` | Override the fallback for unknown types |
| `has(type)` | Check if a type is registered |
| `resolve(type)` | Get the builder (or fallback) |

### ActionHandler

| Method | Description |
|---|---|
| `register(type, handler)` | Register a handler for an action type |
| `registerAll(map)` | Register multiple handlers |
| `handle(action)` | Dispatch an action |
| `onUnhandled` | Catch-all callback for unknown types |

---

## License

MIT — see [LICENSE](LICENSE).
