/// The result of comparing two [SduiSchema] versions.
///
/// [hasBreakingChanges] is the fast check callers use to gate publish flows.
/// [SchemaDiff.empty] is a convenient constant for "no changes".
class SchemaDiff {
  final List<BreakingChange> breaking;
  final List<NonBreakingChange> nonBreaking;

  const SchemaDiff({
    required this.breaking,
    required this.nonBreaking,
  });

  bool get hasBreakingChanges => breaking.isNotEmpty;
  bool get hasChanges => breaking.isNotEmpty || nonBreaking.isNotEmpty;

  static const SchemaDiff empty = SchemaDiff(breaking: [], nonBreaking: []);
}

/// A schema change that is backwards-incompatible with existing consumers.
class BreakingChange {
  final String description;

  const BreakingChange(this.description);

  @override
  String toString() => description;
}

/// A schema change that is safe for existing consumers (additive or cosmetic).
class NonBreakingChange {
  final String description;

  const NonBreakingChange(this.description);

  @override
  String toString() => description;
}
