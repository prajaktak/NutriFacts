# Development Issues
## NutriFacts — iOS App

**Version:** 1.0
**Date:** 2026-03-05

Each issue is scoped to roughly 1–2 hours of focused work. Issues are ordered by dependency — earlier issues should be completed before later ones that build on them.

---

## ISSUE-01 — Define core data models
**Epic:** Foundation
**User Story:** Supports all US
**Priority:** P0 — must be first

**What to build:**
- Create `NutritionFacts.swift` with all model structs: `NutritionFacts`, `Macronutrients`, `NutrientItem`.
- Create `AppError.swift` with the `AppError` enum and all error cases.
- Create `AppState.swift` with the view state enum: `.idle`, `.loading`, `.success(NutritionFacts)`, `.error(AppError)`.

**Done when:**
- All models compile with no errors.
- No UI code in this issue.

---

## ISSUE-02 — Set up NutritionViewModel
**Epic:** Foundation
**User Story:** Supports all US
**Depends on:** ISSUE-01
**Priority:** P0

**What to build:**
- Create `NutritionViewModel.swift` using `@Observable`.
- Properties: `state: AppState`, `searchText: String`, `isRecording: Bool`.
- Stub methods: `search()`, `clearSearch()`, `startDictation()`, `stopDictation()`, `analyzePhoto(UIImage)`.
- Methods are stubs only — no real AI calls yet.

**Done when:**
- ViewModel compiles and can be injected into views.

---

## ISSUE-03 — Build HomeView layout
**Epic:** Text Search
**User Story:** US-01, US-02
**Depends on:** ISSUE-02
**Priority:** P0

**What to build:**
- Create `HomeView.swift` with:
  - Large navigation title "NutriFacts".
  - Full-width search `TextField` with magnifying glass icon.
  - Clear (X) button that appears when text is entered (US-02).
  - Return key submits the search.
  - Mic button (`mic.fill` SF Symbol) — tappable, no logic yet.
  - Camera button (`camera.fill` SF Symbol) — tappable, no logic yet.
  - Suggestion chips: horizontally scrollable row of example food names (e.g. "Apple", "Oat milk", "Greek yogurt", "Salmon"). Tapping fills the search bar.
  - Empty state: simple text prompt "Search for any food to see its nutrition facts."

**Done when:**
- HomeView renders correctly in preview with all elements visible.
- Typing in the search bar shows/hides the clear button.
- Tapping a suggestion chip fills the search bar.

---

## ISSUE-04 — Build LoadingView and wire app state to navigation
**Epic:** Foundation
**User Story:** US-01
**Depends on:** ISSUE-03
**Priority:** P0

**What to build:**
- Create `LoadingView.swift`: centered activity indicator + contextual message "Looking up nutrition facts for [food name]...".
- Wire `HomeView` to `NutritionViewModel.state`:
  - `.idle` → show HomeView content.
  - `.loading` → show LoadingView overlay.
  - `.success` → navigate to `ResultsView` (stub for now).
  - `.error` → navigate to `ErrorView` (stub for now).
- Use `NavigationStack` as the root container in `ContentView`.

**Done when:**
- Tapping search with stub ViewModel cycles through states visually.
- LoadingView appears and disappears correctly.

---

## ISSUE-05 — Build ResultsView shell with tab picker
**Epic:** Nutrition Results
**User Story:** US-08, US-09, US-10
**Depends on:** ISSUE-04
**Priority:** P1

**What to build:**
- Create `ResultsView.swift` that accepts a `NutritionFacts` value.
- Navigation title = product name.
- Back button returns to HomeView.
- Segmented control (tab picker) at top: "Overview" | "Full Details".
- Switching tabs shows placeholder text for now.
- Unit label ("per 100g" or "per 100ml") visible on both tabs (US-10).

**Done when:**
- ResultsView renders with a product name in the nav bar.
- Tab switching works.
- Unit label correctly shows "per 100g" or "per 100ml" based on `NutritionFacts.isLiquid`.

---

## ISSUE-06 — Build Overview tab with pie chart
**Epic:** Nutrition Results
**User Story:** US-08
**Depends on:** ISSUE-05
**Priority:** P1

