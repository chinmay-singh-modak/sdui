## 1.0.1

- Fix `ComponentParser` compatibility with `analyzer` 12.0.0 — updated AST
  traversal to use `ClassDeclaration.body.members` and
  `ClassDeclaration.namePart.typeName` after breaking API changes in analyzer 12.
- Bump dependency constraints: `analyzer ^12.0.0`, `args ^2.7.0`,
  `glob ^2.1.3`, `path ^1.9.1`, `yaml ^3.1.3`.
- Switch dev dependency from `lints` to `flutter_lints ^6.0.0`; bump
  `test` to `^1.31.0`.
- README: add `num → number` to the Dart type mapping table; add missing
  breaking-change rows (`Prop became required`, `Action support removed`,
  `Action support added`); add `flutter_sdui_kit` to the workspace table.

## 1.0.0

- Initial version.
