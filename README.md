# dodge-the-fireballs

A game I made with my Dad.

A small 2D game built in Godot 4. You fly around dodging fireballs, and your score
goes up every second you survive. The longer you last, the faster they come.

Built to be a first programming project — the code is short, commented, and
designed to be poked at.

## Getting it running

1. Download **Godot 4.2 or newer** from [godotengine.org](https://godotengine.org/download).
   It's a single file, no installer, no account.
2. Open Godot, click **Import**, and pick the `project.godot` file in this folder.
3. Press **F5** (or the ▶ button, top right) to play.

**Controls:** arrow keys or WASD to move. Space or the Start button to begin.

## What's in here

```
project.godot          Project settings and keyboard controls
scenes/
  main.tscn            The game itself — ties everything together
  player.tscn          The character you control
  fireball.tscn        One fireball
  powerup.tscn         A power-up you can grab
  hud.tscn             Score, messages, start button
scripts/
  main.gd              Spawning, scoring, game over
  player.gd            Movement, getting hit, invincibility
  fireball.gd          Fireball behavior
  powerup.gd           Power-up behavior
  hud.gd               Updating the display
assets/                The artwork (SVG files)
```

Godot splits things into **scenes** (what a thing is made of) and **scripts**
(how it behaves). A fireball scene is a physics body plus a sprite plus a
collision shape; the fireball script says what it does. Every scene here has a
matching script, which is a good habit to notice early.

## Things to try together

These are ordered roughly easy to hard. Anything marked `# TWEAK ME` in the
code is a safe place to start.

**Change a number and see what happens.**
In `scripts/player.gd`, find `speed` and change `400.0` to `800.0`. Run it.
Then try `100.0`. This is the whole loop of programming in one move: change
something, run it, see what happened.

**Make the fireballs harder to dodge.**
In `scripts/fireball.gd`, raise `max_speed`. In `scripts/main.gd`, lower
`fastest_spawn` so more can be on screen at once. Find the setting that's fun
rather than the one that's hardest — that's a real design skill.

**Make the star your own.**
The invincibility star has three numbers to play with: `invincible_time` in
`scripts/player.gd`, `lifetime` in `scripts/powerup.gd`, and `powerup_every`
in `scripts/main.gd`. Try a 10-second star that appears every 3 seconds —
then try to find settings where the star matters but the game is still hard.

**Rig the power-up lottery.**
In `scripts/main.gd`, find the `pick_random()` line with the list of
power-up names. Each name has an equal chance — so what happens if you
write `"star"` twice? Try making the snowflake rare and precious. And in
`scripts/fireball.gd`, try a `slow_factor` of `0.1` — almost frozen.

**Make a trap.**
In `scripts/main.gd`, `coin_points` says what a coin is worth. What happens
if you make it *negative*? Suddenly the coin is something to dodge — and
the game has a new kind of decision in it. One number, whole new game.

**Stack the shield.**
The shield in `scripts/player.gd` is a true/false variable: `has_shield`.
Could you turn it into a *number* instead, so grabbing two shields lets you
survive two hits? Every place that touches `has_shield` will need a small
change — finding them all is the exercise.

**Change the colors.**
Open `assets/fireball_1.svg` in any text editor. The `fill="#ff8c1a"` bits are
colors. Try `#00d4ff` for blue fire. Godot reloads the file automatically when
you switch back to it.

**Add a second player.**
In `main.tscn`, duplicate the Player node. You'd need new input actions
(Project → Project Settings → Input Map) and a way for `player.gd` to know
which set of keys to read. This one's a real jump in difficulty and worth
doing slowly.

### Bigger additions

**Replace the sounds.** The hit and pickup sounds in `assets/sounds/` are
tiny computer-made WAV files. Record your own — say "ouch!" into a voice
memo, save it as a WAV, drop it in that folder, and point the `HitSound`
node in `main.tscn` at it. Free real ones live at
[freesound.org](https://freesound.org) and [kenney.nl](https://kenney.nl/assets).

**Cheat at your own game.** The high score is saved in a plain text file.
In the Godot editor, click **Project → Open User Data Folder** — there's
`high_score.txt`. Open it, type `9999`, save, and restart the game. Then
look at `load_high_score()` in `scripts/hud.gd` and explain to your Dad
why that worked. (This is also why real games encrypt their save files.)

**Invent a new power-up.** Four exist now — star, snowflake, shield, and
coin — and they show the whole recipe: a name in the list in `main.gd`, a
picture in `assets/`, and a `match` branch that does the effect. What would
a fifth one do?

## If something breaks

Godot prints errors at the bottom of the editor in the **Output** panel. The
message usually names the file and line number. Reading the error out loud
together is a genuinely useful habit — most of them say exactly what's wrong,
and getting comfortable with error messages instead of alarmed by them is
half of learning to program.

If the game won't start at all, check that **Project → Project Settings →
Application → Run → Main Scene** points at `res://scenes/main.tscn`.

## Where to go next

- [Godot's official 2D tutorial](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/) — this project is a cousin of it
- [Godot documentation](https://docs.godotengine.org/) — genuinely well written
- [Kenney's free game assets](https://kenney.nl/assets) — public domain art and sound
