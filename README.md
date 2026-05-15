# Universal Map Enhancement System Lite (UME Lite)

**Universal Map Enhancement System - Lite Edition**

A drop-in, decoration-only add-on for **GZDoom / UZDoom** (and, with caveats,
**LZDoom** and **Zandronum**) that quietly adds props, gore, and ambient detail
to the original Doom and Doom II campaigns. It is meant to load alongside a
gameplay mod (Brutal Doom, Project Brutality, Brutal Doom Platinum, Demon
Steele, etc.) and never replaces vanilla actors.

UME-Lite is a deliberately **stripped fork** of the larger upstream UME / BD
Map Enhancement System. Most of the heavyweight features have been removed;
read the next section before you assume something works.

---

## Changes from upstream UME

### Removed

The following upstream features have been **deleted from this repository** and
are no longer present in any form:

- **All vehicles**: Tank, Artillery Tank, Mech, Helicopter, stationary Heavy
  Machinegun, Bike. Their DECORATE actors, ammo (`ume_ammo.txt`), the
  `src/vehiclecontrol.acs` controller, `modeldef.bdvehicles.txt`, and
  `sndinfo.vehicles` are all gone.
- **Boss-Mode for E1M8**: `src/bosshealth.acs`, the boss HUD, the `KEYCONF`
  binding, and the `BossMode` alias have been removed. (The
  `sv_allowbossmap` CVAR is still consulted by map detection so boss-aware
  mods can suppress decoration spawns on those maps; see *Configuration*.)
- **Bundled map sets**: `dmlevels.wad` (Brutal Deathmatch `BDM01`-`BDM10`),
  `psxlevels.wad` (PSX Doom `PSXMAP*`), `testmap.wad`, and any Extermination
  Day hooks. There is no `MAPINFO` lump at all.
- **Per-map remap files for Plutonia, TNT, and "OtherMaps"**: only
  `decorate/doom1remap.txt` and `decorate/doom2remap.txt` remain. The TNT,
  Plutonia, PLMap, and PMap signatures and decoration-spawn references have
  also been pruned from `src/mapdetection.acs` and
  `decorate/mapdetection.txt`. TNT and Plutonia are not supported targets in
  this build.
- **HD skies and animated environment lumps**: `textures.hdskies`,
  `doomwalls.bm`, `ANIMDEFS`, `TERRAIN`, and `DECALDEF.Terrain` have been
  removed.
- **Splash audio plumbing**: `src/ssplash.acs`, `sndinfo.vehicles`, and
  `sndinfo.brutalchexquest` are gone. Only `sndinfo.txt` (the `SNDINFO`
  lump, formerly `sndinfo.bd` + `sndinfo.terrain`, now merged) remains.
- **Asset directories**: `music/`, `graphics/`, `textures/`, `patches/`, and
  `announcer/` have been deleted.

### Gutted (still present, but no-op)

These are still in the source tree because removing them would require
re-wiring DECORATE actors that call them, but they currently have empty
bodies and **do nothing at runtime**:

- **Janitor scripts in [`src/bdcvars.acs`](src/bdcvars.acs)**: `BDCheckJanitor`,
  `BDCheckJanitor2`, `BDCheckJanitor3`, `BDCheckJanitor4`,
  `BDCheckDecorations`, `BDDisableMapEnhancements`, `CheckIfDM`,
  `BDCheckWaterRipples`, `BDFootsteps`, and `BD_CheckIfOverLiquid` all have
  empty `{}` bodies. The inventory tokens they used to grant
  (`LowGraphicsMode`, `FeatureDisabled`, etc.) are therefore never set, so
  the corresponding `A_JumpIfInventory` branches in DECORATE never fire.
- **`MapEnhancement<Name>` scripts in [`src/dynamiclev.acs`](src/dynamiclev.acs)**
  are all empty, which means **runtime
  texture replacement (`ReplaceTextures`) does not fire on any map** in this
  build. Only the commented `MapEnhancementE1M1` example shows what such a
  call would look like.
- **`CheckVoxels`**: hard-coded to `SetActorState(0, "Disappear")`, so voxel
  decorations are forced off regardless of the `MES_voxeldec` CVAR.

### Added

