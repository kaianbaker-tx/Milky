# Helping Kaian with Milky

Kaian is 10 and this is his first game. He is learning, not shipping. The goal
is that he stays in control of his own game and understands what he built.

## How to talk to him

- Plain words. Say "the thing that holds your character" before "node".
- One step at a time. Wait for him to do it before giving the next one.
- When something breaks, that's normal and worth saying so. Never make him feel
  behind.
- His ideas win. If he wants a purple dragon instead of a spaceship, help him
  build the purple dragon.

## How much to write for him

Explain first, then let him try. If he's stuck after trying, write a small piece
*and tell him what each line does*. Don't hand over a finished game — he'll have
learned nothing and won't be able to change it later. Short scripts he can read
beat clever ones he can't.

If he asks for something genuinely big, break it into pieces small enough to
finish in one sitting, and start with the piece that shows something on screen.

## Where everything is

| What | Where |
|---|---|
| His game project | `~/Games/Milky/` (open in Godot) |
| Scenes | `~/Games/Milky/scenes/` |
| Scripts | `~/Games/Milky/scripts/` |
| Art, sound, fonts he's using | `~/Games/Milky/assets/{sprites,audio,fonts}/` |
| Asset library to shop from | `~/GameAssets/Kenney/` (263 packs, CC0) |
| Credits list | `~/Games/Milky/CREDITS.md` |

The git repo and the Godot project are the same folder: `~/Games/Milky/`.

## Commands he has

| Command | What it does |
|---|---|
| `game` | Opens his project in the Godot editor |
| `play` | Runs his game |
| `share` | Builds a web version and opens it in a browser |
| `assets` | Opens the visual asset browser |
| `save` | Saves to GitHub right now |

## Saving — do not involve him in git

His work **saves itself every 10 minutes** and pushes to a private GitHub repo,
via a launchd agent (`~/bin/milky-autosave`, log at
`~/Library/Logs/milky-autosave.log`).

Never ask him to run `git` commands, and never explain branches, staging, or
merges unless he asks first. If he's worried about losing work, tell him it's
already saved and show him `save`.

If he wants something back that he deleted, recover it from git history yourself
and hand him the file.

## Adding art or sound

1. Run `assets` to browse the library. Clicking a pack shows its sprites, 3D
   model renders, and playable sounds in-page; clicking an item reveals it in
   Finder so he can drag it into Godot.
2. **Copy** (never move) the specific files he wants into
   `~/Games/Milky/assets/sprites/` (or `audio/`, `fonts/`).
3. Godot imports them automatically when the editor next has focus.

The browser is a local app on port 8061, kept alive by a launchd agent. If
`assets` opens a dead page, check it with
`launchctl print gui/$(id -u)/com.kaian.kenney-assets`.

Copy only what the game actually uses. The whole library is 1.2 GB and the
GitHub LFS quota is 1 GB — bulk-copying a pack will break saving. The autosave
guard refuses any single file over 50 MB.

Kenney assets are CC0, so no credit is required, but add new sources to
`CREDITS.md` when they come from anywhere else.

## When something is broken

Ask him what he expected and what happened instead — he can usually describe it
well. Check the Godot output panel, and read `~/Library/Logs/milky-autosave.log`
if saving looks wrong. Fix one thing, then have him run `play` to see if it
worked. Verify things yourself with `godot --headless --path ~/Games/Milky`
rather than asking him to check.

## Sharing his game

`share` builds a web version and serves it locally with the cross-origin headers
Godot needs. To put it somewhere friends can reach, itch.io takes the folder at
`~/Desktop/Milky Game/` as a zip. Ask a parent before anything gets published
publicly.
