import 'package:flutter/widgets.dart';

import '../core/sdui_context.dart';
import '../models/sdui_action.dart';
import '../models/sdui_node.dart';
import '../styles/style_parser.dart';

/// Builds a text input field.
///
/// Supported props:
/// - `placeholder` (String) — hint text
/// - `value` (String) — initial value
/// - `max_lines` (int) — defaults to 1
/// - `keyboard_type` (String) — "text", "number", "email", "phone"
/// - `obscure` (bool) — password field
/// - `border_color` (String) — hex colour
/// - `corner_radius` (num)
///
/// Fires an action of type `"input_changed"` with payload `{"field": field, "value": text}`
/// whenever the text changes (field = `props['field']`).
Widget textInputBuilder(SduiNode node, SduiContext context) {
  final placeholder = node.props['placeholder'] as String? ?? '';
  final initialValue = node.props['value'] as String? ?? '';
  final maxLines = node.props['max_lines'] as int? ?? 1;
  final obscure = node.props['obscure'] as bool? ?? false;
  final fieldName = node.props['field'] as String? ?? '';
  final cornerRadius =
      (node.props['corner_radius'] as num?)?.toDouble() ?? 8;
  final borderColor = StyleParser.colorFromHex(
      node.props['border_color'] as String?, const Color(0xFFCCCCCC));

  return _SduiTextInput(
    placeholder: placeholder,
    initialValue: initialValue,
    maxLines: maxLines,
    obscure: obscure,
    fieldName: fieldName,
    cornerRadius: cornerRadius,
    borderColor: borderColor,
    onChanged: (value) {
      context.onAction?.call(SduiAction(
        type: 'input_changed',
        payload: {'field': fieldName, 'value': value},
      ));
    },
    onSubmitted: node.action != null
        ? (_) => context.onAction?.call(node.action!)
        : null,
  );
}

