# forge-ui

Shared Flutter package (`forge_ui`) carrying the tkforgeworks brand look: one
theme builder, design tokens, shared widgets and the generic screens every
app repeats. Each app supplies only its colors, icon and domain screens.

**Status:** v0.1.0 is implemented on `v0.1.0/main` and not yet tagged. It
holds the theme, the shared widgets and the about and licences screens. The
sign-in screen (v0.2) and account settings (v0.3) follow with `forge-core`.
The v1 scope is in
[`docs/forge-ui_forge-core_Shared_Flutter_Packages_Spec.md`](docs/forge-ui_forge-core_Shared_Flutter_Packages_Spec.md).

## Using it

Add the package as a git dependency pinned to a release tag:

```yaml
dependencies:
  forge_ui:
    git:
      url: https://github.com/tkforgeworks/forge-ui.git
      ref: v0.1.0
```

Then build both themes from the app's seed color:

```dart
import 'package:forge_ui/forge_ui.dart';

void main() {
  registerForgeFontLicenses(); // the bundled fonts' OFL texts
  runApp(const MyApp());
}

MaterialApp(
  theme: forgeTheme(seed: seed),
  darkTheme: forgeTheme(seed: seed, brightness: Brightness.dark),
);
```

The fonts (Poppins, Source Serif 4, JetBrains Mono) come with the package.
The app declares no fonts and does not use `google_fonts`.

An app with a designed palette passes its own scheme and tokens, one pair per
brightness, and keeps every brand shape and component theme:

```dart
forgeTheme(
  seed: Palette.seed,
  colorScheme: Palette.lightScheme,
  tokens: Palette.lightTokens,
  extensions: const [AppColors.light], // the app's own color roles
);
```

### What is in the package

| Piece | What it is |
|---|---|
| `forgeTheme`, `forgeColorScheme` | The theme builder and the seeded scheme it generates |
| `ForgeTokens` | Color roles `ColorScheme` has no slot for; read with `context.forge` |
| `ForgeType`, `ForgeRadii`, `ForgeBrand` | Type helpers, corner radii, the forge gradient and mark colors |
| `ForgeMonoLabel`, `ForgeTagCapsule`, `ForgeStatusCapsule` | Uppercase mono labels and capsules |
| `ForgeBoxedField` | Outlined text field with its label outside |
| `showForgeConfirmSheet` | Confirmation bottom sheet, destructive by default |
| `ForgeEmptyState`, `ForgeErrorCard`, `ForgeSkeletonList` | Empty, error and loading states |
| `ForgeSettingsGroup` | Labelled card of divider-separated rows |
| `ForgeFab` | The one gradient button |
| `ForgeWorksMark` | The hammer-and-anvil maker mark |
| `ForgeAboutScreen`, `ForgeLicensesScreen` | About and licences screens; links are callbacks |

Shared widgets never hardcode a color. Everything comes from the color scheme
or `ForgeTokens`, so swapping the theme restyles every app.

## Showcase

[`example/`](example) renders every component in light and dark with three
sample seeds and one designed palette. Its tests are golden images; look at
them in `example/test/goldens/` to see the current look without running
anything.

```sh
cd example
flutter run -d linux
```

## Development

```sh
flutter pub get
dart format .
flutter analyze
flutter test                # the package
(cd example && flutter test)  # the showcase goldens
```

After an intended visual change, regenerate the goldens with
`flutter test --update-goldens` in `example/` and review the images.

Work lands by pull request into the current release branch (`vX.Y.Z/main`),
which reaches `main` through a release PR. See the org
[contributing guide](https://github.com/tkforgeworks/.github/blob/main/CONTRIBUTING.md).

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Image assets (logos, icons,
illustrations, screenshots) are **not** covered and are all rights reserved;
see [`NOTICE`](NOTICE). The bundled fonts keep their own license (SIL OFL
1.1); see [`assets/fonts/LICENSES.md`](assets/fonts/LICENSES.md).
