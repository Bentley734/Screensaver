# Screensaver

Screensaver gives your idle Gen1Recomp game five animated escapes, with an optional pause and a transparent view of the moving world behind the effects. Made for players who enjoy leaving their adventure on display.

## Install

1. Download `Screensaver-v1.0.2.zip` from [the latest release](https://github.com/Bentley734/Screensaver/releases/latest).
2. Extract the `screensaver` folder into Gen1Recomp's `mods` directory, enable **Screensaver** in the mod manager and restart the game.
3. Open **Options → Screensaver**, choose an effect and use **Preview** or leave the controls idle.

Requires Gen1Recomp 0.3.54 or newer within the 0.3.x series. Targets Red, Blue, Yellow, Gold, Silver, Crystal, FireRed, LeafGreen, Ruby, Sapphire and Emerald. No ROM graphics or audio are included.

## Five effects

| Effect | Look |
|---|---|
| Star Warp | Blue-white star trails stream out from a glowing vanishing point. |
| Aurora Veil | Layers of green, blue and violet light drift beneath a crescent moon. |
| Neon Pokeballs | Seven luminous outlines bounce, rotate and drift across the screen. |
| Prism Garden | A rotating sixfold garden of color-shifting diamonds. |
| Moonlit Ripples | Expanding elliptical rings and wandering fireflies. |

Previews are in [docs](docs/), including a [32:9 gallery](docs/ultrawide.png), also available as a separate release download.

## Controls

| Setting | Choices | Default |
|---|---|---|
| Screensaver | On / Off | On |
| Effect | Five effects above | Star Warp |
| Idle delay | 1 / 5 / 10 / 15 / 30 / 60 / 120 / 300 / 600 seconds | 60 seconds |
| Animation speed | 0.5× / 1× / 1.5× / 2× | 1× |
| Pause game | On / Off | On |
| Background dim | 0 / 25 / 50 / 75 / 100% | 50% |
| Preview | Start immediately after releasing the selection button | — |

To keep watching the world move, set **Pause Game = Off**, then choose **Background Dim = 0%**, **25%** or **50%**. Effects remain visible over the live game. At 100%, the backdrop fully covers the game. With pause off, battles, scripts and world events continue normally beneath the screensaver. Audio continues in either mode.

Press a key or controller button, move a stick, move/click the mouse, scroll, or touch the screen to dismiss. The initial keyboard/controller wake press and its matching release are consumed. Held gameplay controls prevent activation; modest stick drift is ignored. Losing window focus dismisses the screensaver and restarts the idle timer. Touch controls remain above the overlay.

Settings persist through the game's normal options storage. Preview also enables the screensaver if it was off.

## Compatibility and validation

Uses shared `core.update`, input and `render.hud` hooks. The only internal adapter adds the submenu to Gen 3 options; it stops contributing when the mod is disabled. No game data, save progression, art packs or battle rules are modified. Other mods using these same hooks should forward the hook chain normally. Screensaver only runs where the engine allows mods; online arena boots may disable it.

The regression suite loads the mod through the real sandboxed loader for all eleven games under LuaJIT and Lua 5.3, then checks activation, all five effects, pause/live simulation, wake input, held controls, focus recovery and hook removal. Effects adapt to the full window, including 32:9 ultrawide and portrait displays, without stretching individual balls or diamonds. Native LÖVE rendering checks eight screen sizes, including 3840×1080 and 5120×1440, and verifies artwork in both outer thirds of a 32:9 frame. These checks use fixtures rather than full interactive playthroughs.

From the workspace containing the engine checkout:

```text
python Screensaver/tools/test.py
python gen1recomp-0.3.54/tools/modkit.py validate Screensaver --base fixture
python gen1recomp-0.3.54/tools/modkit.py lint Screensaver
```

All effects are original procedural drawings, using ordinary LÖVE primitives with no shader or texture dependencies.


