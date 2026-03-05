# Development Issues
## NutriFacts — iOS App

**Version:** 1.0
**Date:** 2026-03-05

Each issue is scoped to roughly 1–2 hours of focused work. Issues are ordered by dependency — earlier issues must be completed before later ones that build on them.

All code must follow `CODING_CONVENTIONS.md`. Key rules apply to every issue:
- One type per file. No exceptions.
- Descriptive names only — no single-letter variables, no abbreviations under 3 characters.
- Every SwiftUI view must have a `#Preview` macro (no `traits` argument).
- Use `async/await` — no Combine, no completion handlers.
- Default access to `private`. Expose only what is needed.
- Zero SwiftLint warnings or errors.
- TDD: write a failing test first, then the minimal code to pass it. One behavior per test.
- Use `ThemeColor` for all colors — no hardcoded `Color` values.
- Branch name: `feature/<issue-number>-<short-description>`

---

## ISSUE-01 — Define core data models

**Epic:** Foundation
**User Story:** Supports all user stories
**Priority:** P0 — must be completed first
**Branch:** `feature/01-core-data-models`

**What to build:**

Create the following files, one type per file, in `NutriFacts/Models/`:

- `NutritionFacts.swift` — `struct NutritionFacts: Codable` with properties: `productName: String`, `isLiquid: Bool`, `macronutrients: Macronutrients`, `vitamins: [NutrientItem]`, `minerals: [NutrientItem]`, `allergens: [String]`, `ingredients: String?`
- `Macronutrients.swift` — `struct Macronutrients: Codable` with properties: `calories: Double`, `totalFat: Double`, `saturatedFat: Double`, `transFat: Double`, `carbohydrates: Double`, `sugar: Double`, `dietaryFiber: Double`, `protein: Double`
- `NutrientItem.swift` — `struct NutrientItem: Codable, Identifiable` with properties: `id: UUID`, `nutrientName: String`, `nutrientAmount: Double`, `nutrientUnit: String`
- `AppError.swift` — `enum AppError: Error` with cases: `productNotFound(followUpQuestions: [String])`, `aiUnavailable`, `networkError(Error)`, `invalidImage`, `parsingError`
- `AppState.swift` — `enum AppState` with cases: `idle`, `loading`, `success(NutritionFacts)`, `error(AppError)`

**Coding convention requirements:**
- All types use `let` for immutable properties (`struct` fields are value types, prefer immutability).
- `NutrientItem` uses `nutrientName`, `nutrientAmount`, `nutrientUnit` — not `name`, `amount`, `unit` (compensate for weak type information per conventions).
- All five types in separate files.
- No UI code in this issue.

**TDD — tests to write first in `NutriFactsTests/Models/`:**
- `testNutritionFacts_isLiquid_isFalseByDefault` — verify a constructed `NutritionFacts` with `isLiquid: false` returns false
- `testNutritionFacts_isLiquid_isTrueWhenSet` — verify a constructed `NutritionFacts` with `isLiquid: true` returns true
- `testAppState_success_holdsNutritionFacts` — verify `.success(facts)` holds the expected `NutritionFacts`
- `testAppState_error_holdsAppError` — verify `.error(.aiUnavailable)` holds the expected error

**Done when:**
- All five files compile with no errors.
- All four tests pass.
- Zero SwiftLint warnings.

---

## ISSUE-02 — Set up NutritionViewModel and AIServiceProtocol

**Epic:** Foundation
**User Story:** Supports all user stories
**Depends on:** ISSUE-01
**Priority:** P0
**Branch:** `feature/02-nutrition-viewmodel`

**What to build:**

Create the following files in `NutriFacts/Services/` and `NutriFacts/ViewModels/`:

- `AIServiceProtocol.swift` — `protocol AIServiceProtocol` with:
  - `func lookupNutrition(query: String) async throws -> NutritionFacts`
  - `func lookupNutrition(image: UIImage) async throws -> NutritionFacts`
