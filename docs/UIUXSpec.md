# UI/UX Specification
## NutriFacts — iOS App

**Version:** 1.0
**Date:** 2026-03-05
**Status:** Draft

---

## 1. Design Principles

- **Modern & colorful:** Bold accent colors, gradients on key UI elements, vibrant chart colors.
- **Apple native:** Uses SF Symbols, system fonts (SF Pro), standard iOS navigation patterns, supports Dynamic Type and Dark Mode.
- **Simple:** Each screen has one clear purpose. No unnecessary chrome or decoration.
- **Accessible:** All interactive elements are accessible via VoiceOver. Contrast ratios meet WCAG AA.

---

## 2. Color Palette

| Role | Color | Notes |
|---|---|---|
| Primary Accent | System Blue (`#007AFF`) | Buttons, active states |
| Carbohydrates | System Orange (`#FF9500`) | Pie chart segment |
| Protein | System Green (`#34C759`) | Pie chart segment |
| Fat | System Pink (`#FF2D55`) | Pie chart segment |
| Background | System Background | Adapts to light/dark mode |
| Secondary Background | System Grouped Background | Section backgrounds |
| Label | System Label | Primary text |
| Secondary Label | System Secondary Label | Units, subtitles |
| Error | System Red (`#FF3B30`) | Error messages |

All colors use iOS system colors to ensure automatic Dark Mode support.

---

## 3. Typography

| Usage | Style |
|---|---|
| Screen title | SF Pro Display, Bold, 34pt |
| Section header | SF Pro Text, Semibold, 17pt |
| Nutrient name | SF Pro Text, Regular, 17pt |
| Nutrient value | SF Pro Text, Regular, 17pt |
| Unit label | SF Pro Text, Regular, 13pt, Secondary color |
| Calorie headline | SF Pro Display, Bold, 48pt |
| Macro headline | SF Pro Display, Semibold, 24pt |
| Error message | SF Pro Text, Regular, 17pt |
| Button label | SF Pro Text, Semibold, 17pt |

---

## 4. Screens

---

### Screen 1: Home Screen

**Purpose:** Entry point. Allows users to input a food name via text, speech, or photo.

**Layout:**

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│                                 │
│  NutriFacts          (large title)
│                                 │
│  ┌─────────────────────────────┐│
│  │ 🔍 Search food or product  ││  ← TextField
│  └─────────────────────────────┘│
│                                 │
│        [🎙] [📷]                │  ← Mic + Camera buttons
│                                 │
│  ┌─────────────────────────────┐│
│  │  Try: "Apple", "Oat milk"  ││  ← Suggestion chips (tappable examples)
│  │  "Greek yogurt", "Salmon"  ││
│  └─────────────────────────────┘│
│                                 │
│  (Empty state illustration)     │
│  Search for any food to see     │
│  its nutrition facts.           │
│                                 │
└─────────────────────────────────┘
```

**Elements:**

- **Navigation title:** "NutriFacts" — large title style.
- **Search bar:** Full-width text field with a magnifying glass icon on the left. Clear (X) button appears when text is entered. Return key label: "Search".
- **Mic button:** SF Symbol `mic.fill`, tinted with primary accent color. Positioned below/beside the search bar. When active, turns red (`mic.fill` with system red) and shows a subtle pulsing animation.
- **Camera button:** SF Symbol `camera.fill`, tinted with primary accent color. Tapping opens an action sheet: "Take Photo" / "Choose from Library".
- **Suggestion chips:** Horizontally scrollable row of tappable example food names. Tapping a chip fills the search bar and submits.
- **Empty state:** A simple illustration (food-related) with a short prompt text. Shown only when no results are active.

---

### Screen 2: Loading State

**Purpose:** Shown while the AI processes the request. Overlays or replaces the home screen content.

**Layout:**

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│                                 │
│  NutriFacts                     │
│                                 │
│  [Search bar — disabled]        │
│                                 │
│                                 │
│       ●  ●  ●  (animated)       │  ← Activity indicator
│                                 │
│    Looking up nutrition facts   │
│    for "Apple"...               │
│                                 │
└─────────────────────────────────┘
```

**Elements:**

- Search bar is visible but non-interactive during loading.
- A centered activity indicator (system style or custom animated dots).
- A short contextual message: "Looking up nutrition facts for [food name]..."

---

### Screen 3: Results Screen

**Purpose:** Displays nutrition facts after a successful AI lookup.

