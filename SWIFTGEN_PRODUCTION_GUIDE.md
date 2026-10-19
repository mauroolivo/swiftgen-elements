# SwiftGen Production Guide

## Scope
This guide captures a production-ready baseline from the lab findings in `SWIFTGEN_LAB_JOURNAL.md`.

## 1) Version pinning
- Pin SwiftGen in CI and document local install method.
- Record expected version in team docs (lab used `6.6.2`).
- Add a CI check:

```bash
swiftgen --version
```

## 2) Repository layout
- Keep canonical config at repo root: `swiftgen.yml`.
- Keep generated outputs in source tree under `Generated/`.
- Keep templates under a dedicated folder (for owned customizations), e.g. `swiftgen-elements/Templates/`.

Recommended structure:
- `swiftgen.yml`
- `swiftgen-elements/Generated/SwiftGen/`
- `swiftgen-elements/Templates/`

## 3) Configuration policy
- Keep parser inputs explicit and minimal.
- Prefer one development localization input for code generation (`en.lproj`), while shipping additional locales as runtime resources.
- Avoid duplicate-table string parser inputs across locales.

## 4) Template policy
- Prefer built-in templates unless customization is justified.
- If customizing, keep changes small (for example namespace/access control only).
- Treat custom templates as maintained source code.
- Review template compatibility when upgrading SwiftGen.

## 5) Xcode build integration
Use a Run Script build phase with explicit inputs/outputs and script sandbox compatibility.

Script baseline:
```sh
set -euo pipefail
if ! command -v swiftgen >/dev/null 2>&1; then
  echo "error: SwiftGen is not installed or not in PATH."
  exit 1
fi
cd "$SRCROOT"
swiftgen config lint --config "$SRCROOT/swiftgen.yml"
swiftgen config run --config "$SRCROOT/swiftgen.yml"
```

Important:
- Declare concrete input files (not only broad directories) when script sandboxing is enabled.
- Declare generated output files so Xcode dependency analysis can skip no-change runs.

## 6) Checked-in outputs vs build-time generation
Recommended hybrid policy:
- Keep generated files checked in for reviewability and deterministic clean checkouts.
- Also run generation in CI (and optionally in local builds) to detect drift.

CI consistency pattern:
```bash
swiftgen config lint --config swiftgen.yml
swiftgen config run --config swiftgen.yml
git diff --exit-code
```

## 7) Swift package resource ownership
For package-owned resources:
- Use `Bundle.module` as the baseline for native resource lookup.
- If using SwiftGen in packages, keep module-local config (e.g. `Packages/swiftgen.package.yml`).
- Add tests that prove correct bundle boundaries (wrong-bundle lookups should fail tests).

Observed caveat from lab:
- Built-in `xcassets` generation may need adaptation under strict Swift 6 concurrency checks in package contexts.

## 8) Test strategy
- Compile-time safety: ensure generated accessors are used in feature code.
- Runtime correctness: locale/bundle lookup tests.
- Regression checks:
  - renamed resources
  - missing localization keys
  - script PATH/tool availability failures

## 9) Troubleshooting
### `swiftgen` not found in build phase
- Error: `SwiftGen is not installed or not in PATH.`
- Fix: install/pin SwiftGen and ensure PATH resolution for Xcode build scripts.

### Script sandbox file access error
- Symptom: failed to load resource file under script phase.
- Fix: add exact files to build phase input paths.

### Duplicate localization table parse error
- Symptom: duplicate `Localizable` table from multiple locale inputs.
- Fix: generate from one development locale for accessor generation.

### Stale symbols after rename
- Symptom: old generated accessor still referenced.
- Fix: regenerate and update call sites.

## 10) Minimal CI sequence
```bash
cd /path/to/repo
swiftgen --version
swiftgen config lint --config swiftgen.yml
swiftgen config run --config swiftgen.yml
xcodebuild -project swiftgen-elements.xcodeproj -scheme swiftgen-elements -configuration Debug -destination 'generic/platform=iOS Simulator' build
```

## Recommendation
- Keep native APIs as the default for straightforward resource access.
- Add SwiftGen where typed accessors materially reduce risk (especially localization keys/arguments or standardized API surfaces across modules).
- Keep customization small, versioning explicit, and bundle boundaries test-covered.
