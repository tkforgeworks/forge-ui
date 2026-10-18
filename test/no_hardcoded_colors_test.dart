import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The package's hard rule: shared widgets never hardcode a colour. Every
/// colour comes from the colour scheme or `ForgeTokens`, or theme swapping
/// breaks for every app.
///
/// Three files may hold literals: `forge_brand.dart` (the brand's own
/// colours), `forge_tokens.dart` (the success pair a seed can't produce) and
/// `forge_provider_brand.dart` (the colours Google mandates for its sign-in
/// button). `Colors.transparent` is allowed anywhere, since it paints nothing.
void main() {
  const allowed = {
    'forge_brand.dart',
    'forge_tokens.dart',
    'forge_provider_brand.dart',
  };
  final literal = RegExp(
    r'\bColor(\.from[A-Z]+)?\(|\bColors\.(?!transparent\b)',
  );

  test('no colour literals outside the brand and token files', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !allowed.contains(f.uri.pathSegments.last));
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (final (i, line) in lines.indexed) {
        final code = line.split('//').first;
        if (literal.hasMatch(code)) {
          offenders.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('the check itself catches a literal', () {
    expect(literal.hasMatch('color: Color(0xFFB3641B),'), isTrue);
    expect(
      literal.hasMatch('color: const Color.fromARGB(255, 0, 0, 0)'),
      isTrue,
    );
    expect(literal.hasMatch('color: Colors.white,'), isTrue);
    expect(literal.hasMatch('color: Colors.transparent,'), isFalse);
    expect(literal.hasMatch('final Color? color;'), isFalse);
    expect(literal.hasMatch('Color.lerp(a, b, t)'), isFalse);
    expect(literal.hasMatch('Color.alphaBlend(a, b)'), isFalse);
  });
}
