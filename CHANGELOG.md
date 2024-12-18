## 0.0.1-dev.1

- Adds warning on using `import 'package:flutter/material.dart';`
  ```
  lib/main.dart:1:1 • Do not import 'package:flutter/material.dart'; • no_import_flutter_material • WARNING
  ```
- Adds quick fix to convert `import 'package:flutter/material.dart';` to `import 'package:flutter/widgets.dart';`