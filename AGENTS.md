# AGENTS.md - UME-Lite (Universal Map Enhancement System, Lite)

Guidance for AI agents working in this repository. Read this **first** before
making changes. This tree is a heavily stripped fork of the original UME /
Brutal Doom Map Enhancement System, and many files an agent might expect from
upstream are intentionally gone.

---

## 1. What this project is

UME-Lite is a loose-file Doom add-on (PK3-style directory) intended to be loaded
by **GZDoom / UZDoom** (and, with caveats, **LZDoom** and **Zandronum**) on top
of `doom.wad` or `doom2.wad`, usually alongside a gameplay mod such as Brutal
Doom, Project Brutality, Brutal Doom Platinum, Demon Steele, etc.

This fork keeps the non-replacing decoration pipeline and a subset of gore /
ambient actors. It does **not** ship gameplay systems, player classes, weapons,
vehicle control, boss HUDs, bonus maps, or episode definitions.

What remains at runtime:

- **Complete map detection and decoration spawns** for vanilla Doom 1 and
  Doom II. Maps are identified by player-1 start coordinates, par time, and
  level name, then confirmed with `EvidenceChecker*` DECORATE actors.
- **Per-map decoration placement** through `doom1remap.txt`, `doom2remap.txt`,
  and `mapspecificdec.txt`, using absolute-position `A_SpawnItemEx` calls.
- **Gore, blood, gibs, particles, casings, smoke, fire, puffs, flares, props,
  torches, lamps, natural decorations, fireworks**, one enemy (`Mummy`), and
  one critter (`BDCritterMouse`).
- **Brightmaps, dynamic lights, and model bindings** for the remaining actors.

Important: `MAPINFO.lmp` is absent. UME-Lite does not define episodes, maps,
music, skies, map order, or bundled WAD entries.

A previous fork shipped a `decorate_bdp.txt` alternate root for a Brutal
Doom Platinum compatibility package. That alternate root has been removed;
this build is single-rooted on `decorate.txt` only.

---

## 1.5. Changes from upstream - agent reference

### Removed

These upstream features are intentionally absent. Do not waste time searching
for them unless the user explicitly asks to restore them.

- **Vehicles**: no `tank.txt`, `helicopter.txt`, `mech.txt`,
  `heavymachinegun.txt`, `bike.txt`, `ume_ammo.txt`,
  `src/vehiclecontrol.acs`, `modeldef.bdvehicles.txt`, or
  `sndinfo.vehicles`.
- **Boss-Mode**: no `src/bosshealth.acs`, no boss HUD implementation, no
  `KEYCONF` lump, and no `BossMode` key alias.
- **Bundled map sets and map registration**: no `MAPINFO` lump, no
  `dmlevels.wad`, no `psxlevels.wad`, no `testmap.wad`, and no bundled
  `*.wad` files at all.
- **Complete per-map remap coverage outside Doom 1 / Doom 2**: no
  `decorate/plutoniaremap.txt`, `decorate/tntremap.txt`, or
  `decorate/othermapsremap.txt`. The TNT / Plutonia / PLMap / PMap signatures
  and decoration-spawn references have also been pruned from
  `src/mapdetection.acs` and `decorate/mapdetection.txt`. TNT and Plutonia
  are not supported targets in this build.
- **HD skies / terrain / animated environment lumps**: no `textures.hdskies`,
  `doomwalls.bm`, `ANIMDEFS`, `TERRAIN`, or `DECALDEF.Terrain` lumps.
- **Splash and extra sound libraries**: no `src/ssplash.acs`,
  `sndinfo.brutalchexquest`, or `sndinfo.vehicles`.
- **Asset directories removed**: no `music/`, `graphics/`, `textures/`,
  `patches/`, or `announcer/`.

### Gutted but still present

These files are retained for compatibility with DECORATE calls and load order,
but most of their old behavior has been removed.

