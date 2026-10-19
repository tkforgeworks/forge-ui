# forge-ui & forge-core: Shared Flutter Packages Spec (pointer)

The spec lives in one place: **`tkforgeworks/forge-core`**,
[`docs/forge-ui_forge-core_Shared_Flutter_Packages_Spec.md`](https://github.com/tkforgeworks/forge-core/blob/main/docs/forge-ui_forge-core_Shared_Flutter_Packages_Spec.md)
(on `main` once FC-1 is released; until then on `v0.1.0/main`). Decided
2026-10-17 (cheesy-scribe CHEESE-57, decision 10): this repo used to carry a
byte-identical copy, and every spec change was two PRs that had to land
together. Spec changes are now forge-core PRs under its Jira project `FC`.

What the spec asks of forge-ui, as of its 2026-10-17 revision:

- **Shared first for high-reuse screens.** Sign-in, account, settings, about,
  licences and feedback screens are built here before a second app exists;
  the rule of three applies only to ambiguous reuse.
- **v0.2** (alongside forge-core v0.1, for cheesy-scribe 0.3.0):
  `ForgeSignInProvider` (google, email, apple), `ForgeSignInButton`,
  `ForgeSignInPanel` and `ForgeSignInScreen` (Google button plus an
  always-present email/password form: sign in, create account, forgot
  password; optional skip), "check your email" and "set a new password"
  screens, `ForgeAccountSettings`, `ForgeSignOutSheet` with an "also erase
  this phone" option, `showForgeConfirmSheet(typeToConfirm:)`, busy states.
- **`ForgeProviderBrand`**: the second exception to the no-hardcoded-color
  rule, holding the colors Google mandates for its button.
- **Google Sans Flex** (OFL 1.1) Medium instance for the Google button label,
  plus Google's official "G" logo under `assets/brand/providers/`, both
  listed in `NOTICE`.
- Apple's button and linked-method row wait for the first iOS app.
