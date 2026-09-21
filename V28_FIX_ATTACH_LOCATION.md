# V28 Fix — Composer Actions

Fixed the Messages composer binding crash caused by legacy references to non-existent `fileBtn`, `photoBtn`, and `videoFileBtn` elements.

Those null element references were throwing before the V28 handlers could bind, so Attach / Location / Live Location / Emoji / Voice appeared but did nothing.

The fix is non-destructive and keeps the existing V27/V28 messaging architecture.
