{ stdenv, fetchFromGitHub, cmake, ninja, pkg-config, openjdk, libuuid, utf8cpp
, version ? "4.9.2" }:

let
  antlrsrc = fetchFromGitHub {
    owner = "antlr";
    repo = "antlr4";
    rev = "${version}";
    sha256 = "sha256-t9QFvIkqmiNPcMwEDJwPgvTzhI9eIi/I8zEK4QV9+GY=";
  };
in stdenv.mkDerivation {
  pname = "antlr-cpp";
  version = "${version}";
  src = "${antlrsrc}/runtime/Cpp";
  patches = [
    ../../patches/antlr4_9_2.patch
    ../../patches/0000-antlr-silence-compiler-warnings.patch
  ];

  buildInputs = [ cmake ninja pkg-config libuuid utf8cpp openjdk ];

  cmakeFlags =
    [ "-DANTLR4_INSTALL=ON" "-DUTFCPP_DIR=${utf8cpp}/include/utf8cpp" ];
}
