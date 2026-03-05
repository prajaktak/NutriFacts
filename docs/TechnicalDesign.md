# Technical Design Document
## NutriFacts — iOS App

**Version:** 1.0
**Date:** 2026-03-05
**Status:** Draft

---

## 1. Technology Stack

| Layer | Technology |
|---|---|
| Language | Swift 6 |
| UI Framework | SwiftUI |
| Minimum iOS Target | iOS 18 |
| Online AI | OpenAI API (GPT-4o) |
| Offline AI | Apple FoundationModels (Apple Intelligence) |
| Speech Input | Apple Speech framework (SFSpeechRecognizer) |
| Photo / Camera | SwiftUI PhotosPicker + AVFoundation |
| Networking | Swift async/await + URLSession |
| Charts | Swift Charts (native) |
| No backend | All data flows through OpenAI or on-device model |

---

## 2. High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│                   SwiftUI Views                     │
│  HomeView  │  ResultsView  │  ErrorView             │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│              NutritionViewModel                     │
│  (ObservableObject / @Observable)                   │
│  - Manages state: input, loading, results, errors   │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│              AIAgentService (Protocol)              │
│  - lookup(query: String) async throws               │
│  - lookup(image: UIImage) async throws              │
└────┬───────────────────────────────────┬────────────┘
     │                                   │
┌────▼──────────────┐       ┌────────────▼───────────┐
│  OpenAIService    │       │  AppleIntelligence      │
│  (online)         │       │  Service (offline)      │
│  URLSession +     │       │  FoundationModels       │
│  OpenAI REST API  │       │  framework              │
└───────────────────┘       └────────────────────────┘
```

---

## 3. Connectivity Detection

- The app uses `Network.framework` (`NWPathMonitor`) to observe connectivity in real time.
- When the path status is `.satisfied`, `OpenAIService` is used.
- When the path status is `.unsatisfied` or `.requiresConnection`, `AppleIntelligenceService` is used.
- The switch between providers happens automatically with no user interaction.

---

## 4. Data Model

### 4.1 NutritionFacts (Core Model)

```swift
struct NutritionFacts: Codable {
    let productName: String
    let isLiquid: Bool              // determines per 100g vs per 100ml label
    let macronutrients: Macronutrients
    let vitamins: [NutrientItem]
    let minerals: [NutrientItem]
    let allergens: [String]
    let ingredients: String?        // nil if not available
}

struct Macronutrients: Codable {
    let calories: Double            // kcal per 100g or 100ml
    let totalFat: Double            // grams
    let saturatedFat: Double        // grams
    let transFat: Double            // grams
    let carbohydrates: Double       // grams
    let sugar: Double               // grams
    let dietaryFiber: Double        // grams
    let protein: Double             // grams
}

struct NutrientItem: Codable, Identifiable {
    let id: UUID
    let name: String                // e.g. "Vitamin C", "Iron"
    let amount: Double              // amount in unit
    let unit: String                // e.g. "mg", "µg", "%"
}
```

### 4.2 AppError (Error Model)

```swift
enum AppError: Error {
    case productNotFound(followUpQuestions: [String])
    case aiUnavailable
    case networkError(Error)
    case invalidImage
    case parsingError
}
```

---

## 5. AI Integration

### 5.1 OpenAI Service (Online)

- **Model:** GPT-4o (supports both text and vision in a single API)
- **Endpoint:** `https://api.openai.com/v1/chat/completions`
- **Auth:** Bearer token using developer's hardcoded API key (stored in a constants file, not in source control — loaded via a `.xcconfig` file)
- **Text query prompt:** Structured prompt asking for nutrition facts in a defined JSON schema matching `NutritionFacts`.
- **Photo query:** Image is base64-encoded and sent as a multimodal message alongside the structured prompt.
- **Response parsing:** The JSON response is decoded directly into `NutritionFacts`.
- **Error handling:** If the model cannot identify the product, it returns a structured error response with follow-up questions.

**Prompt Design (Text):**
```
You are a nutrition expert. The user has provided a food or product name.
Return the nutrition facts per 100g (or per 100ml if liquid) in the following JSON format: [schema].
If you cannot identify the product, return an error object with 1-3 follow-up questions to help identify it.
Do not guess or hallucinate values. If a value is unknown, omit it.
```

