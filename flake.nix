{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      nixos-generators,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      self,
      ...
    }@inputs:
    let
      # NOTE: change to `x86_64-linux` if that is your architecture.
      targetSystem = "aarch64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        system = targetSystem;
        config.allowUnfree = true;
      };

      # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-flake-and-module-system
      specialArgs = {
        inherit inputs pkgs-unstable;
      };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.itcalde = ./home.nix;
          home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
        }
        # Allow unfree packages
        { nixpkgs.config.allowUnfree = true; }
      ];

      x86l = "x86_64-linux";
      arml = "aarch64-linux";

      # https://ayats.org/blog/no-flake-utils
      forAllSystems = nixpkgs.lib.genAttrs [
        x86l
        arml
      ];

      nixosSystemFor =
        {
          additionalModules,
          targetSystem ? builtins.currentSystem,
        }:
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = modules ++ additionalModules;
          system = targetSystem;
        };

      baguetteSystem =
        {
          targetSystem ? builtins.currentSystem,
        }:
        nixosSystemFor {
          inherit targetSystem;
          additionalModules = [ self.nixosModules.baguette ];
        };

      crostiniSystem =
        {
          targetSystem,
        }:
        nixosSystemFor {
          inherit targetSystem;
          additionalModules = [ self.nixosModules.crostini ];
        };

    in
    {
      packages = forAllSystems (
        system:
        let
          baguette-nixos = baguetteSystem { targetSystem = system; };
        in
        rec {
          lxc = nixos-generators.nixosGenerate {
            inherit system specialArgs modules;
            format = "lxc";
          };
          lxc-metadata = nixos-generators.nixosGenerate {
            inherit system specialArgs modules;
            format = "lxc-metadata";
          };

          lxc-image-and-metadata = nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
            name = "lxc-image-and-metadata";
            dontUnpack = true;

            installPhase = ''
              mkdir -p $out
              ln -s ${lxc-metadata}/tarball/*.tar.xz $out/metadata.tar.xz
              ln -s ${lxc}/tarball/*.tar.xz $out/image.tar.xz
            '';
          };

          baguette-tarball = baguette-nixos.config.system.build.tarball;
          baguette-image = baguette-nixos.config.system.build.btrfsImage;
          baguette-zimage = baguette-nixos.config.system.build.btrfsImageCompressed;

          default = self.packages.${system}.lxc-image-and-metadata;
        }
      );

      checks = forAllSystems (system: {
        inherit (self.outputs.packages.${system}) baguette-tarball lxc-image-and-metadata;
      });

      nixosConfigurations = {
        # This allows you to re-build the image from inside the container/VM.
        # Defaults to `aarch64-linux`.
        lxc-nixos = self.nixosConfigurations.lxc-nixos-arm64l;
        baguette-nixos = self.nixosConfigurations.baguette-nixos-arm64l;

        # Explicitly build for `aarch64-linux`
        lxc-nixos-arm64l = crostiniSystem { targetSystem = arml; };
        baguette-nixos-arm64l = baguetteSystem { targetSystem = arml; };

        # Explicitly build for `x86_64-linux`
        lxc-nixos-x86l = crostiniSystem { targetSystem = x86l; };
        baguette-nixos-x86l = baguetteSystem { targetSystem = x86l; };
      };

      nixosModules = rec {
        crostini = ./crostini.nix;
        baguette = ./baguette.nix;
        default = crostini;
      };

      templates.default = {
        path = self;
        description = "nixos-crostini quick start";
      };
    };
}
