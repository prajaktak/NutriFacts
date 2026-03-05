# Coding Conventions

This document outlines the coding standards and conventions for the Sequence Game project.

**IMPORTANT**: Always refer to this document before writing code, suggesting changes, or reviewing code. All code must adhere to these conventions.

## Quick Reference Checklist

Before writing any code, ensure you:
- [ ] Reviewed file organization rules (one type per file)
- [ ] Checked naming conventions (descriptive names, no short abbreviations)
- [ ] Verified TDD approach (one behavior per test)
- [ ] Reviewed SwiftLint rules
- [ ] Checked Apple Swift API Design Guidelines
- [ ] Verified OOP principles (SOLID, encapsulation, composition)
- [ ] Ensured proper access control (private by default)
- [ ] Added `#Preview` for SwiftUI views

## File Organization

### One Type Per File
- **Each enum, struct, or class MUST be in its own file.**
- Do NOT combine multiple types in a single file.
- Example: `JackRule.swift` contains only the `JackRule` enum.
- Example: `Card.swift` contains only the `Card` struct.

### File Structure
- Models: `SequenceGame/models/`
- Views: `SequenceGame/Views/`
- Tests: `SequenceGameTests/`

## Testing (TDD - Test-Driven Development)

### Test Structure
- **One behavior per test** — each test MUST test only ONE thing.
- If you need to test multiple inputs, write **separate tests** for each.
- Do NOT combine multiple assertions that test different behaviors.

### Test Naming
- Use descriptive names: `testFunctionName_condition_expectedResult`
- Example: `jackClassification_clubs_returnsPlaceAnywhere`
- Example: `testPlaceChip_setsChip`

### Test Examples

✅ **CORRECT** — One behavior per test:
```swift
@Test("Jack classification: clubs → placeAnywhere")
func jackClassification_clubs_returnsPlaceAnywhere() {
    let gameState = GameState()
    let jackOfClubs = Card(cardFace: .jack, suit: .clubs)
    #expect(gameState.classifyJack(jackOfClubs) == .placeAnywhere)
}

@Test("Jack classification: diamonds → placeAnywhere")
func jackClassification_diamonds_returnsPlaceAnywhere() {
    let gameState = GameState()
    let jackOfDiamonds = Card(cardFace: .jack, suit: .diamonds)
    #expect(gameState.classifyJack(jackOfDiamonds) == .placeAnywhere)
}
```

❌ **WRONG** — Testing multiple behaviors:
```swift
@Test("Jack classification: clubs/diamonds → placeAnywhere")
func jackClassification_twoEyed_returnsPlaceAnywhere() {
    let gameState = GameState()
    let jackOfClubs = Card(cardFace: .jack, suit: .clubs)
    let jackOfDiamonds = Card(cardFace: .jack, suit: .diamonds)
    #expect(gameState.classifyJack(jackOfClubs) == .placeAnywhere)
    #expect(gameState.classifyJack(jackOfDiamonds) == .placeAnywhere)  // ❌ Second behavior
}
```

### TDD Workflow
1. **Write a failing test first** — test the behavior you want.
2. **Write minimal code** to make the test pass.
3. **Refactor** if needed, keeping tests green.
4. **Repeat** for next behavior.

### Test Guidelines
- **No guards in tests** — hardcode test data instead of using guards.
- **Test single functionality** — one test = one behavior.
- **Keep tests focused** — don't test side effects that aren't part of the function's responsibility.

## Code Style

### Naming Conventions
- **Use descriptive names** — avoid abbreviations shorter than 3 characters.
- **Loop variables**: Use descriptive names (`rowIndex`, `columnIndex`, `playerIndex`) instead of `i`, `j`, `x`, `y`, etc.
- **Avoid single-letter names** unless they're mathematical constants (π, e).

✅ **CORRECT**:
```swift
for rowIndex in 0..<rows {
    for columnIndex in 0..<columns {
        // ...
    }
}
```

❌ **WRONG**:
```swift
for i in 0..<rows {
    for j in 0..<columns {
        // ...
    }
}
```

### Function Responsibilities
- **Single Responsibility Principle** — each function should do ONE thing.
- Functions should be testable independently.
- Example: `placeChip` only places a chip; it doesn't modify the hand or advance the turn.

### Separation of Concerns

#### Functions Must Have Single Responsibility
- **Do NOT mix two or more functionalities in one function.**
- Each function should perform ONE specific task.
- If a function does multiple things, split it into smaller functions.

