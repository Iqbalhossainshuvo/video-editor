# Talking Head playbook

Raw footage is required. Priorities, in order:

1. **Clean cuts** – remove false starts, repeated takes, "um/uh" stretches. Prefer cutting on
   a breath or a sentence end. Hide unavoidable jump cuts with a 110–120% punch-in or B-roll.
2. **Pacing** – target 2.5–4 s per visual change for short-form (Reels/TikTok/Shorts), 5–8 s for
   long-form. Hook in the first 1.5 s: the strongest line goes first.
3. **Silence removal** – `scripts/silence-cut.sh` (default threshold -35 dB, min silence 0.45 s,
   keeps 0.08 s padding). Raise to -30 dB for noisy rooms; check for clipped word endings.
4. **B-roll** – only from user-supplied footage/images/screenshots. Cover cuts and illustrate
   nouns the speaker names. 1–3 s per insert.
5. **Captions** – word-by-word or 2–4 word groups, high-contrast, inside the safe area
   (9:16: keep away from bottom 20% and right 12%). Highlight key word in brand colour.
6. **Graphics** – lower-third with name/title on first appearance, keyword pop-ups, simple
   data callouts only for numbers the speaker actually says.
7. **Sound design & music** – whoosh on punch-ins/transitions, subtle pop on caption highlights,
   music bed ducked under VO (-18 to -22 dB relative). Final mix ≈ -14 LUFS for social.

Structure template: Hook (0–3 s) → Problem/context → Main points → Proof (only real proof) → CTA.
