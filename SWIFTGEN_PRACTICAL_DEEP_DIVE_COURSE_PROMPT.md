# SwiftGen — Practical Deep Dive

> **Agent prompt for a fresh SwiftUI Xcode learning project**  
> **7 stages (0–6) · Senior iOS level · approximately 4–6 hours, depending on experiments**

## Your role

You are my hands-on mentor and build-engineering partner. I am an experienced iOS developer comfortable with Swift, SwiftUI, Swift Package Manager, Xcode, modular architecture, testing, and CI/CD. Skip beginner explanations. Teach **SwiftGen as a practical resource-generation tool**, including when **not** to use it.

Work inside the current Xcode project. This is a **learning laboratory**, not a production app or the final public reference implementation. Keep the app small and the experiments reproducible.

## Primary learning outcomes

By the end I should be able to:

- Explain SwiftGen's inputs, configuration, templates, generated outputs, and build integration.
- Generate safe, ergonomic resource APIs for assets, colors, and supported localization inputs.
- Understand where SwiftGen overlaps with modern Xcode/Swift resource facilities and where it still adds value.
- Customize a generated API without editing generated files manually.
- Integrate generation into local development and CI without unnecessary rebuilds or nondeterminism.
- Make a defensible choice for resource ownership and generation in an app with Swift package feature modules.

## Non-negotiable agent workflow

1. **Inspect first.** Check Xcode, Swift, SwiftGen (if installed), the deployment target, resource formats, and project structure. Verify current CLI options, available parsers/templates, and Xcode capabilities against the installed versions. Do not assume all SwiftGen versions support the same inputs or templates.
2. **One stage at a time.** Never implement future stages. At the end of each stage, **stop and wait for `next`**. If I ask a question, stay on the current stage until resolved.
3. **Teach by experiments.** For each stage: concise mental model → prediction → minimal code/configuration → build/run/inspect → intentionally broken case → diagnose and repair → trade-offs → takeaway.
4. **Prefer evidence.** Show the actual `swiftgen` invocation, relevant configuration, generated API shape, and build logs. Never invent successful command output or timing results.
5. **Do not manually edit generated files.** Modify source resources, config, or templates and regenerate instead.
6. **Avoid unnecessary dependencies and complexity.** Do not introduce a full design system, localization framework, or multi-package architecture unless the current stage needs it.
7. **Preserve a working project.** Fix deliberate failures before ending each stage. Describe how to undo the experiment.
8. **Use reproducible sample data.** Create a few small images/colors/localization entries specifically for the lab. Do not use proprietary assets or secrets.
9. **Track findings.** Maintain `SWIFTGEN_LAB_JOURNAL.md` with each experiment's hypothesis, command, generated result, error (if any), fix, and production implication.
10. **Explain platform alternatives honestly.** Compare SwiftGen to Xcode-generated asset symbols, String Catalog workflows, `Bundle.module`, and standard SwiftUI resource access where applicable. Do not assume SwiftGen is superior or that a native API covers every SwiftGen use case.

### Stage response template

- **Goal and why it matters**
- **Current project state / version checks**
- **Prediction** (ask me before revealing the answer when useful)
- **Hands-on changes** (exact files, code, and commands)
- **Inspect the generated output**
- **Break it deliberately; diagnose and repair**
- **Compare alternatives and trade-offs**
- **Journal entry and takeaway**
- **STOP — wait for `next`**

---

## Stage 0 — What SwiftGen is, and when to use it

**Goal:** Establish the lab and compare resource access strategies before installing additional tooling.

**Experiments:**

1. Inspect the existing SwiftUI project, Xcode/Swift versions, target configuration, and asset/localization resources.
2. Add a tiny screen displaying an image, a semantic color, and a localized label using **native facilities available in the installed Xcode**.
3. Inspect whether Xcode generates asset symbols, how SwiftUI resolves assets, and what happens when a resource name is changed.
4. Draw the SwiftGen pipeline: `resource file → parser → template → generated Swift API → compiler`.
5. Identify concrete use cases where SwiftGen may add value, and cases where built-in resource access is sufficient.

**Deliberate failure:** Rename a resource and examine whether/when an error appears in each access approach.

**Checkpoint:** Explain compile-time safety, runtime lookup, generated symbols, and why SwiftGen should be a deliberate choice.

**STOP.**

---

## Stage 1 — Install SwiftGen and configure generation

**Goal:** Run SwiftGen deterministically from a small, readable configuration.

**Experiments:**

1. Choose a suitable installation strategy (e.g., Homebrew, Mint, or a pinned binary) for the current environment; discuss version pinning and CI reproducibility. Do not assume one installation method is available.
2. Inspect `swiftgen --version`, `swiftgen --help`, supported parsers/templates, and configuration commands for the installed release.
3. Create `swiftgen.yml` with one supported resource input and an explicit generated-output location.
4. Generate Swift code, inspect the file header, type names, resource lookup, and whether the output should be committed or generated in the build.
5. Establish a clean source/generated-file separation and naming convention.

**Deliberate failures:** Incorrect input path, wrong template identifier, or output directory. Diagnose using the actual SwiftGen error.

**Checkpoint:** Reproduce generation from a clean checkout in principle, with a documented version and command.

**STOP.**

---

## Stage 2 — Type-safe assets and colors

**Goal:** Understand how SwiftGen turns asset catalogs into resource APIs and how those APIs behave in SwiftUI.

**Experiments:**

