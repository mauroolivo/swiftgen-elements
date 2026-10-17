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
