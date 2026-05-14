# AGENTS.md — UME-Lite (Universal Map Enhancement System, Lite)

Guidance for AI agents working in this repository. Read this **first** before
making changes; the engine is unforgiving and the patterns here are not obvious
from filenames alone.

---

## 1. What this project is

UME-Lite is a loose-file Doom add-on (PK3-style directory) intended to be loaded
by **GZDoom / UZDoom** (and, with caveats, **LZDoom** and **Zandronum**) on top
of `doom.wad` / `doom2.wad` (and optionally Plutonia, TNT, and PSX Doom). It is
a stripped-down derivative of Sergeant Mark IV's **Brutal Doom Map Enhancement
System**, originally maintained by `BROS_ETT_311` (see comments in
`SRC/MapDetection.acs`).

What it adds at runtime:

- **Map enhancements** — vanilla maps (Doom 1, Doom 2, Plutonia, TNT, PSX Doom)
  are *detected by signature* (player‑1 start coordinates + par time + level
  name) and then enriched with extra props, lights, plant pots, antennae,
  destroyable windows, light shafts, water/lava splashes, etc.
- **Texture upgrades** — original flats/walls are swapped via ACS
  `ReplaceTextures` to higher‑detail variants in `Textures/Replacement/`.
- **Brutal-style gore, blood, gibs, particles, casings, sparks, fire, smoke,
  flares, tracers, footsteps**, with material-aware splash and footstep sounds.
- **Vehicles** — drivable Tank, Artillery Tank, Mech, Helicopter, and a
  stationary Heavy Machinegun, plus enemy variants. Movement is implemented in
  ACS (`SRC/VEHICLECONTROL.acs`) and physics-faking DECORATE actors
  (`DECORATE/Tank.txt` etc.) using `A_CustomMissile` "feeler" projectiles.
- **Boss-Mode** for E1M8 (`/` key by default, see `KEYCONF`) and a generic boss
  HUD (`SRC/BOSSHEALTH.acs`).
- **Brutal Deathmatch maps** (`dmlevels.wad` → `BDM01`–`BDM10`) and **PSX Doom
  maps** (`psxlevels.wad` → `PSXMAP*`) registered through `MAPINFO.lmp`.

UME-Lite does **not** ship a player class, weapons, or monsters of its own — it
is meant to be *combined with a gameplay mod* (Brutal Doom, Project Brutality,
Demon Steele, etc.). Everything here is decoration, environmental FX, and
vehicle support.

---

## 2. Engine, language, and directory layout

This add-on uses the **classic ZDoom modding stack**, not modern ZScript:

- **DECORATE** for actor definitions (no `zscript.zs` exists — do not add one
  unless explicitly asked).
- **ACS** (`SRC/*.acs`, compiled to `ACS/*.o`) for global logic, map
  detection, texture replacement, vehicle input, boss HUD.
- **MAPINFO**, **GLDEFS**, **ANIMDEFS**, **TERRAIN**, **DECALDEF**,
  **MODELDEF**, **SNDINFO**, **CVARINFO**, **KEYCONF**, **brightmap**, and
  **Textures.\*** lumps for engine config.

```
UME-Lite/
├── DECORATE.txt          # Master DECORATE include hub (entry point)
├── DECORATE/             # Actor definitions, split by topic (#include'd above)
├── SRC/                  # ACS source (.acs)
├── ACS/                  # Compiled ACS objects (.o) — referenced by LOADACS
├── LOADACS               # Whitespace-separated list of object libraries to load
├── MAPINFO.lmp           # Episode + per-map definitions (sky, music, next)
├── CVARINFO              # User/server CVARs (MES_*, sv_allowbossmap)
├── KEYCONF               # Adds the BossMode key binding + alias
├── GLDEFS                # Dynamic lights + glow definitions
├── ANIMDEFS              # Animated flats/walls (e.g. HD nukage)
├── TERRAIN               # Splash + terrain (footclip, liquid, damagetype)
├── DECALDEF.Terrain      # Animated decals for water drops, etc.
├── doomdefs.bm,
│   doomwalls.bm          # Brightmap declarations
├── modeldef.txt,
│   Modeldef.BDVehicles.txt,
│   Modeldef.Decorations.txt   # MD3 model bindings
├── SNDINFO.BD,
│   SNDINFO.Vehicles,
│   SNDINFO.Terrain,
│   SNDINFO.BrutalChexQuest    # Sound aliases, $random, $rolloff, $limit
├── Textures.HDSkies      # TEXTURES lump (remap entries for HD skies)
├── SPRITES/, MODELS/, SOUNDS/, GRAPHICS/, MUSIC/,
│   Textures/, VOXELS/, brightmaps/, PATCHES/, announcer/   # Assets
└── *.wad                 # Auxiliary maps & textures (loaded automatically as
                          #   embedded WADs when this directory becomes a PK3)
```

