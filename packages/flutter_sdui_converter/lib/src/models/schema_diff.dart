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

class BreakingChange {
  final String description;

  const BreakingChange(this.description);

  @override
  String toString() => description;
}

class NonBreakingChange {
  final String description;

  const NonBreakingChange(this.description);

  @override
  String toString() => description;
}
