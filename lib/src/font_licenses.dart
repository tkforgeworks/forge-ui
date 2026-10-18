import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the bundled fonts' OFL texts to [LicenseRegistry], so they show on
/// the app's licences page. Flutter's generated notices do not include them,
/// because the fonts are assets, not packages.
///
/// Call it once from `main()`, before `runApp`. Further calls do nothing.
/// The texts load lazily, when the licences page asks for them.
void registerForgeFontLicenses() {
  if (_registered) return;
  _registered = true;
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in forgeFontLicenses) {
      yield LicenseEntryWithLineBreaks([family], await _load(file));
    }
  });
}

var _registered = false;

/// Font family → licence file under `assets/fonts/licenses/`.
const forgeFontLicenses = [
  ('Poppins', 'Poppins-OFL.txt'),
  ('Source Serif 4', 'SourceSerif4-OFL.md'),
  ('JetBrains Mono', 'JetBrainsMono-OFL.txt'),
  ('Google Sans Flex', 'GoogleSansFlex-OFL.txt'),
];

/// In an app the texts are a dependency's assets (`packages/forge_ui/...`);
/// in this package's own tests they are the root package's.
Future<String> _load(String file) async {
  const dir = 'assets/fonts/licenses';
  try {
    return await rootBundle.loadString('packages/forge_ui/$dir/$file');
  } on FlutterError {
    return rootBundle.loadString('$dir/$file');
  }
}
