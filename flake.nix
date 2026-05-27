{
  description = "A minimal flake template that you can adapt to your own project";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

  outputs =
    { self, ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forEachSupportedSystem =
        f:
        lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              self.formatter.${system}
              wget
              postgresql
              postgresqlPackages.postgis
              osm2pgsql
              python313
              # this is nominatim-db
              nominatim
              python313Packages.nominatim-api
              # deps
              python313Packages.psycopg
              python313Packages.python-dotenv
              python313Packages.psutil
              python313Packages.jinja2
              python313Packages.pyicu
              python313Packages.pyyaml
              python313Packages.mwparserfromhell
              python313Packages.pyosmium
              python313Packages.sqlalchemy
              # asyncpg is apparently not necessary since we are using sqlalchemy >= 2.0
              # but we will include it anyways
              python313Packages.asyncpg
              python313Packages.falcon
              python313Packages.starlette
              python313Packages.uvicorn

              # Developer deps:

              python313Packages.flake8
              python313Packages.mypy
              python313Packages.pytest
              python313Packages.pytest-asyncio
              python313Packages.pytest-bdd
              python313Packages.httpx
              python313Packages.asgi-lifespan
              python313Packages.mkdocs
              python313Packages.mkdocstrings
              python313Packages.mkdocs-material
              python313Packages.mkdocs-gen-files
            ];
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
