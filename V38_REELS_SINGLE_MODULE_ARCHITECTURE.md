# V38 — Reels Single-Module Architecture

## Rule
Reels is one canonical functional module only:
`modules/reels/reels.html`

The Home page and other surfaces may show **preview/entry cards only**. They must not contain a second functional Reels implementation.

## Changes
- Removed the duplicate in-page Home Reels implementation.
- Reels entry buttons now open the canonical Reels module.
- Existing Reels backend, UI engine, Like/Comment/Save/Share/Plan features are preserved.
- Existing Home, Discover, Messages, Friends, Groups, News, Marketplace and Digital Marketing modules are preserved.

## Product rule going forward
Every module has one canonical implementation and many optional entry points/previews.
No duplicate functional module in another page.