- `loadacs` now loads only:

  ```
  DYNAMICLEV
  BDCVARS
  MapDetection
  ```

  (The library names declared via `#library` inside the `.acs` sources are
  case-insensitive; `loadacs` matches them by name regardless of file case.)
  There is no `SSPLASH` or `VEHICLECONTROL` library in this build.

- `src/bdcvars.acs` still defines the old Janitor script names, but most are
  empty no-op bodies: `BDCheckJanitor`, `BDCheckJanitor2`,
  `BDCheckJanitor3`, `BDCheckJanitor4`, `BDCheckDecorations`,
  `BDDisableMapEnhancements`, `CheckIfDM`, `BDCheckWaterRipples`,
  `BDFootsteps`, and `BD_CheckIfOverLiquid`.
- `src/bdcvars.acs` functions with real bodies are limited to
  `BDInitialize`, `CheckVoxels`, `BD_CheckMap31TreeSwap`,
  `BD_CheckBloodIntensity`, `BD_CheckBloodExtra1`, and
  `BD_CheckIfLowBlood`.
- `CheckVoxels` is hard-coded to `SetActorState(0, "Disappear")`, so voxel
  decorations are forced off regardless of `MES_voxeldec`.
- Every `MapEnhancement<Name>` script in `src/dynamiclev.acs` is empty. The
  `*DecorationSpawn` actors still call
  `ACS_NamedExecuteAlways("MapEnhancement<Name>")`, but no `ReplaceTextures`
  calls actually run in this build.
- `cvarinfo` still declares old `MES_*` CVARs, but all `MES_*` values are
  effectively inert because the Janitor scripts that used to translate them
  into inventory tokens are empty. The one CVAR still consumed directly is
  `sv_allowbossmap` in `src/mapdetection.acs`.

### Added

- `.gitignore`: excludes OS/editor scratch, local pk3 builds, ACS scratch, and
  the local `acc-1.60-win32/` toolchain.
- `acc-1.60-win32/`: local ACS compiler and `zcommon.acs` headers for
  development only. It is gitignored and must not be shipped.
- `scripts/`: dev-only PowerShell helpers (e.g.
  `scripts/rename-to-lowercase.ps1`, the bulk-rename script that produced
  the current lowercase file/dir layout). Not runtime content; should be
  excluded from built pk3s.

### Renamed / reorganised

- **All directories and most filenames are lowercase.** GZDoom is
  case-insensitive at runtime for lump names, class names, sprite names,
  sound names, ACS library names, and CVAR names, but `#include` paths in
  `decorate.txt`, `Path` / `Model` / `Skin` paths in MODELDEF, and
  `brightmap … map "…"` paths in `doomdefs.bm` are filesystem strings and
  thus case-sensitive on Linux and inside zipped PK3s. The repository was
  bulk-renamed to lowercase to make it portable and to match the standard
  PK3 convention. See `scripts/rename-to-lowercase.ps1` for the canonical
  script. Exceptions:
  - `AGENTS.md` and `README.md` are kept in their original casing.
  - `acc-1.60-win32/` is dev-only and untouched.
  - Files **inside** `sprites/` and `sounds/` use **UPPERCASE base names
    with lowercase extensions** (e.g. `BARIA0.png`, `EXPLODE1.ogg`,
    `WATER1`). The directories themselves are lowercase. This matches the
    typical Doom-modding convention where the base name corresponds to the
    sprite / sound lump name and is conventionally uppercase.
- **MODELDEF lumps merged.** The old `Modeldef.Decorations.txt` was merged
  into `modeldef.txt`; both files used to be loaded as MODELDEF lumps and
  now there is a single MODELDEF lump. A section banner in `modeldef.txt`
  marks where the decoration block begins.
