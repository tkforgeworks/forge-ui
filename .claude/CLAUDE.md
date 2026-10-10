# forge-ui — Claude Reference

## What this is

`forge_ui` is the shared Flutter package for the tkforgeworks brand look: a
theme builder, design tokens and the generic screens every client app repeats
(sign-in, account settings, about, empty/error/loading states). Apps consume
it as a git dependency pinned to a release tag and supply only their seed
color, icon and domain screens. Its sibling `forge-core` (separate repo) owns
sign-in, account and data plumbing. Current phase: repo setup done and the v1
spec settled (2026-10-10); nothing is implemented yet.

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
- Releases: the org release pipeline is **not adopted yet** (deferred until
  v0.1 is close). **Never hand-edit the version or push tags** once it is;
  `pubspec.yaml` holds the upcoming version of the current release branch as
  `X.Y.Z+BUILD`.
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
(id 24830561). No tag or release exists. The package is an empty skeleton with
one placeholder test. The spec pass is done: Tim decided every gap on
2026-10-10 and the decisions are written into the spec (its Decisions table
lists them).

## Next actions

`v0.1.0/main` is cut and `pubspec.yaml` is at `0.1.0+1`. `main` is PR-only, so
every change, including edits to this file and the spec, goes through a topic
branch and a PR into `v0.1.0/main`.

1. Finish spec milestone 1: the empty showcase app under `example/`.
2. Start forge-ui v0.1 (milestone 2): theme builder, tokens, base components,
   about screen, showcase in light and dark with three seeds.

## Open items

### Spec

- **Seed color for each existing app** is the spec's one remaining open item.
  It does not block v0.1; the showcase uses sample seeds.
- **Bundling the fonts.** The cheese app already ships the ten static files
  and their OFL texts (`cheesy-scribe/assets/fonts/`, sources and versions in
  its `LICENSES.md`). Take the files from the upstream sources named there,
  check each family's OFL text, and list them in `NOTICE`.

### Repo and process

- **Jira project.** None exists for forge-ui. Until Tim creates one, follow
  the no-key convention above. When it exists, switch branch names and
  subjects to the keyed form and remove the deviation from
  `.github/org-standards.yml`.
- **Release pipeline.** Deferred until v0.1 is close. Before adopting, note:
  `release-flutter.yml` with `build-windows` and `build-android` both false
  looks like a fit for tagging a package but no repo has run it that way; it
  needs a `JIRA_BASE_URL` variable and a `ticket-prefix`; the bump scripts get
  vendored into `scripts/release/`; and once `release.yml` exists, any merge
  to `main` whose `pubspec.yaml` version has no tag publishes a stable
  release.
- **`v0.0.1/main` still exists.** It is fully merged, has no tag, and the
  `release-branches` ruleset blocks deleting it. Removing it means disabling
  that ruleset briefly, which needs Tim's explicit yes.
- **Placeholder test.** Replace `test/forge_ui_test.dart` when the first
  component lands.
