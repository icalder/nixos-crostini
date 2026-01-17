{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  #programs.git = {
  #enable = true;
  # settings = {
  #   user = {
  #     # email = "you@example.com";
  #     name = "Iain Calder";
  #   };
  #   core = {
  #     editor = "nvim";
  #   };
  #   pull = {
  #     rebase = true;
  #   };
  # };
  #};

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".addKeysToAgent = "yes";
  };

  programs.bash = {
    enable = true;
    # This prepends a 'safe' return to the top of .bashrc so home-manager user systemd script does not fail
    # Could also be done using a case statement
    # case $- in
    #     *i*) ;;
    #       *) return;;
    # esac
    bashrcExtra = ''
      [[ $- == *i* ]] || return 0
    '';
  };

  home.file.".npmrc" = {
    text = ''
      prefix=${config.home.homeDirectory}/.npm-global
    '';
  };

  # Configure another dotfile (e.g., ~/.mycustomrc) ===
  # home.file.".mycustomrc" = {
  #   source = ./dotfiles/mycustomrc; # Path to the file in your config directory
  #   # OR use the text content directly:
  #   # text = ''
  #   #   # Custom settings here
  #   #   export PATH="$HOME/.local/bin:$PATH"
  #   # '';
  # };

  home.packages =
    (with pkgs; [
      vscode
      # LSP server
      nil
      nixfmt
      # Include nodejs by default as it's required by many agents and tools
      nodejs
    ])
    ++ (with pkgs-unstable; [
      deno
    ]);

  home.sessionVariables = {
    DISPLAY = ":0";
  };

  home.sessionPath = [
    # Add custom paths to your $PATH here. For example, if you have a
    # directory where you store your own scripts, you can add it like this:
    # "${config.home.homeDirectory}/bin"
    "${config.home.homeDirectory}/.npm-global/bin"
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.05";
}
