# Changelog

## [1.0.3](https://github.com/chinmay-singh-modak/sdui/compare/flutter_sdui_converter-v1.0.2...flutter_sdui_converter-v1.0.3) (2026-04-08)


### Bug Fixes

* **flutter_sdui_converter:** add monorepo workspace links to README ([a5df86d](https://github.com/chinmay-singh-modak/sdui/commit/a5df86d6fe68a3e3fc2c33577e10bd41fe492497))

## [1.0.2](https://github.com/chinmay-singh-modak/sdui/compare/flutter_sdui_converter-v1.0.1...flutter_sdui_converter-v1.0.2) (2026-04-08)


### Bug Fixes

* **flutter_sdui_converter:** add monorepo workspace links to README ([a5df86d](https://github.com/chinmay-singh-modak/sdui/commit/a5df86d6fe68a3e3fc2c33577e10bd41fe492497))

## 1.0.1

* Fix `ComponentParser` compatibility with `analyzer` 12.0.0 — updated AST
  traversal to use `ClassDeclaration.body.members` and
  `ClassDeclaration.namePart.typeName` after breaking API changes in analyzer 12.
* Bump dependency constraints: `analyzer ^12.0.0`, `args ^2.7.0`,
  `glob ^2.1.3`, `path ^1.9.1`, `yaml ^3.1.3`.
* Switch dev dependency from `lints` to `flutter_lints ^6.0.0`; bump
  `test` to `^1.31.0`.
* README: add `num → number` to the Dart type mapping table; add missing
  breaking-change rows (`Prop became required`, `Action support removed`,
  `Action support added`); add `flutter_sdui_kit` to the workspace table.

## 1.0.0

* Initial version.
