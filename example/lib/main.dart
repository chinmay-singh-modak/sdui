import 'package:flutter/widgets.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

import 'screens/home_screen.dart';
import 'screens/form_screen.dart';
import 'screens/custom_component_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// flutter_sdui_kit — Example App
//
// Demonstrates:
//  • Rendering a server-driven screen from JSON
//  • Data binding with {{templates}}
//  • Conditional visibility with visible_if
//  • Action handling (navigate, api_call, form input)
//  • Error handling (onError, errorWidgetBuilder, fallback)
//  • Custom component registration
//  • Form widgets (text_input, checkbox, switch, dropdown)
// ─────────────────────────────────────────────────────────────────────────────

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF6C63FF),
      builder: (context, _) => const AppShell(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Shell — simple tab bar at the bottom to switch between demo screens
// ─────────────────────────────────────────────────────────────────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  // Shared action handler — prints actions to console.
  final _actions = ActionHandler();
  final _formData = <String, dynamic>{};
  final _errors = <String>[];

  @override
  void initState() {
    super.initState();

    // Navigation handler
    _actions.register('navigate', (action, payload) {
      final route = payload['route'] ?? '?';
      print('→ Navigate to $route');
      setState(() => _errors.add('Navigate → $route'));
    });

    // API call handler
    _actions.register('api_call', (action, payload) {
      final method = payload['method'] ?? 'GET';
      final endpoint = payload['endpoint'] ?? '?';
      print('→ API: $method $endpoint');
      setState(() => _errors.add('API → $method $endpoint'));
    });

    // Form input handler
    _actions.register('input_changed', (action, payload) {
      final field = payload['field'] as String? ?? '';
      final value = payload['value'];
      print('→ Form: $field = $value');
      setState(() {
        _formData[field] = value;
      });
    });

    // Catch-all for unknown actions
    _actions.onUnhandled = (action, payload) {
      print('→ Unhandled action: ${action.type}');
      setState(() => _errors.add('Unhandled: ${action.type}'));
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Content area ──────────────────────────────────
        Expanded(child: _buildTab()),

        // ── Tab bar ───────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            border: Border(
              top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _tabButton(0, '🏠 Home'),
                _tabButton(1, '📝 Forms'),
                _tabButton(2, '🧩 Custom'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab() {
    return switch (_tab) {
      0 => HomeScreen(
            actions: _actions,
            onError: _onError,
          ),
      1 => FormScreen(
            actions: _actions,
            formData: _formData,
            onError: _onError,
          ),
      2 => CustomComponentScreen(
            actions: _actions,
            onError: _onError,
          ),
      _ => const SizedBox.shrink(),
    };
  }

  void _onError(SduiError error) {
    print('[SDUI Error] ${error.type.name}: ${error.message}');
  }

  Widget _tabButton(int index, String label) {
    final isActive = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? const Color(0xFF6C63FF)
                  : const Color(0xFF999999),
            ),
          ),
        ),
      ),
    );
  }
}