- `NutritionViewModel.swift` — `@Observable final class NutritionViewModel` with:
  - `private(set) var appState: AppState = .idle`
  - `var searchText: String = ""`
  - `var isRecording: Bool = false`
  - `private let aiService: AIServiceProtocol` — injected via `init(aiService: AIServiceProtocol)`
  - `func search() async` — sets `appState = .loading`, calls `aiService.lookupNutrition(query: searchText)`, sets result state
  - `func clearSearch()` — clears `searchText`, sets `appState = .idle`
  - `func analyzePhoto(_ selectedImage: UIImage) async` — sets `appState = .loading`, calls `aiService.lookupNutrition(image:)`
  - Stub implementations only — no real AI calls yet

**Coding convention requirements:**
- `NutritionViewModel` depends on `AIServiceProtocol`, not a concrete type (Dependency Inversion).
- `appState` is `private(set)` — views read it but cannot write it.
- All async functions marked `@MainActor`.
- Protocol named `AIServiceProtocol` (noun + capability suffix per conventions).
- Each method does ONE thing (Single Responsibility).

**TDD — tests to write first in `NutriFactsTests/ViewModels/`:**
- `testClearSearch_resetsSearchText` — after calling `clearSearch()`, `searchText` is empty
- `testClearSearch_setsStateToIdle` — after calling `clearSearch()`, `appState` is `.idle`
- `testSearch_setsStateToLoading` — immediately after `search()` starts, `appState` is `.loading` (use a mock that delays)
- `testSearch_onSuccess_setsStateToSuccess` — after mock returns `NutritionFacts`, `appState` is `.success`
- `testSearch_onError_setsStateToError` — after mock throws, `appState` is `.error`

**Done when:**
- `NutritionViewModel` and `AIServiceProtocol` compile.
- All five tests pass using a mock `AIServiceProtocol`.
- Zero SwiftLint warnings.

---

## ISSUE-03 — Build HomeView layout

**Epic:** Text Search
**User Story:** US-01, US-02
**Depends on:** ISSUE-02
**Priority:** P0
**Branch:** `feature/03-home-view`

**What to build:**

Create the following files in `NutriFacts/Views/`:

- `HomeView.swift` — root view shown in `.idle` state:
  - Large navigation title "NutriFacts"
  - `SearchBarView` (see below)
  - Suggestion chips: horizontally scrollable row of `["Apple", "Oat milk", "Greek yogurt", "Salmon", "Banana"]`. Tapping a chip sets `searchText` and calls `search()`.
  - Empty state text: "Search for any food to see its nutrition facts."
- `SearchBarView.swift` — contains:
  - `TextField` with placeholder "Search food or product" and a magnifying glass `Image(systemName: "magnifyingglass")` on the left
  - Clear button (`Image(systemName: "xmark.circle.fill")`) — visible only when `searchText` is not empty, calls `clearSearch()` on tap
  - Mic button (`Image(systemName: "mic.fill")`) — tappable, no logic yet, calls a `onMicTap` closure
  - Camera button (`Image(systemName: "camera.fill")`) — tappable, no logic yet, calls an `onCameraTap` closure
  - Submit on return key

**Coding convention requirements:**
- `HomeView` and `SearchBarView` in separate files (one type per file).
- Use `ThemeColor` for all colors — no hardcoded `Color(...)` values.
- Both files must have `#Preview` macros.
- `SearchBarView` receives `searchText: Binding<String>`, `onMicTap: () -> Void`, `onCameraTap: () -> Void`, `onSubmit: () -> Void`, `onClear: () -> Void` — no direct ViewModel dependency inside `SearchBarView`.

**TDD — tests to write first in `NutriFactsTests/Views/` (use ViewInspector or snapshot if available, otherwise test ViewModel side effects):**
- `testClearSearch_whenSearchTextIsEmpty_clearButtonIsHidden` — verify clear button only appears when text is non-empty (test via ViewModel state)
- `testSuggestionChip_onTap_setsSearchText` — tapping a chip sets `searchText` to the chip label

**Done when:**
- `HomeView` and `SearchBarView` render correctly in preview.
- Clear button appears/disappears based on `searchText`.
- Tapping a suggestion chip fills the search bar.
- Both views have `#Preview`.
- Zero SwiftLint warnings.