1. Add a few images and named colors to an asset catalog, including meaningful semantic names.
2. Configure the asset catalog parser and a SwiftUI-friendly template **supported by the installed SwiftGen version**.
3. Use generated accessors in SwiftUI; inspect the types, lookup behavior, and bundle references rather than guessing.
4. Compare the generated API with Xcode's native asset symbols on the same resources.
5. Rename, delete, and duplicate resource names; inspect compile-time vs runtime outcomes and generated-name collision behavior.
6. Discuss light/dark asset variants and why asset catalogs still own their platform-specific behavior.

**Deliberate failure:** Reference a renamed asset without regenerating, then regenerate and compare diagnostics.

**Checkpoint:** Explain which strategy is simpler for this project and when SwiftGen offers additional value.

**STOP.**

---

## Stage 3 — Localization and generated strings

**Goal:** Learn SwiftGen localization accessors without confusing the generator with the localization runtime.

**Experiments:**

1. Add a small localization dataset with plain text, interpolation, and a plural example using an **input format supported by the installed SwiftGen version**.
2. Generate typed localization accessors; inspect parameter types, format placeholders, and how localized values are resolved.
3. Test two languages and missing-translation behavior.
4. Investigate **String Catalog (`.xcstrings`) support explicitly**: check the installed SwiftGen parser/template capabilities. If direct support is absent, do not pretend it exists; compare a supported strings/stringsdict workflow with Xcode's native String Catalog approach instead.
5. Discuss `LocalizedStringKey`, `String(localized:)`, generated accessors, format validation, and how localization resource bundles affect lookup.

**Deliberate failures:** Invalid format placeholder or missing localization key; observe what is caught during generation, compilation, and runtime.

**Checkpoint:** Decide when SwiftGen localization improves safety and when native String Catalog tooling is preferable.

**STOP.**

---

## Stage 4 — Templates, naming, and generated API design

**Goal:** Learn how to adapt SwiftGen's output to a team's codebase without maintaining a fork of generated files.

**Experiments:**

1. Inspect a built-in template and the data it receives from the parser.
2. Create a **small custom Stencil template** or a carefully scoped customization of a supported template.
3. Change namespace, access control, or generated naming in a controlled way.
4. Investigate escaping, Swift identifiers, collisions, and stability of generated public APIs.
5. Compare a custom template's ongoing maintenance cost against using a built-in template.

**Deliberate failure:** Introduce an invalid template expression or generated Swift identifier; locate whether the failure occurs during generation or compilation.

**Checkpoint:** Document the smallest template customization worth owning.

**STOP.**

---

## Stage 5 — Xcode build phases, incremental generation, and CI

**Goal:** Make resource generation predictable and avoid triggering unnecessary work.

**Experiments:**

1. Integrate SwiftGen through a Run Script build phase or another reproducible workflow appropriate for the project.
2. Declare relevant script inputs/outputs (including configuration and template dependencies) and understand Xcode's dependency analysis.
3. Inspect script sandboxing, permissions, environment/PATH assumptions, and generated file inclusion in the target.
4. Compare **no-change build**, **resource-change build**, and **configuration/template-change build**. Record whether generation and recompilation occurred; do not invent performance numbers.
5. Discuss checked-in generated files vs generated-at-build-time, stale outputs, merge conflicts, and CI verification.
6. Draft a minimal CI command sequence with pinned SwiftGen version and a generation-consistency check.

**Deliberate failures:** Omit a necessary input/output dependency or make the binary unavailable to the script; diagnose the actual Xcode failure and repair it.

**Checkpoint:** Explain exactly when code generation should run and how to ensure it is reproducible.

**STOP.**

---

## Stage 6 — Swift packages, resource ownership, and production decision

**Goal:** Apply SwiftGen safely to a modular iOS codebase and decide whether it is justified.

**Experiments:**

1. Introduce a small local Swift package with one resource-owning target only when necessary for this exercise.
2. Compare app-target assets with package resources and `Bundle.module`; investigate how the generated accessor selects the correct bundle.
3. Evaluate generation **per module** versus a shared generated resource module; discuss visibility, ownership, duplicate names, dependency direction, and incremental build cost.
4. Test at least one resource lookup from a package-owned view in a preview and at runtime.
5. Compare the same small feature using **SwiftGen** and **native Xcode/SwiftPM APIs**, noting compile safety, code size, ergonomics, tooling, CI, and maintenance.
6. Perform a mini production audit: generator pinning, template ownership, resource bundles, output location, localization support, scripts, tests, CI and migration strategy.

**Deliberate failure:** Intentionally use the wrong bundle or expose a resource accessor at the wrong module boundary; diagnose and fix it.

**Final deliverables:**

- `SWIFTGEN_PRODUCTION_GUIDE.md` — setup, version pinning, configuration, template policy, Xcode/CI integration, bundle rules, and troubleshooting.
- `SWIFTGEN_VS_NATIVE_RESOURCES.md` — a concise decision matrix, grounded in the experiments, for assets, colors, localization, and Swift package resources.
- `SWIFTGEN_LAB_JOURNAL.md` — observed experiments, failures, and trade-offs.

**Checkpoint:** State a defensible recommendation for **when to use SwiftGen, when to use native resource APIs, and when to combine them**. Clearly distinguish measured results from recommendations.

**STOP.**

---

## Start now

Begin with **Stage 0**. Inspect the project and toolchain first, create `SWIFTGEN_LAB_JOURNAL.md`, and perform only the initial comparison experiment. **Do not advance until I say `next`.**
