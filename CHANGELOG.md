# Changelog

## [1.3.0] - 2026-10-22

### Added
- Pokemon Orbits: animated sprites circle three elliptical tracks.
- Pokemon Constellation: drifting sprites form a glowing linked star field.
- Pokemon Mosaic: a scrolling grid of animated sprites with gentle bobbing.
- Pokeball Pulses: expanding luminous Pokeball rings spread across the frame.

### Changed
- All four sprite layouts share the active-art provider, bounded species sample and animation support.
- Random mode includes all eleven effects, while preserving its saved index and existing settings.

## [1.2.0] - 2026-10-22

### Added
- Random mode shuffles through all seven effects before starting another round, with no immediate repeats.
- Random Interval selects 5, 10, 15, 30, 60, 120, 300 or 600 seconds between effects (default 30 seconds).
- Rotation uses real time, independently of animation speed, and keeps pause/live-world settings in effect throughout.

## [1.1.1] - 2026-10-22

### Changed
- Aurora Veil now shows only the animated light waves, without the moon or stars.
- Screensaver and Preview only activate in gameplay after a save has loaded, never during intros, title/start screens or new-game setup.
- Returning to title clears the idle timer; loading a save begins a fresh wait.

## [1.1.0] - 2026-10-22

### Added
- Matrix Rain with green, amber, cyan, red, violet and white palettes.
- Animated Rainbow Flow, Ocean Flow, Sunset Flow and Aurora Flow gradients.
- Pokemon Rain draws random front sprites from the current game's live sprite providers, including animated mod frames and Crystal frame sheets.
- Batched Matrix text drawing, bounded sprite sampling and gradual sprite warm-up.

### Changed
- Sprite-provider updates continue before Screensaver pauses the simulation, preserving animations and asynchronous sprite builds while paused.

## [1.0.3] - 2026-10-22

### Changed
- Neon Pokeballs now uses 24 balls at 16:9 and 48 at 32:9, scaling up to 96 on larger layouts to fill more of the screen.

## [1.0.2] - 2026-10-22

### Added
- 1-second, 5-second and 10-second idle delay options.

### Changed
- Delay choices cycle in ascending time order; existing saved delays and the 60-second default are preserved.

## [1.0.1] - 2026-10-22

### Changed
- All effects adapt to the entire window, including 32:9 ultrawide and portrait screens.
- Prism Garden expands across the frame instead of remaining in a central circle.
- Neon Pokeballs begin distributed across the available width and height.
- Wider and taller layouts gain more stars, balls, ripples and fireflies while preserving primitive shapes.

## [1.0.0] - 2026-10-22

### Added
- Star Warp, Aurora Veil, Neon Pokeballs, Prism Garden and Moonlit Ripples.
- Idle delays of 15, 30, 60, 120, 300 and 600 seconds; four animation speeds.
- Screensaver options submenu, preview, enable switch and optional gameplay pause.
- Gentle fade-in, instant dismissal and consumed keyboard/controller wake presses.
- Optional live world behind the effects with five background dim levels, including fully transparent.
- Shared screen-space rendering across all eleven supported games.