✅ **CORRECT**:
```swift
// Single responsibility: remove card from hand
func removeCardFromHand(cardId: UUID) -> Card? {
    guard let playerIndex = players.firstIndex(where: { $0.id == currentPlayer?.id }),
          let handIndex = players[playerIndex].cards.firstIndex(where: { $0.id == cardId }) else {
        return nil
    }
    return players[playerIndex].cards.remove(at: handIndex)
}

// Single responsibility: place chip on board
func placeChip(at position: (row: Int, col: Int), teamColor: Color) {
    guard boardTiles.indices.contains(position.row),
          boardTiles[position.row].indices.contains(position.col) else { return }
    boardTiles[position.row][position.col].isChipOn = true
    boardTiles[position.row][position.col].chip = Chip(
        color: teamColor,
        positionRow: position.row,
        positionColumn: position.col,
        isPlaced: true
    )
}

// Orchestration function that calls single-responsibility functions
func performPlay(at position: (row: Int, col: Int), using cardId: UUID) {
    let playedCard = removeCardFromHand(cardId: cardId)  // ✅ Calls dedicated function
    placeChip(at: position, teamColor: teamColor)  // ✅ Calls dedicated function
    drawReplacementForHand()  // ✅ Calls dedicated function
    advanceTurn()  // ✅ Calls dedicated function
}
```

❌ **WRONG**:
```swift
func performPlay(at position: (row: Int, col: Int), using cardId: UUID) {
    // ❌ Mixing multiple responsibilities:
    // 1. Removing card from hand
    guard let playerIndex = players.firstIndex(where: { $0.id == currentPlayer?.id }),
          let handIndex = players[playerIndex].cards.firstIndex(where: { $0.id == cardId }) else {
        return
    }
    let playedCard = players[playerIndex].cards.remove(at: handIndex)
    
    // 2. Placing chip on board
    boardTiles[position.row][position.col].isChipOn = true
    boardTiles[position.row][position.col].chip = Chip(...)
    
    // 3. Drawing replacement card
    if let drawn = deck.drawCard() {
        players[playerIndex].cards.append(drawn)
    }
    
    // 4. Advancing turn
    currentPlayerIndex = (currentPlayerIndex + 1) % players.count
}
```

#### Classes and Structures Must Have Single Responsibility
- **Each class or struct should represent ONE concept or entity.**
- Do NOT mix unrelated functionality in one type.

✅ **CORRECT**:
```swift
struct Card: Identifiable {
    let id: UUID
    let cardFace: CardFace
    let suit: Suit
    // ✅ Only represents a card
}

class Deck {
    private(set) var cards: [Card] = []
    func resetDeck() { }
    func shuffle() { }
    func drawCard() -> Card? { }
    // ✅ Only manages deck operations
}
```

❌ **WRONG**:
```swift
class GameManager {
    var cards: [Card] = []
    var players: [Player] = []
    func resetDeck() { }  // ❌ Deck functionality
    func shuffle() { }  // ❌ Deck functionality
    func updatePlayerScore() { }  // ❌ Player functionality
    func validateMove() { }  // ❌ Game logic functionality
    func renderUI() { }  // ❌ UI functionality
    // ❌ Too many responsibilities
}
```

#### Closures Must Have Single Responsibility
- **Each closure should perform ONE specific task.**
- Avoid closures that do multiple unrelated things.

✅ **CORRECT**:
```swift
// Closure with single responsibility: filter valid cards
let validCards = player.cards.filter { card in
    card.cardFace != .jack
}

// Closure with single responsibility: transform card to position
let positions = cards.map { card in
    findPosition(for: card)
}
```

❌ **WRONG**:
```swift
// ❌ Closure doing multiple things: filtering AND updating state
let result = player.cards.filter { card in
    if card.cardFace == .jack {
        gameState.updateScore()  // ❌ Side effect - mixing concerns
        return false
    }
    return true
}
```

#### Test Functions Must Have Single Responsibility
- **Each test should verify ONE behavior or scenario.**
- Do NOT test multiple behaviors in one test function.

✅ **CORRECT**:
```swift
@Test("placeChip sets chip at position")
func testPlaceChip_setsChip() {
    // ✅ Tests only chip placement
    state.placeChip(at: (row: 3, col: 3), teamColor: .blue)
    let tile = state.boardTiles[3][3]
    #expect(tile.isChipOn == true)
}

@Test("placeChip does not change current player's hand")
func testPlaceChip_doesNotChangeHand() {
    // ✅ Tests only hand preservation (separate test)
    let startCount = state.players[state.currentPlayerIndex].cards.count
    state.placeChip(at: (row: 2, col: 2), teamColor: .blue)
    #expect(state.players[state.currentPlayerIndex].cards.count == startCount)
}
```

