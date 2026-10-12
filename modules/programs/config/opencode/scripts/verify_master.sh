#!/usr/bin/env bash
# verify_master.sh - mandatory post-transcode verification.
# Usage: verify_master.sh OUTPUT.mov [SOURCE.m4v]
# Exits non-zero if the master is broken or its audio is truncated.
#
# A silent ffmpeg decode is NOT sufficient: truncated audio decodes silently.
# This checks per-stream durations and audio byte counts.

set -uo pipefail
OUT="${1:?usage: verify_master.sh OUTPUT.mov [SOURCE.m4v]}"
SRC="${2:-}"
FAIL=0

if [ ! -s "$OUT" ]; then
  echo "FAIL: missing or empty: $OUT"
  exit 1
fi

echo "=== verifying: $OUT"
echo "size: $(ls -lh "$OUT" | awk '{print $5}')"
echo

# Duration of one stream, falling back to the container value.
# Matroska/WebM (and fragmented MP4) store duration at container level only, so
# per-stream duration probes return "N/A". Comparing against that produced a
# false "FAILED - do not use this master" on a verified-good 9s meme clip.
dur() { # dur <file> <v:0|a:0>
  local d
  d=$(ffprobe -v error -select_streams "$2" -show_entries stream=duration \
        -of csv=p=0 "$1" 2>/dev/null)
  case "$d" in
    ''|N/A|n/a) d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$1" 2>/dev/null) ;;
  esac
  printf '%s' "$d"
}

# ---- video ----
VD=$(dur "$OUT" v:0)
VC=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$OUT" 2>&1)
echo "video: codec=$VC duration=$VD"
case "$VD" in
  *Invalid*|*error*|*moov*) echo "FAIL: video stream unreadable"; FAIL=1 ;;
esac

# ---- audio ----
AD=$(dur "$OUT" a:0)
AC=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$OUT" 2>&1)
echo "audio: codec=$AC duration=$AD"
case "$AD" in
  *Invalid*|*error*|*moov*) echo "FAIL: audio stream unreadable"; FAIL=1 ;;
esac

# ---- audio duration vs video duration (catches truncation) ----
if [ "${FAIL}" -eq 0 ]; then
  SHORT=$(awk -v a="$AD" -v v="$VD" 'BEGIN{d=v-a; if(d<0)d=-d; print d}')
  echo "audio-vs-video gap: ${SHORT}s"
  if awk -v a="$AD" -v v="$VD" 'BEGIN{exit !(a+1 < v)}'; then
    echo "FAIL: AUDIO TRUNCATED - audio is over 1s shorter than video"
    FAIL=1
  fi
fi

# ---- audio byte counts, PER STREAM (proves samples exist end to end) ----
# OBS records 2 audio tracks since 2026-10-12. `-map 0:a` maps every stream into a
# single-stream s16le muxer, which errors and yields 0 bytes - a false FAIL.
# Loop one stream at a time instead.
NA=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$OUT" 2>/dev/null | grep -c .)
: "${NA:=0}"
echo "audio tracks: $NA"
if [ "${FAIL}" -eq 0 ]; then
  an=0
  while [ "$an" -lt "$NA" ]; do
    ADn=$(dur "$OUT" "a:$an")
    BN=$(ffmpeg -v error -i "$OUT" -map 0:a:$an -f s16le - 2>/dev/null | wc -c)
    EN=$(awk -v d="$ADn" 'BEGIN{printf "%d", d*48000*2*2}')
    PN=$(awk -v b="$BN" -v e="$EN" 'BEGIN{if(e>0)printf "%.1f", b*100/e; else print 0}')
    echo "audio[$an] bytes: $BN  expected: $EN  -> ${PN}%"
    if awk -v b="$BN" -v e="$EN" 'BEGIN{exit !(b < e*0.99)}'; then
      echo "FAIL: audio track $an bytes below 99% of duration-implied size"
      FAIL=1
    fi
    an=$((an+1))
  done
fi

# ---- audio probe near the end, PER STREAM (direct truncation test) ----
if [ "${FAIL}" -eq 0 ]; then
  an=0
  while [ "$an" -lt "$NA" ]; do
    ADn=$(dur "$OUT" "a:$an")
    PROBE=$(awk -v d="$ADn" 'BEGIN{s=d-60; if(s<0)s=0; printf "%.0f", s}')
    PB=$(ffmpeg -v error -ss "$PROBE" -i "$OUT" -map 0:a:$an -t 5 -f s16le - 2>/dev/null | wc -c)
    echo "audio[$an] probe at ${PROBE}s (5s): $PB bytes"
    if [ "$PB" -eq 0 ]; then
      echo "FAIL: no audio decodes near the end of track $an"
      FAIL=1
    fi
    an=$((an+1))
  done
fi

# ---- moov atom ----
MOOV=$(python3 - "$OUT" <<'EOF'
import struct,sys,os
p=sys.argv[1]; size=os.path.getsize(p); f=open(p,'rb'); off=0
while off<size:
    f.seek(off); h=f.read(8)
    if len(h)<8: break
    bs=struct.unpack('>I',h[:4])[0]; t=h[4:8].decode('latin1','replace')
    if bs==1: bs=struct.unpack('>Q',f.read(8))[0]
    elif bs==0: bs=size-off
    if t=='moov': print('yes'); break
    off+=bs
else: print('no')
EOF
)
echo "moov atom present: $MOOV"
[ "$MOOV" = "yes" ] || { echo "FAIL: moov missing - file not finalised"; FAIL=1; }

# ---- compare against source if given ----
if [ -n "$SRC" ] && [ -s "$SRC" ]; then
  echo
  SV=$(dur "$SRC" v:0)
  SA=$(dur "$SRC" a:0)
  echo "source video: $SV"
  echo "source audio: $SA"
  awk -v a="$AD" -v s="$SA" 'BEGIN{d=(a-s); if(d<0)d=-d; if(d>1){print "FAIL: audio duration differs from source by "d"s"; exit 1}}' || FAIL=1
  awk -v v="$VD" -v s="$SV" 'BEGIN{d=(v-s); if(d<0)d=-d; if(d>1){print "FAIL: video duration differs from source by "d"s"; exit 1}}' || FAIL=1
fi

# ---- decode check ----
echo
echo "full decode (video+audio):"
DEC=$(ffmpeg -v error -i "$OUT" -f null - 2>&1)
if [ -n "$DEC" ]; then
  echo "$DEC" | head -10
  echo "FAIL: decode produced errors"
  FAIL=1
else
  echo "  decode clean"
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: OK - video and audio both complete"
  exit 0
else
  echo "RESULT: FAILED - do not use this master"
  exit 1
fi