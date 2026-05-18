{ flake.modules.homeManager.moltenPython = { pkgs, config, ... }:

let
  moltenPython = pkgs.python3.withPackages (ps: with ps; [
    pynvim       # Neovim bridge Python (g:molten_python_path)
    ipykernel    # Jupyter kernel launcher
    pandas       # data analysis
    numpy        # data analysis
    matplotlib   # plotting
  ]);
in {
  # Symlink a reproducible Python environment to ~/.venv/molten

  home.file.".venv/molten" = {
    source = moltenPython;
  };

  # Register it as a Jupyter kernel so :MoltenInit can find it

  home.file.".local/share/jupyter/kernels/molten/kernel.json" = {
    text = ''
      {
        "argv": [
          "${config.home.homeDirectory}/.venv/molten/bin/python3",
          "-m",
          "ipykernel_launcher",
          "-f",
          "{connection_file}"
        ],
        "display_name": "Python 3 (molten)",
        "language": "python"
      }
    '';
  };
}; }
