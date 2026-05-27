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
        let
          pgWithExt = pkgs.postgresql.withPackages (p: [ p.postgis ]);

          pg-start = pkgs.writeShellScriptBin "pg-start" ''
            export PGDATA="''${PGDATA:-$PWD/.pgdata}"
            if [ ! -d "$PGDATA" ]; then
              echo "Initializing PostgreSQL with PostGIS..."
              initdb -D "$PGDATA" --auth=trust --no-locale --encoding=UTF8
              echo "unix_socket_directories = '/tmp'" >> "$PGDATA/postgresql.conf"
            fi
            if ! pg_isready -h /tmp -q 2>/dev/null; then
              pg_ctl -D "$PGDATA" -l "$PGDATA/server.log" -w start
              echo "PostgreSQL started."
            else
              echo "PostgreSQL already running."
            fi
          '';

          pg-stop = pkgs.writeShellScriptBin "pg-stop" ''
            pg_ctl -D "''${PGDATA:-$PWD/.pgdata}" stop
          '';
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              self.formatter.${system}
              wget
              pgWithExt
              pg-start
              pg-stop
              osm2pgsql
              python313
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
              python313Packages.asyncpg
              python313Packages.falcon
              python313Packages.starlette
              python313Packages.uvicorn
              # Developer deps
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

            shellHook = ''
              export PGDATA="$PWD/.pgdata"
              export PGHOST=/tmp
              export PGDATABASE=nominatim
            '';
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}

