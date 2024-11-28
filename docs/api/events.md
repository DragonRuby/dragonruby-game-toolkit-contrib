# Events (`args.events`)

Events contains raw events, and a window resize events.

## `resize_occurred`

`args.events.resize_occurred` will be `true` if the window is resized or
if the orientation of the game is changed.

## `orientation_changed`

`args.events.orientation_changed` will be `true` if the window the orientation
of the game has changed. This event is specifically
important to handle if you use render targets _and_ if your game supports
both landscape/portrait modes (within `metadata/game_metadata.txt`
has `orientation=landscape,portrait` or `orientation=portrait,landscape`).

## `raw`

`args.events.raw` is an `Array` of `Hashes` and may be useful for
debugging purposes. Raw events are processed and reflected in the rest
of DragonRuby's API, so it's unlikely that you'll have to leverage
anything within this collection directly.