**Pseudo-PK3 packaging**: this directory is meant to be zipped into a `.pk3`
(or loaded directly as a directory by GZDoom with `-file UME-Lite/`). Filename
case **does not matter** to the engine, but Linux servers care — keep new file
names consistent with neighbours.

---

## 3. Load order and the ACS pipeline

1. `LOADACS` lists the ACS libraries the engine pre-loads:
   `DYNAMICLEV  BDCVARS  SSPLASH  VEHICLECONTROL  MapDetection`.
   Each name corresponds to `ACS/<name>.o`, compiled from `SRC/<name>.acs`.
2. `BDCVARS.acs` runs the `BDInitialize` (script `enter`) and `BDInitiate`
   (`open`) on every map; this is where global texture remaps and player
   buddha-mode tweaks happen.
3. `MapDetection.acs` `Initialize_Enhancements` (`enter`) freezes the player
   for one tic and calls `Detect_Map`, which compares
   `(GetActorX(0)>>16, GetActorY(0)>>16, par_time, level_name)` against a giant
   table; on match it `SpawnForced("EvidenceChecker*", ...)` at fixed world
   coordinates with a known **Thing TID** (the third arg).
4. The spawned `EvidenceChecker*` actor (DECORATE, in
   `DECORATE/MapDetection.txt`) then `A_JumpIf(x == ..., "IsXxx")` to confirm
   it landed on the expected key/torch/lightpost in the *real* map (this filters
   out custom WADs that happen to share par time + start XY) and finally
   `A_SpawnItemEx("<MapName>DecorationSpawn", ..., SXF_ABSOLUTEPOSITION |
   SXF_NOCHECKPOSITION)`.
5. The `*DecorationSpawn` actor (in `DECORATE/Doom1Remap.txt`,
   `Doom2Remap.txt`, `PlutoniaRemap.txt`, `TNTRemap.txt`,
   `OtherMapsRemap.txt`, `MapSpecificDec.txt`) calls
   `ACS_NamedExecuteAlways("MapEnhancement<MapName>")` (defined in
   `SRC/DYNAMICLEV.acs`) to swap textures, then runs hundreds of
   `A_SpawnItemEx` calls placing absolute‑position decorations.

> **Mental model:** ACS finds the map → DECORATE confirms the map →
> DECORATE seeds decorations + ACS swaps textures.

### Re-compiling ACS

ACS sources live in `SRC/` and target `ACS/<name>.o`. Use **`acc.exe`** (the
ZDoom ACS compiler) with `zcommon.acs` on the include path:

```
acc -i <path-to>/zcommon SRC/MapDetection.acs ACS/MapDetection.o
```

Each `.acs` file starts with `#library "<name>"` and `#include "zcommon.acs"`.
Always re-compile after editing — DECORATE references the named/numbered
scripts inside, not the source.

---

## 4. Recurring DECORATE patterns

These idioms are everywhere; recognise them before editing.

- **Inventory tokens as booleans** — `DECORATE/Tokens.txt` defines hundreds of
  zero-state `Inventory` actors (e.g. `IsOverWater`, `IsInATank`,
  `LowGraphicsMode`, `DMGame`). ACS or DECORATE calls `GiveInventory` /
  `TakeInventory`, and other states branch with `A_JumpIfInventory`.
- **CVAR feature flags** — server/user CVARs in `CVARINFO` are read from ACS by
  the **Janitor scripts** in `SRC/BDCVARS.acs` (`BDCheckJanitor`,
  `BDDisableMapEnhancements`, `BDCheckWaterRipples`, `BDFootsteps`,
  `CheckVoxels`, `BD_CheckBloodIntensity`, …). DECORATE actors call them via
  `ACS_NamedExecuteAlways("BDCheck...")` early in their `Spawn` state, and
  branch to a `Vanilla:` / `Vanish:` / `LowBlood:` state if the feature is off.
- **`TNT1 A 0` chains** — DECORATE has no real expressions; conditional logic
  is a long ladder of `TNT1 A 0 A_JumpIf(...)` / `A_JumpIfInventory(...)` /
  `A_SpawnItemEx(...)` lines, each consuming zero tics. Preserve formatting and
  ordering when editing — re-ordering can change which jump fires first.