- [`decorate/compataliases.txt`](decorate/compataliases.txt): eight thin
  `Blood` subclasses (`MuchBlood`, `MuchBlood2`, `MediumBloodSpot`,
  `BigBloodSpot`, `WaterBloodSpot`, `SplatteredLarge`, `MeatDeath`,
  `MeatDeathSmall`) that resolve upstream gore-variant class names still
  referenced by this fork's gore chains. Pure subclasses, **not** `replaces`,
  so gameplay-mod compatibility is preserved.
- [`.gitignore`](.gitignore): covers OS scratch, editor temp files, local
  PK3 builds, ACS scratch, and the bundled `acc-1.60-win32/` toolchain.
- `acc-1.60-win32/`: local ACS compiler, **gitignored**, kept only for
  developer convenience. Never shipped in a built pk3.
- `scripts/`: dev-only helpers, including
  [`scripts/rename-to-lowercase.ps1`](scripts/rename-to-lowercase.ps1) (the
  bulk-rename script that produced the current lowercase file/dir layout).
  Not runtime content; exclude from built pk3s.

### Renamed / reorganised

- **Lowercase rename.** All directories and most filenames are lowercase.
  GZDoom is case-insensitive at runtime for lump names, class names, sprite
  names, sound names, ACS library names, and CVAR names, but `#include`
  paths in `decorate.txt`, MODELDEF `Path` / `Model` / `Skin` values, and
  `doomdefs.bm` `map "..."` paths are real filesystem strings that **are**
  case-sensitive on Linux and inside zipped PK3s. Lowercasing makes the
  tree portable. Exceptions:
  - `AGENTS.md` and `README.md` are kept in their original casing.
  - `acc-1.60-win32/` is dev-only and untouched.
  - Files **inside** `sprites/` and `sounds/` use **UPPERCASE base names
    with lowercase extensions** (e.g. `BARIA0.png`, `EXPLODE1.ogg`,
    `WATER1`). The directories themselves are lowercase.
- **MODELDEF lumps merged.** The old `Modeldef.Decorations.txt` was merged
  into `modeldef.txt`; both used to be loaded as MODELDEF lumps and now
  there is a single MODELDEF lump. A section banner inside `modeldef.txt`
  marks where the decoration block begins.
- **SNDINFO lumps merged.** The old `SNDINFO.BD` and `SNDINFO.Terrain`
  were merged into a single file named `sndinfo.txt` (which the engine
  resolves to lump `SNDINFO`). SNDINFO is order-sensitive (the last
  definition of a key wins), so the merged file keeps the bd block above
  the terrain block to preserve the original alphabetical load order.
  Section banners inside `sndinfo.txt` mark the boundary.

A short-lived alternate root `decorate_bdp.txt`, which scaffolded a
dedicated Brutal Doom Platinum compatibility package, has been removed in a
warning-cleanup pass. UME-Lite now ships only the standalone `decorate.txt`
root.

---

## What's still in the box

After the trim, this is what UME-Lite actually does at runtime:

- **Complete signature-based map detection** for vanilla **Doom 1**
  (E1M1-E3M9) and **Doom II** (MAP01-MAP32). Maps are identified by player-1 start
  coordinates + par time + `PRINTNAME_LEVEL`, then confirmed by
  `EvidenceChecker*` actors that probe a known floor / ceiling / texture in
  the real map.
- **Per-map decoration spawns** placed at hand-tuned absolute world
  coordinates: plant pots, antennae, hanging cables, computer lights, light
  shafts, light posts, destroyable windows, etc.
- **Brutal-style gore**: blood, gibs, limbs, dead-body decorations,
  configurable intensity (controlled by external `bd_bloodamount` /
  `zdoombrutalblood` CVARs supplied by your gameplay mod, **not** by
  `MES_bloodamount`).
- **Particle effects**: sparks, smoke, fire, flares, puffs, and shell
  casings.
- **One enemy** (`Mummy`) and **one critter** (`BDCritterMouse`).
- **Brightmaps** for Doom sprites (`doomdefs.bm` + `brightmaps/ume/`),
  **dynamic lights / glows** (`gldefs`), and **MD3 / MD2 model bindings**
  for decorations and projectiles (`modeldef.txt`).