---

## ISSUE-04 — Wire app state to navigation

**Epic:** Foundation
**User Story:** US-01
**Depends on:** ISSUE-03
**Priority:** P0
**Branch:** `feature/04-app-state-navigation`

**What to build:**

- `LoadingView.swift` — in `NutriFacts/Views/`:
  - Centered `ProgressView` (system activity indicator)
  - Text: "Looking up nutrition facts for \(searchText)…"
  - Search bar visible but disabled during loading
- Update `ContentView.swift` to use `NavigationStack` as root and switch on `NutritionViewModel.appState`:
  - `.idle` → show `HomeView`
  - `.loading` → show `LoadingView` overlay
  - `.success(let nutritionFacts)` → push `ResultsView` (placeholder stub for now)
  - `.error(let appError)` → push `ErrorView` (placeholder stub for now)

**Coding convention requirements:**
- `LoadingView` in its own file with `#Preview`.
- No state management logic inside views — all state in `NutritionViewModel`.
- `NutritionViewModel` passed via environment or constructor injection, not created inside views.

**TDD:**
- `testAppState_loading_showsLoadingView` — when `appState` is `.loading`, `LoadingView` content is visible
- `testAppState_idle_showsHomeView` — when `appState` is `.idle`, `HomeView` content is visible

**Done when:**
- Switching ViewModel state in preview cycles through all four states.
- `LoadingView` appears and disappears correctly.
- Both new views have `#Preview`.
- Zero SwiftLint warnings.

---

## ISSUE-05 — Build ResultsView shell with tab picker

**Epic:** Nutrition Results
**User Story:** US-08, US-09, US-10
**Depends on:** ISSUE-04
**Priority:** P1
**Branch:** `feature/05-results-view-shell`

**What to build:**

- `ResultsView.swift` — in `NutriFacts/Views/`:
  - Accepts `nutritionFacts: NutritionFacts`
  - Navigation title = `nutritionFacts.productName`
  - Back button returns to `HomeView`
  - `Picker` (segmented style) with two segments: "Overview" and "Full Details"
  - Switches between `OverviewTabView` and `DetailsTabView` (both stubs for now)
  - Unit label: "per 100g" when `isLiquid == false`, "per 100ml" when `isLiquid == true` — visible on both tabs
- `UnitLabel.swift` — small reusable view that renders the unit label text

**Coding convention requirements:**
- `ResultsView` and `UnitLabel` in separate files.
- Both have `#Preview` with mock `NutritionFacts` data.
- Tab selection stored as `@State private var selectedTab: ResultsTab` where `ResultsTab` is its own `enum` in `ResultsTab.swift`.
- No hardcoded color values.

**TDD:**
- `testUnitLabel_isLiquidFalse_showsPer100g` — `UnitLabel(isLiquid: false)` displays "per 100g"
- `testUnitLabel_isLiquidTrue_showsPer100ml` — `UnitLabel(isLiquid: true)` displays "per 100ml"

**Done when:**
- `ResultsView` renders with a product name in the nav bar.
- Tab switching works.
- Unit label shows correct text based on `isLiquid`.
- All new types in separate files, each with `#Preview`.
- Zero SwiftLint warnings.

---

## ISSUE-06 — Build Overview tab with pie chart

**Epic:** Nutrition Results
**User Story:** US-08
**Depends on:** ISSUE-05
**Priority:** P1
**Branch:** `feature/06-overview-tab`

**What to build:**

- `OverviewTabView.swift` — in `NutriFacts/Views/`:
  - Accepts `macronutrients: Macronutrients` and `isLiquid: Bool`
  - Donut/pie chart using Swift Charts with three segments:
    - Carbohydrates — `ThemeColor.carbohydrates` (orange)
    - Protein — `ThemeColor.protein` (green)
    - Fat — `ThemeColor.fat` (pink)
    - Values in grams (not calories)
  - Chart animates with sweep on appearance
  - Chart legend: three colored labels below chart
  - 2×2 grid of `MacroSummaryCard` views: Calories (kcal), Fat (g), Carbs (g), Protein (g)
  - `UnitLabel` at the top
