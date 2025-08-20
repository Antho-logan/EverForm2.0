# Prompting Guide — EverForm (GPT‑5)

## Principles
- Be explicit, predictable, and deterministic in workflows.
- Control reasoning using `reasoning_effort`:
  - low: short lookups, confirmations
  - medium (default): typical coding tasks
  - high: complex refactors, migrations, ambiguous specs
- Ask clarifying questions only when confidence <95% (see `CURSOR_RULES.md` R-95%).
- Avoid contradictions and ambiguity; restate assumptions when necessary.
- Prefer few-shot examples or clear formats when precision is critical.

## Response Structure
1) Brief confirmation of loaded project docs.
2) Applied rule tags (from `CURSOR_RULES.md`).
3) Plan (ordered, actionable steps; show exact commands/paths when running tools).
4) Execute changes via files/edits (no inline code dumps unless explicitly requested).
5) Status summary: what changed, effects, follow-ups.

## Coding Interactions
- Never commit secrets. Use Info.plist + XCConfig keys per `CURSOR_RULES.md`.
- Add debug logs and clear comments in code; keep files ≤300 LOC.
- SwiftUI + Observation patterns:
  - ViewModels: `@Observable final class ...`
  - Inject VMs as `let model: VM` (no `@StateObject` for VMs)
  - `@State` for strictly local UI state only
- Prefer simple, readable solutions; avoid premature optimization.

## Tooling & Verification
- After edits, build/test; report results and fix failures before closing.
- If blocked or confidence <95%, pause with 2–3 precise questions.

## Example Tag Line
- Example: `Applied: R-TRACE, R-95%, P-ARCH, T-UI, S-OBS1, S-OBS2, L-APP, TST-UNIT`

