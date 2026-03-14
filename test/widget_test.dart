import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] in Directionality + MediaQuery for test pumping.
Widget _testbed(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: child,
    ),
  );
}

/// Builds a minimal SduiWidget from a body node map.
Widget _sdui(
  Map<String, dynamic> body, {
  ActionHandler? actionHandler,
  Map<String, dynamic> data = const {},
  ComponentRegistry? registry,
  SduiErrorCallback? onError,
  SduiErrorWidgetBuilder? errorWidgetBuilder,
  Widget fallback = const SizedBox.shrink(),
  Map<String, dynamic>? theme,
}) {
  final screen = <String, dynamic>{
    'screen': 'test',
    'body': body,
  };
  if (theme != null) screen['theme'] = theme;

  return _testbed(SduiWidget(
    json: jsonEncode(screen),
    actionHandler: actionHandler,
    data: data,
    registry: registry,
    onError: onError,
    errorWidgetBuilder: errorWidgetBuilder,
    fallback: fallback,
  ));
}

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('text builder', () {
    testWidgets('renders content string', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text',
        'props': {'content': 'Hello World'},
      }));
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('applies heading style', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text',
        'props': {'content': 'Title', 'style': 'heading'},
      }));
      final text = tester.widget<Text>(find.text('Title'));
      expect(text.style?.fontSize, 24);
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('applies subheading style', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text',
        'props': {'content': 'Sub', 'style': 'subheading'},
      }));
      final text = tester.widget<Text>(find.text('Sub'));
      expect(text.style?.fontSize, 18);
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('applies caption style', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text',
        'props': {'content': 'Small', 'style': 'caption'},
      }));
      final text = tester.widget<Text>(find.text('Small'));
      expect(text.style?.fontSize, 12);
    });

    testWidgets('applies hex color override', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text',
        'props': {'content': 'Red', 'color': '#FF0000'},
      }));
      final text = tester.widget<Text>(find.text('Red'));
      expect(text.style?.color, const Color(0xFFFF0000));
    });

    testWidgets('respects max_lines', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text',
        'props': {'content': 'Truncated', 'max_lines': 2},
      }));
      final text = tester.widget<Text>(find.text('Truncated'));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('applies text_align center', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text',
        'props': {'content': 'Centered', 'text_align': 'center'},
      }));
      final text = tester.widget<Text>(find.text('Centered'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('renders empty string when content is missing', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text',
        'props': {},
      }));
      // Should render an empty Text widget without crashing.
      expect(find.byType(Text), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // COLUMN BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('column builder', () {
    testWidgets('renders children vertically', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {'type': 'text', 'props': {'content': 'A'}},
          {'type': 'text', 'props': {'content': 'B'}},
        ],
      }));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('inserts spacing between children', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'props': {'spacing': 16},
        'children': [
          {'type': 'text', 'props': {'content': 'A'}},
          {'type': 'text', 'props': {'content': 'B'}},
        ],
      }));
      // Spacing = SizedBox between children
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacers = sizedBoxes.where((s) => s.height == 16);
      expect(spacers.length, greaterThanOrEqualTo(1));
    });

    testWidgets('wraps in scroll when scroll prop is true', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'props': {'scroll': true},
        'children': [
          {'type': 'text', 'props': {'content': 'Scrollable'}},
        ],
      }));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('applies cross_alignment stretch', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'props': {'cross_alignment': 'stretch'},
        'children': [
          {'type': 'text', 'props': {'content': 'Stretched'}},
        ],
      }));
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ROW BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('row builder', () {
    testWidgets('renders children horizontally', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'row',
        'children': [
          {'type': 'text', 'props': {'content': 'L'}},
          {'type': 'text', 'props': {'content': 'R'}},
        ],
      }));
      expect(find.text('L'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('wraps children in Expanded when flex is set', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'row',
        'children': [
          {'type': 'text', 'props': {'content': 'A', 'flex': 1}},
          {'type': 'text', 'props': {'content': 'B', 'flex': 2}},
        ],
      }));
      final expandeds = tester.widgetList<Expanded>(find.byType(Expanded));
      expect(expandeds.length, 2);
      expect(expandeds.first.flex, 1);
      expect(expandeds.last.flex, 2);
    });

    testWidgets('uses Flexible when flex_fit is loose', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'row',
        'children': [
          {
            'type': 'text',
            'props': {'content': 'Loose', 'flex': 1, 'flex_fit': 'loose'},
          },
        ],
      }));
      expect(find.byType(Flexible), findsOneWidget);
      // Flexible but NOT Expanded (Expanded is a subclass of Flexible)
      expect(find.byType(Expanded), findsNothing);
    });

    testWidgets('wraps in horizontal scroll when scroll prop is true', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'row',
        'props': {'scroll': true},
        'children': [
          {'type': 'text', 'props': {'content': 'Scrollable row'}},
        ],
      }));
      final scroll = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView));
      expect(scroll.scrollDirection, Axis.horizontal);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // PADDING BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('padding builder', () {
    testWidgets('applies uniform padding from all prop', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'padding',
        'props': {'all': 20},
        'children': [
          {'type': 'text', 'props': {'content': 'Padded'}},
        ],
      }));
      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.all(20));
    });

    testWidgets('applies symmetric padding', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'padding',
        'props': {'horizontal': 10, 'vertical': 5},
        'children': [
          {'type': 'text', 'props': {'content': 'Sym'}},
        ],
      }));
      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(
        padding.padding,
        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      );
    });

    testWidgets('wraps multiple children in Column', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'padding',
        'props': {'all': 8},
        'children': [
          {'type': 'text', 'props': {'content': 'A'}},
          {'type': 'text', 'props': {'content': 'B'}},
        ],
      }));
      // The Padding child should be a Column when there are 2+ children.
      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.child, isA<Column>());
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SIZEDBOX BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('sizedbox builder', () {
    testWidgets('renders with explicit width and height', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'sizedbox',
        'props': {'width': 100, 'height': 50},
      }));
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final box = sizedBoxes.firstWhere(
        (s) => s.width == 100 && s.height == 50,
      );
      expect(box, isNotNull);
    });

    testWidgets('renders child inside sizedbox', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'sizedbox',
        'props': {'width': 200, 'height': 100},
        'children': [
          {'type': 'text', 'props': {'content': 'Inside'}},
        ],
      }));
      expect(find.text('Inside'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTAINER BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('container builder', () {
    testWidgets('renders with background color', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'container',
        'props': {'background': '#FF0000'},
        'children': [
          {'type': 'text', 'props': {'content': 'Red box'}},
        ],
      }));
      expect(find.text('Red box'), findsOneWidget);
      final container = tester.widgetList<Container>(find.byType(Container))
          .firstWhere((c) => c.decoration != null);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFFF0000));
    });

    testWidgets('applies corner radius', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'container',
        'props': {'corner_radius': 12, 'background': '#0000FF'},
        'children': [
          {'type': 'text', 'props': {'content': 'Rounded'}},
        ],
      }));
      final container = tester.widgetList<Container>(find.byType(Container))
          .firstWhere((c) => c.decoration != null);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('applies width and height', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'container',
        'props': {'width': 150, 'height': 75},
        'children': [
          {'type': 'text', 'props': {'content': 'Sized'}},
        ],
      }));
      expect(find.text('Sized'), findsOneWidget);
      // Verify a Container with matching constraints exists.
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.any((c) => c.constraints != null), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('button builder', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'button',
        'props': {'label': 'Click Me'},
      }));
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('fires action on tap', (tester) async {
      String? tappedRoute;
      final actions = ActionHandler();
      actions.register('navigate', (context, action, payload) {
        tappedRoute = payload['route'] as String?;
      });

      await tester.pumpWidget(_sdui(
        {
          'type': 'button',
          'props': {'label': 'Go'},
          'action': {
            'type': 'navigate',
            'payload': {'route': '/home'},
          },
        },
        actionHandler: actions,
      ));

      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(tappedRoute, '/home');
    });

    testWidgets('primary variant uses theme color', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'button',
          'props': {'label': 'Primary', 'variant': 'primary'},
        },
        theme: {'primary': '#00FF00'},
      ));
      expect(find.text('Primary'), findsOneWidget);
      // Verify it rendered a Container with the theme primary color.
      final containers = tester.widgetList<Container>(find.byType(Container));
      final btnContainer = containers.where((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration) return dec.color == const Color(0xFF00FF00);
        return false;
      });
      expect(btnContainer, isNotEmpty);
    });

    testWidgets('outline variant has border and transparent bg', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'button',
        'props': {'label': 'Outline', 'variant': 'outline'},
      }));
      expect(find.text('Outline'), findsOneWidget);
      final containers = tester.widgetList<Container>(find.byType(Container));
      final btnContainer = containers.where((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration) return dec.border != null;
        return false;
      });
      expect(btnContainer, isNotEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('card builder', () {
    testWidgets('renders children inside card', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'card',
        'props': {'corner_radius': 8, 'background': '#FFFFFF'},
        'children': [
          {'type': 'text', 'props': {'content': 'Card content'}},
        ],
      }));
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('card with elevation has box shadow', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'card',
        'props': {'elevation': 4, 'background': '#FFFFFF'},
        'children': [
          {'type': 'text', 'props': {'content': 'Elevated'}},
        ],
      }));
      final containers = tester.widgetList<Container>(find.byType(Container));
      final elevated = containers.where((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration) {
          return dec.boxShadow != null && dec.boxShadow!.isNotEmpty;
        }
        return false;
      });
      expect(elevated, isNotEmpty);
    });

    testWidgets('card fires action on tap', skip: true, (tester) async {
      String? tapped;
      final actions = ActionHandler();
      actions.register('navigate', (context, action, payload) {
        tapped = payload['route'] as String?;
      });

      await tester.pumpWidget(_sdui(
        {
          'type': 'card',
          'props': {'background': '#FFFFFF'},
          'action': {
            'type': 'navigate',
            'payload': {'route': '/detail'},
          },
          'children': [
            {'type': 'text', 'props': {'content': 'Tap card'}},
          ],
        },
        actionHandler: actions,
      ));

      await tester.tap(find.text('Tap card'));
      await tester.pump();
      expect(tapped, '/detail');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // DIVIDER BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('divider builder', () {
    testWidgets('renders with default thickness', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {'type': 'text', 'props': {'content': 'Above'}},
          {'type': 'divider', 'props': {}},
          {'type': 'text', 'props': {'content': 'Below'}},
        ],
      }));
      expect(find.text('Above'), findsOneWidget);
      expect(find.text('Below'), findsOneWidget);
    });

    testWidgets('applies custom color and thickness', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'divider',
        'props': {'color': '#FF0000', 'thickness': 3},
      }));
      final containers = tester.widgetList<Container>(find.byType(Container));
      final divider = containers.where((c) => c.color == const Color(0xFFFF0000));
      expect(divider, isNotEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ICON BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('icon builder', () {
    testWidgets('renders star icon fallback', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'icon',
        'props': {'name': 'star', 'size': 32},
      }));
      expect(find.text('⭐'), findsOneWidget);
    });

    testWidgets('renders home icon', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'icon',
        'props': {'name': 'home'},
      }));
      expect(find.text('🏠'), findsOneWidget);
    });

    testWidgets('renders bullet for unknown icon', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'icon',
        'props': {'name': 'nonexistent_icon'},
      }));
      expect(find.text('•'), findsOneWidget);
    });

    testWidgets('applies custom size', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'icon',
        'props': {'name': 'star', 'size': 48},
      }));
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final iconBox = sizedBoxes.where(
        (s) => s.width == 48 && s.height == 48,
      );
      expect(iconBox, isNotEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SCROLL BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('scroll builder', () {
    testWidgets('renders vertical scroll by default', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'scroll',
        'children': [
          {'type': 'text', 'props': {'content': 'Scrollable'}},
        ],
      }));
      final scroll = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView));
      expect(scroll.scrollDirection, Axis.vertical);
    });

    testWidgets('renders horizontal scroll', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'scroll',
        'props': {'direction': 'horizontal'},
        'children': [
          {'type': 'text', 'props': {'content': 'H-scroll'}},
        ],
      }));
      final scroll = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView));
      expect(scroll.scrollDirection, Axis.horizontal);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // LIST BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('list builder', () {
    testWidgets('renders vertical list with shrinkWrap', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'scroll',
        'children': [
          {
            'type': 'list',
            'children': [
              {'type': 'text', 'props': {'content': 'Item 1'}},
              {'type': 'text', 'props': {'content': 'Item 2'}},
            ],
          },
        ],
      }));
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('horizontal list with explicit height renders', (tester) async {
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
      expect(find.text('H2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GESTURE BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('gesture builder', () {
    testWidgets('fires action on tap', (tester) async {
      String? tapped;
      final actions = ActionHandler();
      actions.register('navigate', (context, action, payload) {
        tapped = payload['route'] as String?;
      });

      await tester.pumpWidget(_sdui(
        {
          'type': 'gesture',
          'action': {
            'type': 'navigate',
            'payload': {'route': '/tapped'},
          },
          'children': [
            {'type': 'text', 'props': {'content': 'Tap me'}},
          ],
        },
        actionHandler: actions,
      ));

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      expect(tapped, '/tapped');
    });

    testWidgets('renders with opaque behavior by default', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'gesture',
        'children': [
          {'type': 'text', 'props': {'content': 'Gesture'}},
        ],
      }));
      final gd = tester.widget<GestureDetector>(
        find.byType(GestureDetector).first,
      );
      expect(gd.behavior, HitTestBehavior.opaque);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // CENTER BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('center builder', () {
    testWidgets('wraps child in Center widget', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'center',
        'children': [
          {'type': 'text', 'props': {'content': 'Centered'}},
        ],
      }));
      expect(find.text('Centered'), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ASPECT RATIO BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('aspect_ratio builder', () {
    testWidgets('wraps child in AspectRatio', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'aspect_ratio',
        'props': {'ratio': 16 / 9},
        'children': [
          {'type': 'container', 'props': {'background': '#000000'}},
        ],
      }));
      final ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(ar.aspectRatio, closeTo(16 / 9, 0.01));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTRAINED BOX BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('constrained_box builder', () {
    testWidgets('applies min/max constraints', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'constrained_box',
        'props': {
          'min_width': 50,
          'max_width': 300,
          'min_height': 20,
          'max_height': 200,
        },
        'children': [
          {'type': 'text', 'props': {'content': 'Constrained'}},
        ],
      }));
      final cb = tester.widget<ConstrainedBox>(find.byType(ConstrainedBox));
      expect(cb.constraints.minWidth, 50);
      expect(cb.constraints.maxWidth, 300);
      expect(cb.constraints.minHeight, 20);
      expect(cb.constraints.maxHeight, 200);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SAFE AREA BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('safe_area builder', () {
    testWidgets('wraps child in SafeArea', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'safe_area',
        'children': [
          {'type': 'text', 'props': {'content': 'Safe'}},
        ],
      }));
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.text('Safe'), findsOneWidget);
    });

    testWidgets('respects top/bottom overrides', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'safe_area',
        'props': {'top': false, 'bottom': false},
        'children': [
          {'type': 'text', 'props': {'content': 'No insets'}},
        ],
      }));
      final sa = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(sa.top, false);
      expect(sa.bottom, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // EXPANDED BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('expanded builder', () {
    testWidgets('wraps in Expanded by default', (tester) async {
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
      expect(find.byType(Expanded), findsOneWidget);
      expect(find.text('Fill'), findsOneWidget);
    });

    testWidgets('wraps in Flexible when fit is loose', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {
            'type': 'expanded',
            'props': {'fit': 'loose'},
            'children': [
              {'type': 'text', 'props': {'content': 'Loose'}},
            ],
          },
        ],
      }));
      expect(find.byType(Flexible), findsOneWidget);
      expect(find.byType(Expanded), findsNothing);
    });

    testWidgets('applies custom flex factor via inline flex prop', (tester) async {
      // Use the row's inline flex prop (not expanded type) to avoid double wrap.
      await tester.pumpWidget(_sdui({
        'type': 'row',
        'children': [
          {'type': 'text', 'props': {'content': 'Wide', 'flex': 3}},
          {'type': 'text', 'props': {'content': 'Narrow', 'flex': 1}},
        ],
      }));
      final expandeds = tester.widgetList<Expanded>(find.byType(Expanded));
      expect(expandeds.first.flex, 3);
      expect(expandeds.last.flex, 1);
    });

    testWidgets('expanded builder reads flex from its own props', (tester) async {
      // Test expanded builder in a column (no inline flex conflict).
      await tester.pumpWidget(_sdui({
        'type': 'column',
        'children': [
          {
            'type': 'expanded',
            'props': {'flex': 2},
            'children': [
              {'type': 'text', 'props': {'content': 'Fill'}},
            ],
          },
        ],
      }));
      final expanded = tester.widget<Expanded>(find.byType(Expanded));
      expect(expanded.flex, 2);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // FORM BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('checkbox builder', () {
    testWidgets('renders label and unchecked state', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'checkbox',
        'props': {'checked': false, 'label': 'Agree', 'field': 'agree'},
      }));
      expect(find.text('Agree'), findsOneWidget);
      // Unchecked: no checkmark
      expect(find.text('✓'), findsNothing);
    });

    testWidgets('toggles checked on tap and fires action', (tester) async {
      String? field;
      bool? value;
      final actions = ActionHandler();
      actions.register('input_changed', (_, a, p) {
        field = p['field'] as String?;
        value = p['value'] as bool?;
      });

      await tester.pumpWidget(_sdui(
        {
          'type': 'checkbox',
          'props': {'checked': false, 'label': 'Terms', 'field': 'terms'},
        },
        actionHandler: actions,
      ));

      await tester.tap(find.text('Terms'));
      await tester.pump();
      expect(field, 'terms');
      expect(value, true);
      expect(find.text('✓'), findsOneWidget);
    });

    testWidgets('starts checked and unchecks on tap', (tester) async {
      bool? value;
      final actions = ActionHandler();
      actions.register('input_changed', (_, a, p) {
        value = p['value'] as bool?;
      });

      await tester.pumpWidget(_sdui(
        {
          'type': 'checkbox',
          'props': {'checked': true, 'label': 'On', 'field': 'x'},
        },
        actionHandler: actions,
      ));

      expect(find.text('✓'), findsOneWidget);
      await tester.tap(find.text('On'));
      await tester.pump();
      expect(value, false);
      expect(find.text('✓'), findsNothing);
    });
  });

  group('switch builder', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'switch',
        'props': {'value': false, 'label': 'Darkmode', 'field': 'dm'},
      }));
      expect(find.text('Darkmode'), findsOneWidget);
    });

    testWidgets('toggles on tap and fires action', (tester) async {
      bool? newVal;
      final actions = ActionHandler();
      actions.register('input_changed', (_, a, p) {
        newVal = p['value'] as bool?;
      });

      await tester.pumpWidget(_sdui(
        {
          'type': 'switch',
          'props': {'value': false, 'label': 'Toggle', 'field': 'f'},
        },
        actionHandler: actions,
      ));

      await tester.tap(find.text('Toggle'));
      await tester.pump();
      expect(newVal, true);

      // Tap again to toggle off.
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      expect(newVal, false);
    });
  });

  group('dropdown builder', () {
    testWidgets('shows placeholder when nothing selected', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'dropdown',
        'props': {
          'placeholder': 'Choose',
          'field': 'lang',
          'options': [
            {'label': 'English', 'value': 'en'},
            {'label': 'French', 'value': 'fr'},
          ],
        },
      }));
      expect(find.text('Choose'), findsOneWidget);
    });

    testWidgets('expands and selects an option', (tester) async {
      String? selected;
      final actions = ActionHandler();
      actions.register('input_changed', (_, a, p) {
        selected = p['value'] as String?;
      });

      await tester.pumpWidget(_sdui(
        {
          'type': 'dropdown',
          'props': {
            'placeholder': 'Pick',
            'field': 'lang',
            'options': [
              {'label': 'English', 'value': 'en'},
              {'label': 'Spanish', 'value': 'es'},
            ],
          },
        },
        actionHandler: actions,
      ));

      // Tap to expand.
      await tester.tap(find.text('Pick'));
      await tester.pump();

      // Options should now be visible.
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);

      // Select "Spanish".
      await tester.tap(find.text('Spanish'));
      await tester.pump();

      expect(selected, 'es');
    });
  });

  group('text_input builder', () {
    testWidgets('renders with placeholder', (tester) async {
      await tester.pumpWidget(_sdui({
        'type': 'text_input',
        'props': {
          'placeholder': 'Enter name',
          'field': 'name',
        },
      }));
      // The widget should render without errors (EditableText is internal).
      expect(find.byType(EditableText), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // TEMPLATE RESOLUTION (widget-level)
  // ═══════════════════════════════════════════════════════════════════════════

  group('template resolution', () {
    testWidgets('resolves {{}} placeholders in text', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'text',
          'props': {'content': 'Hi {{user.name}}, you have {{cart.count}} items'},
        },
        data: {
          'user': {'name': 'Bob'},
          'cart': {'count': 5},
        },
      ));
      expect(find.text('Hi Bob, you have 5 items'), findsOneWidget);
    });

    testWidgets('resolves templates in button label', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'button',
          'props': {'label': 'Buy ({{cart.count}})'},
        },
        data: {
          'cart': {'count': 7},
        },
      ));
      expect(find.text('Buy (7)'), findsOneWidget);
    });

    testWidgets('resolves templates in nested props', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'card',
          'props': {'background': '#FFFFFF'},
          'children': [
            {
              'type': 'text',
              'props': {'content': '{{message}}'},
            },
          ],
        },
        data: {'message': 'Dynamic card text'},
      ));
      expect(find.text('Dynamic card text'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // CONDITIONAL VISIBILITY (widget-level)
  // ═══════════════════════════════════════════════════════════════════════════

  group('conditional visibility', () {
    testWidgets('hides node when condition is false', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'column',
          'children': [
            {'type': 'text', 'props': {'content': 'Visible'}},
            {
              'type': 'text',
              'props': {
                'content': 'Hidden',
                'visible_if': 'show',
              },
            },
          ],
        },
        data: {'show': false},
      ));
      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('shows node when condition is true', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'text',
          'props': {
            'content': 'Conditional',
            'visible_if': 'flag',
          },
        },
        data: {'flag': true},
      ));
      expect(find.text('Conditional'), findsOneWidget);
    });

    testWidgets('hides with complex expression', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'text',
          'props': {
            'content': 'Complex',
            'visible_if': 'user.role == admin && user.active',
          },
        },
        data: {
          'user': {'role': 'admin', 'active': false},
        },
      ));
      expect(find.text('Complex'), findsNothing);
    });

    testWidgets('shows with complex expression that evaluates true', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'text',
          'props': {
            'content': 'Admin active',
            'visible_if': 'user.role == admin && user.active',
          },
        },
        data: {
          'user': {'role': 'admin', 'active': true},
        },
      ));
      expect(find.text('Admin active'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTION HANDLING (widget-level)
  // ═══════════════════════════════════════════════════════════════════════════

  group('action handling', () {
    testWidgets('navigate action fires correctly', (tester) async {
      String? route;
      final actions = ActionHandler();
      actions.register('navigate', (_, a, p) => route = p['route'] as String?);

      await tester.pumpWidget(_sdui(
        {
          'type': 'button',
          'props': {'label': 'Nav'},
          'action': {
            'type': 'navigate',
            'payload': {'route': '/settings'},
          },
        },
        actionHandler: actions,
      ));

      await tester.tap(find.text('Nav'));
      await tester.pump();
      expect(route, '/settings');
    });

    testWidgets('api_call action with payload', (tester) async {
      Map<String, dynamic>? receivedPayload;
      final actions = ActionHandler();
      actions.register('api_call', (_, a, p) => receivedPayload = p);

      await tester.pumpWidget(_sdui(
        {
          'type': 'button',
          'props': {'label': 'Call'},
          'action': {
            'type': 'api_call',
            'payload': {'method': 'POST', 'endpoint': '/submit'},
          },
        },
        actionHandler: actions,
      ));

      await tester.tap(find.text('Call'));
      await tester.pump();
      expect(receivedPayload?['method'], 'POST');
      expect(receivedPayload?['endpoint'], '/submit');
    });

    testWidgets('unhandled action calls onUnhandled', (tester) async {
      String? unhandled;
      final actions = ActionHandler(
        onUnhandled: (_, a, p) => unhandled = a.type,
      );

      await tester.pumpWidget(_sdui(
        {
          'type': 'button',
          'props': {'label': 'Unknown'},
          'action': {
            'type': 'unknown_type',
            'payload': {},
          },
        },
        actionHandler: actions,
      ));

      await tester.tap(find.text('Unknown'));
      await tester.pump();
      expect(unhandled, 'unknown_type');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // THEME APPLICATION
  // ═══════════════════════════════════════════════════════════════════════════

  group('theme application', () {
    testWidgets('theme primary color applies to button', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'button',
          'props': {'label': 'Themed', 'variant': 'primary'},
        },
        theme: {'primary': '#FF5722'},
      ));
      expect(find.text('Themed'), findsOneWidget);
      final containers = tester.widgetList<Container>(find.byType(Container));
      final themed = containers.where((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration) return dec.color == const Color(0xFFFF5722);
        return false;
      });
      expect(themed, isNotEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING (widget-level)
  // ═══════════════════════════════════════════════════════════════════════════

  group('error handling (widget)', () {
    testWidgets('fallback shown for null json', (tester) async {
      await tester.pumpWidget(_testbed(
        SduiWidget(json: null, fallback: const Text('Fallback')),
      ));
      expect(find.text('Fallback'), findsOneWidget);
    });

    testWidgets('fallback shown for invalid json', (tester) async {
      final errors = <SduiError>[];
      await tester.pumpWidget(_testbed(
        SduiWidget(
          json: 'not json',
          fallback: const Text('Bad'),
          onError: errors.add,
        ),
      ));
      expect(find.text('Bad'), findsOneWidget);
      expect(errors.single.type, SduiErrorType.parse);
    });

    testWidgets('errorWidgetBuilder replaces broken node', (tester) async {
      final registry = createDefaultRegistry();
      registry.register('broken', (n, c) => throw Exception('oops'));

      await tester.pumpWidget(_testbed(SduiWidget(
        json: jsonEncode({
          'screen': 'test',
          'body': {
            'type': 'column',
            'children': [
              {'type': 'broken', 'props': {}},
              {'type': 'text', 'props': {'content': 'OK'}},
            ],
          },
        }),
        registry: registry,
        errorWidgetBuilder: (e) => Text('ERR:${e.nodeType}'),
      )));
      expect(find.text('ERR:broken'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('onError collects multiple errors', (tester) async {
      final registry = createDefaultRegistry();
      registry.register('err1', (n, c) => throw Exception('1'));
      registry.register('err2', (n, c) => throw Exception('2'));

      final errors = <SduiError>[];
      await tester.pumpWidget(_testbed(SduiWidget(
        json: jsonEncode({
          'screen': 'test',
          'body': {
            'type': 'column',
            'children': [
              {'type': 'err1', 'props': {}},
              {'type': 'err2', 'props': {}},
              {'type': 'text', 'props': {'content': 'Alive'}},
            ],
          },
        }),
        registry: registry,
        onError: errors.add,
      )));
      expect(errors.length, 2);
      expect(find.text('Alive'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SDUI DATA PROVIDER
  // ═══════════════════════════════════════════════════════════════════════════

  group('SduiDataProvider', () {
    testWidgets('provides data to nested SduiWidget', (tester) async {
      await tester.pumpWidget(_testbed(
        SduiDataProvider(
          data: {'greeting': 'Hello from provider'},
          child: SduiWidget(
            json: jsonEncode({
              'screen': 'test',
              'body': {
                'type': 'text',
                'props': {'content': '{{greeting}}'},
              },
            }),
          ),
        ),
      ));
      expect(find.text('Hello from provider'), findsOneWidget);
    });

    testWidgets('local data overrides ancestor data', (tester) async {
      await tester.pumpWidget(_testbed(
        SduiDataProvider(
          data: {'name': 'Ancestor'},
          child: SduiWidget(
            json: jsonEncode({
              'screen': 'test',
              'body': {
                'type': 'text',
                'props': {'content': '{{name}}'},
              },
            }),
            data: {'name': 'Local'},
          ),
        ),
      ));
      // Local data should win.
      expect(find.text('Local'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPLEX COMPOSITION
  // ═══════════════════════════════════════════════════════════════════════════

  group('complex composition', () {
    testWidgets('renders a realistic screen with multiple components', (tester) async {
      String? navRoute;
      final actions = ActionHandler();
      actions.register('navigate', (_, a, p) => navRoute = p['route'] as String?);

      await tester.pumpWidget(_sdui(
        {
          'type': 'scroll',
          'children': [
            {
              'type': 'safe_area',
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
                            'content': 'Welcome, {{user.name}}!',
                            'style': 'heading',
                          },
                        },
                        {
                          'type': 'text',
                          'props': {
                            'content': 'VIP badge',
                            'visible_if': 'user.is_vip',
                          },
                        },
                        {'type': 'divider', 'props': {}},
                        {
                          'type': 'row',
                          'props': {'spacing': 8},
                          'children': [
                            {
                              'type': 'icon',
                              'props': {'name': 'star', 'size': 24},
                            },
                            {
                              'type': 'text',
                              'props': {'content': '{{rating}} stars'},
                            },
                          ],
                        },
                        {
                          'type': 'button',
                          'props': {'label': 'Shop'},
                          'action': {
                            'type': 'navigate',
                            'payload': {'route': '/shop'},
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
        actionHandler: actions,
        data: {
          'user': {'name': 'Alice', 'is_vip': true},
          'rating': 4.5,
        },
      ));

      // Verify template resolution.
      expect(find.text('Welcome, Alice!'), findsOneWidget);
      // Verify conditional visibility.
      expect(find.text('VIP badge'), findsOneWidget);
      // Verify template in nested context.
      expect(find.text('4.5 stars'), findsOneWidget);
      // Verify icon.
      expect(find.text('⭐'), findsOneWidget);
      // Verify button + action.
      await tester.tap(find.text('Shop'));
      await tester.pump();
      expect(navRoute, '/shop');
      // No exceptions.
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides VIP badge when user is not VIP', (tester) async {
      await tester.pumpWidget(_sdui(
        {
          'type': 'column',
          'children': [
            {
              'type': 'text',
              'props': {'content': 'Hi {{user.name}}'},
            },
            {
              'type': 'text',
              'props': {
                'content': 'VIP',
                'visible_if': 'user.is_vip',
              },
            },
          ],
        },
        data: {
          'user': {'name': 'Bob', 'is_vip': false},
        },
      ));
      expect(find.text('Hi Bob'), findsOneWidget);
      expect(find.text('VIP'), findsNothing);
    });
  });
}