- `MacroSummaryCard.swift` — reusable card view showing a value and a label

**Coding convention requirements:**
- `OverviewTabView` and `MacroSummaryCard` in separate files, each with `#Preview`.
- Use mock `Macronutrients` data in previews — do not use magic numbers inline in views.
- All colors via `ThemeColor` — define `ThemeColor.carbohydrates`, `ThemeColor.protein`, `ThemeColor.fat` in a `ThemeColor.swift` file if it does not already exist.
- Chart segment labels use `nutrientAmount` naming style (descriptive).

**TDD:**
- `testMacroSummaryCard_displaysCorrectValue` — card with `value: 52, label: "Calories", unit: "kcal"` displays "52"
- `testMacroSummaryCard_displaysCorrectLabel` — same card displays "Calories"

**Done when:**
- Chart renders with correct colors and segment labels using mock data.
- Macro cards show correct values.
- Sweep animation plays on appearance.
- All new files have `#Preview`.
- Zero SwiftLint warnings.

---

## ISSUE-07 — Build Full Details tab

**Epic:** Nutrition Results
**User Story:** US-09
**Depends on:** ISSUE-05
**Priority:** P1
**Branch:** `feature/07-details-tab`

**What to build:**

- `DetailsTabView.swift` — in `NutriFacts/Views/`:
  - Accepts `nutritionFacts: NutritionFacts`
  - SwiftUI `List` with `.insetGrouped` style
  - `UnitLabel` at the top
  - Sections (each in its own view — see below):
    - `MacronutrientsSectionView` — Calories, Total Fat (with indented Saturated Fat, Trans Fat), Carbohydrates (with indented Sugar, Dietary Fiber), Protein
    - `VitaminsSectionView` — list of `NutrientItem` from `nutritionFacts.vitamins`
    - `MineralsSectionView` — list of `NutrientItem` from `nutritionFacts.minerals`
    - `AllergensSectionView` — list of `nutritionFacts.allergens` or "None detected"
    - `IngredientsSectionView` — plain text or "Not available"
  - Disclaimer footnote at bottom of list
- `NutrientRowView.swift` — reusable row: nutrient name left, value + unit right

**Coding convention requirements:**
- Each section view in its own file (one type per file): `MacronutrientsSectionView.swift`, `VitaminsSectionView.swift`, `MineralsSectionView.swift`, `AllergensSectionView.swift`, `IngredientsSectionView.swift`, `NutrientRowView.swift`.
- Each file has `#Preview` with mock data.
- Indented sub-rows (Saturated Fat, Sugar etc.) use `padding(.leading)` — not a separate section.
- Disclaimer text comes from a constant, not hardcoded in the view.

**TDD:**
- `testNutrientRowView_displaysNutrientName` — row with `nutrientName: "Vitamin C"` displays "Vitamin C"
- `testNutrientRowView_displaysNutrientAmount` — row displays the correct amount string
- `testAllergensSectionView_emptyAllergens_showsNoneDetected` — empty allergens list shows "None detected"

**Done when:**
- All sections render correctly with mock data.
- Disclaimer is visible at the bottom.
- All section views in separate files, each with `#Preview`.
- Zero SwiftLint warnings.

---

## ISSUE-08 — Build ErrorView with follow-up questions

**Epic:** Error Handling
**User Story:** US-11, US-12
**Depends on:** ISSUE-04
**Priority:** P1
**Branch:** `feature/08-error-view`

**What to build:**

- `ErrorView.swift` — in `NutriFacts/Views/`:
  - Accepts `followUpQuestions: [String]` and `onRetry: () -> Void`
  - Friendly error message: "We couldn't identify this food. Let's try to narrow it down."
  - Renders each follow-up question as a labeled `TextField`
  - "Try Again" primary button — calls `onRetry` with answers appended to original context
  - Back button returns to `HomeView`
- `FollowUpQuestionView.swift` — reusable view for a single follow-up question + text field

