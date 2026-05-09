import 'package:flutter/material.dart';
import 'package:flutter_sdui_test/flutter_sdui_test.dart';

// Add to dev_dependencies:
//
//   dev_dependencies:
//     flutter_sdui_test: ^<version>
//
// Then run:
//   flutter test                  # compare against goldens
//   flutter test --update-goldens # regenerate goldens

// ── Example native widget ─────────────────────────────────────────────────────

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Sign in to continue', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // Load schema from a JSON file on disk.
  // Generates two goldens per device:
  //   test/goldens/login_screen_phone_native.png
  //   test/goldens/login_screen_phone_sdui.png
  sduiGoldenTest(
    'login screen',
    nativeWidget: const LoginScreen(),
    schemaPath: 'test/fixtures/login.json',
    devices: [SduiDevices.phone, SduiDevices.tablet],
    threshold: 0.01, // up to 1% pixel diff allowed
  );

  // Or provide the schema inline — useful for quick iteration.
  sduiGoldenTest(
    'inline screen',
    nativeWidget: const LoginScreen(),
    schema: {
      'screen': 'login',
      'body': {
        'type': 'padding',
        'props': {'all': 24},
        'children': [
          {
            'type': 'column',
            'props': {'main_alignment': 'center'},
            'children': [
              {
                'type': 'text',
                'props': {'content': 'Welcome back', 'style': 'heading'},
              },
              {'type': 'spacer', 'props': {'height': 8}},
              {
                'type': 'text',
                'props': {
                  'content': 'Sign in to continue',
                  'color': '#9E9E9E',
                },
              },
            ],
          },
        ],
      },
    },
  );
}
