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
        abseil-cpp = pkgs.abseil-cpp_202111.overrideAttrs (finalAttrs: previousAttrs: {
        patches = [ ./patches/0002-absl-stdmax-params.patch ];
        cmakeFlags = previousAttrs.cmakeFlags ++ [
            "-DCMAKE_POSITION_INDEPENDENT_CODE=TRUE"
            "-DCMAKE_CXX_STANDARD=17"
            "-DABSL_PROPAGATE_CXX_STD=ON"
        ];
    });
        spdlog = pkgs.spdlog.overrideAttrs( finalAttrs: previousAttrs: {
            cmakeFlags = previousAttrs.cmakeFlags ++ [ "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DSPDLOG_FMT_EXTERNAL=OFF" ];
            propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ [ pkgs.utf8cpp ];
        });
        antlr-cpp = pkgs.callPackage ./pkgs/antlr-cpp { version = pkgs.antlr4_9.version;};
        daphne = pkgs.callPackage ./pkgs/daphne { inherit antlr-cpp mlir; grpc = pkgs21.grpc; nlohmann_json = pkgs21.nlohmann_json; spdlog = spdlog.dev; antlr = pkgs.antlr4_9; abseil-cpp = abseil-cpp; };
        mlir = pkgs.callPackage ./pkgs/mlir { };
      };
    };
}
