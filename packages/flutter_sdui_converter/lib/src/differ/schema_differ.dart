import '../models/models.dart';

/// Pure function — no IO. Compares two schemas and categorises changes.
class SchemaDiffer {
  SchemaDiff diff(SduiSchema previous, SduiSchema current) {
    final breaking = <BreakingChange>[];
    final nonBreaking = <NonBreakingChange>[];

    final prevComponents = {for (final c in previous.components) c.type: c};
    final currComponents = {for (final c in current.components) c.type: c};

    // Removed components
    for (final type in prevComponents.keys) {
      if (!currComponents.containsKey(type)) {
        breaking.add(BreakingChange('Component "$type" was removed'));
      }
    }

    // Added components
    for (final type in currComponents.keys) {
      if (!prevComponents.containsKey(type)) {
        nonBreaking.add(NonBreakingChange('Component "$type" was added'));
      }
    }

    // Changed components
    for (final type in prevComponents.keys) {
      final prev = prevComponents[type];
      final curr = currComponents[type];
      if (prev == null || curr == null) continue;

      _diffComponent(type, prev, curr, breaking, nonBreaking);
    }

    return SchemaDiff(breaking: breaking, nonBreaking: nonBreaking);
  }

  void _diffComponent(
    String componentName,
    SduiComponent prev,
    SduiComponent curr,
    List<BreakingChange> breaking,
    List<NonBreakingChange> nonBreaking,
  ) {
    final prevProps = {for (final p in prev.props) p.name: p};
    final currProps = {for (final p in curr.props) p.name: p};

    // Removed props
    for (final name in prevProps.keys) {
      if (!currProps.containsKey(name)) {
        breaking.add(BreakingChange(
            'In "$componentName": prop "$name" was removed'));
      }
    }

    // Added props
    for (final name in currProps.keys) {
      if (!prevProps.containsKey(name)) {
        final p = currProps[name]!;
        if (p.required) {
          breaking.add(BreakingChange(
              'In "$componentName": required prop "$name" was added '
              '(existing consumers won\'t send it)'));
        } else {
          nonBreaking.add(NonBreakingChange(
              'In "$componentName": optional prop "$name" was added'));
        }
      }
    }

    // Changed props
    for (final name in prevProps.keys) {
      final p = prevProps[name];
      final c = currProps[name];
      if (p == null || c == null) continue;

      if (p.type != c.type) {
        breaking.add(BreakingChange(
            'In "$componentName": prop "$name" type changed: '
            '${p.type} → ${c.type}'));
      }

      // Non-required → required is breaking; required → non-required is not
      if (!p.required && c.required) {
        breaking.add(BreakingChange(
            'In "$componentName": prop "$name" became required'));
      }

      // Default added to existing prop — non-breaking
      if (p.defaultValue == null && c.defaultValue != null) {
        nonBreaking.add(NonBreakingChange(
            'In "$componentName": prop "$name" gained a default value '
            '("${c.defaultValue}")'));
      }
    }

    // Action slot: removing it is breaking; adding it is non-breaking.
    if (prev.supportsAction && !curr.supportsAction) {
      breaking.add(BreakingChange(
          'In "$componentName": action support was removed'));
    } else if (!prev.supportsAction && curr.supportsAction) {
      nonBreaking.add(NonBreakingChange(
          'In "$componentName": action support was added'));
    }
  }
}
