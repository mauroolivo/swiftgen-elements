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
