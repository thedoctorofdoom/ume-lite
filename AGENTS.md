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
- **Per-map decoration placement** through `Doom1Remap.txt`, `Doom2Remap.txt`,
  and `MapSpecificDec.txt`, using absolute-position `A_SpawnItemEx` calls.
- **Gore, blood, gibs, particles, casings, smoke, fire, puffs, flares, props,
  torches, lamps, natural decorations, fireworks**, one enemy (`Mummy`), and
  one critter (`BDCritterMouse`).
- **Brightmaps, dynamic lights, and model bindings** for the remaining actors.
- **A Brutal Doom Platinum compatibility package path** using
  `DECORATE_BDP.txt` as an alternate root.

Important: `MAPINFO.lmp` is absent. UME-Lite does not define episodes, maps,
music, skies, map order, or bundled WAD entries.

---

## 1.5. Changes from upstream - agent reference

### Removed

These upstream features are intentionally absent. Do not waste time searching
for them unless the user explicitly asks to restore them.

- **Vehicles**: no `Tank.txt`, `Helicopter.txt`, `Mech.txt`,
  `HeavyMachineGun.txt`, `Bike.txt`, `UME_Ammo.txt`,
  `SRC/VEHICLECONTROL.acs`, `Modeldef.BDVehicles.txt`, or
  `SNDINFO.Vehicles`.
- **Boss-Mode**: no `SRC/BOSSHEALTH.acs`, no boss HUD implementation, no
  `KEYCONF`, and no `BossMode` key alias.
- **Bundled map sets and map registration**: no `MAPINFO.lmp`, no
  `dmlevels.wad`, no `psxlevels.wad`, no `testmap.wad`, and no bundled
  `*.wad` files at all.
- **Complete per-map remap coverage outside Doom 1 / Doom 2**: no
  `DECORATE/PlutoniaRemap.txt`, `DECORATE/TNTRemap.txt`, or
  `DECORATE/OtherMapsRemap.txt`. Some stale TNT / Plutonia signatures remain
  in `SRC/MapDetection.acs` and `DECORATE/MapDetection.txt`, but their
  `TNTMap*DecorationSpawn` / `PMap*DecorationSpawn` actor definitions are not
  present, so those IWADs are not supported targets in this stripped build.
- **HD skies / terrain / animated environment lumps**: no `Textures.HDSkies`,
  `doomwalls.bm`, `ANIMDEFS`, `TERRAIN`, or `DECALDEF.Terrain`.
- **Splash and extra sound libraries**: no `SRC/SSPLASH.acs`,
  `SNDINFO.BrutalChexQuest`, or `SNDINFO.Vehicles`.
- **Asset directories removed**: no `MUSIC/`, `GRAPHICS/`, `Textures/`,
  `PATCHES/`, or `announcer/`.

### Gutted but still present

These files are retained for compatibility with DECORATE calls and load order,
but most of their old behavior has been removed.

- `LOADACS` now loads only:

  ```
  DYNAMICLEV
  BDCVARS
  MapDetection
  ```

  There is no `SSPLASH` or `VEHICLECONTROL` library in this build.

- `SRC/BDCVARS.acs` still defines the old Janitor script names, but most are
  empty no-op bodies: `BDCheckJanitor`, `BDCheckJanitor2`,
  `BDCheckJanitor3`, `BDCheckJanitor4`, `BDCheckDecorations`,
  `BDDisableMapEnhancements`, `CheckIfDM`, `BDCheckWaterRipples`,
  `BDFootsteps`, and `BD_CheckIfOverLiquid`.
- `SRC/BDCVARS.acs` functions with real bodies are limited to
  `BDInitialize`, `CheckVoxels`, `BD_CheckMap31TreeSwap`,
  `BD_CheckBloodIntensity`, `BD_CheckBloodExtra1`, and
  `BD_CheckIfLowBlood`.
- `CheckVoxels` is hard-coded to `SetActorState(0, "Disappear")`, so voxel
  decorations are forced off regardless of `MES_voxeldec`.
- Every `MapEnhancement<Name>` script in `SRC/DYNAMICLEV.acs` is empty. The
  `*DecorationSpawn` actors still call
  `ACS_NamedExecuteAlways("MapEnhancement<Name>")`, but no `ReplaceTextures`
  calls actually run in this build.
- `CVARINFO` still declares old `MES_*` CVARs, but all `MES_*` values are
  effectively inert because the Janitor scripts that used to translate them
  into inventory tokens are empty. The one CVAR still consumed directly is
  `sv_allowbossmap` in `SRC/MapDetection.acs`.

