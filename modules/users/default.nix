{ flake.modules.nixos.users = { username, ... }: {

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAC9NLUu+CUsoqZmR2eIb5xMnHuv4Bmr3gz1b1MEkahHNoiKvnvlvLiKFxis/zZFG/dzXcwS4e3gRA5WiVrn/MPifwG6NJtyIbcDNq5j9OFiVJz0wm523cxKRH1ZoKEve77jYvpaWfJduh+hkTDK4pJ37x3D3vNHo8h74HiBEqZXA6R4EA== n@xps"
    ];
  };

}; }
