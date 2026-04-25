{ flake.modules.nixos.users = { username, ... }: {

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

}; }
