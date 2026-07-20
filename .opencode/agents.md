# Agent Instructions

## Video Clip Conversion for DaVinci Resolve

When the user requests to reformat or convert video clips for DaVinci Resolve, follow these instructions:

### Trigger Phrases
- "reformat videos for davinci"
- "convert clips for davinci"
- "prepare videos for editing"
- "format phone clips"
- Any similar request about converting video files for use in DaVinci Resolve

### Source Files
- Location: `~/Downloads/` or subfolders within Downloads
- Format: Phone-recorded `.mov` files (Apple ProRes HQ codec)
- These are typically large files (several GB each)

### Conversion Settings
- **Output codec**: ProRes 422 (not HQ - saves space while maintaining quality)
- **Output format**: `.mov` container
- **Audio**: PCM 16-bit signed little-endian (`pcm_s16le`)
- **Sample rate**: Preserve original (typically 48000 Hz)
- **Channels**: Preserve original (typically 2ch stereo)

### FFmpeg Command Template
```bash
ffmpeg -i INPUT.mov -c:v prores_ks -profile:v 2 -c:a pcm_s16le OUTPUT.mov
```

- `-c:v prores_ks` - Use the high-quality ProRes encoder
- `-profile:v 2` - ProRes 422 Standard profile (0=proxy, 1=LT, 2=422, 3=HQ)
- `-c:a pcm_s16le` - PCM audio matching original quality

### Destination
- Move converted files to: `~/Videos/`
- Maintain original filename (change extension from any format to `.mov`)
- If a file with the same name exists, ask the user before overwriting

### Workflow
1. Identify source `.mov` files in `~/Downloads/` or user-specified location
2. Convert each file using the FFmpeg command above
3. Move the converted file to `~/Videos/`
4. Report completion with file sizes and location

### Notes
- The original phone recordings are ProRes HQ which DaVinci accepts but files are very large
- Converting to ProRes 422 reduces file size significantly while remaining professional quality
- For YouTube clips (H.265/HEVC in MP4), use: `ffmpeg -i input.mp4 -c:v prores_ks -profile:v 2 -c:a pcm_s16le output.mov`

---

## Video Export for YouTube

When the user has finished editing in DaVinci and wants to prepare videos for YouTube upload, follow these instructions:

### Trigger Phrases
- "export for youtube"
- "prepare for youtube upload"
- "convert for youtube"
- "ready for youtube"
- Any similar request about converting edited videos for YouTube

### Source Files
- Location: `~/Videos/` (edited ProRes files from DaVinci)
- Format: `.mov` files (ProRes 422 or ProRes HQ)

### Conversion Settings
- **Output codec**: H.264 (MP4 container) - universally accepted by YouTube
- **Output format**: `.mp4`
- **Audio**: AAC at 256 kbps
- **CRF**: 18 (high quality, YouTube will re-encode anyway)
- **Preset**: slow (better compression)

### FFmpeg Command Template
```bash
ffmpeg -i INPUT.mov -c:v libx264 -crf 18 -preset slow -c:a aac -b:a 256k OUTPUT.mp4
```

- `-c:v libx264` - H.264 encoder
- `-crf 18` - Constant Rate Factor (lower = better quality, 18 is visually lossless)
- `-preset slow` - Better compression efficiency
- `-c:a aac -b:a 256k` - AAC audio at 256 kbps

### Destination
- Move converted files to: `~/Videos/`
- Append `_youtube` to filename (e.g., `20260712_135905_youtube.mp4`)
- If a file with the same name exists, ask the user before overwriting

### Cleanup
- **Delete the source ProRes `.mov` files after successful conversion**
- ProRes files are very large (often 5-15 GB each)
- Always confirm with user before deleting
- Report space freed

### Workflow
1. Identify source `.mov` files in `~/Videos/` or user-specified location
2. Convert each file using the FFmpeg command above
3. Save converted `.mp4` to `~/Videos/` with `_youtube` suffix
4. Ask user to confirm deletion of source ProRes files
5. Delete confirmed files and report space saved
