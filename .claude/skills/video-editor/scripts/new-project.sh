#!/usr/bin/env bash
# Usage: new-project.sh <slug> <format: 9x16|16x9|1x1|4x5> [duration_seconds]
set -euo pipefail
SLUG="${1:?slug required}"; FORMAT="${2:-9x16}"; DUR="${3:-30}"
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
SKILL="$ROOT/.claude/skills/video-editor"
P="$ROOT/projects/$SLUG"
case "$FORMAT" in
  9x16) W=1080; H=1920 ;; 16x9) W=1920; H=1080 ;; 1x1) W=1080; H=1080 ;; 4x5) W=1080; H=1350 ;;
  *) echo "Unknown format $FORMAT"; exit 1 ;;
esac
[ -e "$P" ] && { echo "Project exists: $P (resume it)"; exit 0; }
mkdir -p "$P"/{assets/{footage,logo,images,screenshots,audio,refs},edit,exports,composition/{vendor,fonts,media}}
sed -e "s/{{PROJECT}}/$SLUG/" -e "s/{{FORMAT}}/$FORMAT ($W×$H)/" "$SKILL/templates/brief.md" > "$P/brief.md"
cp "$ROOT/vendor/gsap.min.js" "$P/composition/vendor/"
cat > "$P/composition/hyperframes.json" <<EOF
{ "name": "$SLUG" }
EOF
cat > "$P/composition/index.html" <<EOF
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=$W, height=$H" />
<script src="vendor/gsap.min.js"></script>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: ${W}px; height: ${H}px; overflow: hidden; background: #000; }
  #root { position: relative; width: 100%; height: 100%; font-family: system-ui, sans-serif; }
  .clip { position: absolute; }
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="$DUR" data-width="$W" data-height="$H">
  <!-- scenes go here: <div class="clip" data-start="0" data-duration="3" data-track-index="1">…</div> -->
</div>
<script>
  const tl = gsap.timeline({ paused: true });
  window.__timelines["main"] = tl;
  tl.seek(0);
</script>
</body>
</html>
EOF
echo "STAGE: brief" > "$P/STATUS.md"
echo "Created $P"
