# Product Requirements Document (PRD)
## NutriFacts — iOS App

**Version:** 1.0
**Date:** 2026-03-05
**Status:** Draft

---

## 1. Overview

NutriFacts is an iPhone app that allows users to look up detailed nutrition facts for any food or product. Users can search by typing a product name, speaking it aloud, or taking a photo of the food or its nutrition label. The app uses AI to interpret the input and return structured nutrition data displayed in a clean, colorful, native iOS interface.

---

## 2. Problem Statement

People want quick, reliable access to nutrition information for the food they eat, but current solutions are either too complex, require account creation, or don't support natural input methods like photos and speech. NutriFacts provides a fast, stateless, AI-powered lookup with no login required.

---

## 3. Goals

- Allow any user to look up nutrition facts for any food or product quickly.
- Support three input methods: text, photo, and speech (dictation).
- Display complete, well-organized nutrition data per 100g or 100ml.
- Work offline using on-device Apple Intelligence, and online using OpenAI.
- Deliver a modern, colorful, native iOS experience.

---

## 4. Non-Goals (Out of Scope for v1.0)

- User accounts or login.
- Search history or saved foods.
- Daily intake tracking or calorie counting.
- Barcode scanning.
- iPad or macOS support.
- Monetization or in-app purchases.
- Settings screen for API key or AI provider selection.
- Multi-language support (English only).
- Conversational / multi-turn AI chat.

---

## 5. Target Users

NutriFacts is designed for a broad audience including:

- General consumers curious about what is in their food.
- Fitness enthusiasts who want macro and micro nutrient data.
- People with dietary restrictions (allergies, diabetes, etc.) who need detailed ingredient and allergen information.
- Parents and caregivers managing nutrition for their families.

---

## 6. Features

### 6.1 Text Search
- A search bar on the home screen allows users to type a food or product name in English.
- On submit, the app queries the AI and returns nutrition facts.

### 6.2 Speech Input (Dictation)
- A microphone button next to the search bar activates speech-to-text dictation.
- The spoken words are transcribed into the search bar in English.
- The user can review the transcribed text before submitting.
- Dictation is simple (not conversational).

### 6.3 Photo Input
- A camera button allows the user to take a photo or choose from the photo library.
- Two scenarios are handled:
  - **Food photo:** AI visually identifies the food and returns nutrition facts.
  - **Nutrition label photo:** AI reads the label using OCR and extracts the nutrition data.
- Both scenarios use the same photo input flow; the AI determines which scenario applies.

### 6.4 Nutrition Results Display
Results are shown in a two-tab view:

**Tab 1 — Overview (Pie Chart)**
- A colorful pie chart showing the macronutrient breakdown: Carbohydrates, Protein, Fat.
- Key headline numbers: Calories, Protein, Carbs, Fat displayed prominently.
- Values are per 100g (solid foods) or per 100ml (liquids).

**Tab 2 — Full Details**
- A complete scrollable list of all nutrition data, organized into sections:
  - **Macronutrients:** Calories, Total Fat, Saturated Fat, Trans Fat, Carbohydrates, Sugar, Dietary Fiber, Protein
  - **Vitamins:** All vitamins the AI can identify (e.g. Vitamin A, C, D, B12, etc.)
  - **Minerals:** All minerals the AI can identify (e.g. Calcium, Iron, Potassium, Sodium, etc.)
  - **Allergens:** Common allergens present (e.g. Gluten, Dairy, Nuts, Soy, etc.)
  - **Ingredients:** Full ingredients list if available
- All values are strictly per 100g or per 100ml (depending on whether the product is solid or liquid).

### 6.5 Error Handling & Follow-Up
- If the AI cannot identify the product or needs more information, it shows a friendly error message.
- The app then presents follow-up questions to the user to help narrow down the product (e.g. "Is this a raw or cooked item?", "Which brand?").
- The user can answer and resubmit.

### 6.6 AI Engine
- **Online:** OpenAI API is used when the device has an internet connection. The developer's API key is embedded for v1.0.
- **Offline:** Apple Intelligence (on-device FoundationModels) is used as a fallback when there is no internet connection.
- The app detects connectivity automatically and switches AI providers without user interaction.

---

## 7. User Flow

1. User opens the app → Home screen with search bar and input buttons.
2. User inputs a food name via text, speech, or photo.
3. App shows a loading indicator while AI processes the request.
4. App displays nutrition results in the two-tab view.
5. If AI cannot identify the product, app shows an error and follow-up questions.
6. User answers follow-up questions and resubmits.

---

## 8. Design Principles

- **Modern & colorful:** Bold use of color, gradients, and visual hierarchy.
- **Apple native:** Follows iOS Human Interface Guidelines. Uses SF Symbols, standard navigation patterns, and system fonts.
- **Simple:** No clutter. Every screen has a single clear purpose.
- **Accessible:** Supports Dynamic Type and VoiceOver.

---

## 9. Constraints & Assumptions

- The app requires iOS 18 or later (for Apple Intelligence / FoundationModels support).
- The OpenAI API key is hardcoded by the developer for v1.0.
- Nutrition data accuracy depends on the AI model's knowledge; the app is not a medical device and should display an appropriate disclaimer.
- Speech dictation is English only.
- No data is stored or sent to any backend other than OpenAI's API.

---

## 10. Success Metrics (Post-Launch)

- User can get nutrition facts for a common food in under 10 seconds.
- Photo recognition works correctly for common foods and printed nutrition labels.
- App works fully offline for common foods using Apple Intelligence.
- Zero crashes on supported iOS versions.

---

## 11. Decisions Made

| Question | Decision |
|---|---|
| Minimum iOS version | iOS 18 |
| Pie chart basis | Grams (Carbs g, Protein g, Fat g) |
| Disclaimer text | "Nutrition data is generated by AI and is intended for general informational purposes only. Values are approximate and may not reflect the exact composition of a specific product or brand. This app is not a medical device. Always consult a healthcare professional for dietary advice." |

The disclaimer is shown as a small footnote at the bottom of the Results screen (both tabs).
