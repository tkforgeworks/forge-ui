# forge-ui — Claude Reference

## What this is

`forge_ui` is the shared Flutter package for the tkforgeworks brand look: a
theme builder, design tokens and the generic screens every client app repeats
(sign-in, account settings, about, empty/error/loading states). Apps consume
it as a git dependency pinned to a release tag and supply only their seed
color, icon and domain screens. Its sibling `forge-core` (separate repo) owns
sign-in, account and data plumbing. Current phase: `v0.1.0-rc.1` is published
and waiting to be adopted; the cheese app
(`tkforgeworks/cheesy-scribe`) is its first consumer and the reference for
what v0.1 contains.

Spec: `docs/forge-ui_forge-core_Shared_Flutter_Packages_Spec.md`. The same
file lives in `forge-core/docs/`; the two copies must stay identical, so any
spec change lands in both repos together.

## Stack & commands

Flutter package (Material 3), Flutter `3.47.5` pinned in `.github/workflows/ci.yml`.

| Task | Command |
|---|---|
| Install | `flutter pub get` |
| Format | `dart format .` |
| Analyze | `flutter analyze` |
| Test | `flutter test` |
| Showcase goldens | `cd example && flutter test` |
| Regenerate goldens | `cd example && flutter test --update-goldens` |
| Cut a release candidate | `scripts/release/bump-version.sh rc` (on `vX.Y.Z/main`) |
| Finalize a release | `scripts/release/bump-version.sh final` (on `vX.Y.Z/main`) |

Layout: `lib/forge_ui.dart` is the only public library and exports everything
under `lib/src/` (`theme/`, `widgets/`, `screens/`). Fonts and their OFL texts
are in `assets/fonts/`. `example/` is the showcase app; its tests are golden
images under `example/test/goldens/` and run as the `showcase / ci` job. Read
the golden PNGs to see the current look without running anything.
`example/README.md` is the component catalogue: it embeds those same PNGs
beside a code example for each component, so a new or changed component
means updating the gallery section, its golden and that README together.

## Repo & process conventions (org standard)

- Branching (org standard, `tkforgeworks/.github/docs/branching-and-release.md`):
  `main` is the released state; work accumulates on the current release branch
  `vX.Y.Z/main` (currently `v0.1.0/main`; `v0.0.1/main` was the repo-setup
  batch and is merged); topic branches
  PR **into the release branch**, never into `main`; the release branch reaches
  `main` via a release PR.
- `main` is protected by the org repository ruleset: PR-only, no force-push or
  deletion, **no bypass actors** (not even admins). Required check: `ci / ci`.
  Release branches (`v*/main`) have a second ruleset: no force-push/deletion,
  no required check.
  Standard: `tkforgeworks/.github/docs/branch-protection-ruleset.md`.
- CI consumes the shared reusable workflow
  `tkforgeworks/.github/.github/workflows/ci-flutter.yml@main`.
  Don't hand-roll steps that belong in the shared workflow — change it there.
  `dart format` ignores `analysis_options.yaml` excludes, so every `.dart`
  file in the repo must be formatted.
- **Commit subjects are the changelog.** Imperative summary; bug fixes start
  with `Fix ...`.
- **No Jira project yet (open item).** Until one exists, topic branches are
  `vX.Y.Z/<short-topic>` and subjects carry no key. Once it exists: branches
  become `vX.Y.Z/<KEY>-N-short-topic`, subjects `<KEY>-N: Imperative summary`,
  and the deviation in `.github/org-standards.yml` is removed.
- Releases: `.github/workflows/release.yml` consumes the org
  `release-flutter.yml` with both platform builds off, so a release is a tag
  and a GitHub release with notes and no files. On the release branch,
  `scripts/release/bump-version.sh rc` publishes prerelease `vX.Y.Z-rc.N`;
  `bump-version.sh final` opens the release PR, and merging it into `main`
  publishes `vX.Y.Z`. **Never hand-edit the version or push tags**; the
  workflow creates the tag. `pubspec.yaml` holds the upcoming version as
  `X.Y.Z[-rc.N]+BUILD` (the build number means nothing for a package but the
  bump script requires it). No `ticket-prefix`, so release notes are the
  commit subjects. The bump scripts are vendored copies of the org ones
  (`tkforgeworks/.github` @ `a800dd1`); don't edit them here.
- Apps consume a release as a git dependency pinned to an **exact tag**
  (`ref: vX.Y.Z`). Bumping that line is the only way an app picks up a change.
- License: **Apache-2.0** (`LICENSE` is the verbatim Apache text — never
  edit it). Image assets (`.svg`/`.png`/etc.) are **all rights reserved** via
  `NOTICE`. `pubspec.yaml` has no license field. Bundled third-party assets
  (fonts) keep their own licenses and get listed in `NOTICE`. Standard:
  `tkforgeworks/.github/docs/licensing.md`.
- `.github/org-standards.yml` records the last org standards check and this
  repo's deliberate deviations.
