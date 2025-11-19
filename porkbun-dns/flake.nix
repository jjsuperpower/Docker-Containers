{
  description = "Porkbun Dynamic DNS Python Application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = { self, nixpkgs, flake-utils, nix2container }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nix2containerPkgs = nix2container.packages.${system};
        
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          requests
          nuitka
        ]);

        porkbun-ddns = pkgs.stdenv.mkDerivation {
          pname = "porkbun-ddns";
          version = "1.0.0";
          
          src = pkgs.lib.cleanSourceWith {
            src = ./.;
            filter = path: type: baseNameOf path == "porkbun_ddns.py";
          };

          nativeBuildInputs = [ pythonEnv ];
          buildPhase = ''
            python -m nuitka --no-progressbar --standalone --include-module=requests --static-libpython=yes porkbun_ddns.py
          '';

          # nuitka standalone does not detect that zlib is needed, so we explicitly include it
          installPhase = ''
            mkdir -p $out/usr/local/porkbun-ddns
            mkdir -p $out/bin
            cp -r porkbun_ddns.dist/* $out/usr/local/porkbun-ddns
            cp ${pkgs.zlib}/lib/* $out/usr/local/porkbun-ddns
            ln -s $out/usr/local/porkbun-ddns/porkbun_ddns.bin $out/bin/porkbun-ddns
          '';
          
          meta = with pkgs.lib; {
            description = "Dynamic DNS client for Porkbun domains";
            license = licenses.bsd3;
            maintainers = [ "Jonathan Sanderson" ];
            platforms = platforms.unix;
          };
        };

        dockerImage = nix2containerPkgs.nix2container.buildImage {
          name = "porkbun-ddns";
          tag = "latest";
          maxLayers = 40;

          copyToRoot = [
            (pkgs.buildEnv {
              name = "root";
              paths = [ 
                porkbun-ddns
                pkgs.nano 
                pkgs.busybox 
              ];
              pathsToLink = [ "/bin" ];
            })
          ];
          
          config = {
            Cmd = [ "/bin/porkbun-ddns" ];
            Env = [
              "domains_file=/data/domains.txt"
              "interval=60" 
              "log_level=INFO"
            ];
            WorkingDir = "/";
          };
        };

      in
      {
        packages = {
          default = porkbun-ddns;
          porkbun-ddns = porkbun-ddns;
          docker = dockerImage.copyToDockerDaemon;
        };

        apps = {
          default = {
            type = "app";
            program = "${porkbun-ddns}/bin/porkbun-ddns-wrapper";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            pythonEnv
            ruff
            python3Packages.pytest
            python3Packages.nuitka
            docker
            pkgs.cacert
            pkgs.zlib
            pkgs.glibc
          ];
          
          shellHook = ''
            echo "Porkbun DDNS Development Environment"
            echo "Python: $(python --version)"
            echo "Available packages: requests"
            echo ""
            echo "Usage:"
            echo "  python porkbun_ddns.py  # Run the script directly"
            echo "  nix run                 # Run via Nix"
            echo "  nix build .#docker      # Build Docker image"
            echo ""
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}