{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
      inputs.home-manager.follows = "";
    };
  };

  outputs = { self, nixpkgs, disko, agenix }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
        ];
        config = { allowUnfree = true; };
      };
    in
    {
      packages.x86_64-linux = rec {
        h2o_wave = pkgs.callPackage ./nix/pkgs/wave.nix { };
        wave = pkgs.callPackage ./nix/pkgs/waved.nix { };
        ebb = pkgs.callPackage ./nix/pkgs/ebb.nix { inherit h2o_wave; };
      };

      nixosModules = {
        waved = import ./nix/modules/waved.nix;
      };

      nixosConfigurations.hetzner =
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            self.nixosModules.waved
            ./nix/systems/hetzner/config.nix
            ./nix/systems/hetzner/disk-config.nix
          ];
        };

      devShells.x86_64-linux = {
        default =
          let
            ebbPython = pkgs.python3.withPackages (ps: with ps; [
              requests
              docopt-ng
              flake8
              black
            ] ++ [ self.packages.x86_64-linux.h2o_wave ]
            );
            ebbMain = pkgs.writeShellApplication {
              name = "ebb";
              runtimeInputs = [ ebbPython ];
              text = ''
                python -m ebb.cli "$@"
              '';
            };
          in
          pkgs.mkShell {
            buildInputs = [
              ebbPython
              ebbMain
              self.packages.x86_64-linux.wave
              (pkgs.sqlite.override { interactive = true; })
            ];
          };
      };
    };
  # Bold green prompt for `nix develop`
  # Had to add extra escape chars to each special char
  nixConfig.bash-prompt = "\\[\\033[01;32m\\][nix-flakes \\W] \$\\[\\033[00m\\] ";
}
