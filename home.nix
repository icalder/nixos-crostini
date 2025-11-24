{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        # email = "you@example.com";
        name = "Iain Calder";
      };
      core = {
        editor = "nvim";
      };
      pull = {
        rebase = true;
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".addKeysToAgent = "yes";
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

  home.packages = with pkgs; [
    vscode
    # LSP server
    nil
    nixfmt-rfc-style
    # Include nodejs by default as it's required by many agents and tools
    nodejs
  ];

  home.sessionVariables = {
    DISPLAY = ":0";
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.05";
}
