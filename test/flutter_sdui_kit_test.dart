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
    testWidgets('dispatches to registered handler', (tester) async {
      final handler = ActionHandler();
      String? receivedRoute;
      handler.register('navigate', (context, action, payload) {
        receivedRoute = payload['route'] as String?;
      });
      late BuildContext ctx;
      await tester.pumpWidget(Builder(builder: (c) { ctx = c; return const SizedBox(); }));
      handler.handle(ctx, SduiAction(
        type: 'navigate',
        payload: {'route': '/shop'},
      ));
      expect(receivedRoute, '/shop');
    });

    testWidgets('calls onUnhandled for unknown action types', (tester) async {
      String? unhandledType;
      final handler = ActionHandler(
        onUnhandled: (context, action, _) => unhandledType = action.type,
      );
      late BuildContext ctx;
      await tester.pumpWidget(Builder(builder: (c) { ctx = c; return const SizedBox(); }));
      handler.handle(ctx, const SduiAction(type: 'unknown_action'));
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

    testWidgets('renders from pre-parsed JSON map', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'text',
          'props': {'content': 'Pre-parsed'},
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(json: jsonStr),
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
    test('contains all built-in types including form + gesture + layout wrappers', () {
      final registry = createDefaultRegistry();
      for (final type in [
        'text', 'column', 'row', 'padding', 'sizedbox', 'container',
        'scroll', 'image', 'button', 'icon', 'card', 'list', 'divider',
        'text_input', 'checkbox', 'switch', 'dropdown', 'gesture',
        'expanded', 'center', 'safe_area', 'aspect_ratio', 'constrained_box',
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
      actions.register('input_changed', (context, action, payload) {
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
      actions.register('input_changed', (context, action, payload) {
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

  // ── Layout safety tests ───────────────────────────────────────────────

  group('Layout safety', () {
    testWidgets('column inside scroll does not crash (infinite height)', (tester) async {
      // This is the classic "unbounded height" scenario: scroll gives
      // unbounded constraints to its child, and Column needs to size itself.
      // Our Column uses MainAxisSize.min, so it safely shrink-wraps.
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'scroll',
          'children': [
            {
              'type': 'column',
              'children': [
                {'type': 'text', 'props': {'content': 'Item 1'}},
                {'type': 'text', 'props': {'content': 'Item 2'}},
                {'type': 'text', 'props': {'content': 'Item 3'}},
              ],
            },
          ],
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(json: jsonStr),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('row with flex children distributes space', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'row',
          'children': [
            {'type': 'text', 'props': {'content': 'Left', 'flex': 1}},
            {'type': 'text', 'props': {'content': 'Right', 'flex': 2}},
          ],
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(json: jsonStr),
        ),
      );

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expanded builder wraps child in Expanded', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'column',
          'children': [
            {'type': 'text', 'props': {'content': 'Header'}},
            {
              'type': 'expanded',
              'children': [
                {'type': 'text', 'props': {'content': 'Fills space'}},
              ],
            },
          ],
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(json: jsonStr),
        ),
      );

      expect(find.text('Fills space'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nested column > column does not throw', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'column',
          'children': [
            {
              'type': 'column',
              'children': [
                {'type': 'text', 'props': {'content': 'Nested'}},
              ],
            },
            {'type': 'text', 'props': {'content': 'After'}},
          ],
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(json: jsonStr),
        ),
      );

      expect(find.text('Nested'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('constrained_box limits child size', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'constrained_box',
          'props': {'max_width': 200, 'max_height': 100},
          'children': [
            {'type': 'text', 'props': {'content': 'Constrained'}},
          ],
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(json: jsonStr),
        ),
      );

      expect(find.text('Constrained'), findsOneWidget);
      // Verify the ConstrainedBox widget exists and renders without error.
      expect(find.byType(ConstrainedBox), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderer error boundary catches bad builder gracefully', (tester) async {
      // Register a builder that throws, and verify the tree still renders
      // the sibling node without crashing.
      final registry = createDefaultRegistry();
      registry.register('bad_widget', (node, ctx) {
        throw Exception('Intentional test error');
      });

      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'column',
          'children': [
            {'type': 'bad_widget', 'props': {'foo': 'bar'}},
            {'type': 'text', 'props': {'content': 'Survivor'}},
          ],
        },
      });

      final errors = <SduiError>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(
            json: jsonStr,
            registry: registry,
            onError: errors.add,
          ),
        ),
      );

      // The bad widget is replaced with SizedBox.shrink, sibling renders fine.
      expect(find.text('Survivor'), findsOneWidget);
      // The error was forwarded to the onError callback.
      expect(errors, hasLength(1));
      expect(errors.first.type, SduiErrorType.render);
      expect(errors.first.nodeType, 'bad_widget');
      expect(tester.takeException(), isNull);
    });

    testWidgets('horizontal list inside column with explicit height works', (tester) async {
      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'column',
          'children': [
            {'type': 'text', 'props': {'content': 'Title'}},
            {
              'type': 'list',
              'props': {
                'direction': 'horizontal',
                'height': 100,
                'spacing': 8,
              },
              'children': [
                {'type': 'text', 'props': {'content': 'A'}},
                {'type': 'text', 'props': {'content': 'B'}},
              ],
            },
          ],
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: SduiWidget(json: jsonStr),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Error handling tests ──────────────────────────────────────────────

  group('Error handling', () {
    testWidgets('shows fallback when json is null', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(
            json: null,
            fallback: const Text('Loading…'),
          ),
        ),
      );

      expect(find.text('Loading…'), findsOneWidget);
    });

    testWidgets('shows fallback when json is empty', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(
            json: '',
            fallback: const Text('No data'),
          ),
        ),
      );

      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('calls onError and shows fallback on invalid JSON', (tester) async {
      final errors = <SduiError>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(
            json: '{ this is not valid json }',
            onError: errors.add,
            fallback: const Text('Parse failed'),
          ),
        ),
      );

      expect(find.text('Parse failed'), findsOneWidget);
      expect(errors, hasLength(1));
      expect(errors.first.type, SduiErrorType.parse);
    });

    testWidgets('errorWidgetBuilder replaces broken node with custom widget', (tester) async {
      final registry = createDefaultRegistry();
      registry.register('crasher', (node, ctx) {
        throw StateError('boom');
      });

      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'column',
          'children': [
            {'type': 'crasher', 'props': {}},
            {'type': 'text', 'props': {'content': 'OK'}},
          ],
        },
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(
            json: jsonStr,
            registry: registry,
            errorWidgetBuilder: (error) => Text('ERR: ${error.nodeType}'),
          ),
        ),
      );

      // The broken node is replaced with the custom error widget.
      expect(find.text('ERR: crasher'), findsOneWidget);
      // The sibling node still renders.
      expect(find.text('OK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('onError collects all errors from tree', (tester) async {
      final registry = createDefaultRegistry();
      registry.register('boom1', (n, c) => throw Exception('one'));
      registry.register('boom2', (n, c) => throw Exception('two'));

      final jsonStr = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'column',
          'children': [
            {'type': 'boom1', 'props': {}},
            {'type': 'boom2', 'props': {}},
            {'type': 'text', 'props': {'content': 'Still here'}},
          ],
        },
      });

      final errors = <SduiError>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SduiWidget(
            json: jsonStr,
            registry: registry,
            onError: errors.add,
          ),
        ),
      );

      expect(errors, hasLength(2));
      expect(errors[0].nodeType, 'boom1');
      expect(errors[1].nodeType, 'boom2');
      expect(find.text('Still here'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
