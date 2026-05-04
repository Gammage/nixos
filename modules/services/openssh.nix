{ flake.modules.nixos.openssh = { ... }: {
  
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true; # Temporary for recovery
      KbdInteractiveAuthentication = false;
      MaxAuthTries = 2;
    };
  };

}; }
