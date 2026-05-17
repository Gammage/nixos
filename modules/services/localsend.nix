{ flake.modules.nixos.localsend = { pkgs, ... }: {

  environment.systemPackages = [ pkgs.localsend ];

  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

}; }
