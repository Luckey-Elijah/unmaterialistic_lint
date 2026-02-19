# `unmaterialistic`

An analyzer plugin for warning you against importing Flutter's Material library: `import 'package:flutter/material.dart'`.

## Install

Add package:

```sh
flutter pub add dev:unmaterialistic
```

Update your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - unmaterialistic
```

## Example

```dart
import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
```

The plugin will report a warning in your IDE:

```text
Do not import 'package:flutter/material.dart'; • no_import_flutter_material • WARNING
```

Apply the quick-fix to convert the import:

```diff
- import 'package:flutter/material.dart';
+ import 'package:flutter/widgets.dart';
```
