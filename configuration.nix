# Originally taken from:
# https://github.com/Misterio77/nix-starter-configs/blob/cd2634edb7742a5b4bbf6520a2403c22be7013c6/minimal/nixos/configuration.nix
# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  # inputs,
  # lib,
  # config,
  pkgs,
  ...
}:
{
  imports = [
    # You can import other NixOS modules here.
    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
  ];

  # Enable flakes: https://nixos.wiki/wiki/Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.channel.enable = false;

  services.pulseaudio.enable = true;
  virtualisation.docker.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no"; # Recommended for security
    };
  };

  # Search for additional packages here: https://search.nixos.org/packages
  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  programs.ssh = {
    startAgent = true;
  };

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    itcalde = {
      isNormalUser = true;

      linger = true;
      extraGroups = [
        "wheel"
        "audio"
        "docker"
      ];

      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAuSEf//2a4x+eTqtmhNfQuTJ0vMmGSq5En6FAsxTUYPauzXmH59sG/SRryZpsQq+nGEZLfQ1R2mAq8M71ZJPCCOoYTN3yxdyCpjlodva7+5PpTvE9KQmThlm9Y+RL8dVq413uEwlav2kLa0RBsx10i2vcVMJ1FKno7mQz5/u6G3CXt++YJoPWoNVPIxIIefUot2kj9b2b7wf4EuWPOr5noH41N/E67/1OqfItqaaSGgP9ky9qCKdrI8J1ukhSDsvxmlF/f0kgpl6KVAEpx0/qfVsBoR5BBuNJg8gcWUso0Y92D+7sWULKXZV69Ka4uJ93HqCrKkd1iQpGOO/n6VCRkQ== itcalde@wombatzone.localdomain"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
