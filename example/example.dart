import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Example: Rendering a server-driven home screen with flutter_sdui_kit
// ─────────────────────────────────────────────────────────────────────────────

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF6C63FF),
      builder: (context, _) => const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Set up action handlers
    final actions = ActionHandler();
    actions.register('navigate', (action, payload) {
      // ignore: avoid_print
      print('Navigate to ${payload['route']}');
    });
    actions.register('api_call', (action, payload) {
      // ignore: avoid_print
      print('API call: ${payload['method']} ${payload['endpoint']}');
    });

    // 2. Provide runtime data for {{template}} expressions
    final data = {
      'user': {'name': 'John', 'is_premium': true},
      'cart': {'count': 3},
    };

    // 3. Render the screen
    return SduiWidget(
      json: _sampleJson,
      actionHandler: actions,
      data: data,
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
