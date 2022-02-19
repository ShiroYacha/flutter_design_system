import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_design_annotation/flutter_design_annotation.dart';
import 'package:flutter_design_codegen/src/utils.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

// TODO: refactor this properly
class DesignGenerator extends GeneratorForAnnotation<TDesign> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    return _generateSource(buildStep, element, annotation);
  }

  Future<String> _generateSource(
    BuildStep buildStep,
    Element element,
    ConstantReader annotation,
  ) async {
    final visitor = ModelVisitor();
    element.visitChildren(visitor);
    // Parse class meta data
    final clazz = visitor.classType.element;
    final className = clazz.name;
    final folderNamespaces =
        extractClassElementFolderNamespace(element as ClassElement);
    final namespace = folderNamespaces;
    // Construct viewer widget builder source
    final buildCodepair = await _extractBuilderSourceCode(
      resolver: buildStep.resolver,
      visitor: visitor,
      annotation: annotation,
    );
    final fieldMetaDatasetCode = _extractFieldMetaDataset(
      resolver: buildStep.resolver,
      parameters: visitor.classType.element.constructors.first.parameters,
      annotation: annotation,
    );
    // Assemble source
    return '''
final ${buildClassPageFieldName(element)} = ViewerDocumentPage(
  id: '${className.camelCase}',
  namespace: [${namespace.map((e) => "'$e'").join(',')}],
  title: ${_readNullableAnnotation<String>(annotation, 'title') ?? "'$className'"},
  subtitle: ${_readNullableAnnotation<String>(annotation, 'subtitle')},
  description: ${_readNullableAnnotation<String>(annotation, 'description')},
  sections: [
    ViewerSectionUnion.component(
      id: 'anatomy',
      title: 'Anatomy',
      ctorName: '$className',
      designLink: ${_readNullableAnnotation<String>(annotation, 'designLink')},
      builder: ViewerWidgetBuilder(
        build: ${buildCodepair[0]},
        fieldMetaDataset: $fieldMetaDatasetCode,
      ),
      sourceCode: const ViewerSourceCode(
        location: '${element.librarySource.uri}',
        code: \'\'\'
/// Built from the following function 
${buildCodepair[1]}

/// Widget
${await _extractSourceFromElement(
      resolver: buildStep.resolver,
      element: element,
    )}
\'\'\'
      ),
    ),
    ${annotation.read('showApiDocs').boolValue ? '''
    const ViewerSectionUnion.apiDocs(
      id: 'apiDocs',
      title: 'API reference',
    ),
''' : ''}
  ],
);
''';
  }

  Future<String> _extractSourceFromElement({
    required Resolver resolver,
    required Element element,
  }) async {
    final code = (await resolver.astNodeFor(element)).toString();
    return DartFormatter().format(
      code
          // TODO: find a better approach, e.g. impl. visitor
          // Skip all annotations
          .substring(
            element is ClassElement
                ? code.contains('@design')
                    ? code.indexOf('@design class') + 7
                    : code.indexOf(') class') + 2
                : 0,
          )
          // Add commas to all probable places
          .replaceAll('[^(]);', ',);')
          .replaceAll('[^;]})', ',})'),
    );
  }

  // TODO: improve this..
  dynamic _readNullableAnnotation<T>(ConstantReader annotation, String field) {
    final reader = annotation.read(field);
    if (reader.isNull) return null;
    if (T == String) {
      return "'''${reader.stringValue}'''";
    }
    return reader;
  }

  dynamic _readNullableAnnotationMapValue(
    ConstantReader annotation,
    String field,
    String key,
    DartType type,
  ) {
    final reader = annotation.read(field);
    if (reader.isNull || !reader.isMap) return null;
    final map = reader.mapValue;
    for (final e in map.entries) {
      if (e.key?.toStringValue() == key) {
        if (type.isDartCoreString) {
          return "r'${e.value!.toStringValue()}'";
        }
        if (type.isDartCoreDouble) {
          return e.value!.toDoubleValue();
        }
        if (type.isDartCoreInt) {
          return e.value!.toIntValue();
        }
        if (type.isDartCoreBool) {
          return e.value!.toBoolValue();
        }
        if (type.isDartCoreList) {
          return e.value!.toListValue();
        }
        if (type.isDartCoreMap) {
          return e.value!.toMapValue();
        }
        if (type.isDartCoreSet) {
          return e.value!.toSetValue();
        }
        if (type.isDartCoreSymbol) {
          return e.value!.toSymbolValue();
        }
        throw UnsupportedError('Dynamic type not supported!');
      }
    }
    return null;
  }

  Future<List<String>> _extractBuilderSourceCode({
    required Resolver resolver,
    required ModelVisitor visitor,
    required ConstantReader annotation,
  }) async {
    final clazz = visitor.classType.element;
    final params = visitor.classType.element.constructors.first.parameters;
    final sb = StringBuffer('(context, factory) => ${clazz.name}(');
    for (final e in params.where((e) => e.name != 'key')) {
      if (e.isNamed) {
        sb.write("${e.name}: factory.build(context, '${e.name}'),");
      } else {
        sb.write("factory.build(context, '${e.name}'),");
      }
    }
    sb.write(')');
    return [sb.toString(), sb.toString()];
  }

  String _extractFieldMetaDataset({
    required Resolver resolver,
    required List<ParameterElement> parameters,
    required ConstantReader annotation,
  }) {
    final sb = StringBuffer('const [');
    for (final e in parameters.where((e) => e.name != 'key')) {
      // TODO: figure out how to deal with function signature...

      final type = e.type.element != null
          ? e.type.getDisplayString(withNullability: false)
          : 'Function';

      sb.write(
        '''
FieldMetaData(
  name: '${e.name}',
  type: $type,
  typeName: '$type',
  isOptional: ${e.isOptional},
  defaultValue: ${e.defaultValueCode},
  defaultValueCode: ${e.defaultValueCode != null ? "'${e.defaultValueCode}'" : null},
  viewerInitValue: ${_readNullableAnnotationMapValue(annotation, 'viewerInitValueMap', e.name, e.type)},
  documentation: ${e.documentationComment != null ? "'${e.documentationComment}'" : null},
),''',
      );
    }
    sb.write(']');
    return sb.toString();
  }
}

class ModelVisitor extends SimpleElementVisitor {
  late InterfaceType classType;
  Map<String, FieldElement> fields = {};
  Map<String, MethodElement> methods = {};

  @override
  void visitConstructorElement(ConstructorElement element) {
    classType = element.returnType;
  }

  @override
  void visitMethodElement(MethodElement element) {
    methods[element.name] = element;
  }

  @override
  void visitFieldElement(FieldElement element) {
    fields[element.name] = element;
  }
}

extension StringParsingExtension on String {
  String prependLineReturnOn(String replacer) => replaceAll(
        replacer,
        '\n$replacer',
      );
  String prependLineReturnOnAll(Iterable<String> replacers) => replacers.fold(
        this,
        (pe, e) => pe.prependLineReturnOn(e),
      );
}
