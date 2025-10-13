{
  description = "Marp presentation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            marp-cli
          ];
        };

        packages.default = pkgs.stdenv.mkDerivation {
          name = "marp-presentation";
          src = ./.;
          buildInputs = [ pkgs.marp-cli ];
          buildPhase = ''
            marp slides.md -o presentation.html
          '';
          installPhase = ''
            mkdir -p $out
            cp presentation.html $out/
          '';
        };
      }
    );
}