**Layout:**

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│  < Back          Apple          │  ← Navigation bar with food name
│                                 │
│  [Overview]  [Full Details]     │  ← Tab picker (segmented control)
│                                 │
│  ┌─────────────────────────────┐│
│  │                             ││
│  │     (Tab content here)      ││
│  │                             ││
│  └─────────────────────────────┘│
└─────────────────────────────────┘
```

**Navigation:** Back button returns to Home. Food name shown as navigation title.

---

#### Tab 1: Overview

```
┌─────────────────────────────────┐
│                                 │
│         per 100g                │  ← Unit label, centered, secondary color
│                                 │
│      ┌───────────────┐          │
│      │               │          │
│      │  [Pie Chart]  │          │  ← Colorful donut/pie chart
│      │               │          │
│      └───────────────┘          │
│                                 │
│  ┌────────┐ ┌────────┐          │
│  │ 52 kcal│ │ 0.2g   │          │  ← Calorie + Fat cards
│  │Calories│ │  Fat   │          │
│  └────────┘ └────────┘          │
│  ┌────────┐ ┌────────┐          │
│  │ 14g    │ │ 0.3g   │          │  ← Carbs + Protein cards
│  │ Carbs  │ │Protein │          │
│  └────────┘ └────────┘          │
│                                 │
│  ■ Carbs  ■ Protein  ■ Fat      │  ← Chart legend
│                                 │
└─────────────────────────────────┘
```

**Elements:**

- **Unit label:** "per 100g" or "per 100ml" — centered at top, secondary color, small font.
- **Pie / Donut chart:** Uses Swift Charts. Three segments: Carbs (orange), Protein (green), Fat (pink). Segments are labeled with percentage or gram values.
- **Macro summary cards:** Four cards in a 2x2 grid: Calories (kcal), Fat (g), Carbs (g), Protein (g). Each card has a large bold value and a label. Cards have a rounded rectangle background in the secondary grouped background color.
- **Legend:** Three colored dots with labels below the chart.

---

#### Tab 2: Full Details

```
┌─────────────────────────────────┐
│         per 100g                │  ← Unit label
│                                 │
│  MACRONUTRIENTS                 │  ← Section header
│  Calories          52 kcal      │
│  Total Fat         0.2 g        │
│  — Saturated Fat   0.0 g        │
│  — Trans Fat       0.0 g        │
│  Carbohydrates     14 g         │
│  — Sugar           10 g         │
│  — Dietary Fiber   2.4 g        │
│  Protein           0.3 g        │
│                                 │
│  VITAMINS                       │  ← Section header
│  Vitamin C         5.1 mg       │
│  Vitamin B6        0.04 mg      │
│  ...                            │
│                                 │
│  MINERALS                       │  ← Section header
│  Potassium         107 mg       │
│  Phosphorus        11 mg        │
│  ...                            │
│                                 │
│  ALLERGENS                      │  ← Section header
│  None detected                  │
│  (or list of allergens)         │
│                                 │
│  INGREDIENTS                    │  ← Section header
│  (full text or "Not available") │
│                                 │
└─────────────────────────────────┘
```

**Elements:**

- **Unit label:** Same as Tab 1 — "per 100g" or "per 100ml".
- **Section headers:** Uppercase, secondary color, standard iOS list section header style.
- **Rows:** Each row shows nutrient name (left) and value + unit (right). Sub-items (Saturated Fat, Sugar, etc.) are indented slightly.
- **Allergens:** If none, shows "None detected". If present, shows a list. Known allergens are highlighted in a warning color.
- **Ingredients:** Plain text paragraph. If unavailable, shows "Not available".
- **Style:** Uses SwiftUI `List` with `insetGrouped` style for native iOS feel.

---

### Screen 4: Error Screen

**Purpose:** Shown when the AI cannot identify the food. Guides the user with follow-up questions.

**Layout:**

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│  < Back                         │
│                                 │
│       (Warning illustration)    │
│                                 │
│   We couldn't identify this     │
│   food. Let's try to narrow     │
│   it down.                      │
│                                 │
│  ┌─────────────────────────────┐│
│  │ Is this raw or cooked?      ││  ← Follow-up question 1
│  │ ○ Raw   ○ Cooked   ○ Other  ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ Do you know the brand name? ││  ← Follow-up question 2
│  │ [Text field]                ││
│  └─────────────────────────────┘│
│                                 │
│       [Try Again]               │  ← Primary button
│                                 │
└─────────────────────────────────┘
```

**Elements:**

- **Illustration:** A simple, friendly warning icon or food question mark. Not alarming.
- **Error message:** Friendly, plain English. No technical jargon.
- **Follow-up questions:** 1–3 questions generated by the AI. Each question renders as either a multiple-choice option group or a text input, depending on the question type.
- **Try Again button:** Primary style (filled, accent color). Submits the original query plus the user's follow-up answers.
- **Back button:** Returns to Home without submitting.

---

## 5. Navigation Structure

```
HomeView (root)
├── (loading overlay — inline, no navigation)
├── ResultsView (push navigation)
│   ├── OverviewTab
│   └── DetailsTab
└── ErrorView (push navigation)
    └── (retry → back to HomeView with context)
```

- Navigation uses SwiftUI `NavigationStack`.
- No tab bar at the app level (the tab bar is only inside ResultsView).
- The app is a single-flow experience: input → loading → result or error.

---

## 6. Animations & Transitions

- **Loading:** Smooth fade-in of the loading indicator when a query is submitted.
- **Results appearance:** Results view pushes in from the right (standard NavigationStack push).
- **Pie chart:** Animates in with a sweep animation when the Overview tab loads.
- **Mic button active state:** Subtle pulse animation (scale up/down) while recording.
- **Tab switch:** Instant tab content switch (no animation needed between Overview and Details tabs).

---

## 7. Empty & Edge States

| State | UI |
|---|---|
| App first launch | Empty home with illustration and suggestion chips |
| Loading | Activity indicator with contextual message |
| Success | Results view with two tabs |
| Error / not found | Error screen with follow-up questions |
| No internet + Apple Intelligence unavailable | Inline error on home screen: "AI is currently unavailable. Please check your connection." |
| Camera / mic permission denied | Inline alert explaining why permission is needed with a link to Settings |
| Photo too blurry / unclear | Error screen with message "The photo isn't clear enough. Try taking a clearer photo or use text search." |

---

## 8. Accessibility

- All buttons have descriptive accessibility labels (e.g. `accessibilityLabel("Search by voice")`).
- The pie chart provides an accessibility description of the macro breakdown in text form.
- All text scales with Dynamic Type.
- Color is never the only way to convey information (values are also shown as text).
- VoiceOver reads section headers and nutrient rows in a logical order.