- **SNDINFO lumps merged.** The old `SNDINFO.BD` and `SNDINFO.Terrain`
  were merged into a single file named `sndinfo.txt`. The engine resolves
  this to lump `SNDINFO` (the last extension is stripped to form the lump
  name). SNDINFO is order-sensitive for repeated keys (the last definition
  wins), and the legacy alphabetical load order was bd-then-terrain, so
  the merged file preserves that order: the bd block comes first, the
  terrain block second. Section banners inside `sndinfo.txt` mark the
  boundary. There are still a few overlapping keys (`world/watersplash`,
  `world/sludgegloop`, `world/lavasizzle`, `world/drip`, and their
  `$limit` / `$volume`); the terrain values still win for those, exactly
  as before the merge.

### Present but not included by `decorate.txt`

These files exist under `decorate/` but are not included by the standalone
`decorate.txt` root. Do not assume they run.

- `decorate/flatdecals.txt`
- `decorate/goregroups.txt` (the include is present but commented out)
- `decorate/keyplacement.txt`
- `decorate/reviewthistoreplacetreesinwolfmaps.txt`

---

## 2. Engine, language, and directory layout

This add-on uses the classic ZDoom modding stack, not modern ZScript:

- **DECORATE** for actor definitions. There is no `zscript.zs`; do not add one
  unless explicitly asked.
- **ACS** (`src/*.acs`, compiled to `acs/*.o`) for map detection and retained
  compatibility stubs.
- **GLDEFS**, **MODELDEF**, **SNDINFO**, **CVARINFO**, and brightmap lumps for
  engine configuration.

Current layout:

```
UME-Lite/
|-- decorate.txt              # Standalone DECORATE root (full)
|-- decorate/                 # Remaining actor definitions
|-- src/                      # ACS source: bdcvars, dynamiclev, mapdetection
|-- acs/                      # Compiled ACS objects referenced by loadacs
|-- loadacs                   # DYNAMICLEV, BDCVARS, MapDetection (library names)
|-- cvarinfo                  # Declares old CVAR surface, mostly inert
|-- gldefs                    # Dynamic lights and glows
|-- doomdefs.bm               # Brightmap declarations
|-- modeldef.txt              # MD3 / MD2 model bindings (effects + decorations)
|-- sndinfo.txt               # Sound aliases, rolloff, random groups
|                             # (single lump; was sndinfo.bd + sndinfo.terrain)
|-- sprites/, models/, sounds/,
|   voxels/, brightmaps/      # Runtime assets
|-- scripts/                  # Dev-only helpers (e.g. rename-to-lowercase.ps1)
`-- acc-1.60-win32/           # Dev-only ACS compiler, gitignored
```

There is no `MAPINFO`, `KEYCONF`, `ANIMDEFS`, `TERRAIN`, `DECALDEF.Terrain`,
`textures.*`, `doomwalls.bm`, `music/`, `graphics/`, `patches/`,
`announcer/`, or bundled `*.wad`.

**Pseudo-PK3 packaging**: this directory is meant to be zipped into a `.pk3`
or loaded directly as a directory with `-file UME-Lite/`. Runtime packages
should exclude `src/`, `scripts/`, `acc-1.60-win32/`, `.git/`, `.cursor/`,
and local pk3 build outputs.

---

## 3. Load order and the ACS pipeline

1. `loadacs` lists the ACS libraries the engine pre-loads:
   `DYNAMICLEV`, `BDCVARS`, and `MapDetection`.
2. `src/bdcvars.acs` runs `BDInitialize` (`enter`) on every map. Most old
   Janitor scripts are now no-op compatibility stubs. Do not assume a CVAR
   declared in `cvarinfo` changes behavior unless you find a real `GetCvar`
   reader.
3. `src/mapdetection.acs` runs `Initialize_Enhancements` (`enter`), freezes
   player 1 briefly, and calls `Detect_Map`.
4. `Detect_Map` compares `(GetActorX(0)>>16, GetActorY(0)>>16, par_time,
   level_name)` against the signature table. Only Doom 1 / Doom 2 signatures
   are checked. On a match, it `SpawnForced`s an `EvidenceChecker*` actor at
   fixed map coordinates with a known Thing TID.
5. The spawned `EvidenceChecker*` actor in `decorate/mapdetection.txt`
   confirms it landed on the expected object / sector / texture in the real
   IWAD map, then spawns a `<MapName>DecorationSpawn` actor.
6. The `*DecorationSpawn` actor in `decorate/doom1remap.txt`,
   `decorate/doom2remap.txt`, or `decorate/mapspecificdec.txt` calls
   `ACS_NamedExecuteAlways("MapEnhancement<Name>")`, then runs many
   absolute-position `A_SpawnItemEx` calls to place props.
7. In this build, the `MapEnhancement<Name>` scripts are empty. The spawn
   calls still happen, but texture swaps do not.

Mental model:

```
ACS detects map
  -> DECORATE evidence checker confirms map
  -> DECORATE decoration spawner places props
  -> ACS MapEnhancement hook is called but currently does nothing