- Update this file as the last step of closing any ticket that changed
  conventions, architecture, or status.

## Architecture decisions (locked)

- `forge_ui` never depends on `forge_core` or Supabase. Shared screens take
  callbacks and plain data; each app wires them to `forge-core`.
- Shared widgets never hardcode a color. Every color comes from
  `Theme.of(context).colorScheme` or the `ForgeTokens` theme extension, or
  theme swapping breaks for every app.
- Code is promoted into the package only when a second app needs it.
- **The one exception to the color rule is `ForgeBrand`** (the forge gradient
  and the mark's colors), plus the success pair inside `forge_tokens.dart`.
  `test/no_hardcoded_colors_test.dart` fails on a color literal anywhere else
  in `lib/`.
- `forgeTheme` takes a seed; an app with a designed palette also passes its
  own `colorScheme` and `tokens` (one pair per brightness) and its own
  extensions through `extensions`. The cheese app uses that path.
- Font families are declared in this package, so styles must set
  `package: 'forge_ui'` (go through `ForgeType`); the resolved family is
  `packages/forge_ui/Poppins`.
- Every public name is prefixed `Forge` (`forge` for functions).
- No named spacing or motion tokens exist yet. The cheese app has none to
  promote, so none were invented; add them when a real need shows up.
- Fonts are fixed and bundled as static instances: Poppins (UI), Source
  Serif 4 (editorial), JetBrains Mono (labels). No `google_fonts`.
- Icons are Heroicons outline, through the `heroicons` package (MIT).
- Release scope: v0.1 is theme, tokens, base components and the about screen;
  the sign-in screen ships in v0.2 with forge-core v0.1, and account settings
  in v0.3 with forge-core v0.2.
- A null `onGoogle` / `onApple` callback hides that sign-in button. Linked
  sign-in methods use forge_ui's own `ForgeSignInProvider` enum and
  `ForgeLinkedSignIn` type.

## Current status

As of 2026-10-10: repo setup to org standards is done and on `main` (PRs #1
and #2, checked against `tkforgeworks/.github` @ `be3ad49`). Both rulesets are
live: `main` (id 24830672, required check `ci / ci`) and `release-branches`
(id 24830561). The spec is settled (PR #4).

forge-ui v0.1 is built and on `v0.1.0/main` (PR #5): bundled fonts,
`forgeTheme` with tokens and every component theme, the shared widgets, the
about and licences screens, and the showcase with goldens. What moved in is
the cheese app's generic layer (its `ScribeTheme`, `app/widgets/` and
about/licences screens), renamed and with the palette taken out. The showcase
builds for Linux but has only been exercised through its tests, not launched
by hand.

`v0.1.0-rc.1` was published on 2026-10-10 (commit `47b16bf`), the first run
of the org Flutter pipeline with both builds off: it produced the tag and a
prerelease with notes and no files. A scratch app pinning `ref: v0.1.0-rc.1`
resolved it from GitHub and ran a widget test against it.

## Next actions

`pubspec.yaml` is at `0.1.0-rc.1+2`. `main` is PR-only, so every change,
including edits to this file and the spec, goes through a topic branch and a
PR into `v0.1.0/main`.

1. The cheese app adopts `v0.1.0-rc.1` under **CHEESE-48** (fix version
   0.1.1 of that app, worked in the cheesy-scribe repo; the ticket carries the
   old-name-to-new-name mapping). Its 0.1.0 store release ships first, so
   this waits on that app's `v0.1.1/main`.
2. Fix what adoption exposes here, each fix followed by a new release
   candidate (`bump-version.sh rc`) that CHEESE-48 re-pins to.
3. When the cheese app is happy: `bump-version.sh final` and the release PR
   `v0.1.0/main` → `main`, which publishes `v0.1.0`.
4. forge-ui v0.2: the sign-in screen, alongside forge-core v0.1.

## Open items

### Spec

- **Seed color for each existing app** is the spec's one remaining open item.
  The cheese app's is rind amber `#B3641B`, with its designed scheme.

### Repo and process

- **Jira project.** None exists for forge-ui, and Tim does not want one yet
  (decided 2026-10-10). Follow the no-key convention above. If one is ever
  created, switch branch names and subjects to the keyed form and remove the
  deviation from `.github/org-standards.yml`.
- **Release pipeline gate.** Fixed in the org workflow on 2026-10-10
  (`tkforgeworks/.github` PR #16): `publish` now requires the CI gate to have
  passed. No release has run under the fix with a failing gate, so the first
  time a gate fails, confirm that nothing was published.
- **`v0.0.1/main` still exists.** It is fully merged, has no tag, and the
  `release-branches` ruleset blocks deleting it. Removing it means disabling
  that ruleset briefly, which needs Tim's explicit yes.
- **Goldens are compared exactly.** They were generated on Linux with
  Flutter 3.47.5, the version CI pins. Bumping Flutter means regenerating
  them in the same PR.
