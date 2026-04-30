{ flake.modules.nixos.users = { username, ... }: {
  
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # ben@desktop public key: allows desktop → any host SSH access
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOBNbDPljjrG8iIKyMLVxGZvljnVy91RvahYtbmdaOB ben@desktop"
      # ben@laptop public key: allows laptop → any host SSH access
      # TODO: Get this from laptop: ssh ben@laptop "cat ~/.ssh/id_ed25519.pub"
      # Or if laptop is offline, generate a new key on laptop: ssh-keygen -t ed25519 -C "ben@laptop"
      # "ssh-ed25519 <LAPTOP_PUB_KEY> ben@laptop"
    ];
  };

}; }
