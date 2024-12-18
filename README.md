# `unmaterialistic_lint`

A custom_lint for warning you against importing Flutter's Material library: `import 'package:flutter/material.dart'`.

> [!WARNING]
> This is experimental and quick-fixes are kind of a hack right now.

## Install

Add package:

```sh
flutter pub add dev:custom_lint dev:unmaterialistic_lint
```

Update your `analysis_options.yaml`

```yaml
analyzer:
  plugins:
    - custom_lint
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

Let's check for any lint warnings.

```console
$ dart run custom_lint
Building package executable...
Built custom_lint:custom_lint.
Analyzing...                           0.1s

  lib/main.dart:1:1 • Do not import 'package:flutter/material.dart'; • no_import_flutter_material • WARNING

1 issue found.
```

Now lets apply the lint fix.

```console
$ dart run custom_lint --fix
Building package executable... (1.0s)
Built custom_lint:custom_lint.
Analyzing...                           0.1s

No issues found!
```

What changed?

```diff
- import 'package:flutter/material.dart';
+ import 'package:flutter/widgets.dart';

...
```
