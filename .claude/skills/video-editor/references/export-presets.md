# Export presets

| Platform | Res | FPS | Codec | Video bitrate | Audio | Loudness |
|---|---|---|---|---|---|---|
| Reels / TikTok / Shorts (9:16) | 1080×1920 | 30 | H.264 High, yuv420p | 12–16 Mbps | AAC 320k 48 kHz | -14 LUFS |
| YouTube (16:9) | 1920×1080 (or 3840×2160) | 30 / 60 | H.264 High | 16 Mbps (1080p) / 45 Mbps (4K) | AAC 320k | -14 LUFS |
| LinkedIn / X feed (1:1 or 4:5) | 1080×1080 / 1080×1350 | 30 | H.264 | 8–10 Mbps | AAC 192k | -14 LUFS |
| Website hero / ads | 1920×1080 | 30 | H.264 + WebM (VP9) | 8 Mbps | AAC 192k / Opus | -16 LUFS |
| Master / archive | source | source | ProRes 422 HQ (.mov) | — | PCM | — |

Final encode (from the HyperFrames render):

```bash
ffmpeg -i render.mp4 -c:v libx264 -profile:v high -pix_fmt yuv420p -b:v 14M -maxrate 16M -bufsize 28M \
  -r 30 -movflags +faststart -af loudnorm=I=-14:TP=-1.0:LRA=11 -c:a aac -b:a 320k -ar 48000 out.mp4
```

Verify: `ffprobe -v error -show_entries stream=codec_name,width,height,r_frame_rate -show_entries format=duration out.mp4`
