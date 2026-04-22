{
  description = "Porkbun Dynamic DNS Python Application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
        ]);

        porkbun-ddns = pkgs.writeShellApplication {
          name = "porkbun-ddns";
          runtimeInputs = [ pythonEnv ];  # your existing pythonEnv
          text = ''
            exec python ${./porkbun_ddns.py} "$@"
          '';
        };

        nixDockerImage = nix2containerPkgs.nix2container.buildImage {
          name = "porkbun-ddns";
          tag = "nix";
          maxLayers = 40;

          copyToRoot = [
            (pkgs.buildEnv {
              name = "root";
              paths = [ 
                porkbun-ddns
                pkgs.nano 
                pkgs.busybox 
              ];
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

        debianDockerImage = pkgs.writeShellScriptBin "porkbun-ddns-debian" ''
          #!/bin/sh
          set -e
          docker buildx build -t porkbun-ddns:debian -f ${./Dockerfile.debian} .
        '';

        alpineDockerImage = pkgs.writeShellScriptBin "porkbun-ddns-alpine" ''
          #!/bin/sh
          set -e
          docker buildx build -t porkbun-ddns:alpine -f ${./Dockerfile.alpine} .
        '';

        buildAllDockerImages = pkgs.writeShellScriptBin "build-all-docker" ''
          #!/bin/sh
          set -e
          ${nixDockerImage.copyToDockerDaemon}/bin/copy-to-docker-daemon
          ${debianDockerImage}/bin/porkbun-ddns-debian
          ${alpineDockerImage}/bin/porkbun-ddns-alpine
        '';

      in
      {
        packages = {
          default = porkbun-ddns;
          porkbun-ddns = porkbun-ddns;
          build-docker-nix = nixDockerImage.copyToDockerDaemon;
          build-docker-debian = debianDockerImage;
          build-docker-alpine = alpineDockerImage;
          build-docker-all = buildAllDockerImages;
        };

        apps = {
          default = {
            type = "app";
            program = "${porkbun-ddns}/bin/porkbun-ddns";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            pythonEnv
            ruff
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