#!/usr/bin/env bash
# Usage: render.sh <slug> [draft|looks|delivery] [fps=30]
set -euo pipefail
SLUG="${1:?slug}"; Q="${2:-draft}"; FPS="${3:-30}"
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
P="$ROOT/projects/$SLUG"; C="$P/composition"
if [ -z "${HYPERFRAMES_BROWSER_PATH:-}" ]; then
  for b in /opt/pw-browsers/chromium_headless_shell-*/chrome-linux/headless_shell \
           "$HOME"/.cache/ms-playwright/chromium_headless_shell-*/chrome-linux/headless_shell \
           /usr/bin/google-chrome /usr/bin/chromium; do
    [ -x "$b" ] && { export HYPERFRAMES_BROWSER_PATH="$b"; break; }
  done
fi
cd "$C"
npx --prefix "$ROOT" hyperframes lint
OUT="$P/exports/${SLUG}_${Q}_${FPS}fps.mp4"
npx --prefix "$ROOT" hyperframes render -q "$Q" -f "$FPS" -o "$OUT"
ffprobe -v error -show_entries stream=codec_name,width,height,r_frame_rate -show_entries format=duration "$OUT"
echo "Rendered: $OUT"