**What to build:**
- Create `OverviewTabView.swift`.
- Colorful donut/pie chart using Swift Charts with three segments: Carbs (orange), Protein (green), Fat (pink). Values in grams.
- Chart legend below the chart.
- 2×2 grid of macro summary cards: Calories (kcal), Fat (g), Carbs (g), Protein (g).
- Sweep animation when chart loads.
- Use hardcoded mock `NutritionFacts` data to build and verify the layout.

**Done when:**
- Chart renders with correct colors and segment labels.
- Macro cards show correct values from the model.
- Sweep animation plays on appearance.

---

## ISSUE-07 — Build Full Details tab
**Epic:** Nutrition Results
**User Story:** US-09
**Depends on:** ISSUE-05
**Priority:** P1

**What to build:**
- Create `DetailsTabView.swift`.
- SwiftUI `List` with `insetGrouped` style.
- Sections: Macronutrients, Vitamins, Minerals, Allergens, Ingredients.
- Each row: nutrient name (left), value + unit (right).
- Sub-items (Saturated Fat, Trans Fat, Sugar, Fiber) are indented.
- Allergens: "None detected" if empty; otherwise list items.
- Ingredients: plain text paragraph or "Not available".
- Disclaimer footnote at the bottom of the list.
- Use the same mock data as ISSUE-06.

**Done when:**
- All sections render correctly with mock data.
- Disclaimer is visible at the bottom.

---

## ISSUE-08 — Build ErrorView with follow-up questions
**Epic:** Error Handling
**User Story:** US-11, US-12
**Depends on:** ISSUE-04
**Priority:** P1

**What to build:**
- Create `ErrorView.swift` that accepts an `AppError`.
- Friendly error message (no raw API errors shown).
- Display 1–3 follow-up questions from `AppError.productNotFound(followUpQuestions:)`.
- Each question renders as a `TextField` for text answers.
- "Try Again" primary button — calls `ViewModel.search()` with combined original query + follow-up answers appended as context.
- Back button returns to HomeView.

**Done when:**
- ErrorView renders with a sample error and follow-up questions.
- "Try Again" button triggers a new search.

---

## ISSUE-09 — Implement OpenAI text search service
**Epic:** AI Engine
**User Story:** US-13
**Depends on:** ISSUE-02
**Priority:** P1

**What to build:**
- Create `Secrets.xcconfig` with the OpenAI API key. Add to `.gitignore`.
- Create `OpenAIService.swift` conforming to an `AIServiceProtocol` with `func lookup(query: String) async throws -> NutritionFacts`.
- Build the structured prompt for text queries.
- Call `https://api.openai.com/v1/chat/completions` with GPT-4o.
- Parse the JSON response into `NutritionFacts`.
- On failure/unrecognized product, parse follow-up questions and throw `AppError.productNotFound`.
- Wire into `NutritionViewModel.search()`.

**Done when:**
- Typing "Apple" and searching returns real nutrition facts from OpenAI.
- An unrecognized query returns follow-up questions.

---

## ISSUE-10 — Implement connectivity detection and AI provider switching
**Epic:** AI Engine
**User Story:** US-13, US-14
**Depends on:** ISSUE-09
**Priority:** P1

**What to build:**
- Create `ConnectivityMonitor.swift` using `NWPathMonitor` (`Network` framework).
- Expose a published `isOnline: Bool` property.
- Create `AppleIntelligenceService.swift` as a stub (returns a hardcoded result or throws `.aiUnavailable` for now — full implementation is ISSUE-14).
- Create `AIAgentService.swift` that wraps both services: uses `OpenAIService` when online, `AppleIntelligenceService` when offline.
- Wire `AIAgentService` into `NutritionViewModel`.

**Done when:**
- Turning off Wi-Fi/cellular causes the app to switch to the offline service automatically.
- No user interaction required for the switch.

---

## ISSUE-11 — Add Info.plist permissions entries
**Epic:** Permissions
**User Story:** US-15, US-16
**Depends on:** ISSUE-03
**Priority:** P1

**What to build:**
- Add the following keys to `Info.plist`:
  - `NSMicrophoneUsageDescription` — "NutriFacts needs microphone access to transcribe your spoken food name."
  - `NSSpeechRecognitionUsageDescription` — "NutriFacts uses speech recognition to convert your voice to text."
  - `NSCameraUsageDescription` — "NutriFacts uses your camera to identify food or read nutrition labels."
  - `NSPhotoLibraryUsageDescription` — "NutriFacts accesses your photo library so you can choose a food photo."

