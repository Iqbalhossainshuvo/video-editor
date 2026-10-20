---
name: video-editor
description: Reusable video editing workflow for talking-head, SaaS/product, faceless and explainer videos. Use when the user wants to plan, storyboard, edit, animate, review or export a video in this repository. Collects the brief, builds a storyboard for approval, then builds with HyperFrames + ffmpeg and exports.
---

# Video Editor

A brief → storyboard → approval → build → review → fix → export pipeline.
Rendering engine: **HyperFrames** (HTML + GSAP → MP4), plus **ffmpeg** for cutting,
silence removal, audio mixing and final encodes.

## Golden rules

1. **Never invent claims, stats, testimonials, logos, brand colours or fonts.** Use only what
   the brief and `assets/` provide. If something is missing, ask or leave a clearly marked
   placeholder (`[[CTA TEXT]]`) — never a made-up value.
2. **Storyboard first.** Do not render the final video until the user approves `storyboard.md`.
3. **Reference workflows are guidance, not templates.** Adapt pacing, style and structure to
   the project's video type, platform and goal.
4. **Everything local.** Vendor scripts (GSAP) are copied into the project; no CDN links in
   compositions (renders must work offline). Never modify upstream HyperFrames source.

## Step 1 — Start or resume a project

```bash
bash .claude/skills/video-editor/scripts/new-project.sh <slug> <format>   # format: 9x16 | 16x9 | 1x1 | 4x5
```

This creates `projects/<slug>/` with `brief.md`, `assets/{footage,logo,images,screenshots,audio,refs}`,
`edit/`, `composition/` (HyperFrames project, GSAP vendored) and `exports/`.
If `projects/<slug>/` already exists, read `brief.md`, `storyboard.md` and `STATUS.md` and resume
from the recorded stage.

## Step 2 — Fill the brief

Fill `brief.md` from the user's message. Required fields: company, video type, goal, duration,
format, voiceover, music, sound design, brand colours, font, references, assets, editing style,
CTA, export spec. Ask only for fields that are missing **and** change the build — batch the
questions into one message. Record answers in `brief.md`.

## Step 3 — Pick the playbook

| Video type | Read | Raw footage |
|---|---|---|
| Talking head | `references/talking-head.md` | Required |
| SaaS / product | `references/saas-product.md` | Optional (screen recordings / screenshots) |
| Faceless / explainer | `references/faceless-explainer.md` | Not needed |

## Step 4 — Storyboard (stop for approval)

Write `projects/<slug>/storyboard.md` using `references/storyboard-template.md`: one row per
scene with time range, visual, on-screen text, VO/script line, motion, audio cue and asset used.
Durations must add up to the brief's duration. Optionally render 3–5 still frames
(`npx hyperframes snapshot`) as a style preview. **Then stop and ask for approval.** Record
`STAGE: storyboard-awaiting-approval` in `STATUS.md`.

## Step 5 — Build (after approval)

1. **Prep footage** (talking head): normalise to H.264/30fps, then cut silences
   `bash .claude/skills/video-editor/scripts/silence-cut.sh in.mp4 edit/cut.mp4 [-35dB] [0.45]`
   and apply manual cuts listed in the storyboard.
2. **Compose** in `composition/index.html` (HyperFrames rules below). One clip element per scene,
   B-roll / captions / graphics on higher `data-track-index` values.
3. **Audio**: VO on its own track; music ducked ~-18 dB under VO; SFX on cuts/reveals only
   where the brief says sound design = yes. Use only audio files the user supplied or licensed.
4. Lint: `npx hyperframes lint` (must be 0 errors).

### HyperFrames essentials

- Root: `<div id="root" data-composition-id="main" data-start="0" data-duration="N" data-width data-height>`
- Every timed element: `class="clip" data-start="s" data-duration="s" data-track-index="n"`
- `<video>`/`<audio>` are clips too; the framework owns playback (don't call `.play()`).
- Animation: one paused GSAP timeline registered as `window.__timelines["main"] = tl;`
  Times are absolute seconds. No `setTimeout`, no `Math.random()` without a seed, no CSS
  animations that aren't seekable.
- Fonts: put font files in `composition/fonts/` and load with `@font-face` (no Google Fonts URL).
- Deep reference (if available): `npx hyperframes docs`, or the upstream skills in
  `~/hyperframes/skills/hyperframes-core/`.

## Step 6 — Review and fix

1. Draft render: `bash .claude/skills/video-editor/scripts/render.sh <slug> draft`
2. `npx hyperframes snapshot` at each scene midpoint and **look at every frame**. Check:
   text inside safe area (platform UI zones for 9:16), legibility/contrast, caption sync,
   no jump cuts left unintentionally, audio levels (`npx hyperframes audio`), CTA on screen ≥2 s,
   duration matches brief, no invented content.
3. Fix, re-render, repeat. Log issues fixed in `STATUS.md`.

## Step 7 — Export

`bash .claude/skills/video-editor/scripts/render.sh <slug> delivery [fps]` then apply the export
preset from `references/export-presets.md` (resolution, fps, codec, bitrate, loudness).
Deliver `exports/<slug>_<format>_<fps>fps.mp4` and verify with `ffprobe`.

## Environment notes

- Render browser: if `npx hyperframes browser ensure` can't download, point at any local Chrome:
  `export HYPERFRAMES_BROWSER_PATH=/path/to/chrome-headless-shell` (`render.sh` auto-detects).
- Transcription for captions needs whisper-cpp (`npx hyperframes doctor` shows status). Without
  it, ask the user for an SRT/script or use the approved VO script for caption timing.
