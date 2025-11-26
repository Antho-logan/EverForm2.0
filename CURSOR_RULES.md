This file intentionally mirrors `CURSOR_RULES.md` for tools that expect a lowercase filename.

See `CURSOR_RULES.md` for the authoritative rules.

# Cursor Rules – Biohack iOS App

## Assistant Operating Mode (Enforcement + GPT‑5 Practices)
- These rules are authoritative. The assistant must enforce them on every response.
- Confidence gate: if <95% confident (R-95%), ask clarifying questions before editing code.
- Tagging (R-TRACE): echo applied rule tags in each response, e.g., `Applied: R-LOGS, S-OBS1`.
- Reasoning Effort control: default to medium; lower for concise tasks; raise for complex refactors/migrations.
- Output style: structured, explicit, predictable. Resolve ambiguities; avoid contradictions.
- Few-shot/examples when needed to maximize instruction adherence and clarity.
- After loading these rules, wait for explicit user instructions before scaffolding or creating files.

## Always
- **(R-LOGS)** Add debug logs & inline comments in all code for readability and troubleshooting.
- **(R-TRACE)** When you apply any rule(s) from this document, echo the rule tags (e.g., `Applied: R-LOGS, S-OBS1`) in your output.
- **(R-95%)** Do not modify code until you are ≥95% confident you understand the request. Ask clarifying questions until you reach that threshold.

## Environment & Build
- **(E-SWEETPAD)** CRITICAL: Do NOT touch the Sweeppad connection or related build scripts/configuration. Ensure all changes compile to avoid breaking the connection.

## Project
- **(P-ROOT)** All files live under: `/EverForm`
- **(P-ENTRY)** App entry file: `EverFormApp.swift` with `@main` and SwiftUI `App`.
- **(P-ARCH)** SwiftUI + MVVM using Observation. Single target, no extra modules.
- **(P-ENV)** Support dev / test / prod via XCConfig + Info.plist keys (no hardcoded secrets).
- **(P-SCOPE)** iOS only (iOS 17+).

## Tech Stack
- **(T-UI)** SwiftUI (UIKit fallback only if absolutely necessary).
- **(T-DB)** Supabase for database and authentication.
- **(T-REV)** RevenueCat for monetization.
- **(T-TEL)** TelemetryDeck for analytics.
- **(T-RAG)** KnowledgeService stub for RAG retrieval.

## Swift Coding Rules
- **(C-SIMPLE)** Prefer simple, clear solutions. Keep files ≤300 LOC; refactor at that point.
- **(C-DRY)** Avoid duplication—reuse existing code.
- **(C-CLEAN)** Keep codebase tidy and organized.
- **(C-ONEOFF)** Avoid one-off scripts inside app targets.
- **(C-REALDATA)** Mock data only in tests (never in dev/prod code).
- **(C-ENVSAFE)** Never overwrite `.env`; never commit secrets.

## State Management (Observation)
- **(S-OBS1)** Annotate view models with `@Observable final class …`.
- **(S-OBS2)** In Views, don’t use @StateObject for VMs; inject as `let model: MyModel`.
- **(S-CHILDREF)** For reference-type state, pass via initializer to child views.
- **(S-BINDVAL)** For value-type state, use @Binding only if child writes; pass value otherwise.
- **(S-ENV)** Use @Environment only for app-wide shared dependencies.
- **(S-LOCAL)** Use @State only for local view state.

## Performance
- **(P-LAZY)** Use LazyVStack/HStack/VGrid for large lists/grids.
- **(P-ID)** Use stable id values in ForEach.

## Lifecycle
- **(L-APP)** @main SwiftUI App; structure with Scenes.
- **(L-VIEW)** Use onAppear/onDisappear for light hooks.

## Data Flow & Errors
- **(D-OBS)** Use Observation for reactivity.
- **(D-ERR)** Propagate errors with typed Error + Result; surface safe messages to users.

## Testing
- **(TST-UNIT)** Unit tests for ViewModels & business logic in UnitTests/.
- **(TST-UI)** UI tests for critical flows in UITests/.
- **(TST-PREV)** SwiftUI previews with sample inputs.

## SwiftUI Patterns
- **(UI-BIND)** Use @Binding for two-way parent↔child only.
- **(UI-PREFKEY)** Use custom PreferenceKey for child→parent communication.
- **(UI-DI)** Use @Environment for dependency injection of global services.

## Security
- **(SEC-SAFE)** No secrets in code or logs. Don’t store sensitive data insecurely.
- **(SEC-NET)** Strip PII from telemetry; avoid verbose payloads.

## Declarations & Modules
- **(DECL-DUPE)** Check that a type doesn’t already exist before creating it.
- **(MOD-ONE)** No extra modules or packages; single app target.

---

# Folder Structure
/EverForm/
  EverForm.xcodeproj/
  EverForm/
    EverFormApp.swift
    Config/
      Config.dev.xcconfig
      Config.test.xcconfig
      Config.prod.xcconfig
    Core/
      Theme/
      Logging/
      Services/
        SessionStore.swift
        PreferenceService.swift
        ProfileService.swift
        KnowledgeService.swift
        SupabaseService.swift
        RevenueCatService.swift
        TelemetryService.swift
    Features/
      Onboarding/
      MainMenu/
      Training/
      Nutrition/
      Sleep/
      Mobility/
      Supplements/
      Progress/
      Knowledge/
      Settings/
    Resources/
      Assets.xcassets
      Localized.strings (en, nl)
    Tests/
      UnitTests/
      UITests/

---

# Start-of-Work Checklist (R-95%)
Before any change, Cursor must:
1) Identify the exact user story & impacted files.  
2) List which rules will be applied (tags).  
3) Ask questions if confidence <95%.  
4) Proceed only when ≥95% confident and echo applied rule tags in the output.