❌ **WRONG**:
```swift
@Test("placeChip sets chip and does not change hand")
func testPlaceChip_multipleBehaviors() {
    // ❌ Testing two different behaviors in one test
    state.placeChip(at: (row: 3, col: 3), teamColor: .blue)
    let tile = state.boardTiles[3][3]
    #expect(tile.isChipOn == true)  // Behavior 1
    
    let startCount = state.players[state.currentPlayerIndex].cards.count
    #expect(state.players[state.currentPlayerIndex].cards.count == startCount)  // Behavior 2
}
```

### Comments
- **Focus on "why"** — explain the reason, not what the code does.
- Avoid restating code in comments.

## Apple Swift API Design Guidelines

These guidelines are based on Apple's official [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).

### Fundamental Principles

#### Clarity at the Point of Use
- Code should read clearly at the point of use.
- Clarity is more important than brevity.

#### Clarity over Brevity
- **Prefer clarity** — make code easy to read and understand.
- Avoid abbreviations that aren't immediately clear.
- Write code for other developers to read.

✅ **CORRECT**:
```swift
func removeCardFromHand(cardId: UUID) -> Card?
func placeChip(at position: (row: Int, col: Int), teamColor: Color)
```

❌ **WRONG**:
```swift
func remCard(id: UUID) -> Card?  // ❌ Unclear abbreviation
func put(at pos: (Int, Int), col: Color)  // ❌ Too brief, confusing
```

### Naming Guidelines

#### Use Terminology Well
- **Prefer terms of art**: Use established terms that developers expect.
  - Example: `remove`, `insert`, `contains`, `isEmpty`
- **Avoid abbreviations**: Don't abbreviate unless the abbreviation is universally understood.
  - ❌ `idx`, `cnt`, `dbg` 
  - ✅ `index`, `count`, `debug`
- **Avoid ambiguous terms**: Use specific, unambiguous names.

#### Compensate for Weak Type Information
- Use descriptive names when types don't provide enough information.

✅ **CORRECT**:
```swift
let playerName: String
let handCount: Int
let currentPlayerIndex: Int
```

❌ **WRONG**:
```swift
let name: String  // ❌ Too generic
let count: Int    // ❌ Count of what?
let index: Int    // ❌ Index of what?
```

### Conventions for Types

#### Types as Nouns
- Types and protocols are **nouns**: `Card`, `Player`, `GameState`, `Deck`
- Use singular forms: `Card`, not `Cards`

✅ **CORRECT**:
```swift
struct Card { }
enum Suit { }
class GameState { }
```

❌ **WRONG**:
```swift
struct Cards { }  // ❌ Use singular
enum Suits { }    // ❌ Use singular
```

#### Protocols as Qualities
- Protocols describing **what something is** should be nouns: `Identifiable`, `Equatable`
- Protocols describing **capabilities** should end in `-able`, `-ible`, or `-ing`:
  - ✅ `Comparable`, `Codable`, `Equatable`
  - ❌ `Compare`, `Code`, `Equal`

#### Methods and Functions

**Methods that Mutate:**
- Name should be a verb: `remove`, `insert`, `append`, `shuffle`
- Do NOT use `-ed` or `-ing` suffix (those are for non-mutating versions)

✅ **CORRECT**:
```swift
mutating func removeCard(at index: Int)
mutating func shuffle()
func append(_ item: Card)
```

**Methods that are Non-Mutating:**
- Use verb forms: `distance(to:)`, `contains(_:)`
- Or noun phrases: `count`, `isEmpty`

✅ **CORRECT**:
```swift
func contains(_ card: Card) -> Bool
var count: Int { }
var isEmpty: Bool { }
```

**Mutating vs Non-Mutating Pairs:**
- Mutating: `shuffle()`, `remove(at:)`
- Non-mutating: `shuffled()`, `removing(at:)` (if needed)

#### Boolean Methods and Properties
- **Predicates** should read as assertions: `isEmpty`, `hasCards`, `isSelected`

✅ **CORRECT**:
```swift
var isEmpty: Bool
func contains(_ card: Card) -> Bool
var isSelected: Bool
```

❌ **WRONG**:
```swift
var empty: Bool        // ❌ Not clear it's a question
func check(_ card: Card) -> Bool  // ❌ Use contains
var selected: Bool    // ❌ Use isSelected
```

#### Protocols Describing What Something Is
- Protocols that describe **what something is** should be nouns: `Collection`, `Sequence`

### Parameters

#### Choose Parameter Names to Serve Documentation
- Parameter names should be **self-documenting**.
- Use labels for clarity, omit them when obvious from context.

✅ **CORRECT**:
```swift
func placeChip(at position: (row: Int, col: Int), teamColor: Color)
func removeCardFromHand(cardId: UUID) -> Card?
```

❌ **WRONG**:
```swift
func placeChip(at: (Int, Int), Color)  // ❌ Missing labels
func removeCardFromHand(id: UUID)  // ❌ Unclear what 'id' refers to
```

