#!/usr/bin/env bash
# Remove silences from a talking-head clip.
# Usage: silence-cut.sh <in> <out> [threshold=-35dB] [min_silence=0.45] [pad=0.08]
set -euo pipefail
IN="${1:?input}"; OUT="${2:?output}"; TH="${3:--35dB}"; MIN="${4:-0.45}"; PAD="${5:-0.08}"
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$IN")
ffmpeg -hide_banner -i "$IN" -af "silencedetect=noise=$TH:d=$MIN" -f null - 2> "$OUT.silence.log" || true
python3 - "$OUT.silence.log" "$DUR" "$PAD" > "$OUT.keep.txt" <<'PY'
import re, sys
log, dur, pad = open(sys.argv[1]).read(), float(sys.argv[2]), float(sys.argv[3])
starts = [float(x) for x in re.findall(r"silence_start: ([\d.]+)", log)]
ends = [float(x) for x in re.findall(r"silence_end: ([\d.]+)", log)]
keep, t = [], 0.0
for i, s in enumerate(starts):
    e = ends[i] if i < len(ends) else dur
    a, b = t, min(s + pad, dur)
    if b - a > 0.15: keep.append((a, b))
    t = max(e - pad, 0)
if dur - t > 0.15: keep.append((t, dur))
for a, b in keep: print(f"{a:.3f} {b:.3f}")
PY
N=0; FILTER=""; CONCAT=""
while read -r A B; do
  FILTER+="[0:v]trim=$A:$B,setpts=PTS-STARTPTS[v$N];[0:a]atrim=$A:$B,asetpts=PTS-STARTPTS[a$N];"
  CONCAT+="[v$N][a$N]"; N=$((N+1))
done < "$OUT.keep.txt"
[ "$N" -eq 0 ] && { echo "No speech segments found"; exit 1; }
ffmpeg -hide_banner -y -i "$IN" -filter_complex "${FILTER}${CONCAT}concat=n=$N:v=1:a=1[v][a]" \
  -map "[v]" -map "[a]" -c:v libx264 -crf 18 -preset medium -pix_fmt yuv420p -c:a aac -b:a 192k "$OUT"
NEW=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")
echo "Kept $N segments: ${DUR}s -> ${NEW}s  (segments: $OUT.keep.txt)"
