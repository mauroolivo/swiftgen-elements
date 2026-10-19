# SwiftGen Lab Journal

## Stage 0 — Initial comparison experiment

### Goal
Establish the native-resource baseline before changing the app or relying on SwiftGen-generated APIs.

### Hypothesis
This fresh SwiftUI app will already have some native Xcode resource-generation capabilities enabled, but there will be little or no meaningful generated surface until the project contains named assets or localization data beyond the defaults.

### Commands run
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && printf 'Xcode:\n' && xcodebuild -version && printf '\nSwift:\n' && swift --version && printf '\nSwiftGen:\n' && if command -v swiftgen >/dev/null 2>&1; then swiftgen --version; else echo 'swiftgen not installed'; fi

cd /Users/mauro/files/code/uimatters/swiftgen-elements && xcodebuild -list -project swiftgen-elements.xcodeproj

cd /Users/mauro/files/code/uimatters/swiftgen-elements && xcodebuild -project swiftgen-elements.xcodeproj -scheme swiftgen-elements -configuration Debug -destination 'generic/platform=iOS Simulator' build | cat
```

### Observed project state
- App entry point: `swiftgen-elements/swiftgen_elementsApp.swift`
- Root view: `swiftgen-elements/ContentView.swift`
- Current UI uses only native SwiftUI APIs: `Image(systemName: "globe")`, `.foregroundStyle(.tint)`, and `Text("Hello, world!")`
- Asset catalog currently contains only:
  - `AccentColor.colorset`
  - `AppIcon.appiconset`
- No localization files found yet:
  - no `.strings`
  - no `.stringsdict`
  - no `.xcstrings`
  - no `.lproj` directories

### Version / configuration checks
- Xcode: `27.1 (27A9269)`
- Swift: `Apple Swift version 6.4`
- SwiftGen: `6.6.2` already installed locally
- iOS deployment target in `project.pbxproj`: `27.0`
- `LOCALIZATION_PREFERS_STRING_CATALOGS = YES`
- `STRING_CATALOG_GENERATE_SYMBOLS = YES`
- `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES`
- `ENABLE_USER_SCRIPT_SANDBOXING = YES`

### Build result
- Baseline app build succeeded with no code changes.
- Xcode emitted a derived file at:
  - `DerivedSources/GeneratedAssetSymbols.swift`

### Generated result inspected
`GeneratedAssetSymbols.swift` exists, which confirms Xcode is prepared to generate native asset symbol APIs.

Important nuance from this baseline:
- the generated color/image symbol extensions are currently empty
- the file contains the bundle plumbing and typed resource support infrastructure
- with only `AccentColor` and `AppIcon`, there are no useful app-specific named asset accessors yet

### Error encountered
None during the initial inspection.

### Fix applied
None needed.

### Production implication
Modern Xcode already participates in resource API generation. SwiftGen is therefore not automatically justified just because a project uses assets or localization; the value proposition has to be compared against the native generated/resource APIs actually available in the installed Xcode.

### Open questions for the next Stage 0 experiment
- What native API shape appears after adding named color/image assets?
- How do native string/localization facilities behave once we add localizable content?
- When a resource is renamed, which access patterns fail at compile time versus runtime?

## Stage 1 — Install SwiftGen and configure generation

### Goal
Run SwiftGen deterministically from a small, readable configuration using one supported input type.

### Hypothesis
Given `swiftgen` is already installed, we should generate a single assets API file from all 3 catalogs with `swiftgen config run`, and deliberate config mistakes should fail with clear diagnostics.

### Installation strategy decision (for this lab)
- Current environment already has Homebrew-managed SwiftGen `6.6.2` at `/opt/homebrew/bin/swiftgen`.
- For this lab, we used the installed binary and documented exact version/commands.
- Production implication: Homebrew is machine-global; teams should pin tool version in CI and/or use a project-pinned binary strategy for stricter reproducibility.

### Commands run
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen --version && echo '---' && swiftgen --help && echo '---' && swiftgen config --help && echo '---' && swiftgen template --help && echo '---' && swiftgen run --help

cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen template list | cat

cd /Users/mauro/files/code/uimatters/swiftgen-elements && mkdir -p swiftgen-elements/Generated/SwiftGen && swiftgen config lint && swiftgen config run --verbose
```

### Configuration used
`swiftgen.yml`
```yaml
xcassets:
  inputs:
    - swiftgen-elements/Assets.xcassets
    - swiftgen-elements/Colors.xcassets
    - swiftgen-elements/Icons.xcassets
  outputs:
    - templateName: swift5
      output: swiftgen-elements/Generated/SwiftGen/Assets+Generated.swift
```

### Generated result inspected
Generated file:
- `swiftgen-elements/Generated/SwiftGen/Assets+Generated.swift`

