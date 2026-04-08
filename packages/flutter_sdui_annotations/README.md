# flutter_sdui_annotations

Lightweight annotations for marking Flutter widgets as SDUI (Server-Driven UI) components.

Add this as a regular `dependency` in your app — it has zero heavy dependencies (only `meta`) and no analyzer coupling.

---

## Installation

```yaml
# pubspec.yaml
dependencies:
  flutter_sdui_annotations: ^1.0.0
```

---

## Annotations

### `@SduiComponent`

Marks a widget class as an SDUI component. The `name` becomes the component's type identifier in the generated JSON schema.

```dart
@SduiComponent(name: 'PrimaryButton')
class PrimaryButton extends StatelessWidget { ... }
```

### `@SduiProp`

Marks a constructor field as a serializable prop. The optional `defaultValue` overrides the value inferred from the constructor default — if omitted, the converter reads the constructor parameter default directly.

```dart
@SduiProp()
final String label;

@SduiProp(defaultValue: 'blue')
final String color;
```

### `@SduiAction`

Marks a callback field as an SDUI action. Action fields are not emitted as props — they set `supportsAction: true` on the component in the schema.

```dart
@SduiAction()
final VoidCallback? onTap;
```

---

## Full example

```dart
import 'package:flutter_sdui_annotations/flutter_sdui_annotations.dart';

@SduiComponent(name: 'PrimaryButton')
class PrimaryButton extends StatelessWidget {
  @SduiProp()
  final String label;

  @SduiProp(defaultValue: 'blue')
  final String color;

  @SduiAction()
  final VoidCallback? onTap;

  const PrimaryButton({
    required this.label,
    this.color = 'blue',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) { ... }
}
```

Running `flutter_sdui_converter` on the above produces:

```json
{
  "type": "PrimaryButton",
  "props": [
    { "name": "label", "type": "string", "required": true },
    { "name": "color", "type": "string", "required": false, "default": "blue" }
  ],
  "supportsAction": true
}
```

---

## Part of the flutter_sdui_kit workspace

| Package                    | Role                              |
| -------------------------- | --------------------------------- |
| `flutter_sdui_annotations` | Annotations (this package)        |
| `flutter_sdui_converter`   | CLI + programmatic converter tool |
| `flutter_sdui_test`        | Golden test utilities             |
