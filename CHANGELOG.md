# Changelog

## 0.1.0

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

## 0.1.0+2

Updated Package Description
