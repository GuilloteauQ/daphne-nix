{
  description = "Daphne experiments";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    daphne-nix.url = "github:GuilloteauQ/daphne-nix";
  };

  outputs = { self, nixpkgs, daphne-nix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      mySrc = pkgs.fetchFromGitHub {
        owner = "GuilloteauQ";
        repo = "daphne";
        rev = "6e9ece6e34a7be7c8dd9f3bebfbdb681ef4bddbe";
        sha256 = "sha256-mDjCnTYjQZchimGGSKKBMadMBqDsQ2ROf/CG4EQMIh4=";
      };
    in {
      packages.${system} = rec {
        daphne = daphne-nix.packages.${system}.daphne.overrideAttrs (finalAttrs: previousAttrs: {
          src = mySrc;
          version = previousAttrs.version + "-expes";
        });
        daphne-singularity = pkgs.singularity-tools.buildImage {
          name = "daphne";
          contents = [ daphne ];
          runScript = "${daphne}/bin/daphne $@";
          diskSize = 2048;
        };
        daphne-docker = pkgs.dockerTools.buildImage {
          name = "daphne";
          tag = daphne.version;
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ daphne ];
            pathsToLink = [ "/bin" ];
          };
          runAsRoot = "  #!${pkgs.runtimeShell}\n  mkdir -p /data\n";
          config = {
            Cmd = [ "/bin/daphne" ];
            WorkingDir = "/data";
            Volumes = { "/data" = { }; };
          };
        };
      };
    };
}
