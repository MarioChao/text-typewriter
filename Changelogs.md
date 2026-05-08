# Changelogs

## [v0.0.1] Graphemes | 2026/05/08

Type texts by "graphemes" instead of by code units.
- Iterate through graphemes using `utf8.graphemes()`.
- Texts maintain their position when typed out using `MaxVisibleGraphemes` (mainly for non-left-aligned texts).

Removed pauses on whitespace characters.

Modified sound effects to play on non-whitespace characters (`[^%s]`).

## [v0.0.0] Text typewriter module | 2026/05/07

Published `TextTypewriter`, initially developed for [dreamer's dialog system](https://github.com/MarioChao/dreamers-dialog-system).

Added default configs for character speed, pause delay, and sound effects.
