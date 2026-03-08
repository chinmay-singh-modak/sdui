/// Flutter Server-Driven UI Kit
///
/// A framework for rendering UI from server-provided JSON schemas.
/// Register custom component builders, action handlers, and style resolvers
/// to extend the kit for your application.
library;

// ── Models ──────────────────────────────────────────────────────────────
export 'src/models/sdui_action.dart';
export 'src/models/sdui_node.dart';
export 'src/models/sdui_screen.dart';
export 'src/models/sdui_theme.dart';

// ── Core ────────────────────────────────────────────────────────────────
export 'src/core/sdui_context.dart';
export 'src/core/component_registry.dart';
export 'src/core/action_handler.dart';
export 'src/core/sdui_renderer.dart';
export 'src/core/default_registry.dart';
export 'src/core/expression_evaluator.dart';
export 'src/core/template_resolver.dart';
export 'src/core/sdui_data_provider.dart';

// ── Styles ──────────────────────────────────────────────────────────────
export 'src/styles/style_parser.dart';

// ── Built-in component builders ─────────────────────────────────────────
export 'src/components/text_builder.dart';
export 'src/components/layout_builders.dart';
export 'src/components/container_builders.dart';
export 'src/components/image_builder.dart';
export 'src/components/button_builder.dart';
export 'src/components/common_builders.dart';
export 'src/components/form_builders.dart';
export 'src/components/gesture_builder.dart';

// ── Drop-in widget ──────────────────────────────────────────────────────
export 'src/sdui_widget.dart';
