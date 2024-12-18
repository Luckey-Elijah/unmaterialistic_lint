import 'package:analyzer/error/error.dart' as err;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Entrypoint of `unmaterialistic`
PluginBase createPlugin() => _UnmaterialisticLinter();

class _UnmaterialisticLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return const [_UnmaterialisticLintCode()];
  }
}

class _UnmaterialisticLintCode extends DartLintRule {
  const _UnmaterialisticLintCode() : super(code: _code);

  static const _code = LintCode(
    name: 'no_import_flutter_material',
    problemMessage: "Do not import 'package:flutter/material.dart';",
    errorSeverity: err.ErrorSeverity.WARNING,
  );

  @override
  List<Fix> getFixes() => [_ConvertMaterialImportToWidgetsImport()];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final importedLibrary = node.element?.importedLibrary;
      if (importedLibrary?.identifier == 'package:flutter/material.dart') {
        reporter.atNode(node, code);
      }
    });
  }
}

class _ConvertMaterialImportToWidgetsImport extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    err.AnalysisError analysisError,
    List<err.AnalysisError> others,
  ) {
    context.registry.addImportDirective((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;
      reporter
          .createChangeBuilder(
        message: "Convert import to 'package:flutter/widgets.dart';",
        priority: 10,
      )
          .addDartFileEdit((builder) {
        final identifier = node.element?.importedLibrary?.identifier;
        if (identifier == null) return;

        final keywordOffset = node.element?.importKeywordOffset;
        if (keywordOffset == null) return;

        final sourceRange = SourceRange(
          keywordOffset + "import '".length,
          identifier.length,
        );

        builder.addSimpleReplacement(
          sourceRange,
          'package:flutter/widgets.dart',
        );
      });
    });
  }
}