Observed API shape highlights:
- `internal enum Asset`
- `Asset.Assets.accentColor`
- `Asset.Colors.accent`
- `Asset.Colors.base`
- `Asset.Icons.caretLeftLight`
- helper types: `ColorAsset`, `ImageAsset`, and `BundleToken`

### Deliberate failure A (incorrect input path)
Temporary bad config used:
- `swiftgen.bad-input.yml` with `swiftgen-elements/DoesNotExist.xcassets`

Command:
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen config run --config swiftgen.bad-input.yml
```

Actual error:
- `swiftgen: error: File swiftgen-elements/DoesNotExist.xcassets not found.`
- `Error: There was an error with your configuration file, see above for more information.`

### Deliberate failure B (wrong template name)
Temporary bad config used:
- `swiftgen.bad-template.yml` with `templateName: swift6`

Command:
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen config run --config swiftgen.bad-template.yml
```

Actual error:
- `Error: Template named swift6 not found. Use 'swiftgen template list' to list available named templates or use 'templatePath' to specify a template by its full path.`

### Repair
Re-ran valid config and confirmed deterministic output state:
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen config lint --config swiftgen.yml && swiftgen config run --config swiftgen.yml && ls -l swiftgen-elements/Generated/SwiftGen/Assets+Generated.swift
```

Observed:
- `Not writing the file as content is unchanged`
- output file remains present and up to date

Cleanup:
- removed temporary failure files (`swiftgen.bad-input.yml`, `swiftgen.bad-template.yml`)

### Production implication
- `swiftgen.yml` is a reproducible source of truth for generation inputs and outputs.
- `swiftgen config lint` is a fast sanity gate before generation.
- template/input errors fail early with actionable messages.
- unchanged output write-skipping helps reduce noisy diffs and unnecessary downstream work.

### Takeaway
Stage 1 goal met: generation is reproducible from config, output location is explicit, and failure diagnostics are clear enough to debug common setup mistakes quickly.


## Stage 2 — Type-safe assets and colors

### Goal
Understand how SwiftGen turns asset catalogs into APIs, how those APIs behave in SwiftUI, and how this compares with native Xcode asset symbols.

### Hypothesis
SwiftGen and native Xcode asset symbols should both provide compile-time safety once symbols are regenerated, but their failure timing differs when an asset is renamed and generation is out of date.

### Hands-on changes
Added sample resources:
- `swiftgen-elements/Colors.xcassets/status-warning.colorset/Contents.json`
- `swiftgen-elements/Icons.xcassets/caret-right-light.imageset/Contents.json`
- `swiftgen-elements/Icons.xcassets/caret-right-light.imageset/caret-right-light.svg`

Updated view usage in:
- `swiftgen-elements/ContentView.swift`

The view now shows side-by-side usage:
- SwiftGen API: `Asset.Icons.*.swiftUIImage`, `Asset.Colors.statusWarning.swiftUIColor`
- Native API: `Image(.caretLeftRenamed)`, `Color.statusWarning`

### Commands run
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen config run --verbose

cd /Users/mauro/files/code/uimatters/swiftgen-elements && xcodebuild -project swiftgen-elements.xcodeproj -scheme swiftgen-elements -configuration Debug -destination 'generic/platform=iOS Simulator' build | cat
```

### Inspect the generated output
SwiftGen output file:
- `swiftgen-elements/Generated/SwiftGen/Assets+Generated.swift`

Confirmed symbols include:
- `Asset.Colors.statusWarning`
- `Asset.Icons.caretLeftRenamed`
- `Asset.Icons.caretRightLight`

Native Xcode generated symbols (DerivedSources) included:
- `Color.statusWarning`
- `ImageResource.caretLeftRenamed`
- `ImageResource.caretRightLight`

### Deliberate failure; diagnose and repair
#### Failure setup
Renamed icon asset folder from `caret-left-light.imageset` to `caret-left-renamed.imageset` (and matching svg filename) without first updating usage.

#### Build without regenerating SwiftGen
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && xcodebuild -project swiftgen-elements.xcodeproj -scheme swiftgen-elements -configuration Debug -destination 'generic/platform=iOS Simulator' build | cat
```
Observed error:
- `type 'ImageResource' has no member 'caretLeftLight'`

Interpretation:
- Native symbols are regenerated during build, so stale native references fail immediately at compile time.
- SwiftGen reference to old generated symbol did not fail yet because SwiftGen had not been rerun.

#### Build after regenerating SwiftGen
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen config run --verbose
cd /Users/mauro/files/code/uimatters/swiftgen-elements && xcodebuild -project swiftgen-elements.xcodeproj -scheme swiftgen-elements -configuration Debug -destination 'generic/platform=iOS Simulator' build | cat
```
Observed error:
- `type 'Asset.Icons' has no member 'caretLeftLight'`

