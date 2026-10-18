# Bundled fonts

All four families are licensed under the SIL Open Font License 1.1 and are
bundled (not fetched at runtime) so apps render offline and on first launch.
Per the OFL, each licence text ships alongside the fonts in `licenses/`; per
this repo's `NOTICE`, third-party assets keep their own licences. Static
instances are used rather than variable fonts so that `FontWeight` in
`TextStyle` selects the face directly.

| Family | Files | Source | Licence |
|---|---|---|---|
| Poppins | Regular 400, Medium 500, SemiBold 600, Bold 700 | github.com/google/fonts `ofl/poppins` | `licenses/Poppins-OFL.txt` (Indian Type Foundry) |
| Source Serif 4 | Regular 400, Semibold 600, Italic 400, Semibold Italic 600 | github.com/adobe-fonts/source-serif release 4.005R (TTF) | `licenses/SourceSerif4-OFL.md` (Adobe) |
| JetBrains Mono | Regular 400, Medium 500 | github.com/JetBrains/JetBrainsMono release 2.304 | `licenses/JetBrainsMono-OFL.txt` (JetBrains) |
| Google Sans Flex | Medium 500 (sign-in button label only) | github.com/google/fonts `ofl/googlesansflex` (variable font) | `licenses/GoogleSansFlex-OFL.txt` (Google) |

The first three are unmodified copies of the upstream files. Google Sans Flex
is a Modified Version under the OFL: a static instance cut from the variable
font with fontTools (`varLib.instancer wght=500 opsz=18 wdth=100 ROND=0
slnt=0 --update-name-table`, then `pyftsubset` to Latin, Latin Extended and
general punctuation). The OFL declares no Reserved Font Names for it; Google's
`TRADEMARKS.md` allows the name to identify the font and nothing else. It
exists only because Google's sign-in branding guidelines require Google Sans
Medium on the button; nothing else in the brand uses it. Add a face here and
in `pubspec.yaml` before any widget uses a new weight.

`registerForgeFontLicenses()` (`lib/src/font_licenses.dart`) adds the three
texts to Flutter's `LicenseRegistry`, so they appear on an app's licences
page.
