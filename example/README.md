# forge_ui showcase

Renders every `forge_ui` component in light and dark with three sample seeds
and one designed palette. Run it before tagging a release, and use it as the
reference when building a new screen.

```sh
flutter run -d linux      # or an Android device
```

Open the drawer to switch palette; the sun/moon button switches brightness.

## Golden tests

`test/` holds a golden image of the gallery for each palette and brightness,
plus the about and licences screens. CI runs them as the `showcase` job.

```sh
flutter test                      # compare against the committed images
flutter test --update-goldens     # after an intended visual change
```

Look at the regenerated images before committing them: they are the review
of the change.
