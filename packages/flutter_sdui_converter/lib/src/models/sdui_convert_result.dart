class SduiConvertResult<S, E> {
  final S? _success;
  final E? _error;
  final bool _isSuccess;

  const SduiConvertResult._success(S value)
      : _success = value,
        _error = null,
        _isSuccess = true;

  const SduiConvertResult._failure(E error)
      : _success = null,
        _error = error,
        _isSuccess = false;

  factory SduiConvertResult.success(S value) =>
      SduiConvertResult._success(value);

  factory SduiConvertResult.failure(E error) =>
      SduiConvertResult._failure(error);

  bool get isSuccess => _isSuccess;
  bool get isFailure => !_isSuccess;

  void fold({
    required void Function(S) onSuccess,
    required void Function(E) onError,
  }) {
    if (_isSuccess) {
      onSuccess(_success as S);
    } else {
      onError(_error as E);
    }
  }

  T map<T>({
    required T Function(S) onSuccess,
    required T Function(E) onError,
  }) {
    if (_isSuccess) {
      return onSuccess(_success as S);
    } else {
      return onError(_error as E);
    }
  }
}

class SduiConvertError {
  final String message;
  final String? file;
  final int? line;

  const SduiConvertError({
    required this.message,
    this.file,
    this.line,
  });

  @override
  String toString() {
    final parts = <String>[];
    if (file != null) parts.add(file!);
    if (line != null) parts.add('line $line');
    final location = parts.isEmpty ? '' : ' (${parts.join(', ')})';
    return 'Error$location: $message';
  }
}