Interpretation:
- After regeneration, SwiftGen aligns to renamed assets and stale Swift references fail at compile time too.

#### Repair
Updated references to renamed symbol in `swiftgen-elements/ContentView.swift`:
- `Asset.Icons.caretLeftRenamed`
- `Image(.caretLeftRenamed)`

Verification build succeeded.

### Compare alternatives and trade-offs
- Native asset symbols are zero-config once Xcode setting is enabled and update on every build.
- SwiftGen adds explicit generated source control, customizable templates, and cross-resource consistency.
- With SwiftGen, forgetting to regenerate can defer failures (or become runtime failures if stale generated code still compiles and code path executes).
- With native symbols, renamed assets usually fail at compile time on next build without extra generation steps.

### Undo / rollback notes
- To undo this experiment, rename `caret-left-renamed.imageset` back to `caret-left-light.imageset`, revert `ContentView.swift`, then rerun `swiftgen config run`.

### Takeaway
For this project size, native symbols are simpler operationally. SwiftGen still provides value when teams want a controlled generated API surface, template customization, and standardized resource access patterns across modules.


## Stage 3 — Localization and generated strings

### Goal
Learn SwiftGen localization accessors and separate what generation validates from what localization runtime resolves.

### Hypothesis
SwiftGen should generate typed `L10n` accessors from `.strings`/`.stringsdict`; argument type mismatches should fail at compile time, while missing translation values in secondary locales remain a runtime concern.

### Hands-on changes
Added localization resources:
- `swiftgen-elements/en.lproj/Localizable.strings`
- `swiftgen-elements/en.lproj/Localizable.stringsdict`
- `swiftgen-elements/es.lproj/Localizable.strings`
- `swiftgen-elements/es.lproj/Localizable.stringsdict`

Configured strings generation in:
- `swiftgen.yml`

Current strings config:
```yaml
strings:
  inputs:
    - swiftgen-elements/en.lproj
  outputs:
    - templateName: structured-swift5
      output: swiftgen-elements/Generated/SwiftGen/L10n+Generated.swift
```

Updated `swiftgen-elements/ContentView.swift` to use:
- `L10n.Home.title`
- `L10n.Home.welcome(username)`
- `L10n.Notifications.unread(unreadCount)`
- `L10n.Cart.items(unreadCount)`

### Commands run
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen config lint && swiftgen config run --verbose

cd /Users/mauro/files/code/uimatters/swiftgen-elements && xcodebuild -project swiftgen-elements.xcodeproj -scheme swiftgen-elements -configuration Debug -destination 'generic/platform=iOS Simulator' clean build | cat
```

### Inspect the generated output
Generated file:
- `swiftgen-elements/Generated/SwiftGen/L10n+Generated.swift`

Generated API shape includes:
- `L10n.Home.title`
- `L10n.Home.welcome(_:)`
- `L10n.Notifications.unread(_:)` with `Int`
- `L10n.Cart.items(_:)` with `Int` (plural key from stringsdict)

### Break it deliberately; diagnose and repair
#### Failure A: duplicate table input config
Tried strings inputs as both `en.lproj` and `es.lproj`.

Observed SwiftGen error:
- `Error: Duplicate file of the same type for table "Localizable" ...`

Fix:
- use one development-localization input (`en.lproj`) for code generation.
- keep other locales (`es.lproj`) for runtime localization resources.

#### Failure B: wrong accessor argument type
Deliberately changed:
- `L10n.Notifications.unread(unreadCount)` -> `L10n.Notifications.unread("three")`

Observed compile-time error:
- `cannot convert value of type 'String' to expected argument type 'Int'`

Fix:
- restored typed call with `Int` argument.

### Runtime localization check (two locales + missing key)
Used a Swift script to inspect `en.lproj` and `es.lproj` directly:
- `[en] title=Inbox`
- `[en] welcome=Welcome, Mauro!`
- `[en] unread=3 unread notifications`
- `[en] cart=3 items in cart`
- `[es] title=Bandeja`
- `[es] welcome=Hola, Mauro!`
- `[es] unread=notifications.unread` (missing key behavior)
- `[es] cart=3 articulos en el carrito`

### String Catalog support check
Installed SwiftGen `6.6.2` exposes parsers including `strings`/`xcassets` but no dedicated `.xcstrings` parser command in `swiftgen --help` or `swiftgen run --help`.

### Compare alternatives and trade-offs
- SwiftGen gives typed localization function signatures and catches argument-type misuse at compile time.
- Missing translations across locales are not fully validated by this generation setup; they still require runtime checks/tests.
- Native Xcode String Catalog workflows are strong for translation management, while SwiftGen adds explicit code API control for `.strings`/`.stringsdict` pipelines.

### Undo / rollback notes
- Remove `strings:` section from `swiftgen.yml`.
- Delete `en.lproj` / `es.lproj` localization files.
- Delete `swiftgen-elements/Generated/SwiftGen/L10n+Generated.swift`.
- Revert localization usage in `swiftgen-elements/ContentView.swift`.

### Takeaway
SwiftGen localization accessors improve call-site type safety and ergonomics, but translation completeness remains a runtime/testing responsibility. For this setup, SwiftGen and native localization tooling are complementary rather than mutually exclusive.

## Stage 4 - Templates, naming, and generated API design

### Goal
Customize generated localization API shape (namespace + access control) using a small owned template, then evaluate maintenance cost and failure behavior.

### Hypothesis
Duplicating the built-in strings template with minimal edits should let us safely change namespace and visibility while preserving parser behavior. A broken template should fail at generation time with a Stencil parse error.

### Commands run
```bash
cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen template --help

cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen template list | cat

cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen template cat strings structured-swift5 | cat

cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen config lint --config swiftgen.yml && swiftgen config run --config swiftgen.yml --verbose | cat

cd /Users/mauro/files/code/uimatters/swiftgen-elements && swiftgen strings swiftgen-elements/en.lproj --templatePath swiftgen-elements/Templates/strings-stage4-bad.stencil --output /tmp/Stage4Bad.swift 2>&1 | cat

cd /Users/mauro/files/code/uimatters/swiftgen-elements && rm -f swiftgen-elements/Templates/strings-stage4-bad.stencil && swiftgen config lint --config swiftgen.yml && swiftgen config run --config swiftgen.yml --verbose | cat

cd /Users/mauro/files/code/uimatters/swiftgen-elements && xcodebuild -project swiftgen-elements.xcodeproj -scheme swiftgen-elements -configuration Debug -destination 'generic/platform=iOS Simulator' build 2>&1 | cat
```

### Hands-on changes
Added custom template:
- `swiftgen-elements/Templates/strings-structured-swift5-lab.stencil`

Updated config outputs (in both config files used in repo):
- `swiftgen.yml`
- 
Added second strings output with params:
- `templatePath: swiftgen-elements/Templates/strings-structured-swift5-lab.stencil`
- `output: swiftgen-elements/Generated/SwiftGen/StringsLab+Generated.swift`
- `params.enumName: StringsLab`
- `params.publicAccess: true`

Updated usage in:
- `swiftgen-elements/ContentView.swift`

Added Stage 4 section that calls:
- `StringsLab.Home.title`
- `StringsLab.Home.welcome(username)`
- `StringsLab.idCancel`

### Inspect the generated output
Generated custom file:
- `swiftgen-elements/Generated/SwiftGen/StringsLab+Generated.swift`

Observed API differences vs built-in output:
- root enum renamed from `L10n` to `StringsLab`
- visibility changed from `internal` to `public`
- same nested key structure and typed function signatures preserved

Template data/features confirmed from built-in template inspection:
- `tables` tree (table names, levels, strings)
- per-key metadata (`string.key`, `string.translation`, `string.types`)
- params used for customization (`enumName`, `publicAccess`, `bundle`, `lookupFunction`, etc.)

### Break it deliberately; diagnose and repair
#### Failure
Created a temporary invalid Stencil template (`strings-stage4-bad.stencil`) with malformed `{% if %}` syntax.

Observed SwiftGen error:
- `Error: 'if' expression error: dangling token`

#### Repair
- removed bad template file
- reran `swiftgen config lint` + `swiftgen config run`
- rebuilt app successfully

### Compare alternatives and trade-offs
- Built-in templates have near-zero maintenance and are safest for long-term upgrades.
- Small custom templates are useful when a team needs stable naming/visibility conventions not covered by params alone.
- Owning a template introduces upgrade overhead (diffing upstream template changes, validating compatibility after SwiftGen updates).
- The smallest worthwhile customization here is namespace/access control while preserving parser logic and runtime lookup behavior.

### Undo / rollback notes
- Remove custom strings output from `swiftgen.yml`.
- Delete `swiftgen-elements/Templates/strings-structured-swift5-lab.stencil`.
- Delete `swiftgen-elements/Generated/SwiftGen/StringsLab+Generated.swift`.
- Remove `StringsLab` calls from `swiftgen-elements/ContentView.swift`.

### Takeaway
Stage 4 confirms that targeted template ownership works well when customization scope is small and explicit. The custom namespace/access change is valuable; deeper divergence from built-in templates should be justified by clear API needs because maintenance cost grows quickly.