- **`A_SpawnItemEx` with absolute placement** — map-specific decorations use
  `SXF_ABSOLUTEPOSITION | SXF_NOCHECKPOSITION` so coordinates are world-space,
  not relative to the spawner. This is how the per-map `*DecorationSpawn`
  actors place props at exact map locations.
- **Vehicle "pitch feelers"** — Tank / Helicopter actors fire short
  `A_CustomMissile("CheckPitchFront/Back/Center", ...)` projectiles that on
  impact give `PitchFrontToken` / `PitchBackToken`; the parent then jumps to
  the appropriate sprite frame to fake terrain-following pitch on a flat-floor
  engine. Don't "simplify" these — they are load-bearing.
- **Cross-port branches** — a lot of code does
  `if (GetCvar("MES_isrunningzandronum") == 1) { … } else { … }` because
  Zandronum lacks features GZDoom has. When adding logic that uses ZDoom-only
  tricks, gate it the same way.
- **Replacement actors** — `replaces XYZ` is used sparingly (e.g.
  `Golden_NOPE_NO_THNX!! replaces GoldenBoner`) because the goal is to be
  **non-replacing** so we coexist with gameplay mods. Prefer
  `EvidenceChecker*` + `*DecorationSpawn` pattern over `replaces`.

---

## 5. Conventions

- **Naming**
  - Actors / classes are `BDEC*` (Brutal Doom Enhanced Content), `Brutal_*`,
    `BD_*`, or `<MapName>DecorationSpawn`.
  - CVARs are `MES_*` (server/user) or `sv_*`.
  - ACS scripts are usually named (`script "Detect_Map" …`) — only use raw
    numeric IDs when an existing convention demands it (e.g. boss HUD `621`,
    bruiser `1622`–`1624`, dynamic `2093/3125/3126/3127`).
- **Style**
  - DECORATE keywords are case-insensitive but the project uses ALL-CAPS for
    flags (`+THRUACTORS`) and PascalCase for properties (`Radius 12`). Match
    surrounding style.
  - One state line per visual; comments use `//`.
  - Indentation is loose — most files mix tabs and spaces. Don't reformat
    unrelated code.
- **Compatibility floor**
  - Code path defaults assume **GZDoom 4.x / UZDoom 4.14.x**. Anything that
    requires newer features must be guarded.
  - **Never** introduce ZScript without explicit approval — the project has
    been deliberately kept on DECORATE for Zandronum compatibility.

---

## 6. How to make common changes

### Add a decoration to an existing detected map

1. Find the map's `*DecorationSpawn` actor (search `DECORATE/Doom1Remap.txt`,
   `Doom2Remap.txt`, `PlutoniaRemap.txt`, `TNTRemap.txt`,
   `OtherMapsRemap.txt`, or `MapSpecificDec.txt`).
2. Add a new line inside its `Spawn:` state:
   ```
   TNT1 A 0 A_SpawnItemEx("BDECPlantPot", X, Y, Z, 0, 0, 0, ANGLE,
       SXF_ABSOLUTEPOSITION | SXF_NOCHECKPOSITION)
   ```
   `Z = 999` snaps to ceiling-relative, `Z = -999` snaps to floor.
3. The actor name must already exist in one of the `DECORATE/*.txt` files
   (most live in `Furniture.txt`, `Lamps.txt`, `Natural.txt`, `Torches.txt`,
   `Particles.txt`, etc.).

### Detect a new vanilla / megawad map

1. Pick a stable signature: player-1 start `(x, y)` (right-shifted by 16,
   matching the ACS code), `par` time, and `PRINTNAME_LEVEL`. Avoid signatures
   shared by multiple known maps.
2. In `SRC/MapDetection.acs > script "Detect_Map"`, add a new `if (...)`
   block that `SpawnForced`s an evidence actor at known-good map coordinates,
   passing a unique TID.
3. In `DECORATE/MapDetection.txt`, add a new evidence-confirmation jump that
   spawns a new `<MapName>DecorationSpawn`.
4. Define `<MapName>DecorationSpawn` in the appropriate `*Remap.txt` file and
   create `MapEnhancement<MapName>` in `SRC/DYNAMICLEV.acs` for texture swaps.
5. Re-compile both ACS libraries.

### Add a new sound

1. Drop the lump in `SOUNDS/<category>/`.
2. Register a logical name in the relevant `SNDINFO.*` file. Add `$rolloff`,
   `$limit`, `$volume`, or `$random` qualifiers as needed.
3. Reference the *logical* name (not the lump) from DECORATE: `A_PlaySound`,
   `SeeSound`, `DeathSound`.

