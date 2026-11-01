# forge-ui — Claude Reference

## What this is

`forge_ui` is the shared Flutter package for the tkforgeworks brand look: a
theme builder, design tokens and the generic screens every client app repeats
(sign-in, account settings, about, empty/error/loading states). Apps consume
it as a git dependency pinned to a release tag and supply only their seed
color, icon and domain screens. Its sibling `forge-core` (separate repo) owns
sign-in, account and data plumbing. Current phase: the cheese app
(`tkforgeworks/cheesy-scribe`, its first consumer and the reference for what
v0.1 contains) adopted it in its `v0.2.0` release candidates and pins the
first stable release, `v0.1.0` (2026-10-14). `v0.2.0/main` was cut from
`main` on 2026-10-17 (FU-1) for the v0.2 work: the sign-in and account
screens cheesy-scribe 0.3.0 needs. A fix to `v0.1.0` would go on a
`v0.1.1/main` cut from `main`.

**Spec: the canonical copy is in `tkforgeworks/forge-core`**,
`docs/forge-ui_forge-core_Shared_Flutter_Packages_Spec.md` (decided
2026-10-17). This repo's `docs/` file of the same name is a pointer to it,
not a copy; spec changes land in forge-core only (its Jira project is `FC`).

## Stack & commands

Flutter package (Material 3), Flutter `3.47.5` pinned in `.github/workflows/ci.yml`.
`pubspec.yaml`'s `environment` is a separate, lower floor (Dart `^3.13.2`,
Flutter `>=3.47.2`): the oldest toolchain a consuming app pins. `flutter
create` writes the current SDK there, which locks out every app on an older
patch at `pub get` (cheesy-scribe's CI, on Flutter 3.47.2, could not resolve
`v0.1.0-rc.1`). Raise it only when the code needs a newer SDK.

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
are in `assets/fonts/`; provider logos (Google's "G", 1x–4x) in
`assets/brand/providers/`, all rights reserved by their owners (NOTICE). `example/` is the showcase app; its tests are golden
images under `example/test/goldens/` and run as the `showcase / ci` job. Read
the golden PNGs to see the current look without running anything.
`example/README.md` is the component catalogue: it embeds those same PNGs
beside a code example for each component, so a new or changed component
means updating the gallery section, its golden and that README together.

## Repo & process conventions (org standard)

- Branching (org standard, `tkforgeworks/.github/docs/branching-and-release.md`):
  `main` is the released state; work accumulates on the current release branch
  `vX.Y.Z/main` (currently **`v0.2.2/main`**, cut from `main` on 2026-10-31
  for the Anvil desktop fixes FU-9..12; `v0.2.1/main` shipped as `v0.2.1`
  the same day, `v0.2.0/main` as `v0.2.0` on 2026-10-19, `v0.1.0/main`
  as `v0.1.0` on 2026-10-14 and `v0.0.1/main` was the repo-setup batch, all
  merged); topic branches PR **into the release branch**, never
  into `main`; the release branch reaches `main` via a release PR.
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
- **Jira project `FU`** (`https://tkforgeworks.atlassian.net/browse/FU`,
  created 2026-10-17; forge-core is `FC`). **Commit subjects are the
  changelog:** `FU-N: Imperative summary`; bug fixes `FU-N: Fix ...`.
  Branches `vX.Y.Z/FU-N-short-topic`. Move a ticket to *In Progress* when
  its branch opens. **Never close a ticket unless asked** — comment "Actions
  taken" + commit hash and leave it for the human to verify. Commits before
  FU-1 carry no key; the `org-standards.yml` deviation for that was removed
  in FU-1.
- Releases: `.github/workflows/release.yml` consumes the org
  `release-flutter.yml` with both platform builds off, so a release is a tag
  and a GitHub release with notes and no files. On the release branch,
  `scripts/release/bump-version.sh rc` publishes prerelease `vX.Y.Z-rc.N`;
  `bump-version.sh final` opens the release PR, and merging it into `main`
  publishes `vX.Y.Z`. **Never hand-edit the version or push tags**; the
  workflow creates the tag. `pubspec.yaml` holds the upcoming version as
  `X.Y.Z[-rc.N]+BUILD` (the build number means nothing for a package but the
  bump script requires it). `ticket-prefix: FU` and the repo variable
  `JIRA_BASE_URL` (both FU-2) make release notes link each `FU-N:` subject.
  The bump scripts are vendored copies of the org ones
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
- **High-reuse screens are built here first** (decided 2026-10-17): sign-in,
  account, settings, about, licences and feedback screens go into the package
  from the start, even with one consumer, so the next app gets the same views
  without a migration; RCs and pin moves are cheap. The rule of three
  (promote only when a second app needs it) applies to everything whose
  reuse is ambiguous.
- **The exceptions to the color rule are `ForgeBrand`** (the forge gradient
  and the mark's colors), plus the success pair inside `forge_tokens.dart`,
  and from v0.2 **`ForgeProviderBrand`**: the fill, stroke and text colors
  Google mandates for its sign-in button (light `#FFFFFF`/`#747775`/
  `#1F1F1F`, dark `#131314`/`#8E918F`/`#E3E3E3`, neutral `#F2F2F2`), kept
  apart from the brand's own. `test/no_hardcoded_colors_test.dart` fails on
  a color literal anywhere else in `lib/`.
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
  Serif 4 (editorial), JetBrains Mono (labels). No `google_fonts`. v0.2 adds
  a Medium instance of **Google Sans Flex** (Google's OFL 1.1 rebuild of
  Google Sans, on Google Fonts since 2025-11) for the Google button label
  only, which Google's branding guidelines require; never bundle the
  proprietary Google Sans. Done in FU-2: the OFL declares no Reserved Font
  Names and Google's TRADEMARKS.md allows the name to identify the font;
  `GoogleSansFlex-Medium.ttf` is a static instance (`fontTools
  varLib.instancer wght=500`, other axes at default, `pyftsubset` to Latin;
  recipe in `assets/fonts/LICENSES.md`). The Google "G" is cropped from
  Google's pre-approved button PNGs (the 2026 bundle's SVGs use filters and
  `foreignObject` gradients Flutter can't render), background lifted to
  alpha, shipped at 1x–4x; all rights reserved by Google, listed in
  `NOTICE`. `ForgeSignInButton` loads it with an `errorBuilder` because this
  package's own widget tests have no `packages/forge_ui/` prefix; the
  showcase goldens are where it is really rendered.
- Icons are Heroicons outline, through the `heroicons` package (MIT).
- **Density (FU-10, v0.2.2).** `forgeTheme(density:)` takes
  `ForgeDensity.touch` (the default: the phone metrics the brand started
  on, full-width 50/48 buttons) or `ForgeDensity.desktop` (Anvil: buttons
  sized to their label at 36 high, tighter fields, search bar and list
  tiles, `VisualDensity.compact` theme-wide). The touch path is pixel-
  identical to before densities existed, and the showcase goldens prove
  it; a private `_Metrics` record per density holds every value that
  differs, so never scatter density ternaries through the builder.
  Desktop also keeps the scrollbar thumb visible (FU-12); both densities
  draw it in `textGhost` with `ForgeRadii.tag` corners.
- **Status roles (FU-9, v0.2.2).** `ForgeTokens` carries `warning`,
  `info` and `success` with their on-colours and tinted containers, from
  fixed hues per brightness (a seed cannot produce them). They are optional
  in the `const` constructor behind getters that fall back by the success
  container's luminance, so pre-FU-9 literals compile unchanged; new
  literals should pass them. `successContainer`/`onSuccessContainer` is
  the older capsule green and is not derived from `success`.
  `ForgeStatusCapsule` takes `tone`; `active: true` still means success.
- **`ForgeType.code` (FU-11, v0.2.2)** is JetBrains Mono as body text (13,
  no tracking, as typed) for identifiers, export keys, formulas and paths;
  `ForgeType.mono` stays the uppercase letterspaced label.
- Release scope: v0.1 is theme, tokens, base components and the about and
  licences screens (shipped). **v0.2 ships the sign-in panel/screen and the
  account settings page together**, alongside forge-core v0.1, for
  cheesy-scribe 0.3.0 (2026-10-17; the earlier plan put account settings in
  v0.3): `ForgeSignInProvider` (google, email, apple), `ForgeSignInButton`,
  `ForgeSignInPanel` (Google button + email/password form: sign in, create
  account, forgot password; embeddable in an app's Account screen),
  `ForgeSignInScreen` (panel + optional skip), "check your email" and "set a
  new password" screens, `ForgeAccountSettings`, `ForgeSignOutSheet` with an
  "also erase this phone" option, `showForgeConfirmSheet(typeToConfirm:)`,
  busy states. Apple's button is reserved for the first iOS app.
- A null `onGoogle` / `onApple` callback hides that sign-in button; the
  email/password form is always present. Linked sign-in methods use
  forge_ui's own `ForgeSignInProvider` enum and `ForgeLinkedSignIn` type.

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

The cheese app adopted it under CHEESE-48 (2026-10-13) and moved through
`v0.1.0-rc.2` (SDK floor lowered so its Flutter 3.47.2 CI resolves the
package) and `v0.1.0-rc.3` (`ForgeAboutScreen.onSendFeedback`, CHEESE-51).
Tim's device passes on its `v0.2.0` RCs found it matching, so `v0.1.0` was
finalised on 2026-10-14 from the rc.3 code (`bump-version.sh final`, release
PR `v0.1.0/main` → `main`) and the cheese app re-pinned to `ref: v0.1.0`.
`v0.1.0/main` and `v0.0.1/main` were deleted on 2026-10-16 with the
ruleset-toggle runbook.

2026-10-17: Jira project `FU` created; `v0.2.0/main` cut from `main`; FU-1
replaced the spec copy with a pointer to forge-core's canonical spec, which
FC-1 revised the same day for cheesy-scribe 0.3.0 (Google and email/password
sign-in, deletion in the first forge-core release, shared-first screens).

2026-10-18: FU-2: `ForgeProviderBrand`, Google Sans Flex Medium, the Google
"G" asset, `ForgeSignInButton` (Google light/dark/neutral, busy; email
outlined; Apple asserts), `ForgeSignInProvider` and `ForgeLinkedSignIn`;
"Sign in" gallery section, goldens and README; `ticket-prefix: FU` on the
release workflow. The licences screen's `fontsLine` now names four fonts
(cheesy-scribe's renders of that screen change when it re-pins). Shipped as
`v0.2.0-rc.1`.

2026-10-18: FU-3: `ForgeSignInPanel` (provider buttons over the email form
with sign in / create / forgot modes, own validation, field + form errors,
busy) and `ForgeSignInScreen` (app bar, optional "Not now"); "Sign-in
panel" gallery section, sign-in screen goldens, README. Keys on the panel
(`emailFieldKey`, `passwordFieldKey`, `submitKey`, `switchModeKey`,
`forgotKey`, `showPasswordKey`) and `ForgeSignInScreen.skipKey` are what
app tests drive. Shipped as `v0.2.0-rc.2`.

2026-10-18: FU-4: `ForgeCheckEmailScreen` (confirm / reset wording, "Send
again" on a cooldown that starts when the screen opens, change-address and
Done; keys `resendKey`, `changeEmailKey`, `doneKey`) and
`ForgeSetPasswordScreen` (two matching fields ≥ 8, show/hide, busy; keys
`passwordFieldKey`, `confirmFieldKey`, `submitKey`, `showPasswordKey`);
"Email screens" gallery entry, screen goldens, README. Shipped as
`v0.2.0-rc.3`. FU-5 (typed / async confirm sheet) shipped as `v0.2.0-rc.4`.

2026-10-18: FU-6: `ForgeAccountSettings` (signed-out → `signedOut` widget;
signed-in → Account group with email and a username field saved once on
Done or blur, Sign-in methods group with linked rows plus "Link Google" /
"Set a password" when they apply, the app's `status` slot under
`statusLabel`, Sign out and Delete account rows that open the shared
sheets themselves: `onSignOut({eraseLocal})` after `showForgeSignOutSheet`,
`onDeleteAccount` as the typed sheet's `onConfirmAsync`) and
`showForgeSignOutSheet` / `ForgeSignOutSheet` with the "Also erase this
phone" checkbox (`ForgeSignOutChoice`). Keys `usernameFieldKey`,
`linkGoogleKey`, `setPasswordKey`, `signOutKey`, `deleteKey`,
`ForgeSignOutSheet.eraseKey/confirmKey/cancelKey`. With it the v0.2 scope
is complete.

2026-10-18: FU-5: `showForgeConfirmSheet` gained `typeToConfirm` (+
`caseSensitive`) and `onConfirmAsync` (`Future<String?>`: null closes with
true, a message keeps the sheet open as an error under the field; progress
in the confirm button, cancel disabled, `PopScope(canPop: false)` while
busy). `ForgeConfirmSheet` is stateful now; keys `fieldKey`, `confirmKey`,
`cancelKey`. Existing callers unchanged.

2026-10-19: **v0.2.0 final cut from rc.6's code** (this status change
only). cheesy-scribe 0.3.0 adopted rc.1–rc.6 across eleven RCs on Tim's
device (sign-in panel, check-email and set-password screens, account
settings, typed confirm sheet, sign-out sheet) and re-pins to `v0.2.0`.

2026-10-31: **v0.2.1 released** (FU-8, the `ForgeAboutScreen` FAB slot).
`v0.2.2/main` cut the same day for the gaps Anvil found while building its
theme on v0.2.1 (ANVL-154), all merged in one session: FU-11
`ForgeType.code` (PR #24, also starts the cycle at 0.2.2+15), FU-9 status
roles and capsule tones (PR #25), FU-10 `ForgeDensity` (PR #26), FU-12
scrollbar theme (PR #27). Anvil is the first desktop consumer and adopts
the 0.2.2 tag under ANVL-170, which blocks its first 0.2.0 RC. The
showcase has a density toggle beside the brightness one and desktop
goldens for the Buttons and Scrolling sections.

## Next actions

`main` is PR-only, so every change, including edits to this file, goes
through a topic branch and a PR into `v0.2.2/main`.

1. **v0.2.0 released** (2026-10-19; FU-2..6 done, adopted by cheesy-scribe
   0.3.0 and re-pinned to the stable tag).
2. **v0.2.1** (`v0.2.1/main`, 2026-10-31): FU-8 gives `ForgeAboutScreen` an
   optional `floatingActionButton` (passed to its Scaffold; the list's
   bottom padding grows from 40 to `ForgeAboutScreen.fabBottomPadding`, 88,
   only when one is set, so the about golden is unchanged) for
   cheesy-scribe's floating feedback button (CHEESE-72). A patch release so
   FU-7 (Apple sign-in, 0.3.0, for cheesy-scribe 1.0.0) keeps its number.
   The showcase's about entry passes no button on purpose: its golden is
   the "unchanged without one" check; `example/README.md` names the slot.
3. **v0.2.2** (`v0.2.2/main`, 2026-10-31): FU-9/10/11/12 merged; cut the
   RC and finalise so Anvil (ANVL-170) can pin `v0.2.2`. Cheesy Scribe is
   unaffected until it re-pins (touch density is the default; its
   `ForgeTokens` literals keep compiling).
4. Keep the callback shapes aligned with forge-core's real API as it lands
   (the spec's `ForgeAccountSettings` sketch is the contract).

## Open items

### Spec

- **Seed color for each existing app** is the spec's one remaining open item.
  The cheese app's is rind amber `#B3641B`, with its designed scheme.

### Repo and process

- **Release pipeline gate.** Fixed in the org workflow on 2026-10-10
  (`tkforgeworks/.github` PR #16): `publish` now requires the CI gate to have
  passed. No release has run under the fix with a failing gate, so the first
  time a gate fails, confirm that nothing was published.
- **Goldens are compared exactly.** They were generated on Linux with
  Flutter 3.47.5, the version CI pins. Bumping Flutter means regenerating
  them in the same PR.
