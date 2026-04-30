{ flake.modules.nixos.users = { username, ... }: {
  
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOBNbDPljjrG8iIKyMLVxGZvljnVy91RvahYtbmdaOB ben@MainPC"
    ];
  };

}; }