#### Omit Labels When They Don't Improve Clarity
- Omit labels for the first parameter when the method name makes it clear.

✅ **CORRECT**:
```swift
func contains(_ card: Card) -> Bool  // ✅ Clear from context
func append(_ item: Card)  // ✅ Clear from context
```

❌ **WRONG**:
```swift
func contains(card: Card) -> Bool  // ❌ Redundant label
```

### Special Conventions

#### Document Complex Functionality
- Use **documentation comments** (`///`) for complex functions.
- Explain the "why" and behavior, not just "what".

✅ **CORRECT**:
```swift
/// Computes all valid board positions for a given card (non-Jack).
/// Returns positions where the card can be placed matching both
/// cardFace and suit.
func computePlayableTiles(for card: Card) -> [(row: Int, col: Int)]
```

#### Prefer Composition Over Inheritance
- Use **structs and protocols** over classes when possible.
- Value types (`struct`, `enum`) over reference types (`class`) when appropriate.

✅ **CORRECT**:
```swift
struct Card: Identifiable, Equatable { }
struct BoardTile { }
enum Suit: CaseIterable { }
```

#### Use Enums for States
- Use **enums** for finite states and options.

✅ **CORRECT**:
```swift
enum GameOverlayMode {
    case turnStart
    case cardSelected
    case deadCard
    case postPlacement
}
```

### Error Handling

#### Use Optionals for Simple Error Cases
- Use `Optional` for "not found" or "doesn't exist" cases.

✅ **CORRECT**:
```swift
func drawCard() -> Card?  // Returns nil if deck is empty
func findPlayer(by id: UUID) -> Player?  // Returns nil if not found
```

#### Use Result Types for Detailed Errors
- Use `Result<T, Error>` when you need detailed error information.

### Type Safety

#### Prefer Type Safety
- Use Swift's type system to prevent errors.
- Avoid `Any` and force casting when possible.

✅ **CORRECT**:
```swift
let cards: [Card] = []
let player: Player? = findPlayer(by: id)
```

❌ **WRONG**:
```swift
let cards: [Any] = []  // ❌ Too generic
let player = findPlayer(by: id) as! Player  // ❌ Force cast
```

### Documentation

#### Use Documentation Comments
- Use `///` for public APIs and complex logic.
- Use `//` for inline comments explaining "why".

✅ **CORRECT**:
```swift
/// Removes a card from the current player's hand and returns it.
/// Returns `nil` if the card is not found in the hand.
func removeCardFromHand(cardId: UUID) -> Card? {
    // Guard ensures we have a valid player and card exists
    guard let playerIndex = players.firstIndex(where: { $0.id == currentPlayer?.id }),
          let handIndex = players[playerIndex].cards.firstIndex(where: { $0.id == cardId }) else {
        return nil
    }
    return players[playerIndex].cards.remove(at: handIndex)
}
```

### Collection Conventions

#### Follow Established Collection Patterns
- Use methods that match Swift standard library: `isEmpty`, `contains`, `first`, `filter`, `map`

✅ **CORRECT**:
```swift
if players.isEmpty { return }
if players.contains(where: { $0.id == playerId }) { }
let firstPlayer = players.first
```

## Object-Oriented Programming (OOP) Conventions

These conventions guide the use of object-oriented principles in Swift, following best practices for Swift's unique type system.

### SOLID Principles

#### Single Responsibility Principle (SRP)
- **Each class, struct, or function should have ONE reason to change.**
- A type should do ONE thing and do it well.

✅ **CORRECT**:
```swift
struct Card: Identifiable, Equatable {
    let id: UUID
    let cardFace: CardFace
    let suit: Suit
    // Only responsible for representing a card
}

class Deck {
    private(set) var cards: [Card] = []
    func resetDeck() { }
    func shuffle() { }
    func drawCard() -> Card? { }
    // Only responsible for managing a deck of cards
}
```

❌ **WRONG**:
```swift
class GameManager {
    var cards: [Card] = []
    var players: [Player] = []
    func updateUI() { }  // ❌ UI responsibility
    func saveToDatabase() { }  // ❌ Data persistence responsibility
    func validateMove() { }  // ❌ Game logic responsibility
    // Too many responsibilities
}
```

#### Open/Closed Principle (OCP)
- **Open for extension, closed for modification.**
- Use protocols and extensions to add functionality without modifying existing code.

✅ **CORRECT**:
```swift
protocol Playable {
    func canPlay() -> Bool
}

extension Card: Playable {
    func canPlay() -> Bool {
        return cardFace != .jack || suit == .clubs || suit == .diamonds
    }
}
```

#### Liskov Substitution Principle (LSP)
- **Subtypes must be substitutable for their base types.**
- Derived classes must not break expectations of the base class/protocol.

