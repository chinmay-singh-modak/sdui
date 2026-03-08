import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

/// Home screen — demonstrates the core SDUI features:
///  • Data binding via {{templates}}
///  • Conditional visibility via visible_if
///  • Theme colours from the server
///  • Action handling (navigate, api_call)
///  • Layout components (scroll, column, row, padding, divider, card, icon)
///  • Buttons with variants (primary, outline, text)
///  • Error handling (onError, errorWidgetBuilder, fallback)
class HomeScreen extends StatelessWidget {
  final ActionHandler actions;
  final SduiErrorCallback onError;

  const HomeScreen({
    super.key,
    required this.actions,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return SduiWidget(
      json: _homeJson,
      actionHandler: actions,
      data: {
        'user': {'name': 'Chinmay', 'is_premium': true, 'role': 'admin'},
        'cart': {'count': 3},
        'stats': {'orders': 12, 'points': 1580},
      },
      onError: onError,
      fallback: const Center(child: Text('Loading home…')),
      errorWidgetBuilder: (error) => Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x22FF0000),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '⚠ ${error.message}',
          style: const TextStyle(color: Color(0xFFCC0000), fontSize: 12),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JSON — simulates a server response for the home screen
// ─────────────────────────────────────────────────────────────────────────────

final _homeJson = jsonEncode({
  'screen': 'home',
  'version': 1,
  'cache_ttl': 300,
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
          // ── Header ──────────────────────────────────────────────────
          {
            'type': 'padding',
            'props': {'horizontal': 20, 'vertical': 16},
            'children': [
              {
                'type': 'column',
                'props': {'spacing': 4},
                'children': [
                  {
                    'type': 'text',
                    'props': {
                      'content': 'Welcome back, {{user.name}}! 👋',
                      'style': 'heading',
                      'color': '#1A1A2E',
                    },
                  },
                  {
                    'type': 'text',
                    'props': {
                      'content': "Here's what's new today.",
                      'style': 'caption',
                      'color': '#9A9A9A',
                    },
                  },
                ],
              },
            ],
          },

          // ── Premium banner (only visible when user.is_premium) ────
          {
            'type': 'padding',
            'props': {'horizontal': 20, 'bottom': 12},
            'children': [
              {
                'type': 'card',
                'props': {
                  'corner_radius': 16,
                  'background': '#6C63FF',
                  'elevation': 3,
                },
                'children': [
                  {
                    'type': 'padding',
                    'props': {'all': 16},
                    'children': [
                      {
                        'type': 'column',
                        'props': {'spacing': 4},
                        'children': [
                          {
                            'type': 'row',
                            'props': {'spacing': 8, 'cross_alignment': 'center'},
                            'children': [
                              {
                                'type': 'icon',
                                'props': {'name': 'star', 'size': 20},
                              },
                              {
                                'type': 'text',
                                'props': {
                                  'content': 'Premium Member',
                                  'style': 'subheading',
                                  'color': '#FFFFFF',
                                  'visible_if': 'user.is_premium',
                                },
                              },
                            ],
                          },
                          {
                            'type': 'text',
                            'props': {
                              'content': 'You have {{stats.points}} points',
                              'style': 'caption',
                              'color': '#DDDDFF',
                            },
                          },
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },

          // ── Stats Row ───────────────────────────────────────────────
          {
            'type': 'padding',
            'props': {'horizontal': 20, 'bottom': 16},
            'children': [
              {
                'type': 'row',
                'props': {'spacing': 12},
                'children': [
                  _statCard('📦', '{{stats.orders}}', 'Orders'),
                  _statCard('🛒', '{{cart.count}}', 'In Cart'),
                  _statCard('⭐', '{{stats.points}}', 'Points'),
                ],
              },
            ],
          },

          // ── Divider ─────────────────────────────────────────────────
          {
            'type': 'divider',
            'props': {'color': '#F0F0F0', 'thickness': 1},
          },

          // ── Action Buttons ──────────────────────────────────────────
          {
            'type': 'padding',
            'props': {'all': 20},
            'children': [
              {
                'type': 'column',
                'props': {'spacing': 10},
                'children': [
                  {
                    'type': 'text',
                    'props': {
                      'content': 'Quick Actions',
                      'style': 'subheading',
                    },
                  },
                  {
                    'type': 'row',
                    'props': {'spacing': 10},
                    'children': [
                      {
                        'type': 'button',
                        'props': {
                          'label': 'Shop Now',
                          'variant': 'primary',
                          'full_width': true,
                          'flex': 1,
                        },
                        'action': {
                          'type': 'navigate',
                          'payload': {'route': '/shop'},
                        },
                      },
                      {
                        'type': 'button',
                        'props': {
                          'label': 'Explore',
                          'variant': 'outline',
                          'full_width': true,
                          'flex': 1,
                        },
                        'action': {
                          'type': 'navigate',
                          'payload': {'route': '/explore'},
                        },
                      },
                    ],
                  },
                  {
                    'type': 'button',
                    'props': {
                      'label': 'View Orders →',
                      'variant': 'text',
                    },
                    'action': {
                      'type': 'navigate',
                      'payload': {'route': '/orders'},
                    },
                  },
                ],
              },
            ],
          },

          // ── Admin-only section (visible_if: user.role == admin) ────
          {
            'type': 'padding',
            'props': {'horizontal': 20, 'bottom': 20},
            'children': [
              {
                'type': 'card',
                'props': {
                  'corner_radius': 12,
                  'background': '#FFF3E0',
                  'visible_if': 'user.role == admin',
                },
                'children': [
                  {
                    'type': 'padding',
                    'props': {'all': 16},
                    'children': [
                      {
                        'type': 'row',
                        'props': {'spacing': 8, 'cross_alignment': 'center'},
                        'children': [
                          {
                            'type': 'icon',
                            'props': {'name': 'settings', 'size': 20},
                          },
                          {
                            'type': 'column',
                            'props': {'spacing': 2},
                            'children': [
                              {
                                'type': 'text',
                                'props': {
                                  'content': 'Admin Panel',
                                  'style': 'body',
                                  'color': '#E65100',
                                },
                              },
                              {
                                'type': 'text',
                                'props': {
                                  'content':
                                      'Visible only to admins (visible_if demo)',
                                  'style': 'caption',
                                  'color': '#BF360C',
                                },
                              },
                            ],
                          },
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  },
});

// Helper to build a stat card node
Map<String, dynamic> _statCard(String icon, String value, String label) {
  return {
    'type': 'card',
    'props': {
      'corner_radius': 12,
      'background': '#F8F8FF',
      'flex': 1,
    },
    'children': [
      {
        'type': 'padding',
        'props': {'all': 12},
        'children': [
          {
            'type': 'column',
            'props': {'spacing': 4, 'cross_alignment': 'center'},
            'children': [
              {'type': 'text', 'props': {'content': icon, 'style': 'heading'}},
              {'type': 'text', 'props': {'content': value, 'style': 'subheading'}},
              {
                'type': 'text',
                'props': {'content': label, 'style': 'caption', 'color': '#888888'},
              },
            ],
          },
        ],
      },
    ],
  };
}
