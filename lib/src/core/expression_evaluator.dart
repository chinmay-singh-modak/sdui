/// A simple expression evaluator for SDUI conditional and template logic.
///
/// Supports:
/// - Variable lookup: `"user.name"` → resolves from a data map
/// - Equality: `"user.role == admin"`
/// - Inequality: `"user.role != guest"`
/// - Boolean: `"user.is_premium"` (truthy check)
/// - Negation: `"!user.is_premium"`
/// - Numeric comparisons: `"cart.count > 0"`, `"cart.count >= 5"`
/// - Logical AND / OR: `"user.is_premium && cart.count > 0"`
class ExpressionEvaluator {
  ExpressionEvaluator._();

  /// Evaluate a condition string against a [data] map.
  /// Returns `true` if the expression is satisfied.
  static bool evaluate(String expression, Map<String, dynamic> data) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) return true;

    // Logical OR (lowest precedence)
    if (trimmed.contains('||')) {
      return trimmed
          .split('||')
          .any((part) => evaluate(part, data));
    }

    // Logical AND
    if (trimmed.contains('&&')) {
      return trimmed
          .split('&&')
          .every((part) => evaluate(part, data));
    }

    // Negation
    if (trimmed.startsWith('!')) {
      return !evaluate(trimmed.substring(1), data);
    }

    // Comparison operators
    for (final op in ['!=', '==', '>=', '<=', '>', '<']) {
      final idx = trimmed.indexOf(op);
      if (idx > 0) {
        final left = _resolve(trimmed.substring(0, idx).trim(), data);
        final right = _resolve(trimmed.substring(idx + op.length).trim(), data);
        return _compare(left, right, op);
      }
    }

    // Bare value — truthy check
    final value = _resolve(trimmed, data);
    return _isTruthy(value);
  }

  /// Resolve a dotted path (e.g. `"user.name"`) from [data],
  /// or return a literal string/number if it doesn't match a path.
  static dynamic _resolve(String token, Map<String, dynamic> data) {
    // Try numeric literal
    final asNum = num.tryParse(token);
    if (asNum != null) return asNum;

    // Try boolean literal
    if (token == 'true') return true;
    if (token == 'false') return false;
    if (token == 'null') return null;

    // Strip surrounding quotes for string literals
    if ((token.startsWith('"') && token.endsWith('"')) ||
        (token.startsWith("'") && token.endsWith("'"))) {
      return token.substring(1, token.length - 1);
    }

    // Try dot-path resolution against data
    final resolved = resolvePath(token, data);
    if (resolved != null) return resolved;

    // If the path didn't resolve and it's a simple identifier (no dots),
    // treat it as a bare string literal (e.g. "admin", "guest").
    if (!token.contains('.')) return token;

    return null;
  }

  /// Walk a dot-separated path into a nested map.
  static dynamic resolvePath(String path, Map<String, dynamic> data) {
    final segments = path.split('.');
    dynamic current = data;
    for (final seg in segments) {
      if (current is Map<String, dynamic> && current.containsKey(seg)) {
        current = current[seg];
      } else {
        return null;
      }
    }
    return current;
  }

  static bool _compare(dynamic left, dynamic right, String op) {
    switch (op) {
      case '==':
        return left?.toString() == right?.toString();
      case '!=':
        return left?.toString() != right?.toString();
      case '>':
        return _toNum(left) > _toNum(right);
      case '<':
        return _toNum(left) < _toNum(right);
      case '>=':
        return _toNum(left) >= _toNum(right);
      case '<=':
        return _toNum(left) <= _toNum(right);
      default:
        return false;
    }
  }

  static num _toNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? '') ?? 0;
  }

  static bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
}
