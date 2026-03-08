import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

/// Custom Component screen — demonstrates:
///  • Creating a `ComponentRegistry` with `createDefaultRegistry()`
///  • Registering a brand-new widget type (`star_rating`)
///  • Rendering JSON that uses the custom type alongside built-in types
class CustomComponentScreen extends StatelessWidget {
  final ActionHandler actions;
  final SduiErrorCallback onError;

  const CustomComponentScreen({
    super.key,
    required this.actions,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    // 1️⃣  Start with the default registry (all 23 built-in types)
    final registry = createDefaultRegistry();

    // 2️⃣  Register a custom "star_rating" builder
    registry.register('star_rating', _starRatingBuilder);

    // 3️⃣  Register a custom "badge" builder
    registry.register('badge', _badgeBuilder);

    return SduiWidget(
      json: _customJson,
      registry: registry,
      actionHandler: actions,
      onError: onError,
      fallback: const Center(child: Text('Loading custom screen…')),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom builder: star_rating
//  props:
//    • rating   (int)   — number of filled stars (0-5)
//    • max      (int)   — total stars, default 5
//    • size     (double) — icon size, default 24
//    • color    (String) — hex colour for filled stars
// ─────────────────────────────────────────────────────────────────────────────
Widget _starRatingBuilder(SduiNode node, SduiContext ctx) {
  final rating = (node.props['rating'] as num?)?.toInt() ?? 0;
  final max = (node.props['max'] as num?)?.toInt() ?? 5;
  final size = (node.props['size'] as num?)?.toDouble() ?? 24.0;
  final colorHex = node.props['color'] as String? ?? '#FFC107';

  final color = _hexToColor(colorHex);
  final emptyColor = const Color(0xFFCCCCCC);

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(max, (i) {
      final isFilled = i < rating;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          isFilled ? '★' : '☆',
          style: TextStyle(
            fontSize: size,
            color: isFilled ? color : emptyColor,
          ),
        ),
      );
    }),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom builder: badge
//  props:
//    • text       (String)
//    • background (String) — hex
//    • text_color  (String) — hex
// ─────────────────────────────────────────────────────────────────────────────
Widget _badgeBuilder(SduiNode node, SduiContext ctx) {
  final text = node.props['text'] as String? ?? '';
  final bg = _hexToColor(node.props['background'] as String? ?? '#6C63FF');
  final fg = _hexToColor(node.props['text_color'] as String? ?? '#FFFFFF');

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.bold),
    ),
  );
}

Color _hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

