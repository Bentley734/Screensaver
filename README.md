# Screensaver

Screensaver gives your idle Gen1Recomp game sixteen animated escapes, with an optional pause and a transparent view of the moving world behind the effects. Made for players who enjoy leaving their adventure on display.

## Install

1. Download `Screensaver-v1.4.0.zip` from [the latest release](https://github.com/Bentley734/Screensaver/releases/latest).
2. Extract the `screensaver` folder into Gen1Recomp's `mods` directory, enable **Screensaver** in the mod manager and restart the game.
3. Load a save, open **Options → Screensaver**, choose an effect and use **Preview** or leave the controls idle.

Requires Gen1Recomp 0.3.54 or newer within the 0.3.x series. Targets Red, Blue, Yellow, Gold, Silver, Crystal, FireRed, LeafGreen, Ruby, Sapphire and Emerald. No Pokemon sprite files or ROM data are bundled in the playable package; Pokemon Rain borrows images from your own game and active sprite mods.

## Sixteen effects

| Effect | Look |
|---|---|
| Star Warp | Blue-white star trails stream out from a glowing vanishing point. |
| Aurora Veil | Animated waves of green, blue and violet light. |
| Neon Pokeballs | 24 luminous balls bounce and rotate at 16:9; 48 fill a 32:9 screen, scaling with the layout. |
| Prism Garden | A rotating sixfold garden of color-shifting diamonds. |
| Moonlit Ripples | Expanding elliptical rings and wandering fireflies. |
| Matrix Rain | Falling digital glyphs with six solid palettes and four animated gradients. |
| Pokemon Rain | Random front sprites from the active battle sprite set, including live animation frames. |
| Pokemon Orbits | Sprites circle three glowing elliptical tracks at different speeds and directions. |
| Pokemon Constellation | Drifting animated sprites form a luminous network of linked stars. |
| Pokemon Mosaic | An endless scrolling tile wall of animated sprites with gentle bobbing. |
| Pokeball Pulses | Luminous Pokeball outlines expand and fade across the screen. |
| Retro Pipes | Growing shaded pipes turn through colorful right-angle networks. |
| Mystify Trails | Bouncing wireframe polygons leave flowing multicolor trails. |
| Bubble Drift | Glossy translucent bubbles drift and shimmer across the screen. |
| Flurry Streams | Swirling colored particles trace luminous flowing streams. |
| Flying Toasters | Original winged toasters flap past drifting slices of toast. |

Previews are in [docs](docs/), including a [32:9 gallery](docs/ultrawide.png). Releases contain only the installable mod ZIP so the launcher updater cannot accidentally select a preview archive. The five classic-desktop homages use original procedural artwork inspired by Windows and Mac-era screensavers; no operating-system assets or binaries are included.

## Controls

| Setting | Choices | Default |
|---|---|---|
| Screensaver | On / Off | On |
| Effect | Sixteen effects above / Random | Star Warp |
| Idle delay | 1 / 5 / 10 / 15 / 30 / 60 / 120 / 300 / 600 seconds | 60 seconds |
| Animation speed | 0.5× / 1× / 1.5× / 2× | 1× |
| Pause game | On / Off | On |
| Background dim | 0 / 25 / 50 / 75 / 100% | 50% |
| Matrix color | Green / Amber / Cyan / Red / Violet / White / Rainbow Flow / Ocean Flow / Sunset Flow / Aurora Flow | Green |
| Random interval | 5 / 10 / 15 / 30 / 60 / 120 / 300 / 600 seconds | 30 seconds |
| Preview | Start after releasing the selection button, within a loaded game | — |

To keep watching the world move, set **Pause Game = Off**, then choose **Background Dim = 0%**, **25%** or **50%**. Effects remain visible over the live game. At 100%, the backdrop fully covers the game. With pause off, battles, scripts and world events continue normally beneath the screensaver. Audio continues in either mode.

Press a key or controller button, move a stick, move/click the mouse, scroll, or touch the screen to dismiss. The initial keyboard/controller wake press and its matching release are consumed. Held gameplay controls prevent activation; modest stick drift is ignored. Losing window focus dismisses the screensaver and restarts the idle timer. Touch controls remain above the overlay.

Settings persist through the game's normal options storage. Preview also enables the screensaver if it was off.

The idle timer and Preview are enabled only after loading a save and entering gameplay. Intros, title/start screens and new-game setup never activate the screensaver. Returning to title dismisses the overlay and resets the timer; loading another save begins a fresh wait. A new adventure must be saved and loaded before Screensaver is eligible.

Choose **Effect = Random** to cycle through all sixteen screensavers. **Random Interval** controls how long each is shown, measured in real seconds regardless of Animation Speed. Each round shuffles all sixteen effects; none repeats within a round or immediately across round boundaries. A fresh activation starts a new shuffle and a full switch interval. Matrix keeps your selected palette, sprite effects keep live animation, and Pause Game / Background Dim apply throughout. Fixed-effect selections never cycle. The interval is independent of Idle Delay, which controls only when Screensaver first starts.

For **Matrix Rain**, choose **Matrix Color** to select a solid palette or a flowing gradient. The [palette gallery](docs/matrix-palettes.png) shows all ten choices.

**Pokemon Rain, Orbits, Constellation and Mosaic** resolve front battle art each frame through the shared image providers and animation hooks. When a sprite mod offers separate player/enemy styles, the front/enemy battle style is used. Animation follows the pack's playback settings, including when Pause Game is on. Crystal's native front-picture sheets loop as well. Other mods must expose animations through these shared providers/hooks; a private renderer cannot be detected automatically. Up to 16 random species are sampled each activation and shared across the sprites. The sample loads gradually while the selected pack prepares the images. Missing artwork shows a loading message.

Sprite previews use a local 1025Dex sprite-provider fixture; your installed effects use your active artwork. Preview Pokemon artwork comes from the DBK pack credited by [1025Dex](https://github.com/Bentley734/1025Dex).

## Compatibility and validation

Uses shared `core.update`, input and `render.hud` hooks, plus the engine's live sprite providers and `battle.mon_pic` animation hook. An internal adapter adds the submenu to Gen 3 options; it stops contributing when the mod is disabled. No game data, save progression, art packs or battle rules are modified. Other mods using these same hooks should forward the hook chain normally. Screensaver only runs where the engine allows mods; online arena boots may disable it.

The regression suite loads the mod through the real sandboxed loader for all eleven games under LuaJIT and Lua 5.3, then checks all sixteen effects, complete Random rounds, classic animation geometry, ten Matrix palettes, changing gradients, all four sprite layouts advancing frames while paused, static sprites, missing-art fallback, nine idle deadlines, pause/live simulation, wake input, held controls, focus recovery, hook removal and the launcher's ZIP selection. Effects adapt to the full window, including 32:9 ultrawide and portrait displays, without stretching individual balls or diamonds. Native LÖVE rendering checks eight screen sizes, including 3840×1080 and 5120×1440, and verifies artwork in both outer thirds of a 32:9 frame. These checks use fixtures rather than full interactive playthroughs.

From the workspace containing the engine checkout:

```text
python Screensaver/tools/test.py
python gen1recomp-0.3.54/tools/modkit.py validate Screensaver --base fixture
python gen1recomp-0.3.54/tools/modkit.py lint Screensaver
python Screensaver/tools/package.py
```

The twelve effects that do not use Pokemon sprites are original procedural graphics. Matrix uses the built-in font atlas and a text batch. All four sprite effects borrow engine/mod images and never release or change their pixels.



