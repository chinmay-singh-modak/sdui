import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

void main() {
  group('SduiNode', () {
    test('parses a leaf node from JSON', () {
      final json = {
        'type': 'text',
        'props': {'content': 'Hello', 'style': 'heading'},
      };
      final node = SduiNode.fromJson(json);
      expect(node.type, 'text');
      expect(node.props['content'], 'Hello');
      expect(node.children, isEmpty);
      expect(node.action, isNull);
    });

    test('parses nested children recursively', () {
      final json = {
        'type': 'column',
        'children': [
          {'type': 'text', 'props': {'content': 'A'}},
          {'type': 'text', 'props': {'content': 'B'}},
        ],
      };
      final node = SduiNode.fromJson(json);
      expect(node.children.length, 2);
      expect(node.children[0].props['content'], 'A');
    });

    test('parses an action when present', () {
      final json = {
        'type': 'button',
        'props': {'label': 'Tap'},
        'action': {
          'type': 'navigate',
          'payload': {'route': '/home'},
        },
      };
      final node = SduiNode.fromJson(json);
      expect(node.action, isNotNull);
      expect(node.action!.type, 'navigate');
      expect(node.action!.payload['route'], '/home');
    });
  });

  group('SduiScreen', () {
    test('parses a full screen response', () {
      final json = {
        'screen': 'home',
        'version': 2,
        'cache_ttl': 300,
        'theme': {
          'primary': '#6C63FF',
          'background': '#FFFFFF',
          'text': '#1A1A2E',
        },
        'body': {
          'type': 'scroll',
          'children': [
            {'type': 'text', 'props': {'content': 'Hello'}},
          ],
        },
      };
      final screen = SduiScreen.fromJson(json);
      expect(screen.screen, 'home');
      expect(screen.version, 2);
      expect(screen.cacheTtl, 300);
      expect(screen.theme, isNotNull);
      expect(screen.body.type, 'scroll');
      expect(screen.body.children.length, 1);
    });
  });

  group('ComponentRegistry', () {
    test('resolves registered builders', () {
      final registry = ComponentRegistry();
      Widget builder(SduiNode n, SduiContext c) => const SizedBox();
      registry.register('test', builder);
      expect(registry.has('test'), isTrue);
      expect(registry.resolve('test'), builder);
    });

    test('returns fallback for unknown type', () {
      final registry = ComponentRegistry();
      // Should not throw — returns fallback
      final builder = registry.resolve('unknown');
      expect(builder, isNotNull);
    });
  });

  group('ActionHandler', () {
    test('dispatches to registered handler', () {
      final handler = ActionHandler();
      String? receivedRoute;
      handler.register('navigate', (action, payload) {
        receivedRoute = payload['route'] as String?;
      });
      handler.handle(SduiAction(
        type: 'navigate',
        payload: {'route': '/shop'},
      ));
      expect(receivedRoute, '/shop');
    });

    test('calls onUnhandled for unknown action types', () {
      String? unhandledType;
      final handler = ActionHandler(
        onUnhandled: (action, _) => unhandledType = action.type,
      );
      handler.handle(const SduiAction(type: 'unknown_action'));
      expect(unhandledType, 'unknown_action');
    });
  });

  group('createDefaultRegistry', () {
    test('contains all built-in types', () {
      final registry = createDefaultRegistry();
      for (final type in [
        'text', 'column', 'row', 'padding', 'sizedbox', 'container',
        'scroll', 'image', 'button', 'icon', 'card', 'list', 'divider',
      ]) {
        expect(registry.has(type), isTrue, reason: 'Missing builder for "$type"');
      }
    });
  });

  group('StyleParser', () {
    test('parses hex colours', () {
      expect(StyleParser.colorFromHex('#FF0000'), const Color(0xFFFF0000));
      expect(StyleParser.colorFromHex('#00FF00AA'), const Color(0x00FF00AA));
    });

    test('parses edge insets from "all"', () {
      final insets = StyleParser.edgeInsetsFromProps({'all': 16});
      expect(insets, const EdgeInsets.all(16));
    });

    test('parses edge insets from horizontal/vertical', () {
      final insets = StyleParser.edgeInsetsFromProps({
        'horizontal': 8,
        'vertical': 12,
      });
      expect(insets, const EdgeInsets.symmetric(horizontal: 8, vertical: 12));
    });
  });

  group('SduiWidget (integration)', () {
    testWidgets('renders from raw JSON string', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'version': 1,
        'body': {
          'type': 'text',
          'props': {'content': 'Hello SDUI'},
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(json: jsonStr),
        ),
      );

      expect(find.text('Hello SDUI'), findsOneWidget);
    });

    testWidgets('renders from pre-parsed SduiScreen', (tester) async {
      final screen = SduiScreen(
        screen: 'test',
        body: const SduiNode(
          type: 'text',
          props: {'content': 'Pre-parsed'},
        ),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(screen: screen),
        ),
      );

      expect(find.text('Pre-parsed'), findsOneWidget);
    });
  });

  // ── Expression Evaluator ──────────────────────────────────────────────

  group('ExpressionEvaluator', () {
    final data = {
      'user': {'name': 'John', 'role': 'admin', 'is_premium': true},
      'cart': {'count': 3},
      'empty_list': <dynamic>[],
    };

    test('resolves a truthy bool path', () {
      expect(ExpressionEvaluator.evaluate('user.is_premium', data), isTrue);
    });

    test('resolves equality', () {
      expect(ExpressionEvaluator.evaluate('user.role == admin', data), isTrue);
    });

    test('resolves inequality', () {
      expect(ExpressionEvaluator.evaluate('user.role != guest', data), isTrue);
    });

    test('resolves numeric comparison', () {
      expect(ExpressionEvaluator.evaluate('cart.count > 0', data), isTrue);
      expect(ExpressionEvaluator.evaluate('cart.count > 10', data), isFalse);
    });

    test('resolves negation', () {
      expect(ExpressionEvaluator.evaluate('!empty_list', data), isTrue);
    });

    test('resolves logical AND', () {
      expect(
        ExpressionEvaluator.evaluate(
            'user.is_premium && cart.count > 0', data),
        isTrue,
      );
    });

    test('resolves logical OR', () {
      expect(
        ExpressionEvaluator.evaluate(
            'user.role == guest || cart.count > 0', data),
        isTrue,
      );
    });

    test('returns false for missing path', () {
      expect(ExpressionEvaluator.evaluate('missing.path', data), isFalse);
    });
  });

  // ── Template Resolver ─────────────────────────────────────────────────

  group('TemplateResolver', () {
    final data = {
      'user': {'name': 'John'},
      'cart': {'count': 3},
    };

    test('replaces placeholders in a string', () {
      expect(
        TemplateResolver.resolve('Hello, {{user.name}}!', data),
        'Hello, John!',
      );
    });

    test('replaces multiple placeholders', () {
      expect(
        TemplateResolver.resolve(
            '{{user.name}} has {{cart.count}} items', data),
        'John has 3 items',
      );
    });

    test('leaves unresolved placeholders by default', () {
      expect(
        TemplateResolver.resolve('Hi {{unknown}}', data),
        'Hi {{unknown}}',
      );
    });

    test('removes unresolved when flag is set', () {
      expect(
        TemplateResolver.resolve('Hi {{unknown}}', data,
            removeUnresolved: true),
        'Hi ',
      );
    });

    test('resolves props map recursively', () {
      final props = {
        'content': 'Welcome, {{user.name}}!',
        'nested': {'label': '{{cart.count}} items'},
      };
      final resolved = TemplateResolver.resolveProps(props, data);
      expect(resolved['content'], 'Welcome, John!');
      expect((resolved['nested'] as Map)['label'], '3 items');
    });
  });

  // ── Conditional Visibility ────────────────────────────────────────────

  group('Conditional visibility', () {
    testWidgets('hides a node when visible_if is false', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'column',
          'children': [
            {
              'type': 'text',
              'props': {'content': 'Always visible'},
            },
            {
              'type': 'text',
              'props': {
                'content': 'Premium only',
                'visible_if': 'user.is_premium',
              },
            },
          ],
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(
            json: jsonStr,
            data: {
              'user': {'is_premium': false}
            },
          ),
        ),
      );

      expect(find.text('Always visible'), findsOneWidget);
      expect(find.text('Premium only'), findsNothing);
    });

    testWidgets('shows a node when visible_if is true', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'text',
          'props': {
            'content': 'Premium content',
            'visible_if': 'user.is_premium',
          },
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(
            json: jsonStr,
            data: {
              'user': {'is_premium': true}
            },
          ),
        ),
      );

      expect(find.text('Premium content'), findsOneWidget);
    });
  });

  // ── Template Data Binding ─────────────────────────────────────────────

  group('Template data binding', () {
    testWidgets('resolves {{}} in rendered text', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'text',
          'props': {'content': 'Hello, {{user.name}}!'},
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(
            json: jsonStr,
            data: {
              'user': {'name': 'Alice'}
            },
          ),
        ),
      );

      expect(find.text('Hello, Alice!'), findsOneWidget);
    });
  });

  // ── Default Registry completeness ─────────────────────────────────────

  group('createDefaultRegistry (v2)', () {
    test('contains all built-in types including form + gesture', () {
      final registry = createDefaultRegistry();
      for (final type in [
        'text', 'column', 'row', 'padding', 'sizedbox', 'container',
        'scroll', 'image', 'button', 'icon', 'card', 'list', 'divider',
        'text_input', 'checkbox', 'switch', 'dropdown', 'gesture',
      ]) {
        expect(registry.has(type), isTrue,
            reason: 'Missing builder for "$type"');
      }
    });
  });

  // ── Form builders ─────────────────────────────────────────────────────

  group('Form builders', () {
    testWidgets('checkbox toggles on tap', (tester) async {
      String? lastField;
      bool? lastValue;

      final actions = ActionHandler();
      actions.register('input_changed', (action, payload) {
        lastField = payload['field'] as String?;
        lastValue = payload['value'] as bool?;
      });

      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'checkbox',
          'props': {
            'checked': false,
            'label': 'Accept terms',
            'field': 'terms_accepted',
          },
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(json: jsonStr, actionHandler: actions),
        ),
      );

      expect(find.text('Accept terms'), findsOneWidget);

      await tester.tap(find.text('Accept terms'));
      await tester.pump();

      expect(lastField, 'terms_accepted');
      expect(lastValue, true);
    });

    testWidgets('switch toggles on tap', (tester) async {
      bool? toggled;

      final actions = ActionHandler();
      actions.register('input_changed', (action, payload) {
        toggled = payload['value'] as bool?;
      });

      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'switch',
          'props': {
            'value': false,
            'label': 'Notifications',
            'field': 'notifications',
          },
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(json: jsonStr, actionHandler: actions),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      await tester.tap(find.text('Notifications'));
      await tester.pump();

      expect(toggled, true);
    });
  });
}
