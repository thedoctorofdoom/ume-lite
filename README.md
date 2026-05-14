# UME-Lite

**Universal Map Enhancement System — Lite Edition**

A drop-in add-on for **GZDoom / UZDoom** (and, with caveats, **LZDoom** and
**Zandronum**) that quietly upgrades the look and feel of the classic Doom
campaigns without touching gameplay. Think of it as scenery, weather, and
ambient detail bolted onto vanilla maps — designed to coexist with your
favourite gameplay mod (Brutal Doom, Project Brutality, Demon Steele, etc.).

---

## What it does

When you load a familiar map, UME-Lite recognises it and overlays a curated
set of enhancements on top of the original geometry:

- **Map detection** — every vanilla map of *Doom*, *Doom II*, *Plutonia*,
  *TNT: Evilution*, and *PSX Doom* is identified by a fingerprint of the
  player's start position, par time, and level name. No actor replacements,
  no gameplay-mod conflicts.
- **Decorations on detected maps** — extra props, plant pots, antennae,
  hanging cables, computer lights, light shafts, light posts, destroyable
  windows, and animated waterfalls placed at hand-tuned coordinates.
- **Texture upgrades** — original flats and walls are swapped at runtime for
  higher-detail variants (sand, lava, metal panels, light fixtures, sky
  textures, etc.).
- **Material-aware footsteps & splashes** — different sounds for grass, dirt,
  metal, tile, wood, snow, gravel, and stone; proper splash effects in water,
  blood, slime, nukage, and lava.
- **Brutal-style gore** — configurable blood amount with cinematic gibs,
  blood mist, wall splatter, bouncing limbs, and persistent decals.
- **Particle effects** — sparks, smoke, fire, flares, tracers, and shell
  casings tuned for visual punch without tanking performance.
- **Vehicles** — drivable Tank, Artillery Tank, Mech, Helicopter, and a
  stationary Heavy Machinegun, plus enemy variants. (See *Vehicles* below.)
- **Boss Mode** — an optional toggle that turns E1M8 into a properly menacing
  boss arena with a HUD health bar (`/` key by default).
- **Bonus map sets** — *Brutal Deathmatch* (`BDM01`–`BDM10`) and *PSX Doom*
  maps, registered as their own episodes.
- **HD skies, animated nukage, brightmaps, dynamic lights, and 3D models**
  for select decorations and vehicles.

UME-Lite intentionally ships **no weapons, no monsters, and no player class**.
That's the job of the gameplay mod you load alongside it.

---

## Requirements

| | |
|---|---|
| **Engine** | GZDoom 4.x or UZDoom 4.14.3+ recommended. LZDoom and Zandronum work but with reduced effects. |
| **IWAD** | `doom.wad`, `doom2.wad`, `plutonia.wad`, or `tnt.wad`. PSX Doom maps require the bundled `psxlevels.wad` (already included). |
| **Disk** | ~6 MB unpacked. |

---

## Installation

### Option A — drag & drop (easiest)

1. Zip the **contents** of this folder into `UME-Lite.pk3`
   (everything inside the `UME-Lite/` directory, not the directory itself).
2. Drop `UME-Lite.pk3` onto your `gzdoom.exe` along with your IWAD and any
   gameplay mod you'd like to use.

### Option B — load as a directory

GZDoom can load loose folders directly. From a terminal:

```
gzdoom -iwad doom2.wad -file path/to/UME-Lite/ -file BrutalDoom.pk3
```

Always load **UME-Lite *after* your gameplay mod** so its enhancements layer
on top without being overwritten.

---

## Configuration

UME-Lite exposes a handful of CVARs you can change from the console
(`~` to open) or set in your autoexec:

| CVAR | Default | Effect |
|---|---|---|
| `mes_disabledecorations` | `0` | `1` removes all per-map decorations. |
| `mes_disablemapenhancements` | `0` | `1` disables texture replacement and decoration spawns entirely. |
| `mes_disablewaterripples2` | `0` | `1` turns off rippling water FX. |
| `mes_voxeldec` | `1` | `0` skips voxel-based props (boost FPS). |
| `mes_bloodamount` | `2` | `0` = none, `1` = low, `2` = normal, `3` = lots, `4` = absurd, `5+` = anime gore. |
| `mes_lowgraphicsmode` | `0` | `1` strips most particle FX (for older GPUs / multiplayer). |
| `mes_infinitecasings` | `0` | `1` keeps spent shell casings on the floor forever. |
| `mes_footstepsounds` | `1` | `0` mutes material-aware footsteps. |
| `mes_isrunningzandronum` | `1` | Set automatically; controls cross-port branches. |
| `sv_allowbossmap` | `0` | `1` enables the Boss Mode arena on E1M8 (server CVAR). |

### Boss Mode key

`KEYCONF` adds a *Map Enhancements – Boss Mode* binding (default `/`). Press
it on E1M8 to toggle Boss Mode and reload the map.

---

## Vehicles

| Vehicle | What it is |
|---|---|
| **Tank** | Treaded MBT with a coaxial machine gun and main cannon; fakes terrain pitch on flat floors. |
| **Artillery Tank** | Long-range variant with mortar-style projectiles. |
| **Mech** | Bipedal walker carrying machine gun, rockets, lasers, and mortars. |
| **Helicopter** | Flies; rocket pods + missiles. |
| **Heavy Machine Gun** | Stationary emplacement for fixed defence. |
| **Bike** | Legacy two-wheeler kept for compatibility with older content. |

