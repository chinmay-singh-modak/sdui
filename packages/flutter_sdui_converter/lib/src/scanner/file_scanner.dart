import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

import '../config/sdui_config.dart';

/// Auto-excluded regardless of user config.
const _autoExclude = ['**/*.g.dart', '**/*.freezed.dart'];

class FileScanner {
  /// Returns all `.dart` files under [projectPath] that match [config].
  ///
  /// Include patterns are applied first, then exclude patterns are subtracted.
  /// [_autoExclude] patterns are always applied on top of user excludes.
  Future<List<File>> scan(String projectPath, ScanConfig config) async {
    final included = await _expand(projectPath, config.include);
    final allExcludes = [...config.exclude, ..._autoExclude];
    final excluded = await _expand(projectPath, allExcludes);

    final excludedPaths = excluded.map((f) => f.path).toSet();
    return included.where((f) => !excludedPaths.contains(f.path)).toList();
  }

  Future<List<File>> _expand(String root, List<String> patterns) async {
    final files = <File>[];
    for (final rawPattern in patterns) {
      // If pattern has no glob chars, treat it as a directory prefix.
      final pattern = _hasGlobChars(rawPattern) ? rawPattern : '$rawPattern/**';
      final glob = Glob(pattern);
      await for (final entity in glob.list(root: root)) {
        if (entity.path.endsWith('.dart')) {
          files.add(File(entity.path));
        }
      }
    }
    // Deduplicate by canonical path
    final seen = <String>{};
    return files.where((f) => seen.add(p.canonicalize(f.path))).toList();
  }

  static bool _hasGlobChars(String pattern) =>
      pattern.contains('*') || pattern.contains('?') || pattern.contains('{');
}
