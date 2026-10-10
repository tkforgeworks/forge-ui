# forge-ui

Shared Flutter package (`forge_ui`) carrying the tkforgeworks brand look: one
theme builder, design tokens and the generic screens every app repeats. Each
app supplies only its seed color, icon and domain screens.

**Status:** repo setup. Nothing is implemented yet and no version is tagged.
The v1 scope is in
[`docs/forge-ui_forge-core_Shared_Flutter_Packages_Spec.md`](docs/forge-ui_forge-core_Shared_Flutter_Packages_Spec.md).

## Development

```sh
flutter pub get
dart format .
flutter analyze
flutter test
```

Work lands by pull request into the current release branch (`vX.Y.Z/main`),
which reaches `main` through a release PR. See the org
[contributing guide](https://github.com/tkforgeworks/.github/blob/main/CONTRIBUTING.md).

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Image assets (logos, icons,
illustrations, screenshots) are **not** covered and are all rights reserved;
see [`NOTICE`](NOTICE).