```

### Re-compiling ACS

ACS sources live in `src/` and target `acs/<name>.o`. Use the local compiler
and include headers in `acc-1.60-win32/`:

```
acc-1.60-win32/acc.exe -i acc-1.60-win32 src/mapdetection.acs acs/mapdetection.o
```

Each `.acs` file starts with `#library "<name>"` and
`#include "zcommon.acs"`. Always recompile after editing `src/*.acs`; the
engine runs the compiled `.o` files, not the source.

---

## 4. Recurring DECORATE patterns

Recognise these idioms before editing.

- **Inventory tokens as booleans**: `decorate/tokens.txt` defines many
  zero-state `Inventory` actors. ACS or DECORATE can call `GiveInventory` /
  `TakeInventory`, and other states branch with `A_JumpIfInventory`. Many old
  tokens are now never granted because the Janitor scripts are empty.
- **CVAR feature flags**: old CVARs remain in `cvarinfo`, but most readers are
  gone. If you need a working CVAR, fill in or add an ACS script that actually
  reads it and sets inventory state.
- **`TNT1 A 0` chains**: DECORATE uses long zero-tic ladders of
  `A_JumpIf`, `A_JumpIfInventory`, and `A_SpawnItemEx`. Preserve ordering;
  changing it can change which branch fires first.
- **`A_SpawnItemEx` with absolute placement**: map-specific decorations use
  `SXF_ABSOLUTEPOSITION | SXF_NOCHECKPOSITION` so coordinates are world-space,
  not relative to the spawner.
- **Replacement actors**: avoid `replaces` unless the user explicitly asks.
  This fork stays gameplay-mod-friendly by using the
  `EvidenceChecker*` -> `*DecorationSpawn` pattern instead of replacing
  vanilla map actors.

---

## 5. Conventions

- **Naming**
  - Actors / classes are usually `BDEC*`, `Brutal_*`, `BD_*`, or
    `<MapName>DecorationSpawn`.
  - CVARs are old-style `MES_*` or `sv_*`, but `MES_*` values are inert unless
    a script actively reads them.
  - ACS scripts are usually named. Preserve existing raw numeric IDs where
    they already exist (`2093`, `230`, `3125`, etc.).
- **Style**
  - DECORATE keywords are case-insensitive, but the project uses ALL-CAPS for
    flags (`+THRUACTORS`) and PascalCase / mixed historical casing for
    properties. Match nearby code.
  - One state line per visual; comments use `//`.
  - Indentation is loose and mixed. Do not reformat unrelated code.
- **Compatibility floor**
  - Code paths assume GZDoom 4.x / UZDoom 4.14.x unless a port-specific branch
    says otherwise.
  - Do not introduce ZScript without explicit approval; this tree is still
    DECORATE + ACS for broad port compatibility.
