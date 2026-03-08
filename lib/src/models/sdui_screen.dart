import 'sdui_node.dart';
import 'sdui_theme.dart';

/// The top-level response returned by the SDUI server for a screen.
///
/// ```json
/// {
///   "screen": "home",
///   "version": 1,
///   "cache_ttl": 300,
///   "theme": { ... },
///   "body": { ... }
/// }
/// ```
class SduiScreen {
  /// An identifier for the screen (used for caching / analytics).
  final String screen;

  /// Schema version — the client can use this for migration or feature-gating.
  final int version;

  /// How long (in seconds) this response can be served from a local cache.
  final int cacheTtl;

  /// Optional theme overrides for this screen.
  final SduiTheme? theme;

  /// The root node of the component tree.
  final SduiNode body;

  const SduiScreen({
    required this.screen,
    this.version = 1,
    this.cacheTtl = 0,
    this.theme,
    required this.body,
  });

  factory SduiScreen.fromJson(Map<String, dynamic> json) {
    return SduiScreen(
      screen: json['screen'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      cacheTtl: json['cache_ttl'] as int? ?? 0,
      theme: json.containsKey('theme')
          ? SduiTheme.fromJson(json['theme'] as Map<String, dynamic>)
          : null,
      body: SduiNode.fromJson(json['body'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'screen': screen,
        'version': version,
        'cache_ttl': cacheTtl,
        if (theme != null) 'theme': theme!.toJson(),
        'body': body.toJson(),
      };
}