✅ **CORRECT**:
```swift
protocol Movable {
    func move(to position: (Int, Int))
}

struct Chip: Movable {
    func move(to position: (Int, Int)) {
        // Chip-specific implementation
    }
}

struct Piece: Movable {
    func move(to position: (Int, Int)) {
        // Piece-specific implementation
    }
}
```

#### Interface Segregation Principle (ISP)
- **Clients should not depend on interfaces they don't use.**
- Prefer small, focused protocols over large, monolithic ones.

✅ **CORRECT**:
```swift
protocol Identifiable {
    var id: UUID { get }
}

protocol Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool
}

// Use composition for multiple capabilities
struct Card: Identifiable, Equatable { }
```

❌ **WRONG**:
```swift
protocol GameEntity {
    var id: UUID { get }
    var name: String { get }
    var position: (Int, Int) { get set }
    var score: Int { get set }
    func draw() { }
    func update() { }
    func save() { }
    // ❌ Too many responsibilities - not all entities need all methods
}
```

#### Dependency Inversion Principle (DIP)
- **Depend on abstractions (protocols), not concrete implementations.**
- High-level modules should not depend on low-level modules.

✅ **CORRECT**:
```swift
protocol CardProvider {
    func drawCard() -> Card?
}

class GameState {
    private let deck: CardProvider  // ✅ Depends on abstraction
    
    init(cardProvider: CardProvider) {
        self.deck = cardProvider
    }
}
```

❌ **WRONG**:
```swift
class GameState {
    private let deck = Deck()  // ❌ Direct dependency on concrete type
}
```

### Encapsulation

#### Access Control
- **Use the most restrictive access level that works.**
- Default to `private` or `fileprivate`, only make `internal` or `public` when needed.

**Access Levels (most to least restrictive):**
1. `private` — only within the same declaration
2. `fileprivate` — only within the same file
3. `internal` — default, within the same module
4. `public` — accessible from other modules
5. `open` — can be subclassed/overridden from other modules

✅ **CORRECT**:
```swift
class GameState {
    private var deck: Deck = .init()  // ✅ Internal implementation
    @Published var players: [Player] = []  // ✅ Public state
    
    private func setupBoard() { }  // ✅ Internal helper
}
```

#### Property Encapsulation
- Use `private(set)` to allow read access but restrict write access.
- Expose computed properties for controlled access.

✅ **CORRECT**:
```swift
class Deck {
    private(set) var cards: [Card] = []  // ✅ Readable, not writable externally
    
    private var shuffleSeed: Int = 0  // ✅ Completely private
}
```

### Inheritance vs Composition

#### Prefer Composition Over Inheritance
- **Swift favors value types and composition.**
- Use protocols and structs over classes when possible.

✅ **CORRECT** (Composition):
```swift
struct Card: Identifiable, Equatable {
    let id: UUID
    let cardFace: CardFace
    let suit: Suit
}

struct Player {
    let id: UUID
    let name: String
    var cards: [Card]  // ✅ Composition
    let team: Team  // ✅ Composition
}
```

❌ **WRONG** (Unnecessary Inheritance):
```swift
class GameEntity { }
class Card: GameEntity { }  // ❌ Unnecessary hierarchy
class Player: GameEntity { }  // ❌ Unnecessary hierarchy
```

#### When to Use Inheritance
- Use class inheritance only when you need:
  - **Reference semantics** (shared state)
  - **Polymorphism** with `override`
  - **Inherited implementation** from base class

✅ **CORRECT** (When Inheritance Makes Sense):
```swift
class ObservableObject: AnyObject {
    // Base class for observable objects
}

final class GameState: ObservableObject {
    // ✅ Inherits ObservableObject functionality
}
```

### Polymorphism

#### Protocol-Oriented Programming
- **Swift favors protocols over classes for polymorphism.**
- Use protocols to define capabilities and structs/enums for implementation.

✅ **CORRECT**:
```swift
protocol Drawable {
    func draw() -> Card?
}

struct Deck: Drawable {
    func draw() -> Card? { }
}

struct ShuffledDeck: Drawable {
    func draw() -> Card? { }
}

// Polymorphism through protocols
func useDeck(_ deck: Drawable) {
    let card = deck.draw()  // ✅ Works with any Drawable
}
```

#### Method Overriding
- Use `override` keyword when overriding superclass methods.
- Use `final` to prevent overriding when not needed.

✅ **CORRECT**:
```swift
class BaseCardProvider {
    func provideCard() -> Card? {
        return nil
    }
}

class DeckProvider: BaseCardProvider {
    override func provideCard() -> Card? {  // ✅ Explicit override
        return deck.drawCard()
    }
}
```

### Abstraction