### Added

- `DECORATE_BDP.txt`: alternate DECORATE root for the Brutal Doom Platinum
  compatibility build. It includes only:
  `MapSpecificDec.txt`, `MapDetection.txt`, `Doom1Remap.txt`,
  `Doom2Remap.txt`.
- `.gitignore`: excludes OS/editor scratch, local pk3 builds, ACS scratch, and
  the local `acc-1.60-win32/` toolchain.
- `acc-1.60-win32/`: local ACS compiler and `zcommon.acs` headers for
  development only. It is gitignored and must not be shipped.

### Present but not included by DECORATE.txt

These files exist under `DECORATE/` but are not included by the standalone
`DECORATE.txt` root. Do not assume they run.

- `DECORATE/FlatDecals.txt`
- `DECORATE/GOREGROUPS.txt` (the include is present but commented out)
- `DECORATE/KeyPLacement.txt`
- `DECORATE/ReviewThisToReplaceTreesInWolfMaps.txt`

---

## 2. Engine, language, and directory layout

This add-on uses the classic ZDoom modding stack, not modern ZScript:

- **DECORATE** for actor definitions. There is no `zscript.zs`; do not add one
  unless explicitly asked.
- **ACS** (`SRC/*.acs`, compiled to `ACS/*.o`) for map detection and retained
  compatibility stubs.
- **GLDEFS**, **MODELDEF**, **SNDINFO**, **CVARINFO**, and brightmap lumps for
  engine configuration.

Current layout:

```
UME-Lite/
|-- DECORATE.txt              # Standalone DECORATE root (full)
|-- DECORATE_BDP.txt          # BDP-compat DECORATE root (minimal)
|-- DECORATE/                 # Remaining actor definitions
|-- SRC/                      # ACS source: BDCVARS, DYNAMICLEV, MapDetection
|-- ACS/                      # Compiled ACS objects referenced by LOADACS
|-- LOADACS                   # DYNAMICLEV, BDCVARS, MapDetection
|-- CVARINFO                  # Declares old CVAR surface, mostly inert
|-- GLDEFS                    # Dynamic lights and glows
|-- doomdefs.bm               # Brightmap declarations
|-- modeldef.txt,
|   Modeldef.Decorations.txt  # Remaining MD3 / MD2 model bindings
|-- SNDINFO.BD,
|   SNDINFO.Terrain           # Sound aliases, rolloff, random groups
|-- SPRITES/, MODELS/, SOUNDS/,
|   VOXELS/, brightmaps/      # Runtime assets
`-- acc-1.60-win32/           # Dev-only ACS compiler, gitignored
```

There is no `MAPINFO.lmp`, `KEYCONF`, `ANIMDEFS`, `TERRAIN`,
`DECALDEF.Terrain`, `Textures.*`, `doomwalls.bm`, `MUSIC/`, `GRAPHICS/`,
`PATCHES/`, `announcer/`, or bundled `*.wad`.

**Pseudo-PK3 packaging**: this directory is meant to be zipped into a `.pk3`
or loaded directly as a directory with `-file UME-Lite/`. Runtime packages
should exclude `SRC/`, `acc-1.60-win32/`, `.git/`, and local pk3 build
outputs.

---

## 3. Load order and the ACS pipeline

1. `LOADACS` lists the ACS libraries the engine pre-loads:
   `DYNAMICLEV`, `BDCVARS`, and `MapDetection`.
2. `BDCVARS.acs` runs `BDInitialize` (`enter`) on every map. Most old Janitor
   scripts are now no-op compatibility stubs. Do not assume a CVAR declared in
   `CVARINFO` changes behavior unless you find a real `GetCvar` reader.
3. `MapDetection.acs` runs `Initialize_Enhancements` (`enter`), freezes player
   1 briefly, and calls `Detect_Map`.
4. `Detect_Map` compares `(GetActorX(0)>>16, GetActorY(0)>>16, par_time,
   level_name)` against the signature table. The complete supported path is
   Doom 1 / Doom 2. Stale TNT / Plutonia checks still exist, but their
   decoration-spawn actors are missing. On a match, it `SpawnForced`s an
   `EvidenceChecker*` actor at fixed map coordinates with a known Thing TID.
5. The spawned `EvidenceChecker*` actor in `DECORATE/MapDetection.txt`
   confirms it landed on the expected object / sector / texture in the real
   IWAD map, then spawns a `<MapName>DecorationSpawn` actor.
6. The `*DecorationSpawn` actor in `DECORATE/Doom1Remap.txt`,
   `DECORATE/Doom2Remap.txt`, or `DECORATE/MapSpecificDec.txt` calls
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

ACS sources live in `SRC/` and target `ACS/<name>.o`. Use the local compiler
and include headers in `acc-1.60-win32/`:

```
acc-1.60-win32/acc.exe -i acc-1.60-win32 SRC/MapDetection.acs ACS/MapDetection.o
```

Each `.acs` file starts with `#library "<name>"` and
`#include "zcommon.acs"`. Always recompile after editing `SRC/*.acs`; the
engine runs the compiled `.o` files, not the source.