Vehicles consume their own ammo types (`TankAmmo`, `MechAmmo`, etc., defined
in `DECORATE/UME_Ammo.txt`) and use `SRC/VEHICLECONTROL.acs` to capture
forward / back / strafe / turn input each tic.

---

## Bundled map sets

Defined in `MAPINFO.lmp`:

- **Extermination Day** (`EDAY01`+) — episode hook for the Brutal Doom Ext.
  Day campaign if you have it.
- **Brutal Deathmatch** (`BDM01`–`BDM10`) — Sgt. Mark IV's deathmatch arenas
  shipped in `dmlevels.wad`. Run with:
  ```
  gzdoom -iwad doom2.wad -file UME-Lite/ +map BDM01
  ```
- **PSX Doom maps** (`PSXMAP*`, `PSMAP*`) — selected levels from PSX Doom in
  `psxlevels.wad`, with their original soundtracks.
- `TEST` (*UAC Testing Center*) — a debug sandbox in `testmap.wad`.

---

## What's in the box

```
UME-Lite/
├── DECORATE.txt          → master include for all DECORATE actor files
├── DECORATE/             → ~60 .txt files: gore, vehicles, decorations,
│                           map detection, particles, footsteps, …
├── SRC/                  → ACS source (.acs)
├── ACS/                  → compiled ACS libraries (.o)
├── MAPINFO.lmp           → episode + per-map definitions
├── CVARINFO              → user/server CVARs listed above
├── KEYCONF               → Boss Mode key binding
├── GLDEFS                → dynamic lights & glow definitions
├── ANIMDEFS              → animated flats (HD nukage, etc.)
├── TERRAIN               → splash & terrain definitions
├── DECALDEF.Terrain      → animated decals
├── modeldef*.txt         → MD3 model bindings
├── SNDINFO.*             → sound aliases, rolloff, $random, $limit
├── doomdefs.bm,
│   doomwalls.bm          → brightmap definitions
├── Textures.HDSkies      → HD sky remaps
├── SPRITES/, MODELS/, SOUNDS/, GRAPHICS/,
│   MUSIC/, Textures/, VOXELS/, brightmaps/,
│   PATCHES/, announcer/  → assets
└── *.wad                 → bundled maps & extra textures
```

---

## Compatibility

- **Single-player & cooperative** — fully supported on GZDoom and UZDoom.
- **Deathmatch** — automatically downgrades to a low-graphics path to keep
  network traffic sane. Set `mes_lowgraphicsmode 1` manually if needed.
- **Zandronum** — most features work; some advanced FX are gated behind
  `mes_isrunningzandronum`. K8Vavoom is *not* supported (destructible
  decorations break).
- **Custom WADs** — UME-Lite only enhances maps it positively recognises, so
  unknown PWADs are left untouched. If your favourite megawad shares a par
  time *and* player-1 start coordinates with a vanilla map you may see
  decorations placed in the wrong room — disable enhancements with
  `mes_disablemapenhancements 1` if that happens.

---

## Modifying

If you'd like to extend UME-Lite — add a new map detection, drop in a new
decoration, or tweak the gore — read [AGENTS.md](AGENTS.md) first. It walks
through the load order, the EvidenceChecker → DecorationSpawn pattern, the
Janitor CVAR scripts, and how to recompile ACS with `acc`.

External references for the engine APIs in use:

- ZDoom Wiki — [DECORATE](https://zdoom.org/w/index.php?title=DECORATE_format_specifications),
  [actor properties](https://zdoom.org/w/index.php?title=Actor_properties),
  [actor flags](https://zdoom.org/w/index.php?title=Actor_flags),
  [actor states](https://zdoom.org/w/index.php?title=Actor_states),
  [action functions](https://zdoom.org/w/index.php?title=Action_functions),
  [classes](https://zdoom.org/w/index.php?title=Classes),
  [DECORATE expressions](https://zdoom.org/w/index.php?title=DECORATE_expressions).
- [zdoom-docs (stable)](https://github.com/zdoom-docs/stable) — authoritative
  language reference.
- [UZDoom 4.14.3 source](https://github.com/UZDoom/UZDoom/tree/4.14.3) —
  versioned engine code matching this project's compatibility floor.

---

## Credits

UME-Lite is a stripped-down, gameplay-mod-friendly derivative of work by:

- **Sergeant Mark IV** — original *Brutal Doom Map Enhancement System*,
  vehicles, gore, decorations, deathmatch maps.
- **BROS_ETT_311** — the rewritten signature-based map detection in
  `SRC/MapDetection.acs`, plus the GZDoom / LZDoom / Zandronum compatibility
  pass.
- **TDRR** and **Kaminsky** — additional help on the detection rewrite (see
  in-source comments).

The original asset comments ask that you credit the authors if you reuse
material from this mod. Please do.

---

## License & reuse

This add-on bundles assets from third parties under the terms set out in the
in-source comments. If you fork or redistribute, keep the credit headers
intact and follow the original authors' wishes — at minimum, give credit and
ask before reusing custom assets in your own WAD.