**Coding convention requirements:**
- `ErrorView` and `FollowUpQuestionView` in separate files, each with `#Preview`.
- `@State private var answerTexts: [String]` for storing user answers — one entry per question.
- Error message text comes from a constant, not inline in the view.
- No raw API error text shown to the user — only friendly messages.

**TDD:**
- `testFollowUpQuestionView_displaysQuestionText` — view with question "Is this raw or cooked?" displays that text
- `testErrorView_emptyFollowUpQuestions_showsNoQuestionFields` — with empty `followUpQuestions`, no text fields shown

**Done when:**
- `ErrorView` renders with sample questions in preview.
- "Try Again" is tappable and calls `onRetry`.
- Both files have `#Preview`.
- Zero SwiftLint warnings.

---

## ISSUE-09 — Implement OpenAI text search service

**Epic:** AI Engine
**User Story:** US-13
**Depends on:** ISSUE-02
**Priority:** P1
**Branch:** `feature/09-openai-text-service`

**What to build:**

- `Secrets.xcconfig` — at project root, containing `OPENAI_API_KEY = <your-key>`. Add `Secrets.xcconfig` to `.gitignore`. **Never commit the key.**
- `OpenAIService.swift` — in `NutriFacts/Services/`, conforming to `AIServiceProtocol`:
  - `func lookupNutrition(query: String) async throws -> NutritionFacts`
  - Builds a structured JSON prompt requesting `NutritionFacts` schema
  - Calls `https://api.openai.com/v1/chat/completions` using `URLSession` and `async/await`
  - Reads API key from `Bundle.main.infoDictionary` (loaded via `.xcconfig`)
  - Parses JSON response into `NutritionFacts`
  - On unrecognized product: parses follow-up questions from response and throws `AppError.productNotFound(followUpQuestions:)`
- `NutritionFactsResponseParser.swift` — `struct` responsible only for parsing the raw API JSON into `NutritionFacts` or `AppError` (Single Responsibility — parsing is separate from networking)
- Wire `OpenAIService` into `NutritionViewModel` via `AIServiceProtocol`

**Coding convention requirements:**
- `OpenAIService` and `NutritionFactsResponseParser` in separate files (Single Responsibility).
- No force unwrap (`!`), no force try (`try!`), no force cast (`as!`).
- API key never in source code — only via `.xcconfig`.
- All networking uses `async/await` — no callbacks.
- `@MainActor` on ViewModel methods that update state.

**TDD (use a mock URLSession or inject a `NetworkSession` protocol):**
- `testLookupNutrition_validQuery_returnsNutritionFacts` — mock returns valid JSON, assert `NutritionFacts.productName` is correct
- `testLookupNutrition_unknownProduct_throwsProductNotFound` — mock returns error JSON, assert `AppError.productNotFound` is thrown
- `testNutritionFactsResponseParser_validJSON_parsesProductName` — parser correctly extracts `productName`
- `testNutritionFactsResponseParser_missingFields_throwsParsingError` — malformed JSON throws `AppError.parsingError`

**Done when:**
- Typing "Apple" and searching returns real nutrition facts from OpenAI (manual test).
- An unrecognized query returns follow-up questions (manual test).
- All four unit tests pass using mocks.
- Zero SwiftLint warnings.

---

## ISSUE-10 — Implement connectivity detection and AI provider switching

**Epic:** AI Engine
**User Story:** US-13, US-14
**Depends on:** ISSUE-09
**Priority:** P1
**Branch:** `feature/10-connectivity-ai-switching`

**What to build:**

- `ConnectivityMonitoring.swift` — `protocol ConnectivityMonitoring` with `var isOnline: Bool { get }`
- `ConnectivityMonitor.swift` — `final class ConnectivityMonitor: ConnectivityMonitoring, ObservableObject` using `NWPathMonitor`
  - `private(set) var isOnline: Bool` — updates automatically
- `AIAgentService.swift` — `final class AIAgentService: AIServiceProtocol`:
  - Injected with `onlineService: AIServiceProtocol` and `offlineService: AIServiceProtocol` and `connectivityMonitor: ConnectivityMonitoring`
  - Delegates `lookupNutrition(query:)` to `onlineService` when `isOnline`, otherwise `offlineService`
  - If both fail, throws `AppError.aiUnavailable`