#### Use Protocols for Abstraction
- Define interfaces using protocols.
- Hide implementation details behind abstractions.

✅ **CORRECT**:
```swift
protocol GameRules {
    func isValidMove(_ move: Move) -> Bool
    func canPlaceChip(at position: (Int, Int)) -> Bool
}

struct SequenceGameRules: GameRules {
    func isValidMove(_ move: Move) -> Bool {
        // Implementation
    }
    
    func canPlaceChip(at position: (Int, Int)) -> Bool {
        // Implementation
    }
}
```

#### Abstract Away Implementation Details
- Hide complex logic behind simple interfaces.
- Expose only what's needed.

✅ **CORRECT**:
```swift
class GameState {
    // Public interface
    func performPlay(at position: (Int, Int), using cardId: UUID) {
        // Implementation details hidden
    }
    
    // Private implementation
    private func validatePlay(_ card: Card, at position: (Int, Int)) -> Bool {
        // Complex validation logic
    }
}
```

### Class Design

#### When to Use Classes
- Use classes when you need:
  - **Reference semantics** (shared state)
  - **Inheritance** and polymorphism
  - **Identity** (object identity matters)

✅ **CORRECT**:
```swift
class GameState: ObservableObject {
    // ✅ Needs reference semantics for ObservableObject
    // ✅ Shared state across views
}
```

#### When to Use Structs
- Use structs by default for:
  - **Value semantics** (copied, not shared)
  - **No inheritance needed**
  - **Simple data containers**

✅ **CORRECT**:
```swift
struct Card: Identifiable, Equatable {
    let id: UUID
    let cardFace: CardFace
    let suit: Suit
    // ✅ Value type, copied when passed around
}

struct BoardTile {
    let card: Card?
    var isChipOn: Bool
    // ✅ Value type
}
```

#### When to Use Enums
- Use enums for:
  - **Finite states** or options
  - **Related constants**
  - **Discriminated unions**

✅ **CORRECT**:
```swift
enum GameOverlayMode {
    case turnStart
    case cardSelected
    case deadCard
    case postPlacement
    // ✅ Finite set of states
}

enum Suit: CaseIterable {
    case hearts, spades, diamonds, clubs
    // ✅ Related constants
}
```

### Design Patterns in Swift

#### Observer Pattern
- Use `@Published` and `ObservableObject` for SwiftUI.

✅ **CORRECT**:
```swift
final class GameState: ObservableObject {
    @Published var players: [Player] = []
    @Published var currentPlayerIndex: Int = 0
    // ✅ Views automatically observe changes
}
```

#### Strategy Pattern
- Use protocols and structs to encapsulate algorithms.

✅ **CORRECT**:
```swift
protocol ScoringStrategy {
    func calculateScore(for player: Player) -> Int
}

struct SequenceScoring: ScoringStrategy {
    func calculateScore(for player: Player) -> Int {
        // Sequence-specific scoring
    }
}
```

#### Factory Pattern
- Use static methods or initializers for object creation.

✅ **CORRECT**:
```swift
struct Player {
    static func createPlayers(for teams: [Team]) -> [Player] {
        // Factory method for creating players
    }
}
```

### Best Practices

#### Final Classes
- Mark classes as `final` unless they need subclassing.

✅ **CORRECT**:
```swift
final class GameState: ObservableObject {
    // ✅ Cannot be subclassed, improves performance
}
```

#### Avoid Deep Inheritance Hierarchies
- Keep inheritance chains short (1-2 levels max).
- Prefer composition and protocols.

✅ **CORRECT**:
```swift
protocol Playable { }
struct Card: Playable { }  // ✅ Flat hierarchy
```

❌ **WRONG**:
```swift
class Entity { }
class GameEntity: Entity { }
class CardEntity: GameEntity { }  // ❌ Too deep
class PlayingCardEntity: CardEntity { }  // ❌ Too deep
```

#### Immutability When Possible
- Prefer `let` over `var`.
- Use immutable data structures when state changes aren't needed.

✅ **CORRECT**:
```swift
struct Card: Identifiable {
    let id: UUID  // ✅ Immutable
    let cardFace: CardFace  // ✅ Immutable
    let suit: Suit  // ✅ Immutable
}
```

## SwiftUI Views

### Previews
- **Every view MUST have a `#Preview`**.
- Do NOT use `traits` argument in `#Preview` macros.
- Example:
```swift
#Preview {
    MyView()
        .environmentObject(GameState())
}
```

### Theming
- Use `ThemeColor` for all colors.
- UI text should use `ThemeColor.textOnAccent`.
- Do NOT use hardcoded colors.

## Code Quality

### SwiftLint
- **Zero linting errors or warnings** allowed.
- Follow `.swiftlint.yml` configuration.
- Check linting after every build.

