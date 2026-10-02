{ flake.modules.homeManager.whisper = { pkgs, ... }:
  {
    home.packages = [
      (pkgs.whisper-cpp.override { vulkanSupport = true; withSDL = false; })
    ];

    # miniaudio returns MA_SUCCESS while decoding only ~20ms from some
    # containers (.mov, and PCM-in-mkv produced by stream copy), so the
    # FFmpeg fallback in read_audio_data is never reached and whisper
    # silently writes an empty SRT. Skipping miniaudio forces FFmpeg.
    home.sessionVariables.WHISPER_COMMON_MINIAUDIO_SKIP = "1";
  };
}