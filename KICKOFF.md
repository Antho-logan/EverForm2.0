KICKOFF — EVERFORM (CREATE FILES + VERIFY)

You are ChatGPT-5 coding inside Cursor for the EverForm iOS app.

Before any work:
1) LOAD & FOLLOW these docs from the project root on every step:
   - `cursor_rules.md`  (coding/architecture/workflow rules)
   - `prompting_guide.md` (GPT-5 prompting style)
2) CONFIRM you’ve loaded them, list which rule tags you will apply, and ask questions ONLY if your confidence is <95%. Otherwise proceed.

TASK GOAL (Milestone 1 – Frame & Flow):
Create the minimal, runnable SwiftUI scaffold for EverForm using the exact file/folder structure below. Do NOT dump code inline; instead CREATE & SAVE files. Add debug logs and comments as required by rules.

FOLDER & FILES TO CREATE (no code in this prompt; you generate the code and save the files):
/tip tracker/
  tip_trackerApp.swift                      # @main entry; uses SwiftUI App + Scenes
  Config/
    Config.dev.xcconfig
    Config.test.xcconfig
    Config.prod.xcconfig
  Core/
    Theme/
      Theme.swift
      Palette.swift
    Logging/
      DebugLog.swift                         # Log utility; safe in DEBUG only
    Services/
      SessionStore.swift
      PreferenceService.swift
      ProfileService.swift
      KnowledgeService.swift                 # RAG stub; no network yet
      SupabaseService.swift                  # reads keys from Info.plist/XCConfig, no secrets in code
      RevenueCatService.swift
      TelemetryService.swift
  Features/
    Onboarding/
      OnboardingProfileView.swift
      OnboardingPreferencesView.swift
    MainMenu/
      MainMenuView.swift
      MainMenuViewModel.swift
    Auth/
      HomeView.swift
      LoginView.swift
      CreateAccountView.swift
  Resources/
    Assets.xcassets
    Localized.strings (en, nl)
  Tests/
    UnitTests/
      NutritionViewModelTests.swift
    UITests/
      OnboardingFlowUITests.swift

IMPLEMENTATION REQUIREMENTS:
- App Name: **EverForm** (bundle display), but keep main entry file named **tip_trackerApp.swift** (per rules).
- iOS only, iOS 17+, SwiftUI + Observation.
- Scene graph: Splash/Router → Home → (Login | CreateAccount) → Onboarding (Profile, Preferences) → MainMenu.
- Minimal UI with placeholders; no third-party UI libs.
- Add safe **debug logs** on every screen `onAppear` and inside each ViewModel intent.
- Add inline **comments** describing purpose and key decisions.
- Observation rules:
  - ViewModels annotated with `@Observable final class …`
  - Inject VMs as `let model: …` (no @StateObject for VMs).
  - Use `@State` only for truly local UI.

CONFIG & SECURITY:
- Create **three** xcconfig files and wire up Info.plist keys (no secrets hardcoded):
  - SUPABASE_URL, SUPABASE_ANON_KEY
  - REVENUECAT_API_KEY
  - TELEMETRY_APP_ID
  - APP_ENV = dev|test|prod
- Do NOT overwrite any `.env`. Do NOT log secrets or tokens.

SERVICES (stubs today):
- SupabaseService: init(url:key:), login/signup placeholders; no network calls yet.
- RevenueCatService: configure(apiKey:), isPro (default false), placeholders for offerings/purchase/restore.
- TelemetryService: configure(appID:), track(event:props:), strip PII.
- KnowledgeService: `search(_:domain:) -> [ProtocolHit]` and `getProtocol(id:) -> ProtocolDoc` returning empty placeholders.

VIEWS (scope for this kickoff):
- HomeView: welcome + CTAs (Login, Create Account).
- LoginView / CreateAccountView: simple forms; intents log taps; no real auth yet.
- OnboardingProfileView: capture gender, goal, height/weight/BF%; persist via ProfileService.
- OnboardingPreferencesView: theme, accent, diet style; persist via PreferenceService.
- MainMenuView: tiles (Training, Nutrition, Sleep & Recovery, Mobility, Supplements, Progress, Settings) with stub navigation.

TESTS:
- `NutritionViewModelTests.swift`: minimal example showing an intent test (no external deps).
- `OnboardingFlowUITests.swift`: launch app, navigate Home → Create Account (stub) → Onboarding → MainMenu.

THEMING:
- `Theme.swift` + `Palette.swift`: define light/dark friendly palette (ink/charcoal/sakura/indigo/matcha). Keep it simple and consistent.

ACCESSIBILITY & PERFORMANCE:
- Use `LazyVStack` where list-like content is present.
- Provide accessibility labels on primary CTAs.
- Keep files ≤300 LOC; split if larger.

WHAT TO OUTPUT (in this chat):
1) A brief confirmation: “Loaded cursor_rules.md & prompting_guide.md”.
2) Rule tags you applied (e.g., Applied: R-LOGS, R-95%, P-ROOT, P-ENTRY, P-ARCH, P-ENV, T-UI, T-DB, T-REV, T-TEL, S-OBS1, S-OBS2, S-ENV, S-LOCAL, P-LAZY, P-ID, L-APP, L-VIEW, D-OBS, D-ERR, TST-UNIT, TST-UI, UI-BIND, UI-PREFKEY, UI-DI, SEC-SAFE, SEC-NET, DECL-DUPE, MOD-ONE, C-SIMPLE, C-DRY, C-CLEAN, C-REALDATA, C-ENVSAFE).
3) A concise plan (tool preamble): steps to create & save files, then verify build.
4) After creating files, a final **status summary** listing created file paths and any questions if confidence <100%.

STOP CONDITIONS:
- Stop after all files are created/saved and the summary is printed.
- If anything blocks 95% confidence, pause and ask 2–3 precise questions instead of proceeding.

verbosity: low for chat text; high for code diffs in tools (when creating files).
reasoning_effort: medium (upgrade to high if scaffolding encounters ambiguity).

Begin.