### Add a new CVAR-toggleable feature

1. Declare it in `CVARINFO` (`server int MES_newthing = 1;`).
2. Add a check script in `SRC/BDCVARS.acs` (a "Janitor" script that
   `GiveInventory("FeatureDisabled", 1)` or `SetActorState(0, "Vanish")`).
3. Re-compile `BDCVARS.acs`.
4. Call `ACS_NamedExecuteAlways("BDCheck...")` early in the actor's `Spawn`
   state and `A_JumpIfInventory("FeatureDisabled", 1, "Vanish")`.

---

## 7. Things to watch out for

- **Don't replace vanilla actors** unless you have a very good reason.
  Existing `replaces` directives interfere with gameplay mods and were the
  reason this project was rewritten around the EvidenceChecker pattern.
- **Don't change Thing TIDs** spawned by `MapDetection.acs` without updating
  the corresponding `EvidenceChecker*` and `*DecorationSpawn` chain.
- **Recompile ACS** every time you touch `SRC/*.acs`. The shipped `.o` files
  are what the engine runs.
- **Voxels** in `VOXELS/` are gated by `MES_voxeldec`; their actors call
  `CheckVoxels` and jump to a `Disappear:` state when disabled.
- **Casing actors** are gated by `MES_infinitecasings` and `LowGraphicsMode`;
  Janitor 2 + 3 short-circuit them in deathmatch.
- **Blood intensity** has *two* CVAR readers — one for Zandronum
  (`bd_bloodamount`) and one for ZDoom (`zdoombrutalblood`); update both
  branches when changing thresholds.
- **`testmap.wad`** is for local debugging; it is not part of the shipped
  experience. Don't link new content against it.

---

## 8. Testing

There is no automated test harness — this is a Doom mod. Manual loop:

```
gzdoom -iwad doom2.wad -file UME-Lite/ +map MAP01
```

Useful console commands while testing:

- `summon BDECPlantPot` — spawn an actor by name.
- `give Token1` — exercise inventory-token branches.
- `puke -sname Detect_Map` — force re-run map detection (after replacing the
  numeric script id with the named one).
- `mes_disabledecorations 1`, `mes_disablemapenhancements 1`,
  `mes_lowgraphicsmode 1`, `mes_voxeldec 0`, `sv_allowbossmap 1` — exercise
  the CVAR gates.

Test against at least: GZDoom (latest 4.x), UZDoom 4.14.3, and Zandronum (for
the cross-port branches).

---

## 9. External documentation (authoritative)

When a DECORATE keyword, ACS function, actor flag, action function, or class
behaviour is unclear, **consult these in this order**:

1. **ZDoom Wiki — DECORATE** — the primary spec for everything in
   `DECORATE/*.txt`:
   - DECORATE format: <https://zdoom.org/w/index.php?title=DECORATE_format_specifications>
   - Actor properties: <https://zdoom.org/w/index.php?title=Actor_properties>
   - Actor flags: <https://zdoom.org/w/index.php?title=Actor_flags>
   - Actor states: <https://zdoom.org/w/index.php?title=Actor_states>
   - Action functions: <https://zdoom.org/w/index.php?title=Action_functions>
   - DECORATE expressions: <https://zdoom.org/w/index.php?title=DECORATE_expressions>
   - Classes (inheritance hierarchy): <https://zdoom.org/w/index.php?title=Classes>
2. **ZDoom-docs (stable)** — the up-to-date authoritative reference for the
   ZScript / VM language family that DECORATE compiles into. Useful for
   understanding the *semantics* even when writing DECORATE:
   <https://github.com/zdoom-docs/stable>
3. **UZDoom source, tag 4.14.3** — versioned engine source that matches our
   compatibility floor. Use it to confirm flag/property availability or to
   trace what a built-in actor actually does:
   <https://github.com/UZDoom/UZDoom/tree/4.14.3>

For ACS specifically, `zcommon.acs` (shipped with `acc`) is the canonical
reference; the ZDoom Wiki has function pages keyed by name (e.g.
`SpawnForced`, `CheckActorFloorTexture`, `GetLevelInfo`, `ReplaceTextures`).

---

## 10. Credits / lineage (do not strip from source comments)

The source comments credit **Sergeant Mark IV** (original Brutal Doom Map
Enhancement System), **TDRR**, **Kaminsky**, and **BROS_ETT_311** (the
detection rewrite in `SRC/MapDetection.acs`). When refactoring, keep the
comment headers in place — they are the project's only attribution record.