### SwiftLint Configuration

#### Disabled Rules
- `trailing_whitespace` — disabled (project preference)

#### Opt-In Rules (Enabled)
- `empty_count` — prefer `.isEmpty` over `.count == 0`
- `empty_string` — prefer `String()` or `""` appropriately

#### Configured Limits

**Line Length:**
- Warning: 150 characters
- Error: 200 characters
- Ignores function declarations, comments, and URLs

**Function Body Length:**
- Warning: 300 lines
- Error: 500 lines

**Function Parameter Count:**
- Warning: 6 parameters
- Error: 8 parameters

**Type Body Length:**
- Warning: 300 lines
- Error: 500 lines

**File Length:**
- Warning: 1000 lines
- Error: 1500 lines
- Ignores comment-only lines

**Cyclomatic Complexity:**
- Warning: 15
- Error: 25

### Important SwiftLint Rules (Automatically Enabled)

#### Identifier Naming
- **`identifier_name`**: Identifiers must follow naming conventions
  - Minimum length: 3 characters (configurable)
  - Must not start with underscore (private use only)
  - Avoid abbreviations: `cx`, `cy`, `x`, `y`, `i`, `j` are not allowed
  - Use descriptive names: `centerX`, `centerY`, `rowIndex`, `columnIndex`

#### Style Rules
- **`colon`**: Space after colon in type declarations and dictionary literals
- **`comma`**: Space after comma in arrays, dictionaries, etc.
- **`opening_brace`**: Opening brace on same line as declaration
- **`closing_brace`**: Closing brace alignment
- **`attribute_name_spacing`**: Spacing around `@attributes`
- **`function_name_whitespace`**: No whitespace around function names
- **`operator_whitespace`**: Spacing around operators
- **`indentation`**: Consistent indentation (spaces, not tabs)

#### Idiomatic Swift
- **`force_cast`**: Avoid force casting (`as!`) — use safe casting
- **`force_try`**: Avoid `try!` — use proper error handling
- **`force_unwrapping`**: Avoid `!` — use optional binding
- **`implicit_getter`**: Explicit getters for computed properties
- **`control_statement`**: Use proper control flow (no parentheses around conditions)
- **`empty_parameters`**: Use `()` for empty parameter lists
- **`empty_parentheses_with_trailing_closure`**: Trailing closure syntax

#### Code Organization
- **`file_length`**: Keep files under 1500 lines (error threshold)
- **`type_body_length`**: Keep types under 500 lines (error threshold)
- **`function_body_length`**: Keep functions under 500 lines (error threshold)
- **`cyclomatic_complexity`**: Reduce complexity (max 25)

#### Best Practices
- **`redundant_optional_initialization`**: Avoid `var x: Int? = nil`
- **`redundant_nil_coalescing`**: Avoid `?? nil`
- **`unused_enumerated`**: Use enumerated() correctly
- **`unused_optional_binding`**: Don't bind if not using value
- **`vertical_parameter_alignment_on_call`**: Align parameters vertically
- **`vertical_whitespace`**: Proper spacing between code blocks

#### Performance
- **`contains_over_filter_count`**: Use `.contains()` instead of `.filter().count > 0`
- **`contains_over_filter_is_empty`**: Use `.contains()` instead of `.filter().isEmpty`
- **`first_where`**: Use `.first(where:)` instead of `.filter().first`
- **`empty_count`**: Use `.isEmpty` instead of `.count == 0`

#### Code Smells
- **`duplicate_imports`**: Remove duplicate imports
- **`duplicate_enum_cases`**: No duplicate enum cases
- **`unused_import`**: Remove unused imports
- **`unused_closure_parameter`**: Use `_` for unused parameters
- **`unused_private_declaration`**: Remove unused private code

#### SwiftUI Specific
- **`private_action`**: Use private for `@IBAction` methods
- **`private_outlet`**: Use private for `@IBOutlet` properties

### Build Requirements
- **Build must succeed** before committing.
- **All tests must pass** before moving to next feature.
- Fix linting errors immediately.

### Common Linting Errors to Avoid

❌ **WRONG**:
```swift
let cx = 100  // ❌ Too short, use descriptive name
let y = 50    // ❌ Too short
for i in 0..<10 {  // ❌ Use rowIndex, columnIndex, etc.
    for j in 0..<5 {
        // ...
    }
}
```

✅ **CORRECT**:
```swift
let centerX = 100
let centerY = 50
for rowIndex in 0..<10 {
    for columnIndex in 0..<5 {
        // ...
    }
}
```

❌ **WRONG**:
```swift
if (condition) {  // ❌ Unnecessary parentheses
    // ...
}
let count = array.filter { $0 > 5 }.count  // ❌ Use .contains() or .isEmpty
```

