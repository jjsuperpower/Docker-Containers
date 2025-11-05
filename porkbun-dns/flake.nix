{
  description = "Porkbun Dynamic DNS Python Application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          requests
          nuitka
        ]);

        porkbun-ddns = pkgs.stdenv.mkDerivation {
          pname = "porkbun-ddns";
          version = "1.0.0";
          
          src = "./porkbun_ddns.py";

          buildInputs = [ pythonEnv ];
          buildPhase = ''
            python -m nuitka --no-progressbar --standalone --include-module=requests --static-libpython=yes porkbun_ddns.py
          '';

          # nuitka standalone does not detect that zlib is needed, so we explicitly include it
          installPhase = ''
            mkdir -p $out/dist
            cp -r porkbun_ddns.dist/* $out/dist
            cp ${pkgs.zlib}/lib/* $out/dist
            mv $out/dist/porkbun_ddns.bin $out/dist/porkbun_ddns
          '';
          
          meta = with pkgs.lib; {
            description = "Dynamic DNS client for Porkbun domains";
            license = licenses.bsd3;
            maintainers = [ "Jonathan Sanderson" ];
            platforms = platforms.unix;
          };
        };

        dockerImage = pkgs.dockerTools.buildImage {
          name = "porkbun-ddns";
          tag = "latest";
          
          copyToRoot = pkgs.buildEnv {
            name = "porkbun-ddns-env";
            paths = [ 
              porkbun-ddns 
              pkgs.nano 
              pkgs.busybox 
            ];
          };
          
          config = {
            Cmd = [ "/porkbun-ddns" ];
            Env = [
              "domains_file=/data/domains.txt"
              "interval=60" 
              "log_level=INFO"
              "LD_LIBRARY_PATH=/lib:/lib64"
            ];
            WorkingDir = "/";
          };
          
          runAsRoot = ''
            #!${pkgs.runtimeShell}
            ln -s ${porkbun-ddns}/dist/porkbun_ddns /porkbun-ddns
          '';
        };

      in
      {
        packages = {
          default = porkbun-ddns;
          porkbun-ddns = porkbun-ddns;
          docker = dockerImage;
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