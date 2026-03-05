# User Stories
## NutriFacts — iOS App

**Version:** 1.0
**Date:** 2026-03-05
**Status:** Draft

---

## Epic 1: Text Search

### US-01 — Search by typing
**As a** user,
**I want to** type a food or product name into a search bar,
**So that** I can quickly look up its nutrition facts.

**Acceptance Criteria:**
- A search bar is visible on the home screen when the app launches.
- I can type any food or product name in English.
- Pressing the return key or a search button submits the query.
- A loading indicator is shown while the AI processes my request.
- Nutrition results are shown when the AI responds successfully.

---

### US-02 — Clear search and start over
**As a** user,
**I want to** clear my current search and start a new one,
**So that** I can look up a different food without restarting the app.

**Acceptance Criteria:**
- A clear button (X) appears in the search bar when text is entered.
- Tapping it clears the text and returns to the idle home state.

---

## Epic 2: Speech Input

### US-03 — Dictate a food name
**As a** user,
**I want to** tap a microphone button and speak the food name,
**So that** I can search without typing.

**Acceptance Criteria:**
- A microphone button is visible next to the search bar.
- Tapping it starts speech recognition and shows a visual indicator that recording is active.
- My spoken words are transcribed into the search bar in real time.
- I can see the transcribed text before submitting.
- Tapping the microphone button again (or after silence) stops recording.
- I can edit the transcribed text if needed before submitting.

---

### US-04 — Dictation in English only
**As a** user,
**I want to** speak in English,
**So that** the app correctly transcribes my food name.

**Acceptance Criteria:**
- The speech recognizer is set to English (en-US).
- Non-English speech produces a best-effort transcription or a clear error.

---

## Epic 3: Photo Input

### US-05 — Take a photo of a food item
**As a** user,
**I want to** take a photo of a food item (e.g. an apple, a plate of pasta),
**So that** the AI identifies it and shows me its nutrition facts.

**Acceptance Criteria:**
- A camera button is visible on the home screen.
- Tapping it opens the camera.
- I can take a photo and confirm it.
- A loading indicator is shown while the AI processes the image.
- Nutrition results are shown for the identified food.

---

### US-06 — Choose a photo from my library
**As a** user,
**I want to** choose a photo from my photo library,
**So that** I can look up nutrition facts for a food I photographed earlier.

**Acceptance Criteria:**
- The photo input button provides an option to open the photo library.
- I can select an existing photo.
- The app processes it the same way as a camera photo.

---

### US-07 — Take a photo of a nutrition label
**As a** user,
**I want to** take a photo of a nutrition label on a product package,
**So that** the app reads the label and displays the data in its standard format.

**Acceptance Criteria:**
- The app accepts photos of printed nutrition labels.
- The AI extracts the values from the label.
- Values are normalized and displayed per 100g or 100ml.
- The result is shown in the same two-tab results view as text searches.

---

## Epic 4: Nutrition Results

### US-08 — View macro overview with pie chart
**As a** user,
**I want to** see a pie chart showing the macronutrient breakdown,
**So that** I can quickly understand the composition of the food.

**Acceptance Criteria:**
- The first results tab shows a colorful pie chart.
- The chart shows Carbohydrates, Protein, and Fat as segments.
- Each segment is clearly labeled with a name and value.
- Calories, Protein, Carbs, and Fat are displayed as headline numbers below or around the chart.
- All values are per 100g (solid) or per 100ml (liquid).

---

### US-09 — View full nutrition details
**As a** user,
**I want to** see all nutrition data organized into sections,
**So that** I can find specific information like vitamins, minerals, and allergens.

**Acceptance Criteria:**
- The second results tab shows a scrollable list.
- The list is organized into sections: Macronutrients, Vitamins, Minerals, Allergens, Ingredients.
- Each item shows the nutrient name, amount, and unit.
- All values are per 100g (solid) or per 100ml (liquid).
- The unit label (per 100g or per 100ml) is clearly shown.

---

### US-10 — Know if a food is measured per 100g or per 100ml
**As a** user,
**I want to** know whether the values shown are per 100g or per 100ml,
**So that** I understand the basis of the numbers.

**Acceptance Criteria:**
- For solid foods, all values are labeled "per 100g".
- For liquid foods/drinks, all values are labeled "per 100ml".
- This label is clearly visible on both tabs.

---

## Epic 5: Error Handling & Follow-Up

### US-11 — See a helpful error when a product is not recognized
**As a** user,
**I want to** see a friendly message when the AI cannot identify my food,
**So that** I understand what went wrong and what to do next.

**Acceptance Criteria:**
- A clear, non-technical error message is shown.
- The message does not show raw API errors or technical details.

---

### US-12 — Answer follow-up questions to refine my search
**As a** user,
**I want to** answer follow-up questions from the app when my food is not recognized,
**So that** I can give the AI more context and get a result.

**Acceptance Criteria:**
- After an error, the app displays 1–3 follow-up questions.
- Questions are specific and helpful (e.g. "Is this raw or cooked?", "Which brand is this?").
- I can answer by typing or selecting from options if provided.
- Submitting my answers triggers a new AI lookup with the additional context.

---

## Epic 6: AI Engine & Connectivity

### US-13 — Use the app online with OpenAI
**As a** user,
**I want to** get nutrition facts powered by OpenAI when I have internet,
**So that** I get the most accurate and comprehensive data.

**Acceptance Criteria:**
- When connected to the internet, the app uses OpenAI.
- The switch is automatic and invisible to the user.

---

### US-14 — Use the app offline with Apple Intelligence
**As a** user,
**I want to** use the app without an internet connection,
**So that** I can look up common foods even when offline.

**Acceptance Criteria:**
- When there is no internet connection, the app uses Apple's on-device AI.
- The experience is the same from the user's perspective.
- If both AI providers are unavailable, a clear message is shown.

---

## Epic 7: Permissions & Privacy

### US-15 — Grant microphone permission
**As a** user,
**I want to** be prompted to grant microphone access the first time I use speech input,
**So that** I understand why the permission is needed.

**Acceptance Criteria:**
- The system permission dialog appears the first time I tap the microphone button.
- If I deny permission, a message explains that microphone access is needed for dictation.

---

### US-16 — Grant camera and photo library permission
**As a** user,
**I want to** be prompted to grant camera and photo library access the first time I use photo input,
**So that** I understand why the permission is needed.

**Acceptance Criteria:**
- The system permission dialog appears the first time I use the camera or photo library.
- If I deny permission, a message explains that access is needed for photo search.
