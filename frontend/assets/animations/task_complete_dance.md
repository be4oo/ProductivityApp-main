# Task-completion dance

`task_complete_dance.gif` is original pixel art created for this application:
a goofy lime jellybean in sunglasses, doing alternating sneaker kicks.
It contains 32 frames at 80 ms each (a 2.56-second loop), is 192 × 128 pixels,
and is bundled locally. It makes no network requests and uses no third-party
artwork or fonts.

Regenerate the exact GIF with Python's standard library, without installing
anything:

```sh
python3 scripts/generate_completion_gif.py
```

The completion overlay dismisses after 2.6 seconds, permits clicks through it,
and displays only a static success badge when reduced motion is enabled or
the companion is collapsed.