**Done when:**
- All four permission dialogs appear correctly when triggered (can be tested manually).
- Denying any permission shows a graceful inline message (not a crash).

---

## ISSUE-12 — Implement speech dictation input
**Epic:** Speech Input
**User Story:** US-03, US-04
**Depends on:** ISSUE-11
**Priority:** P1

**What to build:**
- Implement `startDictation()` and `stopDictation()` in `NutritionViewModel` using `SFSpeechRecognizer` with `en-US` locale.
- Real-time transcription updates `searchText` as the user speaks.
- Mic button turns red with a pulse animation while recording.
- Tapping mic again stops recording.
- If permission is denied, show an inline alert with a link to Settings.

**Done when:**
- Speaking a food name fills the search bar with the transcription.
- Stopping recording leaves the text in the search bar ready to submit.

---

## ISSUE-13 — Implement photo input (camera + library)
**Epic:** Photo Input
**User Story:** US-05, US-06
**Depends on:** ISSUE-11
**Priority:** P1

**What to build:**
- Camera button shows an action sheet: "Take Photo" / "Choose from Library".
- "Take Photo" opens `UIImagePickerController` (camera source).
- "Choose from Library" opens SwiftUI `PhotosPicker`.
- Selected/captured image is passed to `NutritionViewModel.analyzePhoto(UIImage)`.
- ViewModel sets state to `.loading` then calls `AIAgentService.lookup(image:)` (stub for now — real implementation in ISSUE-15).
- If permission is denied, show an inline alert.

**Done when:**
- User can take or pick a photo and the app enters the loading state.
- Permission denial is handled gracefully.

---

## ISSUE-14 — Implement Apple Intelligence offline service
**Epic:** AI Engine
**User Story:** US-14
**Depends on:** ISSUE-10
**Priority:** P2

**What to build:**
- Implement `AppleIntelligenceService.lookup(query: String)` using Apple's `FoundationModels` framework.
- Use `@Generable` macro to define structured output matching `NutritionFacts`.
- Build the same prompt as the OpenAI service.
- Handle the case where Apple Intelligence is unavailable on the device (throw `.aiUnavailable`).

**Done when:**
- With internet off, searching "Banana" returns real nutrition data from the on-device model.
- Unavailable model state shows a clear error message.

---

## ISSUE-15 — Implement OpenAI photo/vision lookup
**Epic:** Photo Input
**User Story:** US-05, US-06, US-07
**Depends on:** ISSUE-13, ISSUE-09
**Priority:** P2

**What to build:**
- Add `func lookup(image: UIImage) async throws -> NutritionFacts` to `OpenAIService`.
- Base64-encode the image and send as a multimodal message to GPT-4o.
- Use the photo prompt (handles both food recognition and label OCR).
- Parse response into `NutritionFacts`.
- Wire into `NutritionViewModel.analyzePhoto()`.

**Done when:**
- Taking a photo of an apple returns apple nutrition facts.
- Taking a photo of a printed nutrition label returns extracted and normalized values.

---

## Issue Summary Table

| Issue | Title | Priority | Depends On |
|---|---|---|---|
| ISSUE-01 | Define core data models | P0 | — |
| ISSUE-02 | Set up NutritionViewModel | P0 | 01 |
| ISSUE-03 | Build HomeView layout | P0 | 02 |
| ISSUE-04 | Wire app state to navigation | P0 | 03 |
| ISSUE-05 | ResultsView shell with tab picker | P1 | 04 |
| ISSUE-06 | Overview tab with pie chart | P1 | 05 |
| ISSUE-07 | Full Details tab | P1 | 05 |
| ISSUE-08 | ErrorView with follow-up questions | P1 | 04 |
| ISSUE-09 | OpenAI text search service | P1 | 02 |
| ISSUE-10 | Connectivity detection + AI switching | P1 | 09 |
| ISSUE-11 | Info.plist permissions entries | P1 | 03 |
| ISSUE-12 | Speech dictation input | P1 | 11 |
| ISSUE-13 | Photo input (camera + library) | P1 | 11 |
| ISSUE-14 | Apple Intelligence offline service | P2 | 10 |
| ISSUE-15 | OpenAI photo/vision lookup | P2 | 13, 09 |

**Suggested order for a solo developer:**
01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 11 → 09 → 10 → 12 → 13 → 14 → 15