UME-Lite intentionally ships **no weapons, no monsters except a mummy, no
player class, no maps, no MAPINFO**. That's the job of the gameplay mod /
megawad you load alongside it.

---

## Requirements

| | |
|---|---|
| **Engine** | GZDoom 4.x or UZDoom 4.14.3+ recommended. LZDoom and Zandronum work but with reduced effects. K8Vavoom is not supported. |
| **IWAD** | `doom.wad` or `doom2.wad`. Plutonia and TNT IWADs will load (the mod is non-replacing) but are not supported targets in this build; their map signatures and decoration-spawn paths have been removed entirely. |
| **Disk** | A few MB unpacked. |

---

## Installation

### Option A - drag & drop

1. Zip the **contents** of this folder into `UME.pk3`
   (everything inside the `UME-Lite/` directory, not the directory itself).
   When zipping, exclude `acc-1.60-win32/`, `src/`, `scripts/`, `.git/`,
   and `.cursor/` because they are not needed at runtime.
2. Drop `UME.pk3` onto your `gzdoom.exe` along with your IWAD and any
   gameplay mod you'd like to use.

### Option B - load as a directory

GZDoom can load loose folders directly:

```
gzdoom -iwad doom2.wad -file BrutalDoom.pk3 -file path/to/UME-Lite/
```

Always load **UME-Lite *after* your gameplay mod** so its decoration spawns
layer on top without being overwritten.

---

## Configuration

UME-Lite ships several CVARs in [`cvarinfo`](cvarinfo), but **almost all of
them are inert in this build** because they remain only for load-order
compatibility with mods that already set them.

The single CVAR that still does anything:

| CVAR | Default | Effect |
|---|---|---|
| `sv_allowbossmap` | `0` | Server CVAR. When `1`, [`src/mapdetection.acs`](src/mapdetection.acs) skips the `EvidenceChecker*` spawns on certain Doom 1 boss maps so a boss-aware gameplay mod can take them over without UME's decorations interfering. |

The following CVARs are **declared but inert** in this build:
`MES_isrunningzandronum`, `MES_disabledecorations`, `MES_disablemapenhancements`,
`MES_disablewaterripples2`, `MES_voxeldec`, `MES_bloodamount`,
`MES_lowgraphicsmode`, `MES_infinitecasings`, `MES_footstepsounds`. The
DECORATE actors that used to consult them via the BDCVARS Janitor scripts
will silently fall through to their default state.

Blood intensity *is* still configurable, but it reads the **gameplay mod's**
CVARs (`bd_bloodamount` for Brutal Doom on Zandronum, `zdoombrutalblood` for
ZDoom-family ports), not anything declared here.

---

## What's in the box