✅ **CORRECT**:
```swift
if condition {  // ✅ No parentheses
    // ...
}
let hasItems = array.contains { $0 > 5 }  // ✅ Use .contains()
```

## State Management

### GameState
- `GameState` is the **single source of truth** for game state.
- Views should read from `GameState` via `@EnvironmentObject`.
- Do NOT duplicate state in views.

### Views
- Views should be **stateless** where possible.
- Use `@Binding` only when necessary.
- Prefer reading from `GameState` instead of maintaining local state.

## Project-Specific Rules

### Board State
- Board tiles should be read from `gameState.boardTiles`.
- Do NOT maintain a separate board state in views.

### Card Comparison
- Compare cards by **both `cardFace` AND `suit`**.
- Do NOT rely solely on `cardId` for matching.

### Player Seating
- Current player should always appear at the **bottom of the seating ring**.
- Ring should hide when a card is selected.

## UI-Specific Patterns

### Previews and Styling
- Every SwiftUI view MUST include a `#Preview`.
- Prefer styling via centralized theme and small extensions (e.g., `ThemeColor`, `View+ButtonStyles.swift`).
- Avoid hard-coded colors; use theme tokens.

### Accessibility
- Ensure sufficient color contrast; validate against system accessibility settings.
- Support Dynamic Type (use `font(.body)` etc. and avoid fixed sizes where possible).
- Respect `Reduce Motion` and `Increase Contrast` user settings.

### Touch Targets & Hit Testing
- Maintain minimum comfortable hit target sizes.
- Use `.allowsHitTesting(false)` only for visual overlays that should not block interactions.

## Asynchronous & Concurrency

- Prefer Swift Concurrency (async/await) over completion handlers in new code.
- Always consider cancellation; pass `Cancellation` where appropriate or check `Task.isCancelled` in long-running tasks.
- Use `@MainActor` for UI-updating functions.
- Keep async functions single-purpose; compose at higher levels.

## Dependency Injection

- Depend on protocols for testability and decoupling.
- Pass dependencies via initializers or method parameters; avoid global singletons.
- For SwiftUI, prefer constructor injection for views; avoid deep implicit dependencies.

Example:
```swift
protocol CardProvider {
    func drawCard() -> Card?
}

final class GameState: ObservableObject {
    private let cardProvider: CardProvider
    init(cardProvider: CardProvider) { self.cardProvider = cardProvider }
}
```

## Error Handling Details

- Use `Optional` for simple "not found" or absence cases.
- Use `Result<T, Error>` or `throws` when the caller should distinguish error reasons.
- Log errors with context at boundaries; avoid noisy logs inside tight loops.
- Surface user-facing errors with clear, friendly messages; avoid exposing technical details.
- Propagate errors upward; do not silently swallow errors unless intentionally non-critical.

## SwiftUI Environment Usage

- Use `@EnvironmentObject` only for shared, app-wide state that many views read.
- Prefer explicit parameter passing / bindings for local state to avoid hidden dependencies.
- Keep the number of environment objects minimal; document each environment object in the parent composition root.
- Avoid chaining environment objects deeply; compose views with explicit inputs instead.

## Third-Party Libraries / Dependencies

- Prefer Swift Package Manager (SPM) for dependencies.
- Require approval before adding a new dependency: justify purpose, alternatives considered, and maintenance plan.
- Pin versions; review and update on a scheduled cadence.
- Perform security and license checks (transitive deps included).
- Remove unused dependencies promptly.

## Code Review and Submission

### Pull Request Etiquette
- Small, focused PRs (one concern per PR) with clear titles and descriptions.
- Link related tasks or issues.
- Include screenshots/GIFs for UI changes.
- Checklist before opening PR:
  - [ ] Builds successfully
  - [ ] All tests pass
  - [ ] Zero SwiftLint warnings/errors
  - [ ] Follows `CODING_CONVENTIONS.md`

### Branching & Commits
- Use feature branches: `feature/<short-description>`; fixes: `fix/<short-description>`.
- Write descriptive commit messages (imperative mood): "Add", "Fix", "Refactor".
- Rebase or squash to keep history clean when merging.

### Reviews
- Reviewers focus on correctness, readability, test coverage, and adherence to conventions.
- Authors respond to feedback promptly; resolve comments or follow-up tasks.

## Review Checklist

Before submitting code:
- [ ] All tests pass
- [ ] Zero linting errors/warnings
- [ ] One type per file
- [ ] One behavior per test
- [ ] All views have `#Preview`
- [ ] Descriptive variable names (no short abbreviations)
- [ ] Code builds successfully
- [ ] Functions have single responsibility

---

**Last Updated**: Based on project patterns and feedback as of Sprint 2.
