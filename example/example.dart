import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Example: Rendering a server-driven home screen with flutter_sdui_kit
// ─────────────────────────────────────────────────────────────────────────────

void main() => runApp(const ExampleApp());

/// Shared navigator key — lets action handlers navigate even when the SDUI
/// widget is above the Navigator in the tree.
final _navigatorKey = GlobalKey<NavigatorState>();

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF6C63FF),
      navigatorKey: _navigatorKey,
      builder: (context, child) => const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Set up action handlers with navigatorKey for safe navigation
    final actions = ActionHandler(navigatorKey: _navigatorKey);
    actions.register('navigate', (context, action, payload) {
      // Uses navigatorOf() — tries Navigator.of(context) first, then
      // falls back to the navigatorKey.
      actions.navigatorOf(context).pushNamed(payload['route'] as String);
    });
    actions.register('api_call', (context, action, payload) {
      // ignore: avoid_print
      print('API call: ${payload['method']} ${payload['endpoint']}');
    });

    // 2. Provide runtime data for {{template}} expressions
    final data = {
      'user': {'name': 'John', 'is_premium': true},
      'cart': {'count': 3},
    };

    // 3. Render the screen — just pass the JSON string, that's it!
    return SduiWidget(
      json: _sampleJson,
      actionHandler: actions,
      data: data,

      // 4. Error handling — all errors are forwarded to you
      onError: (error) {
        // ignore: avoid_print
        print('SDUI error: ${error.type.name} — ${error.message}');
        // Send to Crashlytics / Sentry / your analytics
      },

      // 5. Fallback widget when JSON is null / empty / fails to parse
      fallback: const Center(
        child: Text('Loading screen…'),
      ),

      // 6. Per-node error widget when a single component fails to render
      errorWidgetBuilder: (error) => Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0x22FF0000),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: Text(
          'Component "${error.nodeType}" failed',
          style: const TextStyle(color: Color(0xFFCC0000), fontSize: 12),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample server response (normally fetched from your API)
// ─────────────────────────────────────────────────────────────────────────────

final _sampleJson = jsonEncode({
  'screen': 'home',
  'version': 1,
  'cache_ttl': 300,
  'theme': {
    'primary': '#6C63FF',
    'background': '#FFFFFF',
    'text': '#1A1A2E',
  },
  'body': {
    'type': 'scroll',
    'children': [
      {
        'type': 'padding',
        'props': {'all': 16},
        'children': [
          {
            'type': 'column',
            'props': {'spacing': 12},
            'children': [
              {
                'type': 'text',
                'props': {
                  'content': 'Welcome back, {{user.name}}!',
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
              {
                'type': 'text',
                'props': {
                  'content': 'Premium exclusive deal 🎉',
                  'style': 'body',
                  'visible_if': 'user.is_premium',
                },
              },
              {
                'type': 'row',
                'props': {'spacing': 8},
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
            ],
          },
        ],
      },
      {
        'type': 'divider',
        'props': {'color': '#EFEFEF', 'thickness': 1},
      },
      {
        'type': 'padding',
        'props': {'all': 16},
        'children': [
          {
            'type': 'column',
            'props': {'spacing': 12},
            'children': [
              {
                'type': 'text',
                'props': {'content': 'Preferences', 'style': 'subheading'},
              },
              {
                'type': 'checkbox',
                'props': {
                  'checked': false,
                  'label': 'Enable notifications',
                  'field': 'notifications',
                },
              },
              {
                'type': 'switch',
                'props': {
                  'value': true,
                  'label': 'Dark mode',
                  'field': 'dark_mode',
                },
              },
              {
                'type': 'dropdown',
                'props': {
                  'placeholder': 'Select language',
                  'field': 'language',
                  'options': [
                    {'label': 'English', 'value': 'en'},
                    {'label': 'Spanish', 'value': 'es'},
                    {'label': 'French', 'value': 'fr'},
                  ],
                },
              },
            ],
          },
        ],
      },
    ],
  },
});
