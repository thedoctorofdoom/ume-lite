# Universal Map Enhancement System Lite (UME Lite)

**Universal Map Enhancement System - Lite Edition**

A drop-in, decoration-only add-on for **GZDoom / UZDoom** (and, with caveats,
**LZDoom** and **Zandronum**) that quietly adds props, gore, and ambient detail
to the original Doom and Doom II campaigns. It is meant to load alongside
gameplay mods and never replaces vanilla actors.

---

## What this mod does

UME-Lite is an **ambient layer**: it recognizes the classic **Doom** and **Doom
II** IWAD episodes and lays extra scenery onto those layouts—pots, lamps,
cables, small props, and similar touches tuned per map—without editing the maps
themselves or replacing the monsters and pickups you already have from the IWAD
or another mod.

Alongside that, it adds richer **battlefield clutter**—blood pools and splatter,
chunks and body decoration, sparks, smoke, shell casings, and other incidental
effects. Gore strength follows **your gameplay mod's** usual blood CVARs when
those are present, not UME-Lite's own `MES_*` settings (most of those are only
there for backwards compatibility).

Visually it leans on **models, glows / dynamic lights, and brightmaps** where
those assets apply. Almost everything is ornamental: besides a lone mummy and
a small critter actor, **you still bring weapons, monsters, progression, and
maps** via the IWAD and whatever else you load.

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
   When zipping, exclude `src/`, `scripts/`, `.git/`, `.cursor/`, and any
   local **ACS compiler** folder you keep for development (not needed at
   runtime).
2. Drop `UME.pk3` onto your `gzdoom.exe` along with your IWAD and any
   gameplay mod you'd like to use.

### Option B - load as a directory

GZDoom can load loose folders directly:

```
gzdoom -iwad doom2.wad -file gameplaymod.pk3 -file path/to/UME-Lite/
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
CVARs (`bd_bloodamount` on Zandronum, `zdoombrutalblood` on other
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
|                                (single SNDINFO lump)
|-- sprites/, models/, sounds/, voxels/,
|   brightmaps/               -> shipped runtime assets
|-- scripts/                  -> dev-only helpers (lowercase rename, etc.)
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
CVAR scripts, and how to recompile ACS (**ACC**, from [ZDoom downloads](https://zdoom.org/downloads); see **Editing** on that page).

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

UME-Lite is a gameplay-mod-friendly project that builds on work by:

- **Sergeant Mark IV**: original *Universal Map Enhancement System* lineage,
  decorations, and gore.
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
