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
    in
    {
      packages.${system} = rec {
        antlr-cpp = pkgs.callPackage ./pkgs/antlr-cpp { };
        daphne = pkgs.callPackage ./pkgs/daphne { inherit antlr-cpp mlir; grpc = pkgs21.grpc; };
        mlir = pkgs.callPackage ./pkgs/mlir { };
      };
    };
}
