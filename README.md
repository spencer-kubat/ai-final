# Wheel of Sustainability 🎡

A **Wheel of Fortune**-style word game built in **Godot 4.4**, where every puzzle is a sustainability-related term or concept. Play against friends, AI opponents, or both — with computer players that use real search algorithms to decide their moves.

**Live Demo (Web - Chrome):** [https://spencer-kubat.github.io/ai-final/](https://spencer-kubat.github.io/ai-final/)

---

## Overview

Wheel of Sustainability is a digital adaptation of the classic Wheel of Fortune TV game show. Players take turns spinning a wheel to earn dollar amounts, then guess consonants to reveal letters in a hidden phrase. Vowels can be purchased for $250. The first player to correctly solve the full phrase wins the round and keeps their prize money.

All 100 puzzles are drawn from a curated word list of sustainability and environmental topics — everything from "Solar power" and "Carbon footprint" to "Circular economy" and "Vertical farming."

### AI Opponents

The game's AI players are the core technical feature. Rather than picking letters randomly, computer players use a pipeline of search and filtering algorithms whose behavior changes based on the selected difficulty:

- **CSP Filtering** — The AI treats the partially revealed phrase as a constraint satisfaction problem. It compares the pattern of revealed letters, blanks, and already-guessed letters against the full phrase list to produce a set of candidate solutions. This narrows hundreds of phrases down to a handful (or one) that could match.

- **Uniform Cost Search (Easy/Medium)** — From the filtered candidates, the AI counts how often each unguessed consonant appears across all remaining possibilities and picks the most frequent one. This maximizes the expected payout per spin while avoiding the $250 vowel cost, optimizing for the player's budget.

- **Greedy Search (Hard)** — The AI picks the single best-matching candidate phrase (fewest mismatches with the current board) and selects the most common unguessed letter from that phrase. This is more aggressive and converges on a solve faster.

- **Auto-solve** — On Hard difficulty, if CSP filtering narrows the candidates down to exactly one phrase, the AI will guess the full solution outright instead of continuing to pick letters.

### Features

- **1–3 players** with any mix of Human and AI participants
- **Three difficulty levels** (Easy, Medium, Hard) that control both puzzle length and AI strategy
- **Animated wheel** with physics-based spin deceleration, Bankrupt wedges, and Lose-a-Turn
- **Typewriter-style announcements** that narrate each game event
- **$250 vowel purchases** with budget enforcement — AI and humans alike must have enough money
- **Web export** via Godot's HTML5/WASM pipeline, playable directly in the browser
- **Native builds** included for Windows (`.exe`) and macOS (`.dmg`)

### Tech Stack

- **Godot 4.4** — Game engine (GL Compatibility renderer for broad browser support)
- **GDScript** — All game logic, AI algorithms, and UI wiring
- **Godot HTML5 Export** — WebAssembly build deployed to GitHub Pages

---

## Usage Instructions

### Starting a Game

1. On the main menu, configure each of the three player slots using the dropdown: **None** (empty seat), **Human**, or **AI**.
2. If a player is set to Human, enter their name in the text field that appears.
3. Select a **Difficulty** level:
   - **Easy** — Shorter phrases (up to 12 characters), AI uses Uniform Cost Search
   - **Medium** — Mid-length phrases (up to 24 characters), AI uses Uniform Cost Search
   - **Hard** — Full-length phrases (up to 48 characters), AI uses Greedy Search and can auto-solve
4. Click **START** to begin.

### Gameplay

On your turn you have several options:

- **SPIN** — Spins the wheel. It lands on a dollar amount, Bankrupt, or Lose a Turn. If it lands on a dollar amount, you then pick a consonant from the alphabet grid. Each occurrence of that letter in the phrase earns you the spin amount. If the letter isn't in the phrase, your turn passes to the next player.
- **Buy a vowel** — After a successful consonant guess, you can click a vowel (A, E, I, O, U) from the alphabet grid for $250. This doesn't end your turn if the vowel is in the phrase.
- **GUESS** — Type the full phrase into the text field and click GUESS to attempt a solve. A correct solve wins the round; an incorrect guess passes your turn.
- **PASS** — Skip your turn voluntarily.
- **QUIT** — Return to the main menu.

AI players take their turns automatically — you'll see the announcer narrate their letter selections and decisions in real time.

---

## Installation Instructions

### Play in Browser (No Install)

Visit the live demo at [https://spencer-kubat.github.io/ai-final/](https://spencer-kubat.github.io/ai-final/). No installation required — runs in Chrome browser.

### Run from Pre-built Binaries

The repository includes native builds:

- **Windows** — Run `Wheel Of Sustainability.exe`
- **macOS** — Open `Wheel Of Sustainability.dmg`

### Build from Source

#### Prerequisites

- **Godot 4.4** (standard or .NET edition) — [https://godotengine.org/download](https://godotengine.org/download)

#### Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/spencer-kubat/ai-final.git
   cd ai-final
   ```

2. **Open the project in Godot:**

   Launch Godot 4.4, click **Import**, and navigate to the `project.godot` file in the cloned directory.

3. **Run the project:**

   Press `F5` (or click the Play button) to run the game in the editor.

4. **Export (optional):**

   To create a standalone build, go to **Project → Export** and select a preset (Web, Windows, macOS). The web export produces the `index.html`, `index.wasm`, `index.pck`, and `index.js` files used for the GitHub Pages deployment.

---

## Authors

- **Spencer Kubat**
- **Uyen Thy Duong**
