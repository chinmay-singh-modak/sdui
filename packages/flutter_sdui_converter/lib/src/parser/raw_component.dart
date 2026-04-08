class RawComponent {
  final String widgetClassName;
  final String sduiName;
  final List<RawProp> props;
  final List<RawAction> actions;
  final String sourceFile;

  const RawComponent({
    required this.widgetClassName,
    required this.sduiName,
    required this.props,
    required this.actions,
    required this.sourceFile,
  });
}

class RawProp {
  final String fieldName;
  final String dartType;
  final bool isNullable;
  final dynamic defaultValue;
  final bool hasDefaultValue;

  const RawProp({
    required this.fieldName,
    required this.dartType,
    required this.isNullable,
    this.defaultValue,
    this.hasDefaultValue = false,
  });
}

class RawAction {
  final String fieldName;

  const RawAction({required this.fieldName});
}
