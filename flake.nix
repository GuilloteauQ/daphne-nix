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
      antlr_version = "4.9.2";
    in
    {
      packages.${system} = rec {
		daphne-lazy = pkgs.callPackage ./pkgs/daphne-lazy { };
        abseil-cpp = pkgs.abseil-cpp_202111.overrideAttrs (finalAttrs: previousAttrs: {
			patches = [ ./patches/0002-absl-stdmax-params.patch ];
			cmakeFlags = previousAttrs.cmakeFlags ++ [
				"-DCMAKE_POSITION_INDEPENDENT_CODE=TRUE"
				"-DCMAKE_CXX_STANDARD=17"
				"-DABSL_PROPAGATE_CXX_STD=ON"
			];
		});
		# protobuf = pkgs21.callPackage ./pkgs/protobuf { };
		protobuf = pkgs.protobuf3_19;
		# mygrpc = pkgs21.grpc.override {protobuf = protobuf;};
		mygrpc = pkgs21.grpc;
        spdlog = pkgs.spdlog.overrideAttrs( finalAttrs: previousAttrs: {
            cmakeFlags = previousAttrs.cmakeFlags ++ [ "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DSPDLOG_FMT_EXTERNAL=OFF" ];
            propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ [ pkgs.utf8cpp ];
        });
        antlr = pkgs.antlr.overrideAttrs(finalAttrs: previousAttrs: {
            version = antlr_version;
             src = pkgs.fetchurl {
                 url = "https://www.antlr.org/download/antlr-${antlr_version}-complete.jar";
                 sha256 = "sha256-uxF7FHZpHcKRWjGO/Tb4lXwK2TRH+x2sARB+sV/hN80=";
              };
		installPhase = ''
        mkdir -p "$out"/{share/java,bin}
        cp "$src" "$out/share/java/antlr-${antlr_version}-complete.jar"

        echo "#! ${pkgs.stdenv.shell}" >> "$out/bin/antlr"
        echo "'${previousAttrs.jre}/bin/java' -cp '$out/share/java/antlr-${antlr_version}-complete.jar:$CLASSPATH' -Xmx500M org.antlr.v4.Tool \"\$@\"" >> "$out/bin/antlr"

        echo "#! ${pkgs.stdenv.shell}" >> "$out/bin/antlr-parse"
        echo "'${previousAttrs.jre}/bin/java' -cp '$out/share/java/antlr-${antlr_version}-complete.jar:$CLASSPATH' -Xmx500M org.antlr.v4.gui.Interpreter \"\$@\"" >> "$out/bin/antlr-parse"

        echo "#! ${pkgs.stdenv.shell}" >> "$out/bin/grun"
        echo "'${previousAttrs.jre}/bin/java' -cp '$out/share/java/antlr-${antlr_version}-complete.jar:$CLASSPATH' org.antlr.v4.gui.TestRig \"\$@\"" >> "$out/bin/grun"

        chmod a+x "$out/bin/antlr" "$out/bin/antlr-parse" "$out/bin/grun"
        ln -s "$out/bin/antlr"{,4}
        ln -s "$out/bin/antlr"{,4}-parse
      '';
        });
        antlr-cpp = pkgs.callPackage ./pkgs/antlr-cpp { version = antlr_version;};
        daphne = pkgs.callPackage ./pkgs/daphne { inherit antlr antlr-cpp mlir;  grpc = mygrpc; nlohmann_json = pkgs21.nlohmann_json; spdlog = spdlog.dev; abseil-cpp = abseil-cpp; };
        mlir = pkgs.callPackage ./pkgs/mlir { };
      };
    };
}