- Stub `AppleIntelligenceService.swift` — `final class AppleIntelligenceService: AIServiceProtocol`, throws `AppError.aiUnavailable` for now (full implementation in ISSUE-14)

**Coding convention requirements:**
- Four separate files (one type per file).
- `AIAgentService` depends only on protocols — never on concrete `OpenAIService` or `AppleIntelligenceService` directly (Dependency Inversion).
- `ConnectivityMonitor` uses `private(set)` for `isOnline`.

**TDD:**
- `testAIAgentService_whenOnline_usesOnlineService` — mock `isOnline = true`, assert `onlineService.lookupNutrition` was called
- `testAIAgentService_whenOffline_usesOfflineService` — mock `isOnline = false`, assert `offlineService.lookupNutrition` was called
- `testAIAgentService_bothServicesFail_throwsAIUnavailable` — both mocks throw, assert `AppError.aiUnavailable`

**Done when:**
- Turning off Wi-Fi/cellular causes the app to use `AppleIntelligenceService` automatically.
- All three tests pass using mocks.
- Zero SwiftLint warnings.

---

## ISSUE-11 — Add Info.plist permission entries

**Epic:** Permissions
**User Story:** US-15, US-16
**Depends on:** ISSUE-03
**Priority:** P1
**Branch:** `feature/11-permissions`

**What to build:**

Add the following keys to `Info.plist`:
- `NSMicrophoneUsageDescription` — "NutriFacts needs microphone access to transcribe your spoken food name."
- `NSSpeechRecognitionUsageDescription` — "NutriFacts uses speech recognition to convert your voice into text."
- `NSCameraUsageDescription` — "NutriFacts uses your camera to identify food or read nutrition labels."
- `NSPhotoLibraryUsageDescription` — "NutriFacts accesses your photo library so you can choose a food photo."

Add permission-denied handling in `HomeView`:
- If microphone or speech recognition permission is denied, show an inline alert explaining the reason with a "Go to Settings" button (using `UIApplication.openSettingsURLString`).
- If camera or photo library permission is denied, show the same pattern.

**Coding convention requirements:**
- Permission-denied alert text comes from string constants — not hardcoded inline.
- No force unwrap when opening the Settings URL.

**TDD:**
- No automated tests for permission dialogs (system controlled). Manual test checklist:
  - [ ] Microphone dialog appears on first mic tap
  - [ ] Camera dialog appears on first camera tap
  - [ ] Photo library dialog appears on first library access
  - [ ] Denying any permission shows graceful inline message

**Done when:**
- All four `Info.plist` entries are present.
- Denying any permission does not crash the app.
- A clear inline message is shown on denial.
- Zero SwiftLint warnings.

---

## ISSUE-12 — Implement speech dictation input

**Epic:** Speech Input
**User Story:** US-03, US-04
**Depends on:** ISSUE-11
**Priority:** P1
**Branch:** `feature/12-speech-dictation`

**What to build:**

- `SpeechRecognitionService.swift` — `final class SpeechRecognitionService` in `NutriFacts/Services/`:
  - Uses `SFSpeechRecognizer` with `en-US` locale
  - `func startRecording() async throws` — begins recognition, updates a `transcribedText: String` property in real time
  - `func stopRecording()` — ends recognition
  - Single Responsibility: this class only handles speech recognition, not ViewModel state
- Update `NutritionViewModel`:
  - `func startDictation() async` — calls `SpeechRecognitionService.startRecording()`, binds `transcribedText` to `searchText`
  - `func stopDictation()` — calls `SpeechRecognitionService.stopRecording()`, sets `isRecording = false`
- Update `SearchBarView` mic button:
  - Active state: `Image(systemName: "mic.fill")` tinted red with a pulse animation
  - Inactive state: `Image(systemName: "mic.fill")` tinted with `ThemeColor.accent`

