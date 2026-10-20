# Video Editor (Claude skill + HyperFrames)

Reusable video editing workflow for Claude Code: **brief → storyboard → approval → build → review → fix → export.**
Supports Talking Head, SaaS/Product, Faceless and Explainer videos in 9:16, 16:9, 1:1 and 4:5.

## Setup (once)

```bash
npm install                      # installs hyperframes + gsap locally
mkdir -p vendor && cp node_modules/gsap/dist/gsap.min.js vendor/
npx hyperframes doctor           # needs Node 22+, ffmpeg, a Chrome/Chromium
npx hyperframes browser ensure   # or: export HYPERFRAMES_BROWSER_PATH=/path/to/chrome
```

Open this folder in Claude Code — the skill in `.claude/skills/video-editor/` activates automatically.

## Use

Tell Claude:

```
Use the video-editor skill.
Company: … | Video type: … | Goal: … | Duration: … s | Format: 9:16
Voiceover: Yes/No | Music: Yes/No | Sound design: Yes/No
Brand colours: … | Font: … | References: … | Assets: … | Editing style: … | CTA: …
Build the storyboard first. Do not invent claims, branding or information.
```

Drop your files in `projects/<name>/assets/` (footage, logo, images, screenshots, audio, refs).

## Layout

```
.claude/skills/video-editor/
  SKILL.md                 workflow + rules
  references/              talking-head, saas-product, faceless-explainer, storyboard, export presets
  scripts/new-project.sh   scaffold a project
  scripts/silence-cut.sh   auto silence removal (ffmpeg)
  scripts/render.sh        lint + render via HyperFrames
  templates/brief.md
projects/<name>/           brief.md, storyboard.md, STATUS.md, assets/, edit/, composition/, exports/
```

HyperFrames (Apache-2.0) is used as an npm dependency; the upstream repo is not modified.
