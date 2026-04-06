import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'raw_component.dart';

class ComponentParser {
  /// Parses all [files] and returns components annotated with @SduiComponent.
  Future<List<RawComponent>> parse(List<File> files) async {
    final components = <RawComponent>[];
    for (final file in files) {
      final found = await _parseFile(file);
      components.addAll(found);
    }
    return components;
  }

  Future<List<RawComponent>> _parseFile(File file) async {
    final content = await file.readAsString();
    final result = parseString(
      content: content,
      featureSet: FeatureSet.latestLanguageVersion(),
      path: file.path,
    );
    final visitor = _SduiVisitor(file.path);
    result.unit.visitChildren(visitor);
    return visitor.components;
  }
}

class _SduiVisitor extends RecursiveAstVisitor<void> {
  final String sourceFile;
  final List<RawComponent> components = [];

  _SduiVisitor(this.sourceFile);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final sduiName = _extractSduiComponentName(node);
    if (sduiName == null) {
      super.visitClassDeclaration(node);
      return;
    }

    // Build maps of field name → annotations and field name → declared type
    final fieldAnnotations = <String, List<Annotation>>{};
    final fieldTypes = <String, String>{};
    for (final member in node.body.members) {
      if (member is FieldDeclaration) {
        final typeStr = member.fields.type?.toSource() ?? 'dynamic';
        for (final variable in member.fields.variables) {
          fieldAnnotations[variable.name.lexeme] = member.metadata.toList();
          fieldTypes[variable.name.lexeme] = typeStr;
        }
      }
    }

    // Find the primary constructor (unnamed or first named)
    ConstructorDeclaration? constructor;
    for (final member in node.body.members) {
      if (member is ConstructorDeclaration && member.name == null) {
        constructor = member;
        break;
      }
    }
    constructor ??= node.body.members.whereType<ConstructorDeclaration>().firstOrNull;

    final props = <RawProp>[];
    final actions = <RawAction>[];

    if (constructor != null) {
      for (final param in constructor.parameters.parameters) {
        final name = _paramName(param);
        if (name == null) continue;

        final annotations = fieldAnnotations[name] ?? [];

        if (_hasAnnotation(annotations, 'SduiAction')) {
          actions.add(RawAction(fieldName: name));
          continue;
        }

        if (_hasAnnotation(annotations, 'SduiProp')) {
          final annotationDefault =
              _extractSduiPropDefault(annotations);
          final constructorDefault = _extractConstructorDefault(param);

          final hasDefault =
              annotationDefault != null || constructorDefault != null;
          final defaultValue = annotationDefault ?? constructorDefault;

          final typeStr = _typeString(param, fieldTypes);
          final isNullable = typeStr.endsWith('?');
          final baseType = isNullable ? typeStr.substring(0, typeStr.length - 1) : typeStr;

          props.add(RawProp(
            fieldName: name,
            dartType: baseType,
            isNullable: isNullable,
            defaultValue: defaultValue,
            hasDefaultValue: hasDefault,
          ));
        }
        // Parameters with neither @SduiProp nor @SduiAction are ignored.
      }
    }

    components.add(RawComponent(
      widgetClassName: node.namePart.typeName.lexeme,
      sduiName: sduiName,
      props: props,
      actions: actions,
      sourceFile: sourceFile,
    ));

    super.visitClassDeclaration(node);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String? _extractSduiComponentName(ClassDeclaration node) {
    for (final annotation in node.metadata) {
      if (_annotationName(annotation) == 'SduiComponent') {
        final args = annotation.arguments?.arguments;
        if (args == null) return null;
        for (final arg in args) {
          if (arg is NamedExpression && arg.name.label.name == 'name') {
            final expr = arg.expression;
            if (expr is SimpleStringLiteral) return expr.value;
            if (expr is AdjacentStrings) return expr.stringValue;
          }
        }
      }
    }
    return null;
  }

  dynamic _extractSduiPropDefault(List<Annotation> annotations) {
    for (final annotation in annotations) {
      if (_annotationName(annotation) == 'SduiProp') {
        final args = annotation.arguments?.arguments;
        if (args == null) return null;
        for (final arg in args) {
          if (arg is NamedExpression &&
              arg.name.label.name == 'defaultValue') {
            return _literalValue(arg.expression);
          }
        }
      }
    }
    return null;
  }

  dynamic _extractConstructorDefault(FormalParameter param) {
    if (param is DefaultFormalParameter) {
      return _literalValue(param.defaultValue);
    }
    return null;
  }

  dynamic _literalValue(Expression? expr) {
    if (expr == null) return null;
    if (expr is IntegerLiteral) return expr.value;
    if (expr is DoubleLiteral) return expr.value;
    if (expr is BooleanLiteral) return expr.value;
    if (expr is SimpleStringLiteral) return expr.value;
    if (expr is AdjacentStrings) return expr.stringValue;
    if (expr is NullLiteral) return null;
    if (expr is PrefixExpression && expr.operator.lexeme == '-') {
      final operand = _literalValue(expr.operand);
      if (operand is int) return -operand;
      if (operand is double) return -operand;
    }
    // Non-literal default (e.g. a const reference) — return its source text
    return expr.toSource();
  }

  String? _paramName(FormalParameter param) {
    if (param is SimpleFormalParameter) return param.name?.lexeme;
    if (param is DefaultFormalParameter) return _paramName(param.parameter);
    if (param is FieldFormalParameter) return param.name.lexeme;
    if (param is SuperFormalParameter) return param.name.lexeme;
    return null;
  }

  String _typeString(FormalParameter param,
      [Map<String, String> fieldTypes = const {}]) {
    if (param is DefaultFormalParameter) {
      return _typeString(param.parameter, fieldTypes);
    }
    if (param is SimpleFormalParameter) {
      return param.type?.toSource() ?? 'dynamic';
    }
    if (param is FieldFormalParameter) {
      // Explicit type annotation on the constructor param wins.
      if (param.type != null) return param.type!.toSource();
      // Otherwise fall back to the field declaration type.
      final name = param.name.lexeme;
      return fieldTypes[name] ?? 'dynamic';
    }
    return 'dynamic';
  }

  bool _hasAnnotation(List<Annotation> annotations, String name) =>
      annotations.any((a) => _annotationName(a) == name);

  String _annotationName(Annotation annotation) {
    final name = annotation.name;
    if (name is PrefixedIdentifier) return name.identifier.name;
    return name.name;
  }
}