```
UME-Lite/
|-- decorate.txt              -> standalone DECORATE root (full)
|-- decorate/                 -> 26 .txt files: gore, decorations,
|                                map detection, particles, casings,
|                                compataliases, ...
|-- src/                      -> ACS source: bdcvars.acs, dynamiclev.acs,
|                                mapdetection.acs
|-- acs/                      -> compiled ACS libraries (.o)
|-- loadacs                   -> "DYNAMICLEV  BDCVARS  MapDetection"
|                                (case-insensitive ACS library names)
|-- cvarinfo                  -> server / user CVARs (mostly inert,
|                                see Configuration above)
|-- gldefs                    -> dynamic lights & glow definitions
|-- doomdefs.bm               -> brightmap definitions for Doom sprites
|-- modeldef.txt              -> MD3 / MD2 model bindings
|                                (effects + decorations, single lump)
|-- sndinfo.txt               -> sound aliases, $rolloff, $random, $limit
|                                (single lump; was sndinfo.bd + sndinfo.terrain)
|-- sprites/, models/, sounds/, voxels/,
|   brightmaps/               -> shipped runtime assets
|-- scripts/                  -> dev-only helpers (lowercase rename, etc.)
|-- acc-1.60-win32/           -> dev-only: ACS compiler (gitignored)
`-- .gitignore
```

There is **no** `MAPINFO`, `KEYCONF`, `ANIMDEFS`, `TERRAIN`,
`DECALDEF.Terrain`, `textures.*`, `music/`, `graphics/`, `patches/`,
`announcer/`, or any bundled `*.wad` in this repository.

> **File-naming conventions.** All directories and most filenames are
> **lowercase**. Files inside `sprites/` and `sounds/` are an exception:
> they use **UPPERCASE base names with lowercase extensions** (e.g.
> `BARIA0.png`, `EXPLODE1.ogg`). This matches the Doom-modding convention
> that the base name corresponds to the lump name. The directories
> `sprites/` and `sounds/` themselves are lowercase.

---

## Compatibility

- **Single-player & cooperative**: works on GZDoom and UZDoom.
- **Deathmatch**: the deathmatch-aware code paths (`CheckIfDM`, low-graphics
  fallback, casing limits) are now empty stubs, so deathmatch behaves the
  same as single-player. There is no automatic downgrade.
- **Zandronum**: the cross-port branch in `BD_CheckBloodIntensity` still
  works, but it reads `isrunningzandronum` (without the `MES_` prefix);
  whether that CVAR is set depends on the gameplay mod / server config you
  run alongside this.
- **Custom WADs**: UME-Lite has complete decoration support only for Doom 1 /
  Doom 2 maps it positively recognises by signature, so unknown PWADs are
  usually left untouched. If a megawad
  shares a par time *and* player-1 start coordinates with a vanilla map you
  may see decorations placed in the wrong room. There is currently no
  user-facing way to disable enhancements (the `MES_disablemapenhancements`
  CVAR no longer wires through), so the workaround is to repackage without
  this mod.

- **Linux & PK3 portability**: file paths in `decorate.txt`, `modeldef.txt`,
  and `doomdefs.bm` are case-sensitive on Linux and inside zipped PK3s.
  This tree uses lowercase paths and lowercase filenames everywhere except
  inside `sprites/` and `sounds/` (UPPERCASE base + lowercase extension),
  so it loads cleanly in either environment. Keep this convention when
  adding new files.

---

## Modifying

If you'd like to extend UME-Lite, fill in an empty Janitor body, add a new
map detection, drop in a new decoration, or wire texture replacement back up
read [AGENTS.md](AGENTS.md) first. It walks through the load order, the
EvidenceChecker -> DecorationSpawn pattern, the (now mostly empty) Janitor
CVAR scripts, and how to recompile ACS with the bundled
`acc-1.60-win32/acc.exe`.

External references for the engine APIs in use:

- ZDoom Wiki - [DECORATE](https://zdoom.org/w/index.php?title=DECORATE_format_specifications),
  [actor properties](https://zdoom.org/w/index.php?title=Actor_properties),
  [actor flags](https://zdoom.org/w/index.php?title=Actor_flags),
  [actor states](https://zdoom.org/w/index.php?title=Actor_states),
  [action functions](https://zdoom.org/w/index.php?title=Action_functions),
  [classes](https://zdoom.org/w/index.php?title=Classes),
  [DECORATE expressions](https://zdoom.org/w/index.php?title=DECORATE_expressions).
- [zdoom-docs (stable)](https://github.com/zdoom-docs/stable) - authoritative
  language reference.
- [UZDoom 4.14.3 source](https://github.com/UZDoom/UZDoom/tree/4.14.3) -
  versioned engine code matching this project's compatibility floor.

---

## Credits

UME-Lite is a stripped-down, gameplay-mod-friendly derivative of work by:

- **Sergeant Mark IV**: original *Brutal Doom Map Enhancement System*,
  decorations, gore, vehicles (since removed in this fork), and deathmatch
  maps (since removed).
- **BROS_ETT_311**: the rewritten signature-based map detection in
  [`src/mapdetection.acs`](src/mapdetection.acs), plus the GZDoom / LZDoom /
  Zandronum compatibility pass.
- **TDRR** and **Kaminsky**: additional help on the detection rewrite (see
  in-source comments).

The original asset comments ask that you credit the authors if you reuse
material from this mod. Please do.

---

## License & reuse

This add-on bundles assets from third parties under the terms set out in the
in-source comments. If you fork or redistribute, keep the credit headers
intact and follow the original authors' wishes; at minimum, give credit and
ask before reusing custom assets in your own WAD.
