## 0.0.3

- Updated README to reflect migration to `analyzer_plugin`.

## 0.0.2

- Removed custom_lint_builder dependency.
- Migrated to the official analyzer_plugin API using ServerPlugin.
- Plugin is now configured via analysis_options.yaml instead of custom_lint.

## 0.0.1-dev.1

- Adds warning on using `import 'package:flutter/material.dart';`
  ```
  lib/main.dart:1:1 • Do not import 'package:flutter/material.dart'; • no_import_flutter_material • WARNING
  ```
- Adds quick fix to convert `import 'package:flutter/material.dart';` to `import 'package:flutter/widgets.dart';`