- **Filesystem case (Linux / PK3 portability)**
  - All directories and most filenames are **lowercase**. New files,
    `#include` paths in `decorate.txt`, MODELDEF `Path` / `Model` / `Skin`
    values, and `doomdefs.bm` `map "..."` paths must all be lowercase. These
    are real filesystem strings and are case-sensitive on Linux and inside
    zipped PK3s.
  - Files inside `sprites/` and `sounds/` use **UPPERCASE base names with
    lowercase extensions** (e.g. `BARIA0.png`, `EXPLODE1.ogg`, `WATER1`).
    This matches the convention that the base name corresponds to a
    sprite or sound lump name. The directories themselves are lowercase.
  - `AGENTS.md`, `README.md`, `acc-1.60-win32/`, `.git/`, `.cursor/`, and
    `scripts/` are exempt from the lowercase rule.
  - Lump-conceptual references in docs (e.g. `MAPINFO`, `KEYCONF`,
    `ANIMDEFS`) may use the canonical uppercase form even when the
    on-disk file would be lowercase.

---

## 6. How to make common changes

### Add a decoration to an existing detected map

1. Find the map's `*DecorationSpawn` actor in `decorate/doom1remap.txt`,
   `decorate/doom2remap.txt`, or `decorate/mapspecificdec.txt`.
2. Add a line inside its `Spawn:` state:

   ```
   TNT1 A 0 A_SpawnItemEx("BDECPlantPot", X, Y, Z, 0, 0, 0, ANGLE, SXF_ABSOLUTEPOSITION | SXF_NOCHECKPOSITION)
   ```

   `Z = 999` is commonly used for ceiling-relative placement and `Z = -999`
   for floor-relative placement in this codebase.
3. Confirm the actor exists in an included DECORATE file before referencing it.

### Detect a new Doom 1 / Doom 2 map variant

1. Pick a stable signature: player-1 start `(x, y)` after `>> 16`, par time,
   and `PRINTNAME_LEVEL`. Avoid signatures shared by multiple maps.
2. In `src/mapdetection.acs`, add an `if (...)` block in `Detect_Map` that
   `SpawnForced`s an evidence actor at known-good map coordinates with a
   unique TID.
3. In `decorate/mapdetection.txt`, add the evidence-confirmation jump that
   spawns a new `<MapName>DecorationSpawn`.
4. Define `<MapName>DecorationSpawn` in `decorate/doom1remap.txt`,
   `decorate/doom2remap.txt`, or `decorate/mapspecificdec.txt`.
5. Add or fill in `MapEnhancement<MapName>` in `src/dynamiclev.acs` only if
   you need ACS behavior such as texture replacement.
6. Recompile the edited ACS library.

### Restore texture replacement for a map

1. Find the matching `MapEnhancement<Name>` script in `src/dynamiclev.acs`.
2. Add the needed `ReplaceTextures`, `ChangeFloor`, `ChangeSky`, or other ACS
   calls there.
3. Recompile `src/dynamiclev.acs` to `acs/dynamiclev.o`.
4. Test the map manually. Decoration spawns call this hook already, but the
   hook body is currently empty.

### Add a new CVAR-toggleable feature

1. Declare the CVAR in `cvarinfo` if it is not already present.
2. Fill in or add an ACS check script in `src/bdcvars.acs` that actually
   reads the CVAR with `GetCvar` and gives inventory or changes actor state.
3. Call the script from the relevant DECORATE actor with
   `ACS_NamedExecuteAlways`.
4. Branch on the inventory token or actor state in DECORATE.
5. Recompile `src/bdcvars.acs`.

Do not assume the existing `MES_*` CVARs work. Most are retained declarations
only.

### Add a new sound

1. Put the sound lump under `sounds/<category>/`. Use an UPPERCASE base name
   with a lowercase extension (e.g. `MYSOUND.ogg`).
2. Register a logical name in `sndinfo.txt` (the only SNDINFO lump in this
   build). New entries normally go in the bd block (above the terrain
   banner). Only put it in the terrain block if it must override an entry
   the bd block sets.
3. Reference the logical name from DECORATE (`A_PlaySound`, `SeeSound`,
   `DeathSound`), not the raw filename.

### Add a new model

1. Put model files (`.md3`, `.md2`) under the appropriate `models/<group>/`
   directory with lowercase names. Skin textures go alongside.