class _SduiTextInput extends StatefulWidget {
  final String placeholder;
  final String initialValue;
  final int maxLines;
  final bool obscure;
  final String fieldName;
  final double cornerRadius;
  final Color borderColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _SduiTextInput({
    required this.placeholder,
    required this.initialValue,
    required this.maxLines,
    required this.obscure,
    required this.fieldName,
    required this.cornerRadius,
    required this.borderColor,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<_SduiTextInput> createState() => _SduiTextInputState();
}

class _SduiTextInputState extends State<_SduiTextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.borderColor),
        borderRadius: BorderRadius.circular(widget.cornerRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: EditableText(
        controller: _controller,
        focusNode: FocusNode(),
        style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
        cursorColor: const Color(0xFF6C63FF),
        backgroundCursorColor: const Color(0xFFCCCCCC),
        maxLines: widget.maxLines,
        obscureText: widget.obscure,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}

/// Builds a checkbox toggle.
///
/// Supported props:
/// - `checked` (bool)
/// - `label` (String)
/// - `field` (String) — field name for the action payload
/// - `size` (num) — box size
/// - `active_color` (String) — hex colour when checked
Widget checkboxBuilder(SduiNode node, SduiContext context) {
  final checked = node.props['checked'] as bool? ?? false;
  final label = node.props['label'] as String? ?? '';
  final fieldName = node.props['field'] as String? ?? '';
  final size = (node.props['size'] as num?)?.toDouble() ?? 20;
  final activeColor = StyleParser.colorFromHex(
      node.props['active_color'] as String?, const Color(0xFF6C63FF));

  return _SduiCheckbox(
    checked: checked,
    label: label,
    size: size,
    activeColor: activeColor,
    onChanged: (value) {
      context.onAction?.call(SduiAction(
        type: 'input_changed',
        payload: {'field': fieldName, 'value': value},
      ));
    },
  );
}

class _SduiCheckbox extends StatefulWidget {
  final bool checked;
  final String label;
  final double size;
  final Color activeColor;
  final ValueChanged<bool>? onChanged;

  const _SduiCheckbox({
    required this.checked,
    required this.label,
    required this.size,
    required this.activeColor,
    this.onChanged,
  });

  @override
  State<_SduiCheckbox> createState() => _SduiCheckboxState();
}

class _SduiCheckboxState extends State<_SduiCheckbox> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _checked = !_checked);
        widget.onChanged?.call(_checked);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _checked ? widget.activeColor : const Color(0x00000000),
              border: Border.all(
                color: _checked ? widget.activeColor : const Color(0xFF999999),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _checked
                ? Center(
                    child: Text(
                      '✓',
                      style: TextStyle(
                        color: const Color(0xFFFFFFFF),
                        fontSize: widget.size * 0.7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          if (widget.label.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(widget.label, style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

/// Builds a toggle switch.
///
/// Supported props:
/// - `value` (bool)
/// - `label` (String)
/// - `field` (String)
/// - `active_color` (String)
Widget switchBuilder(SduiNode node, SduiContext context) {
  final value = node.props['value'] as bool? ?? false;
  final label = node.props['label'] as String? ?? '';
  final fieldName = node.props['field'] as String? ?? '';
  final activeColor = StyleParser.colorFromHex(
      node.props['active_color'] as String?, const Color(0xFF6C63FF));

  return _SduiSwitch(
    value: value,
    label: label,
    activeColor: activeColor,
    onChanged: (v) {
      context.onAction?.call(SduiAction(
        type: 'input_changed',
        payload: {'field': fieldName, 'value': v},
      ));
    },
  );
}

class _SduiSwitch extends StatefulWidget {
  final bool value;
  final String label;
  final Color activeColor;
  final ValueChanged<bool>? onChanged;

  const _SduiSwitch({
    required this.value,
    required this.label,
    required this.activeColor,
    this.onChanged,
  });

  @override
  State<_SduiSwitch> createState() => _SduiSwitchState();
}

class _SduiSwitchState extends State<_SduiSwitch> {
  late bool _on;

  @override
  void initState() {
    super.initState();
    _on = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _on = !_on);
        widget.onChanged?.call(_on);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 28,
            decoration: BoxDecoration(
              color: _on ? widget.activeColor : const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          if (widget.label.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(widget.label, style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

/// Builds a dropdown selector.
///
/// Supported props:
/// - `options` (List<Map>) — each with `label` and `value`
/// - `selected` (String) — currently selected value
/// - `placeholder` (String) — shown when nothing is selected
/// - `field` (String)
/// - `corner_radius` (num)
/// - `border_color` (String)
Widget dropdownBuilder(SduiNode node, SduiContext context) {
  final options = (node.props['options'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      [];
  final selected = node.props['selected'] as String?;
  final placeholder = node.props['placeholder'] as String? ?? 'Select...';
  final fieldName = node.props['field'] as String? ?? '';
  final cornerRadius =
      (node.props['corner_radius'] as num?)?.toDouble() ?? 8;
  final borderColor = StyleParser.colorFromHex(
      node.props['border_color'] as String?, const Color(0xFFCCCCCC));

  return _SduiDropdown(
    options: options,
    selected: selected,
    placeholder: placeholder,
    cornerRadius: cornerRadius,
    borderColor: borderColor,
    onChanged: (value) {
      context.onAction?.call(SduiAction(
        type: 'input_changed',
        payload: {'field': fieldName, 'value': value},
      ));
    },
  );
}

class _SduiDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  final String? selected;
  final String placeholder;
  final double cornerRadius;
  final Color borderColor;
  final ValueChanged<String>? onChanged;

  const _SduiDropdown({
    required this.options,
    required this.selected,
    required this.placeholder,
    required this.cornerRadius,
    required this.borderColor,
    this.onChanged,
  });

  @override
  State<_SduiDropdown> createState() => _SduiDropdownState();
}

class _SduiDropdownState extends State<_SduiDropdown> {
  late String? _selected;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  String get _displayLabel {
    if (_selected == null) return widget.placeholder;
    final match = widget.options.where(
      (o) => o['value']?.toString() == _selected,
    );
    return match.isNotEmpty
        ? (match.first['label'] as String? ?? _selected!)
        : _selected!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: widget.borderColor),
              borderRadius: BorderRadius.circular(widget.cornerRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _displayLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: _selected == null
                        ? const Color(0xFF999999)
                        : const Color(0xFF000000),
                  ),
                ),
                Text(
                  _expanded ? '▲' : '▼',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: widget.borderColor),
              borderRadius: BorderRadius.circular(widget.cornerRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.options.map((opt) {
                final value = opt['value']?.toString() ?? '';
                final label = opt['label'] as String? ?? value;
                final isSelected = value == _selected;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = value;
                      _expanded = false;
                    });
                    widget.onChanged?.call(value);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    color: isSelected
                        ? const Color(0x1A6C63FF)
                        : const Color(0x00000000),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