**Prompt Design (Photo):**
```
You are a nutrition expert. Analyze this image.
If it shows a food item, identify it and return nutrition facts per 100g or 100ml in JSON format: [schema].
If it shows a nutrition label, extract the values and normalize them to per 100g or 100ml.
If you cannot identify the content, return an error object with follow-up questions.
```

### 5.2 Apple Intelligence Service (Offline)

- Uses Apple's `FoundationModels` framework (on-device model).
- Sends the same structured prompt as OpenAI.
- Uses `@Generable` macro for structured output generation directly into `NutritionFacts`.
- Photo input in offline mode: uses Vision framework (`VNRecognizeTextRequest` for label OCR, `VNClassifyImageRequest` for food identification) to extract a text description, which is then passed to the on-device model as a text query.
- Note: Offline mode coverage is limited to common foods the on-device model knows about.

---

## 6. Input Modules

### 6.1 Text Input
- Standard SwiftUI `TextField` with search styling.
- Submit triggered by keyboard return key or a search button.

### 6.2 Speech Input (Dictation)
- Uses `SFSpeechRecognizer` with `en-US` locale.
- Requires `NSSpeechRecognitionUsageDescription` in Info.plist.
- Microphone permission required: `NSMicrophoneUsageDescription` in Info.plist.
- On tap: starts recording, transcribes in real time into the text field.
- On tap again (or silence detection): stops recording, text is ready for submission.

### 6.3 Photo Input
- Camera: `AVCaptureSession` via a SwiftUI wrapper or `UIImagePickerController`.
- Photo library: `PhotosPicker` (SwiftUI native, iOS 16+).
- Requires `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in Info.plist.
- Selected/captured image is passed to `AIAgentService.lookup(image:)`.

---

## 7. View Architecture

```
NutriFactsApp
└── ContentView
    └── HomeView
        ├── SearchBarView (TextField + mic button + camera button)
        └── ResultsView (shown after successful lookup)
            ├── Tab 1: OverviewTabView
            │   ├── Chart (Swift Charts pie chart)
            │   └── MacroSummaryView (Calories, Protein, Carbs, Fat)
            └── Tab 2: DetailsTabView
                ├── MacronutrientsSection
                ├── VitaminsSection
                ├── MineralsSection
                ├── AllergensSection
                └── IngredientsSection
        └── ErrorView (shown on lookup failure)
            ├── ErrorMessageView
            └── FollowUpQuestionsView
```

---

## 8. State Management

- A single `NutritionViewModel` marked with `@Observable` drives the entire app state.
- States:
  - `.idle` — home screen, waiting for input
  - `.loading` — AI request in flight, show loading indicator
  - `.success(NutritionFacts)` — results ready, show ResultsView
  - `.error(AppError)` — lookup failed, show ErrorView with follow-ups

---

## 9. API Key Management

- The OpenAI API key is stored in an `.xcconfig` file (`Secrets.xcconfig`) which is excluded from source control via `.gitignore`.
- The key is accessed in Swift via `Bundle.main.infoDictionary`.
- **Never commit the API key to git.**

---

## 10. Privacy & Permissions

| Permission | Reason |
|---|---|
| Microphone | Speech dictation input |
| Speech Recognition | Convert speech to text |
| Camera | Take photos of food or nutrition labels |
| Photo Library | Choose existing photos |

- No user data is stored on device.
- Photos and text queries are sent to OpenAI API only when online. OpenAI's data usage policies apply.
- No analytics or tracking.

---

## 11. Error Handling Strategy

| Scenario | Behavior |
|---|---|
| Product not recognized | Show error + AI-generated follow-up questions |
| No internet + Apple Intelligence unavailable | Show "AI unavailable" message |
| Network timeout | Show retry option |
| Invalid/unclear photo | Show error + ask user to retake or use text |
| OpenAI API error (rate limit, key issue) | Show generic error + suggest trying again |
| JSON parsing failure | Show generic error + log internally |

---

## 12. Open Technical Questions

- Confirm which `FoundationModels` APIs are available in iOS 18 vs iOS 18.1+ for structured generation.
- Determine if GPT-4o vision supports the required JSON schema output reliably enough, or if a post-processing step is needed.
- Confirm Apple Intelligence availability on all target devices (requires iPhone 15 Pro or later, or iPhone 16+).
