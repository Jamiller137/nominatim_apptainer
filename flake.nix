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
        f: lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                (final: prev: {
                  libspatialite = prev.libspatialite.overrideAttrs (oldAttrs: {
                    configureFlags = (oldAttrs.configureFlags or []) ++ [ "--enable-module" ];
                    # an issue on darwin: could not find mod_spatialite.dylib
                    # so we install it as a module and make sure it is there
                    postInstall = (oldAttrs.postInstall or "") + ''
                      ls -la $out/lib/
                    '';
                  });
                })
              ];
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
              python313Packages.pip
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
              python313Packages.aiosqlite
              python313Packages.pandas
              python313Packages.numpy
              python313Packages.polars
              sqlite
              spatialite-tools
              libspatialite
              fixDarwinDylibNames
            ];

            shellHook = ''
              export PGDATA="$PWD/.pgdata"
              export PGHOST=/tmp
              export PGDATABASE=nominatim
              export LIBSPATIALITE_PATH="${pkgs.libspatialite}/lib/mod_spatialite"
              export LD_LIBRARY_PATH="${pkgs.libspatialite}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
              export SPATIALITE_LIBRARY="${pkgs.libspatialite}/lib/mod_spatialite.dylib"
              export DYLD_LIBRARY_PATH="${pkgs.libspatialite}/lib''${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
            '';
          };
        }
      );

      packages = forEachSupportedSystem (
        { pkgs, system }:
        {
          container = pkgs.dockerTools.buildNixShellImage {
            name = "nominatim-env";
            tag = "latest";
            drv = self.devShells.${system}.default;
            compressor = "none";
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);

      apps = forEachSupportedSystem (
        { pkgs, system }:
        {
          convert-to-sif = {
            type = "app";
            program = toString (pkgs.writeShellScript "convert-to-sif" ''
              set -euo pipefail
              if [ ! -e result ]; then
                nix build .#container
              fi
              cp -L result nominatim-env.tar.gz
              apptainer pull \
                nominatim-env.sif \
                docker-archive://$PWD/nominatim-env.tar.gz
            '');
          };
        }
      );

    };
}

