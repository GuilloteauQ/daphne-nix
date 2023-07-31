{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    nixpkgs_2111.url = "github:nixos/nixpkgs/21.11";
  };

  outputs = { self, nixpkgs, nixpkgs_2111 }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pkgs21 = import nixpkgs_2111 { inherit system; };
      antlr_version = "4.9.3";
    in
    {
      packages.${system} = rec {
        spdlog = pkgs.spdlog.overrideAttrs( finalAttrs: previousAttrs: {
            cmakeFlags = previousAttrs.cmakeFlags ++ [ "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DSPDLOG_FMT_EXTERNAL=OFF" ];
            propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ [ pkgs.utf8cpp ];
        });
        my_antlr = pkgs.antlr.overrideAttrs (finalAttrs: previousAttrs: {
            version = antlr_version;
            src = pkgs.fetchurl {
                url = "https://www.antlr.org/download/antlr-${antlr_version}-complete.jar";
                # sha256 = "sha256-uxF7FHZpHcKRWjGO/Tb4lXwK2TRH+x2sARB+sV/hN80=";
                sha256 = "sha256-r81AlG095NgeKNfIjUZyieBYcoXSetsXKuzFSUoX3zY=";
            };
        });
        antlr-cpp = pkgs.callPackage ./pkgs/antlr-cpp { version = antlr_version;};
        daphne = pkgs.callPackage ./pkgs/daphne { inherit antlr-cpp mlir; grpc = pkgs21.grpc; nlohmann_json = pkgs21.nlohmann_json; spdlog = spdlog.dev; antlr = my_antlr; };
        mlir = pkgs.callPackage ./pkgs/mlir { };
      };
    };
}