**Coding convention requirements:**
- `SpeechRecognitionService` in its own file.
- Uses `async/await` — no Combine or callback-based API.
- Locale hardcoded to `Locale(identifier: "en-US")` per PRD decision.
- Pulse animation uses `withAnimation` — respects Reduce Motion setting.

**TDD:**
- `testStartDictation_setsIsRecordingToTrue` — after `startDictation()`, `isRecording == true`
- `testStopDictation_setsIsRecordingToFalse` — after `stopDictation()`, `isRecording == false`
- `testStartDictation_updatesSearchText` — mock service returning "Apple" sets `searchText == "Apple"`

**Done when:**
- Speaking a food name fills the search bar with the transcription.
- Stopping recording leaves the transcribed text in the search bar.
- Mic button shows correct active/inactive state.
- All three tests pass.
- Zero SwiftLint warnings.

---

## ISSUE-13 — Implement photo input (camera + library)

**Epic:** Photo Input
**User Story:** US-05, US-06
**Depends on:** ISSUE-11
**Priority:** P1
**Branch:** `feature/13-photo-input`

**What to build:**

- Update camera button in `HomeView` to show an `actionSheet` (or `confirmationDialog`) with:
  - "Take Photo" — opens camera via `UIImagePickerController` wrapped in a SwiftUI `UIViewControllerRepresentable`
  - "Choose from Library" — opens `PhotosPicker` (SwiftUI native)
- `CameraPickerView.swift` — `struct CameraPickerView: UIViewControllerRepresentable` wrapping `UIImagePickerController` with `.camera` source
- On image selection: call `NutritionViewModel.analyzePhoto(_ selectedImage: UIImage)`
- `NutritionViewModel.analyzePhoto` sets `appState = .loading` then calls `aiService.lookupNutrition(image:)` (still stubbed — real vision in ISSUE-15)

**Coding convention requirements:**
- `CameraPickerView` in its own file.
- No force unwrap on the camera source check.
- Image passed as `UIImage` — not as `URL` or `Data` (conversion done inside `CameraPickerView`).
- Permission denial handled gracefully (see ISSUE-11).

**TDD:**
- `testAnalyzePhoto_setsStateToLoading` — calling `analyzePhoto` immediately sets `appState` to `.loading`
- `testAnalyzePhoto_onSuccess_setsStateToSuccess` — mock `aiService` returns `NutritionFacts`, asserts `.success`
- `testAnalyzePhoto_onError_setsStateToError` — mock throws, asserts `.error`

**Done when:**
- User can take or pick a photo and the app enters the loading state.
- Permission denial is handled gracefully.
- All three tests pass.
- Zero SwiftLint warnings.

---

## ISSUE-14 — Implement Apple Intelligence offline service

**Epic:** AI Engine
**User Story:** US-14
**Depends on:** ISSUE-10
**Priority:** P2
**Branch:** `feature/14-apple-intelligence-service`

**What to build:**

- Implement `AppleIntelligenceService.lookupNutrition(query: String) async throws -> NutritionFacts`:
  - Uses Apple's `FoundationModels` framework
  - Uses `@Generable` macro to define structured output matching `NutritionFacts`
  - Builds the same structured prompt as `OpenAIService`
  - If Apple Intelligence is unavailable on the device, throws `AppError.aiUnavailable`
- For photo input in offline mode:
  - Use Vision framework `VNRecognizeTextRequest` for nutrition label OCR
  - Use `VNClassifyImageRequest` for food identification
  - Convert the result to a text description, then call `lookupNutrition(query:)` with that description

**Coding convention requirements:**
- OCR and classification logic in a separate `VisionAnalysisService.swift` (Single Responsibility — Vision is separate from FoundationModels).
- Gracefully handle `FoundationModels` unavailability (not all devices support Apple Intelligence).
- No force unwrap on Vision results.

**TDD:**
- `testAppleIntelligenceService_unavailable_throwsAIUnavailable` — mock FoundationModels as unavailable, assert `AppError.aiUnavailable`
- `testAppleIntelligenceService_validQuery_returnsNutritionFacts` — integration test with real on-device model (mark as slow test)

