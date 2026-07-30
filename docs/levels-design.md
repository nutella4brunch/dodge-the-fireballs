# Levels: the plan

*Written 2026-07-29, agreed between Dad and Claude. This is the map for
turning one game into many.*

## The big idea: a console and cartridges

The outer game is a **console**: it owns the level menu, the save file,
the coin wallet, and a coin badge that always floats at the top of the
screen. Each level is a **cartridge**: a folder with a scene that runs
the whole level however it likes.

The console only asks one thing of every cartridge — when a run ends,
report the result:

```gdscript
signal finished(score: int, coins: int)
```

That signal is the entire contract. A level can reuse the shared player,
power-ups, and HUD, or replace all of them. Copying the closest existing
level's folder and changing things is the *intended* way to make a new
level, and `levels/fireballs/` is the reference to copy.

## Folder layout

```
game/
  levels/
    fireballs/          level.tscn, level.gd, fireball.tscn
    dodgeball/          (stage 2) same shape
  scenes/               shared parts bin: player, powerup, hud, menu,
                        coin badge (art stays in assets/ for now)
  scripts/
    levels.gd           the master list of levels
    save_data.gd        the only script that touches the save file
  tests/
    run_tests.gd        unit tests for save data and the level list
```

## The master list (`levels.gd`)

One entry per level. Adding a level = adding a folder + one line here:

```gdscript
var all_levels := [
	{"name": "Fireballs", "folder": "fireballs", "target": 30},
	{"name": "Dodgeball", "folder": "dodgeball", "target": 40},
]
```

List order is unlock order: reach a level's `target` score once and the
next level opens. The list also feeds the menu, so there is no second
place to keep in sync.

## Rules we agreed

- **Levels can change anything.** Hazards, looks, even how the player
  moves. The only fixed point is the `finished` signal.
- **Beating unlocks, coins buy extras.** Levels unlock by skill only.
  The wallet buys skins and other fun things at a shop (stage 3) —
  never level access.
- **Coins are real money.** A coin still gives +10 score in the round,
  and *also* adds 1 coin to the wallet, forever.
- **The coin badge is always visible.** The console draws it on top of
  the menu and on top of every level. It ticks up the moment a coin is
  grabbed.

## The save file

`high_score.txt` grows up into one JSON dictionary handled by
`save_data.gd`:

```json
{"wallet": 0, "unlocked": ["fireballs"], "best": {"fireballs": 36}}
```

The old high score gets migrated in on first launch, not lost.

## Build order (each stage playable, committed, and fun on its own)

1. **The console.** Restructure into console + cartridge with fireballs
   as the only level. Menu, JSON save, wallet, coin badge. Acceptance
   test: the game plays exactly like it does today.
2. **Dodgeball + unlocking.** Second cartridge — bouncy balls that
   bounce off the screen edges and never despawn, so they pile up until
   it's too hard. The unlock rule goes live.
3. **The shop.** 2–3 player skins to buy with the wallet.
4. **More cartridges, forever.** Zombies that chase you, germs, the fly
   vs. the swatters — one folder + one line each.

## Level ideas parking lot

Zombies chasing you · real dodgeball physics · germs attacking · fly
dodging fly swatters · (add yours here)
