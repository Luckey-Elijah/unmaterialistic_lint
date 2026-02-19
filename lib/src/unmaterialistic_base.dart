import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;

/// An analyzer plugin that warns against importing
/// 'package:flutter/material.dart'.
class UnmaterialisticPlugin extends ServerPlugin {
  /// Creates an [UnmaterialisticPlugin].
  UnmaterialisticPlugin(
    ResourceProvider resourceProvider,
  ) : super(resourceProvider: resourceProvider);

  late AnalysisContextCollection _contextCollection;

  @override
  String get contactInfo => 'https://github.com/Luckey-Elijah/unmaterialistic_lint';

  @override
  List<String> get fileGlobsToAnalyze => const ['**/*.dart'];

  @override
  String get name => 'unmaterialistic';

  @override
  String get version => '0.0.1-dev.1';

  @override
  Future<void> afterNewContextCollection({
    required AnalysisContextCollection contextCollection,
  }) async {
    _contextCollection = contextCollection;
    await super.afterNewContextCollection(contextCollection: contextCollection);
  }

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    final result = await analysisContext.currentSession.getResolvedUnit(path);
    if (result is! ResolvedUnitResult) return;

    final errors = <plugin.AnalysisError>[];

    result.unit.visitChildren(
      _MaterialImportVisitor(
        onMaterialImport: (node) {
          errors.add(_createError(path, result, node));
        },
      ),
    );

    channel.sendNotification(
      plugin.AnalysisErrorsParams(path, errors).toNotification(),
    );
  }

  @override
  Future<plugin.EditGetFixesResult> handleEditGetFixes(
    plugin.EditGetFixesParams parameters,
  ) async {
    final path = parameters.file;
    final offset = parameters.offset;

    final analysisContext = _contextCollection.contextFor(path);
    final result = await analysisContext.currentSession.getResolvedUnit(path);
    if (result is! ResolvedUnitResult) {
      return plugin.EditGetFixesResult([]);
    }

    final fixes = <plugin.AnalysisErrorFixes>[];

    for (final directive in result.unit.directives) {
      if (directive is! ImportDirective ||
          directive.uri.stringValue != 'package:flutter/material.dart' ||
          offset < directive.offset ||
          offset > directive.end) {
        continue;
      }

      final error = _createError(path, result, directive);
      final uriNode = directive.uri;

      final change = plugin.SourceChange(
        'Convert import to '
        "'package:flutter/widgets.dart'",
        edits: [
          plugin.SourceFileEdit(
            path,
            -1,
            edits: [plugin.SourceEdit(uriNode.offset + 1, uriNode.length - 2, 'package:flutter/widgets.dart')],
          ),
        ],
      );

      fixes.add(
        plugin.AnalysisErrorFixes(
          error,
          fixes: [plugin.PrioritizedSourceChange(10, change)],
        ),
      );
    }

    return plugin.EditGetFixesResult(fixes);
  }

  plugin.AnalysisError _createError(
    String path,
    ResolvedUnitResult result,
    ImportDirective node,
  ) {
    final startLoc = result.lineInfo.getLocation(node.offset);
    final endLoc = result.lineInfo.getLocation(node.end);

    return plugin.AnalysisError(
      plugin.AnalysisErrorSeverity.WARNING,
      plugin.AnalysisErrorType.LINT,
      plugin.Location(
        path,
        node.offset,
        node.length,
        startLoc.lineNumber,
        startLoc.columnNumber,
        endLine: endLoc.lineNumber,
        endColumn: endLoc.columnNumber,
      ),
      "Do not import 'package:flutter/material.dart';",
      'no_import_flutter_material',
      hasFix: true,
    );
  }
}

class _MaterialImportVisitor extends RecursiveAstVisitor<void> {
  _MaterialImportVisitor({required this.onMaterialImport});

  final void Function(ImportDirective) onMaterialImport;

  @override
  void visitImportDirective(ImportDirective node) {
    if (node.uri.stringValue == 'package:flutter/material.dart') {
      onMaterialImport(node);
    }
    super.visitImportDirective(node);
  }
}