2. Add the `Model <ActorName> { ... }` block to `modeldef.txt` (the only
   MODELDEF lump in this build). Use lowercase `Path`, `Model`, and
   `Skin` values; these are real filesystem paths.

---

## 7. Things to watch out for

- **Empty ACS stubs are intentional**. A `{}` Janitor body is not necessarily a
  bug. Ask or document the behavior before restoring old upstream logic.
- **Texture replacement is currently inert**. `ReplaceTextures` appears only
  in comments / examples unless you add it to a `MapEnhancement<Name>` body.
- **Do not change Thing TIDs** spawned by `src/mapdetection.acs` without
  updating the corresponding `EvidenceChecker*` and decoration-spawn chain.
- **Do not replace vanilla actors** unless there is a very good reason.
  Replacements interfere with gameplay mods.
- **Voxels are forced off** by `CheckVoxels`; `MES_voxeldec` does not re-enable
  them in this build.
- **Casing / low-graphics / deathmatch throttles are inert** until the relevant
  BDCVARS Janitor bodies are restored.
- **Blood intensity uses external CVARs**: `BD_CheckBloodIntensity` reads
  `bd_bloodamount` when `isrunningzandronum == 1`, and
  `zdoombrutalblood` when `isrunningzandronum == 0`. It does not read
  `MES_bloodamount`.
- **Local toolchain is not runtime content**. Keep `acc-1.60-win32/` out of
  built pk3s.

---

## 8. Testing

There is no automated test harness. Manual loop:

```
gzdoom -iwad doom2.wad -file UME-Lite/ +map MAP01
```

Useful console commands while testing:

- `summon BDECPlantPot` - spawn an actor by name.
- `give LowGraphicsMode` - manually exercise branches that old Janitor scripts
  no longer grant automatically.
- `puke -sname Detect_Map` - force re-run map detection in a port that supports
  named ACS pukes.
- `sv_allowbossmap 1` - exercise the remaining live CVAR branch in map
  detection.

The old `mes_disabledecorations`, `mes_disablemapenhancements`,
`mes_lowgraphicsmode`, `mes_voxeldec`, `mes_infinitecasings`, and
`mes_footstepsounds` toggles are declared but have no current effect until the
corresponding BDCVARS logic is restored.

Test against at least: GZDoom (latest 4.x), UZDoom 4.14.3, and Zandronum if a
change touches the Zandronum blood-intensity branch.

---

## 9. External documentation (authoritative)

When a DECORATE keyword, ACS function, actor flag, action function, or class
behavior is unclear, consult these in this order:

1. **ZDoom Wiki - DECORATE**:
   - DECORATE format: <https://zdoom.org/w/index.php?title=DECORATE_format_specifications>
   - Actor properties: <https://zdoom.org/w/index.php?title=Actor_properties>
   - Actor flags: <https://zdoom.org/w/index.php?title=Actor_flags>
   - Actor states: <https://zdoom.org/w/index.php?title=Actor_states>
   - Action functions: <https://zdoom.org/w/index.php?title=Action_functions>
   - DECORATE expressions: <https://zdoom.org/w/index.php?title=DECORATE_expressions>
   - Classes: <https://zdoom.org/w/index.php?title=Classes>
2. **zdoom-docs (stable)**: <https://github.com/zdoom-docs/stable>
3. **UZDoom source, tag 4.14.3**:
   <https://github.com/UZDoom/UZDoom/tree/4.14.3>

For ACS specifically, `zcommon.acs` in `acc-1.60-win32/` is the local canonical
reference.

---

## 10. Credits / lineage (do not strip from source comments)

The source comments credit **Sergeant Mark IV** (original Brutal Doom Map
Enhancement System), **TDRR**, **Kaminsky**, and **BROS_ETT_311** (the
detection rewrite in `src/mapdetection.acs`). When refactoring, keep the
comment headers in place; they are the project's attribution record.
