import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _testbed(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(400, 800)),
      child: child,
    ),
  );
}

Widget _sdui(
  Map<String, dynamic> body, {
  SduiErrorCallback? onError,
  SduiErrorWidgetBuilder? errorWidgetBuilder,
  ComponentRegistry? registry,
  Map<String, dynamic> data = const {},
}) {
  return _testbed(SduiWidget(
    json: jsonEncode({'screen': 'test', 'body': body}),
    onError: onError,
    errorWidgetBuilder: errorWidgetBuilder,
    registry: registry,
    data: data,
  ));
}

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // INFINITE / UNBOUNDED LAYOUT EDGE CASES
  // ═══════════════════════════════════════════════════════════════════════════

  group('infinite layout edge cases', () {
    testWidgets('column inside column (nested unbounded height)', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {
            'type': 'column',
            'children': [
              {'type': 'text', 'props': {'content': 'Inner'}},
            ],
          },
          {'type': 'text', 'props': {'content': 'Outer'}},
        ],
      }));
      expect(find.text('Inner'), findsOneWidget);
      expect(find.text('Outer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('triple-nested columns render safely', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {
            'type': 'column',
            'children': [
              {
                'type': 'column',
                'children': [
                  {'type': 'text', 'props': {'content': 'Deep'}},
                ],
              },
            ],
          },
        ],
      }));
      expect(find.text('Deep'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('row inside row (nested unbounded width)', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'row',
        'children': [
          {
            'type': 'row',
            'children': [
              {'type': 'text', 'props': {'content': 'Inner'}},
            ],
          },
          {'type': 'text', 'props': {'content': 'Outer'}},
        ],
      }));
      expect(find.text('Inner'), findsOneWidget);
      expect(find.text('Outer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('column inside scroll (classic infinite height pattern)', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'scroll',
        'children': [
          {
            'type': 'column',
            'props': {'spacing': 8},
            'children': [
              {'type': 'text', 'props': {'content': 'A'}},
              {'type': 'text', 'props': {'content': 'B'}},
              {'type': 'text', 'props': {'content': 'C'}},
            ],
          },
        ],
      }));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('list inside column without explicit height uses shrinkWrap', (tester) async {
      // A vertical list in a column with no height — should not crash due
      // to shrinkWrap: true + NeverScrollableScrollPhysics in listBuilder.
      await tester.pumpWidget(_sdui({
        'type': 'scroll',
        'children': [
          {
            'type': 'column',
            'children': [
              {'type': 'text', 'props': {'content': 'Title'}},
              {
                'type': 'list',
                'children': [
                  {'type': 'text', 'props': {'content': 'Item 1'}},
                  {'type': 'text', 'props': {'content': 'Item 2'}},
                ],
              },
            ],
          },
        ],
      }));
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('horizontal list in column with explicit height is safe', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {
            'type': 'list',
            'props': {'direction': 'horizontal', 'height': 80},
            'children': [
              {'type': 'text', 'props': {'content': 'H1'}},
              {'type': 'text', 'props': {'content': 'H2'}},
            ],
          },
        ],
      }));
      expect(find.text('H1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scroll inside scroll (nested scrollable)', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'scroll',
        'children': [
          {
            'type': 'column',
            'children': [
              {'type': 'text', 'props': {'content': 'Top'}},
              {
                'type': 'scroll',
                'children': [
                  {'type': 'text', 'props': {'content': 'Nested'}},
                ],
              },
            ],
          },
        ],
      }));
      // Should not assert — nested scroll with min-size column is safe.
      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Nested'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expanded inside column without bounded parent works', (tester) async {
      // A single expanded child in a column that is the root body.
      // The body is laid out with the screen constraints (bounded), so
      // Expanded is valid here.
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {
            'type': 'expanded',
            'children': [
              {'type': 'text', 'props': {'content': 'Fill'}},
            ],
          },
        ],
      }));
      expect(find.text('Fill'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('row with all flex children and spacing', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'row',
        'props': {'spacing': 4},
        'children': [
          {'type': 'text', 'props': {'content': 'A', 'flex': 1}},
          {'type': 'text', 'props': {'content': 'B', 'flex': 1}},
          {'type': 'text', 'props': {'content': 'C', 'flex': 1}},
        ],
      }));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('aspect_ratio in a column does not assert', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {
            'type': 'aspect_ratio',
            'props': {'ratio': 16 / 9},
            'children': [
              {'type': 'container', 'props': {'background': '#000000'}},
            ],
          },
          {'type': 'text', 'props': {'content': 'Below'}},
        ],
      }));
      expect(find.text('Below'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPTY / MISSING DATA EDGE CASES
  // ═══════════════════════════════════════════════════════════════════════════

  group('empty / missing data', () {
    testWidgets('column with zero children renders empty', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [],
      }));
      expect(find.byType(Column), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('row with zero children renders empty', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'row',
        'children': [],
      }));
      expect(find.byType(Row), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('list with zero children renders', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'scroll',
        'children': [
          {
            'type': 'list',
            'children': [],
          },
        ],
      }));
      expect(tester.takeException(), isNull);
    });

    testWidgets('text with missing content prop shows empty', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text',
        'props': {},
      }));
      expect(find.byType(Text), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('button with missing label shows empty string', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'button',
        'props': {},
      }));
      // Should not crash.
      expect(tester.takeException(), isNull);
    });

    testWidgets('container with no props renders', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'container',
        'props': {},
        'children': [
          {'type': 'text', 'props': {'content': 'Bare'}},
        ],
      }));
      expect(find.text('Bare'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('padding with no props renders with zero padding', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'padding',
        'props': {},
        'children': [
          {'type': 'text', 'props': {'content': 'No pad'}},
        ],
      }));
      expect(find.text('No pad'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('node with missing children key renders', (tester) async {
      // A node type that expects children but none are provided.
      await tester.pumpWidget(_sdui({
        'type': 'column',
        // no 'children' key at all
      }));
      expect(find.byType(Column), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('card with no children renders', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'card',
        'props': {'background': '#FFFFFF'},
        'children': [],
      }));
      expect(tester.takeException(), isNull);
    });

    testWidgets('dropdown with empty options list', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'dropdown',
        'props': {
          'placeholder': 'No options',
          'field': 'test',
          'options': [],
        },
      }));
      expect(find.text('No options'), findsOneWidget);
      await tester.tap(find.text('No options'));
      await tester.pump();
      // Expanded but no options — should not crash.
      expect(tester.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ERROR BOUNDARY / RESILIENCE
  // ═══════════════════════════════════════════════════════════════════════════

  group('error boundary resilience', () {
    testWidgets('unknown component type renders fallback', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {'type': 'totally_unknown_widget', 'props': {}},
          {'type': 'text', 'props': {'content': 'After unknown'}},
        ],
      }));
      // The unknown type should use the registry's fallback builder.
      // Sibling should still render.
      expect(find.text('After unknown'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('broken builder does not crash siblings', (tester) async {
      final errors = <SduiError>[];
      final registry = createDefaultRegistry();
      registry.register('explosive', (n, c) => throw StateError('BOOM'));

      await tester.pumpWidget(_sdui(
        {
          'type': 'column',
          'children': [
            {'type': 'explosive', 'props': {}},
            {'type': 'text', 'props': {'content': 'Survived'}},
            {'type': 'explosive', 'props': {}},
            {'type': 'text', 'props': {'content': 'Also survived'}},
          ],
        },
        registry: registry,
        onError: errors.add,
      ));
      expect(find.text('Survived'), findsOneWidget);
      expect(find.text('Also survived'), findsOneWidget);
      expect(errors.length, 2);
      expect(errors.every((e) => e.type == SduiErrorType.render), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('errorWidgetBuilder provides node type info', (tester) async {
      final registry = createDefaultRegistry();
      registry.register('bad', (n, c) => throw Exception('test'));

      await tester.pumpWidget(_sdui(
        {
          'type': 'bad',
          'props': {},
        },
        registry: registry,
        errorWidgetBuilder: (e) => Text('FAIL:${e.nodeType}:${e.type.name}'),
      ));
      expect(find.text('FAIL:bad:render'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('invalid visible_if expression does not crash', (tester) async {
      final errors = <SduiError>[];
      await tester.pumpWidget(_sdui(
        {
          'type': 'text',
          'props': {
            'content': 'Should be hidden',
            'visible_if': 'some.deeply.nested.missing.path',
          },
        },
        onError: errors.add,
        data: {},
      ));
      // Missing path evaluates falsy → node hidden, no crash.
      expect(find.text('Should be hidden'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('template with missing data path leaves placeholder', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'text',
          'props': {'content': 'Hello {{missing.path}}'},
        },
        data: {},
      ));
      // Unresolved template should not crash — shows the raw placeholder.
      expect(find.textContaining('missing.path'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('deeply nested error is caught and siblings render', (tester) async {
      final errors = <SduiError>[];
      final registry = createDefaultRegistry();
      registry.register('fail', (n, c) => throw Exception('deep'));

      await tester.pumpWidget(_sdui(
        {
          'type': 'scroll',
          'children': [
            {
              'type': 'column',
              'children': [
                {
                  'type': 'padding',
                  'props': {'all': 8},
                  'children': [
                    {'type': 'fail', 'props': {}},
                  ],
                },
                {'type': 'text', 'props': {'content': 'Safe sibling'}},
              ],
            },
          ],
        },
        registry: registry,
        onError: errors.add,
      ));
      expect(find.text('Safe sibling'), findsOneWidget);
      expect(errors.length, 1);
      expect(tester.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE-RELATED EDGE CASES
  // ═══════════════════════════════════════════════════════════════════════════

  group('state edge cases', () {
    testWidgets('SduiWidget rebuilds when json changes', (tester) async {
      String makeJson(String name) => jsonEncode({
            'screen': 'test',
            'body': {
              'type': 'text',
              'props': {'content': 'Hello $name'},
            },
          });

      // Start with "Alice".
      await tester.pumpWidget(_testbed(
        _RebuildTester(initialJson: makeJson('Alice')),
      ));
      expect(find.text('Hello Alice'), findsOneWidget);

      // Tap to switch to "Bob".
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(find.text('Hello Bob'), findsOneWidget);
    });

    testWidgets('SduiWidget rebuilds when data changes', (tester) async {
      final json = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'text',
          'props': {'content': 'Count: {{count}}'},
        },
      });

      await tester.pumpWidget(_testbed(
        _DataRebuildTester(json: json),
      ));
      expect(find.text('Count: 0'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(find.text('Count: 2'), findsOneWidget);
    });

    testWidgets('SduiDataProvider update triggers rebuild', (tester) async {
      final json = jsonEncode({
        'screen': 'test',
        'body': {
          'type': 'text',
          'props': {'content': 'Name: {{name}}'},
        },
      });

      await tester.pumpWidget(_testbed(
        _ProviderRebuildTester(json: json),
      ));
      expect(find.text('Name: Alpha'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(find.text('Name: Beta'), findsOneWidget);
    });

    testWidgets('form checkbox state survives parent rebuild', (tester) async {
      // Toggle checkbox, then trigger a parent rebuild — internal state persists.
      await tester.pumpWidget(_testbed(
        _FormStateTester(),
      ));

      // Initially unchecked.
      expect(find.text('✓'), findsNothing);

      // Toggle checkbox.
      await tester.tap(find.text('Accept'));
      await tester.pump();
      expect(find.text('✓'), findsOneWidget);

      // Trigger parent rebuild (counter text changes, but checkbox state persists).
      await tester.tap(find.text('Rebuild'));
      await tester.pump();
      expect(find.text('✓'), findsOneWidget);
      expect(find.text('Rebuilds: 1'), findsOneWidget);
    });

    testWidgets('action handler receives latest closure context', (tester) async {
      // Verifies that repeated taps all go through the same handler.
      int tapCount = 0;
      final actions = ActionHandler();
      actions.register('count_tap', (_, a, p) => tapCount++);

      await tester.pumpWidget(_testbed(SduiWidget(
        json: jsonEncode({
          'screen': 'test',
          'body': {
            'type': 'button',
            'props': {'label': 'Count'},
            'action': {'type': 'count_tap', 'payload': {}},
          },
        }),
        actionHandler: actions,
      )));

      await tester.tap(find.text('Count'));
      await tester.pump();
      expect(tapCount, 1);

      await tester.tap(find.text('Count'));
      await tester.pump();
      expect(tapCount, 2);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPLEX REAL-WORLD LAYOUT PATTERNS
  // ═══════════════════════════════════════════════════════════════════════════

  group('real-world layout patterns', () {
    testWidgets('chat bubble layout: row with flex text + fixed icon', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'row',
        'props': {'spacing': 8},
        'children': [
          {'type': 'text', 'props': {'content': 'Hello there', 'flex': 1}},
          {'type': 'icon', 'props': {'name': 'star', 'size': 16}},
        ],
      }));
      expect(find.text('Hello there'), findsOneWidget);
      expect(find.text('⭐'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('product card: image on top, details below', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'card',
        'props': {'corner_radius': 12, 'background': '#FFFFFF'},
        'children': [
          {
            'type': 'column',
            'children': [
              {
                'type': 'container',
                'props': {'height': 150, 'background': '#EEEEEE'},
              },
              {
                'type': 'padding',
                'props': {'all': 12},
                'children': [
                  {
                    'type': 'column',
                    'props': {'spacing': 4},
                    'children': [
                      {'type': 'text', 'props': {'content': 'Product Name', 'style': 'subheading'}},
                      {'type': 'text', 'props': {'content': '\$29.99', 'style': 'body'}},
                    ],
                  },
                ],
              },
            ],
          },
        ],
      }));
      expect(find.text('Product Name'), findsOneWidget);
      expect(find.text('\$29.99'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('full settings page with form widgets in scroll', (tester) async {
      await tester.pumpWidget(_sdui({
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
                  {'type': 'text', 'props': {'content': 'Settings', 'style': 'heading'}},
                  {'type': 'divider', 'props': {}},
                  {'type': 'switch', 'props': {'label': 'Notifications', 'field': 'notif', 'value': true}},
                  {'type': 'switch', 'props': {'label': 'Dark Mode', 'field': 'dark', 'value': false}},
                  {'type': 'divider', 'props': {}},
                  {
                    'type': 'dropdown',
                    'props': {
                      'placeholder': 'Language',
                      'field': 'lang',
                      'options': [
                        {'label': 'English', 'value': 'en'},
                        {'label': 'Hindi', 'value': 'hi'},
                      ],
                    },
                  },
                  {'type': 'divider', 'props': {}},
                  {
                    'type': 'text_input',
                    'props': {'placeholder': 'Display name', 'field': 'name'},
                  },
                  {
                    'type': 'button',
                    'props': {'label': 'Save', 'variant': 'primary'},
                    'action': {'type': 'api_call', 'payload': {'endpoint': '/save'}},
                  },
                ],
              },
            ],
          },
        ],
      }));
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.byType(EditableText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Test helper widgets for state tests
// ─────────────────────────────────────────────────────────────────────────────

/// Simulates a parent that swaps the JSON string on tap.
class _RebuildTester extends StatefulWidget {
  final String initialJson;
  const _RebuildTester({required this.initialJson});

  @override
  State<_RebuildTester> createState() => _RebuildTesterState();
}

class _RebuildTesterState extends State<_RebuildTester> {
  late String _json;

  @override
  void initState() {
    super.initState();
    _json = widget.initialJson;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _json = jsonEncode({
          'screen': 'test',
          'body': {
            'type': 'text',
            'props': {'content': 'Hello Bob'},
          },
        });
      }),
      child: SduiWidget(json: _json),
    );
  }
}

/// Simulates a parent that updates the data map on tap.
class _DataRebuildTester extends StatefulWidget {
  final String json;
  const _DataRebuildTester({required this.json});

  @override
  State<_DataRebuildTester> createState() => _DataRebuildTesterState();
}

class _DataRebuildTesterState extends State<_DataRebuildTester> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _count++),
      child: SduiWidget(json: widget.json, data: {'count': _count}),
    );
  }
}

/// Simulates an ancestor SduiDataProvider that changes its data.
class _ProviderRebuildTester extends StatefulWidget {
  final String json;
  const _ProviderRebuildTester({required this.json});

  @override
  State<_ProviderRebuildTester> createState() => _ProviderRebuildTesterState();
}

class _ProviderRebuildTesterState extends State<_ProviderRebuildTester> {
  String _name = 'Alpha';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _name = 'Beta'),
      child: SduiDataProvider(
        data: {'name': _name},
        child: SduiWidget(json: widget.json),
      ),
    );
  }
}

/// Tests that form widget internal state survives parent rebuilds.
class _FormStateTester extends StatefulWidget {
  @override
  State<_FormStateTester> createState() => _FormStateTesterState();
}

class _FormStateTesterState extends State<_FormStateTester> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SduiWidget(
          json: jsonEncode({
            'screen': 'test',
            'body': {
              'type': 'checkbox',
              'props': {'checked': false, 'label': 'Accept', 'field': 'agree'},
            },
          }),
        ),
        GestureDetector(
          onTap: () => setState(() => _rebuilds++),
          child: Text('Rebuild'),
        ),
        Text('Rebuilds: $_rebuilds'),
      ],
    );
  }
}
