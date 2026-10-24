{ flake.modules.homeManager.yazi = { pkgs, ... }:
  let
    yazi-play = pkgs.writeShellScriptBin "yazi-play" ''
      set -euo pipefail
      ffprobe=${pkgs.ffmpeg}/bin/ffprobe
      mpv=${pkgs.mpv}/bin/mpv

      audio_count() {
        "$ffprobe" -v error -select_streams a -show_entries stream=index -of csv=p=0 "$1" \
          | awk 'END { print NR + 0 }'
      }

      mix_filter() {
        local n=$1 i filter=""
        for ((i = 1; i <= n; i++)); do
          filter+="[aid$i]"
        done
        printf '%s' "''${filter}amix=inputs=''${n}:duration=longest:dropout_transition=0:normalize=0,alimiter=limit=0.95[ao]"
      }

      if [[ $# -eq 0 ]]; then
        echo "usage: yazi-play FILE..." >&2
        exit 1
      fi

      first=$(audio_count "$1")
      same=1
      for f in "$@"; do
        if [[ $(audio_count "$f") -ne $first ]]; then
          same=0
          break
        fi
      done

      if [[ $same -eq 1 && $first -le 1 ]]; then
        exec "$mpv" --force-window -- "$@"
      fi

      if [[ $same -eq 1 ]]; then
        exec "$mpv" --force-window --lavfi-complex="$(mix_filter "$first")" -- "$@"
      fi

      for f in "$@"; do
        n=$(audio_count "$f")
        if [[ $n -le 1 ]]; then
          "$mpv" --force-window -- "$f"
        else
          "$mpv" --force-window --lavfi-complex="$(mix_filter "$n")" -- "$f"
        fi
      done
    '';
  in {
    home.packages = [
      pkgs.mpv
      yazi-play
    ];

    home.file.".config/yazi/yazi.toml".text = ''
      [opener]
      play = [
        { run = "${yazi-play}/bin/yazi-play %s", desc = "Play", for = "linux", orphan = true },
      ]
    '';
  };
}
