{
  # Good overview of flakes: https://www.tweag.io/blog/2020-05-25-flakes/
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }@inputs:
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
      packages.x86_64-linux =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        in
        rec
        {
          h2o_wave = pkgs.callPackage ./wave.nix { };
          wave = pkgs.callPackage ./waved.nix { };
          ebb = pkgs.callPackage ./ebb.nix { inherit h2o_wave; };
        };

      nixosModules = {
        waved = import ./modules/waved.nix;
      };

      devShells.x86_64-linux =
        {
          default =
            let
              ebbPython = pkgs.python3.withPackages (ps: with ps; [
                requests
                docopt-ng
                flake8
                black
                staticjinja
                psutil
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
                pkgs.nodePackages.sass
                (pkgs.sqlite.override { interactive = true; })
                # Local webserver
                (pkgs.writeShellApplication {
                  name = "serve";
                  runtimeInputs = with pkgs; [ python310 ];
                  text = ''
                    python -m http.server 8000 --directory ./build
                  '';
                })
              ];
            };
        };
    };
  # Bold green prompt for `nix develop`
  # Had to add extra escape chars to each special char
  nixConfig.bash-prompt = "\\[\\033[01;32m\\][nix-flakes \\W] \$\\[\\033[00m\\] ";

}
