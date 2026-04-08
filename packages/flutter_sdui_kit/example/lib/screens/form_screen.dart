import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

/// Form screen — demonstrates form components:
///  • text_input with placeholder and field binding
///  • checkbox with toggle + action fire
///  • switch with toggle + action fire
///  • dropdown with options
///  • All form widgets fire `input_changed` actions automatically
///  • Live form data display (shows collected values)
class FormScreen extends StatelessWidget {
  final ActionHandler actions;
  final Map<String, dynamic> formData;
  final SduiErrorCallback onError;

  const FormScreen({
    super.key,
    required this.actions,
    required this.formData,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── SDUI form rendered from JSON ──────────────────
        Expanded(
          child: SduiWidget(
            json: _formJson,
            actionHandler: actions,
            data: formData,
            onError: onError,
            fallback: const Center(child: Text('Loading form…')),
          ),
        ),

        // ── Live form data panel ──────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            border: Border(
              top: BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Form Data (live)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formData.isEmpty
                    ? 'No data yet — interact with the form above.'
                    : formData.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF333333),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JSON — simulates a server response with a settings/form screen
// ─────────────────────────────────────────────────────────────────────────────

final _formJson = jsonEncode({
  'screen': 'settings',
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
                  // Title
                  {
                    'type': 'text',
                    'props': {'content': 'Settings', 'style': 'heading'},
                  },
                  {
                    'type': 'text',
                    'props': {
                      'content': 'All form changes fire input_changed actions. '
                          'See the live data panel below.',
                      'style': 'caption',
                      'color': '#888888',
                    },
                  },

                  // ── Section: Profile ──────────────────
                  {'type': 'divider', 'props': {}},
                  {
                    'type': 'text',
                    'props': {
                      'content': 'Profile',
                      'style': 'subheading',
                    },
                  },
                  {
                    'type': 'text_input',
                    'props': {
                      'placeholder': 'Display name',
                      'field': 'display_name',
                    },
                  },
                  {
                    'type': 'text_input',
                    'props': {
                      'placeholder': 'Email address',
                      'field': 'email',
                    },
                  },
                  {
                    'type': 'text_input',
                    'props': {
                      'placeholder': 'Password',
                      'field': 'password',
                      'obscure': true,
                    },
                  },
                  {
                    'type': 'text_input',
                    'props': {
                      'placeholder': 'Bio (multi-line)',
                      'field': 'bio',
                      'max_lines': 3,
                    },
                  },

                  // ── Section: Preferences ──────────────
                  {'type': 'divider', 'props': {}},
                  {
                    'type': 'text',
                    'props': {
                      'content': 'Preferences',
                      'style': 'subheading',
                    },
                  },
                  {
                    'type': 'checkbox',
                    'props': {
                      'label': 'Enable notifications',
                      'field': 'notifications',
                      'checked': false,
                    },
                  },
                  {
                    'type': 'checkbox',
                    'props': {
                      'label': 'Subscribe to newsletter',
                      'field': 'newsletter',
                      'checked': true,
                    },
                  },
                  {
                    'type': 'switch',
                    'props': {
                      'label': 'Dark mode',
                      'field': 'dark_mode',
                      'value': false,
                    },
                  },
                  {
                    'type': 'switch',
                    'props': {
                      'label': 'Auto-sync',
                      'field': 'auto_sync',
                      'value': true,
                    },
                  },

                  // ── Section: Region ───────────────────
                  {'type': 'divider', 'props': {}},
                  {
                    'type': 'text',
                    'props': {
                      'content': 'Region',
                      'style': 'subheading',
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
                        {'label': 'German', 'value': 'de'},
                        {'label': 'Hindi', 'value': 'hi'},
                      ],
                    },
                  },
                  {
                    'type': 'dropdown',
                    'props': {
                      'placeholder': 'Select timezone',
                      'field': 'timezone',
                      'options': [
                        {'label': 'UTC-5 (EST)', 'value': 'est'},
                        {'label': 'UTC+0 (GMT)', 'value': 'gmt'},
                        {'label': 'UTC+5:30 (IST)', 'value': 'ist'},
                        {'label': 'UTC+9 (JST)', 'value': 'jst'},
                      ],
                    },
                  },

                  // ── Submit ─────────────────────────────
                  {'type': 'divider', 'props': {}},
                  {
                    'type': 'button',
                    'props': {
                      'label': 'Save Settings',
                      'variant': 'primary',
                      'full_width': true,
                    },
                    'action': {
                      'type': 'api_call',
                      'payload': {
                        'method': 'POST',
                        'endpoint': '/api/settings',
                      },
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