**Done when:**
- With internet off, searching "Banana" returns nutrition data from the on-device model on a supported device.
- Unavailable model state shows the "AI unavailable" error message.
- Tests pass.
- Zero SwiftLint warnings.

---

## ISSUE-15 — Implement OpenAI photo/vision lookup

**Epic:** Photo Input
**User Story:** US-05, US-06, US-07
**Depends on:** ISSUE-13, ISSUE-09
**Priority:** P2
**Branch:** `feature/15-openai-vision`

**What to build:**

- Implement `OpenAIService.lookupNutrition(image: UIImage) async throws -> NutritionFacts`:
  - Converts `UIImage` to base64-encoded JPEG data
  - Sends as a multimodal message to GPT-4o using the photo prompt
  - Parses response using `NutritionFactsResponseParser` (reused from ISSUE-09)
  - Handles both food recognition and nutrition label OCR — the AI determines which applies
- Image compression: resize to max 1024px on the longest side before base64 encoding (keep request payload small)
- `UIImage+Resize.swift` — extension on `UIImage` with `func resized(toMaxDimension maxDimension: CGFloat) -> UIImage`

**Coding convention requirements:**
- Image resizing logic in a `UIImage` extension file — not inside `OpenAIService` (Single Responsibility).
- No force unwrap on `UIImage` to `Data` conversion.
- Base64 encoding is a single private method inside `OpenAIService`.
- Extension named `UIImage+Resize.swift` (one type/extension per file convention).

**TDD:**
- `testUIImageResize_largeImage_reducesToMaxDimension` — a 2000×3000 image resized to max 1024px returns an image where the longest side is ≤ 1024px
- `testLookupNutrition_image_callsVisionEndpoint` — mock URLSession asserts the request body contains a base64 image field
- `testLookupNutrition_image_validResponse_returnsNutritionFacts` — mock returns valid JSON, assert correct `NutritionFacts`

**Done when:**
- Taking a photo of an apple returns apple nutrition facts (manual test).
- Taking a photo of a printed nutrition label returns extracted and normalized values (manual test).
- All three unit tests pass.
- Zero SwiftLint warnings.

---

## Issue Summary Table

| Issue | Title | Priority | Depends On | Branch |
|---|---|---|---|---|
| ISSUE-01 | Define core data models | P0 | — | `feature/01-core-data-models` |
| ISSUE-02 | Set up NutritionViewModel and AIServiceProtocol | P0 | 01 | `feature/02-nutrition-viewmodel` |
| ISSUE-03 | Build HomeView layout | P0 | 02 | `feature/03-home-view` |
| ISSUE-04 | Wire app state to navigation | P0 | 03 | `feature/04-app-state-navigation` |
| ISSUE-05 | Build ResultsView shell with tab picker | P1 | 04 | `feature/05-results-view-shell` |
| ISSUE-06 | Build Overview tab with pie chart | P1 | 05 | `feature/06-overview-tab` |
| ISSUE-07 | Build Full Details tab | P1 | 05 | `feature/07-details-tab` |
| ISSUE-08 | Build ErrorView with follow-up questions | P1 | 04 | `feature/08-error-view` |
| ISSUE-09 | Implement OpenAI text search service | P1 | 02 | `feature/09-openai-text-service` |
| ISSUE-10 | Implement connectivity detection and AI switching | P1 | 09 | `feature/10-connectivity-ai-switching` |
| ISSUE-11 | Add Info.plist permission entries | P1 | 03 | `feature/11-permissions` |
| ISSUE-12 | Implement speech dictation input | P1 | 11 | `feature/12-speech-dictation` |
| ISSUE-13 | Implement photo input (camera + library) | P1 | 11 | `feature/13-photo-input` |
| ISSUE-14 | Implement Apple Intelligence offline service | P2 | 10 | `feature/14-apple-intelligence-service` |
| ISSUE-15 | Implement OpenAI photo/vision lookup | P2 | 13, 09 | `feature/15-openai-vision` |

**Suggested implementation order:**
`01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 11 → 09 → 10 → 12 → 13 → 14 → 15`
