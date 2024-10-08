{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }:
    let
      forAllSystems =
        nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
    in {
      packages = forAllSystems (system: rec {
        default = firmware;

        firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
          name = "firmware";

          src = nixpkgs.lib.sourceFilesBySuffices self [
            ".conf"
            ".keymap"
            ".dtsi"
            ".yml"
            ".shield"
            ".overlay"
            ".defconfig"
          ];

          board = "nice_nano_v2";
          shield = "corne_%PART%";

          zephyrDepsHash =
            "sha256-Z5DzSxGTOnLmfh9MDTponS5+rq4e0c9Xeq21GL3MR3s=";

          meta = {
            description = "ZMK firmware";
            license = nixpkgs.lib.licenses.mit;
            platforms = nixpkgs.lib.platforms.all;
          };
        };

        flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
        update = zmk-nix.packages.${system}.update;
      });

      devShells = forAllSystems
        (system: { default = zmk-nix.devShells.${system}.default; });
    };
}