// ─────────────────────────────────────────────────────────────────────────────
// JSON — uses both built-in and custom types
// ─────────────────────────────────────────────────────────────────────────────
final _customJson = jsonEncode({
  'screen': 'custom_demo',
  'theme': {
    'primary': '#6C63FF',
    'background': '#FFFFFF',
    'text': '#1A1A2E',
  },
  'body': {
    'type': 'safe_area',
    'children': [
      {
        'type': 'scroll',
        'children': [
          {
            'type': 'padding',
            'props': {'all': 20},
            'children': [
              {
                'type': 'column',
                'props': {'spacing': 16},
                'children': [
                  // Header
                  {
                    'type': 'text',
                    'props': {
                      'content': 'Custom Components',
                      'style': 'heading',
                    },
                  },
                  {
                    'type': 'text',
                    'props': {
                      'content':
                          'This screen registers two custom builders — star_rating '
                              'and badge — then uses them in JSON alongside built-in types.',
                      'style': 'caption',
                      'color': '#888888',
                    },
                  },

                  {'type': 'divider', 'props': {}},

                  // ── Product card with star_rating ─────
                  {
                    'type': 'card',
                    'props': {
                      'background': '#FFFFFF',
                      'corner_radius': 12,
                      'elevation': 2,
                    },
                    'children': [
                      {
                        'type': 'padding',
                        'props': {'all': 16},
                        'children': [
                          {
                            'type': 'column',
                            'props': {'spacing': 8},
                            'children': [
                              {
                                'type': 'row',
                                'props': {
                                  'cross_axis': 'center',
                                  'spacing': 8,
                                },
                                'children': [
                                  {
                                    'type': 'text',
                                    'props': {
                                      'content': 'Wireless Headphones',
                                      'style': 'subheading',
                                    },
                                  },
                                  {
                                    'type': 'badge',
                                    'props': {
                                      'text': 'NEW',
                                      'background': '#4CAF50',
                                    },
                                  },
                                ],
                              },
                              {
                                'type': 'star_rating',
                                'props': {
                                  'rating': 4,
                                  'max': 5,
                                  'size': 22,
                                  'color': '#FFC107',
                                },
                              },
                              {
                                'type': 'text',
                                'props': {
                                  'content': '4.0 out of 5  •  1,284 reviews',
                                  'style': 'caption',
                                  'color': '#888888',
                                },
                              },
                              {
                                'type': 'text',
                                'props': {
                                  'content': '\$89.99',
                                  'style': 'subheading',
                                  'color': '#6C63FF',
                                },
                              },
                              {
                                'type': 'button',
                                'props': {
                                  'label': 'Add to Cart',
                                  'variant': 'primary',
                                  'full_width': true,
                                },
                                'action': {
                                  'type': 'api_call',
                                  'payload': {
                                    'endpoint': '/api/cart/add',
                                    'product_id': 'headphones_01',
                                  },
                                },
                              },
                            ],
                          },
                        ],
                      },
                    ],
                  },

                  // ── Second card with star_rating ──────
                  {
                    'type': 'card',
                    'props': {
                      'background': '#FFFFFF',
                      'corner_radius': 12,
                      'elevation': 2,
                    },
                    'children': [
                      {
                        'type': 'padding',
                        'props': {'all': 16},
                        'children': [
                          {
                            'type': 'column',
                            'props': {'spacing': 8},
                            'children': [
                              {
                                'type': 'row',
                                'props': {
                                  'cross_axis': 'center',
                                  'spacing': 8,
                                },
                                'children': [
                                  {
                                    'type': 'text',
                                    'props': {
                                      'content': 'USB-C Charging Cable',
                                      'style': 'subheading',
                                    },
                                  },
                                  {
                                    'type': 'badge',
                                    'props': {
                                      'text': 'SALE',
                                      'background': '#FF5252',
                                    },
                                  },
                                ],
                              },
                              {
                                'type': 'star_rating',
                                'props': {
                                  'rating': 3,
                                  'max': 5,
                                  'size': 22,
                                  'color': '#FFC107',
                                },
                              },
                              {
                                'type': 'text',
                                'props': {
                                  'content': '3.0 out of 5  •  452 reviews',
                                  'style': 'caption',
                                  'color': '#888888',
                                },
                              },
                              {
                                'type': 'text',
                                'props': {
                                  'content': '\$12.99',
                                  'style': 'subheading',
                                  'color': '#6C63FF',
                                },
                              },
                              {
                                'type': 'button',
                                'props': {
                                  'label': 'Add to Cart',
                                  'variant': 'outline',
                                  'full_width': true,
                                },
                                'action': {
                                  'type': 'api_call',
                                  'payload': {
                                    'endpoint': '/api/cart/add',
                                    'product_id': 'cable_02',
                                  },
                                },
                              },
                            ],
                          },
                        ],
                      },
                    ],
                  },

                  // ── How it works ──────────────────────
                  {'type': 'divider', 'props': {}},
                  {
                    'type': 'text',
                    'props': {
                      'content': 'How it works',
                      'style': 'subheading',
                    },
                  },
                  {
                    'type': 'text',
                    'props': {
                      'content':
                          '1. Call createDefaultRegistry() to get a registry with '
                              'all built-in types.\n'
                              '2. Register your own builder with registry.register(name, fn).\n'
                              '3. Pass the registry to SduiWidget — done!',
                      'color': '#555555',
                    },
                  },

                  // Bottom spacing
                  {'type': 'sizedbox', 'props': {'height': 20}},
                ],
              },
            ],
          },
        ],
      },
    ],
  },
});
