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
        ]);

        porkbun-ddns = pkgs.stdenv.mkDerivation {
          pname = "porkbun-ddns";
          version = "1.0.0";
          
          src = ./.;
          
          buildInputs = [ pythonEnv ];
          
          installPhase = ''
            mkdir -p $out/bin
            cp porkbun_ddns.py $out/bin/porkbun-ddns
            chmod +x $out/bin/porkbun-ddns
            
            # Create wrapper script
            cat > $out/bin/porkbun-ddns-wrapper << EOF
            #!${pkgs.bash}/bin/bash
            exec ${pythonEnv}/bin/python $out/bin/porkbun-ddns "\$@"
            EOF
            chmod +x $out/bin/porkbun-ddns-wrapper
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
            paths = [ porkbun-ddns pkgs.nano pkgs.busybox ];
          };
          
          config = {
            Cmd = [ "${porkbun-ddns}/bin/porkbun-ddns-wrapper" ];
            WorkingDir = "/app";
          };
          
          runAsRoot = ''
            #!${pkgs.runtimeShell}
            mkdir -p /app/data
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
            docker
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