---

## 4. Recurring DECORATE patterns

Recognise these idioms before editing.

- **Inventory tokens as booleans**: `DECORATE/Tokens.txt` defines many
  zero-state `Inventory` actors. ACS or DECORATE can call `GiveInventory` /
  `TakeInventory`, and other states branch with `A_JumpIfInventory`. Many old
  tokens are now never granted because the Janitor scripts are empty.
- **CVAR feature flags**: old CVARs remain in `CVARINFO`, but most readers are
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

---

## 6. How to make common changes

### Add a decoration to an existing detected map

1. Find the map's `*DecorationSpawn` actor in `DECORATE/Doom1Remap.txt`,
   `DECORATE/Doom2Remap.txt`, or `DECORATE/MapSpecificDec.txt`.
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
2. In `SRC/MapDetection.acs`, add an `if (...)` block in `Detect_Map` that
   `SpawnForced`s an evidence actor at known-good map coordinates with a
   unique TID.
3. In `DECORATE/MapDetection.txt`, add the evidence-confirmation jump that
   spawns a new `<MapName>DecorationSpawn`.
4. Define `<MapName>DecorationSpawn` in `Doom1Remap.txt`, `Doom2Remap.txt`, or
   `MapSpecificDec.txt`.
5. Add or fill in `MapEnhancement<MapName>` in `SRC/DYNAMICLEV.acs` only if
   you need ACS behavior such as texture replacement.
6. Recompile the edited ACS library.

### Restore texture replacement for a map

1. Find the matching `MapEnhancement<Name>` script in `SRC/DYNAMICLEV.acs`.
2. Add the needed `ReplaceTextures`, `ChangeFloor`, `ChangeSky`, or other ACS
   calls there.
3. Recompile `DYNAMICLEV.acs` to `ACS/DYNAMICLEV.o`.
4. Test the map manually. Decoration spawns call this hook already, but the
   hook body is currently empty.

### Add a new CVAR-toggleable feature

1. Declare the CVAR in `CVARINFO` if it is not already present.
2. Fill in or add an ACS check script in `SRC/BDCVARS.acs` that actually reads
   the CVAR with `GetCvar` and gives inventory or changes actor state.
3. Call the script from the relevant DECORATE actor with
   `ACS_NamedExecuteAlways`.
4. Branch on the inventory token or actor state in DECORATE.
5. Recompile `BDCVARS.acs`.

Do not assume the existing `MES_*` CVARs work. Most are retained declarations
only.

### Add a new sound

1. Put the sound lump under `SOUNDS/<category>/`.
2. Register a logical name in `SNDINFO.BD` or `SNDINFO.Terrain`.
3. Reference the logical name from DECORATE (`A_PlaySound`, `SeeSound`,
   `DeathSound`), not the raw filename.

### Package the BDP variant

For a Brutal Doom Platinum compatibility package, stage the same runtime files
as the standalone pk3 but copy `DECORATE_BDP.txt` to root `DECORATE.txt` inside
the staged package. Load order is:

```
IWAD -> Brutal Doom Platinum -> UME-BDP.pk3
```

Do not merge `DECORATE.txt` and `DECORATE_BDP.txt`; they are alternate roots
for different package variants.

---

## 7. Things to watch out for

- **Empty ACS stubs are intentional**. A `{}` Janitor body is not necessarily a
  bug. Ask or document the behavior before restoring old upstream logic.
- **Texture replacement is currently inert**. `ReplaceTextures` appears only
  in comments / examples unless you add it to a `MapEnhancement<Name>` body.
- **`DECORATE.txt` and `DECORATE_BDP.txt` are alternate roots**. Only one
  should ship as root `DECORATE.txt` in a given pk3.
- **Do not change Thing TIDs** spawned by `MapDetection.acs` without updating
  the corresponding `EvidenceChecker*` and decoration-spawn chain.
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
detection rewrite in `SRC/MapDetection.acs`). When refactoring, keep the
comment headers in place; they are the project's attribution record.
