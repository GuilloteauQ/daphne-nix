{ stdenv, fetchzip, fetchFromGitHub, cmake, ninja, pkg-config, openjdk, antlr, libuuid, utf8cpp, version ? "4.9.2"}:

let
  antlrsrc = fetchFromGitHub {
    owner = "antlr";
    repo = "antlr4";
    rev = "${version}";
     #sha256 = "sha256-t9QFvIkqmiNPcMwEDJwPgvTzhI9eIi/I8zEK4QV9+GY=";
    sha256 = "sha256-FQeb1P9/QLZtw9leWvnx0DshEqgqQI3LCpieybFjw6k=";
  };
in
stdenv.mkDerivation {
  pname = "antlr-cpp";
  version = "${version}";
  src = "${antlrsrc}/runtime/Cpp";
  # patches = [ ../../patches/0000-antlr-silence-compiler-warnings.patch ];
  # patchFlags = "-Np0";

  buildInputs = [
    cmake
    ninja
    pkg-config
  ];

  propagatedBuildInputs = [
    openjdk
    libuuid.dev
    utf8cpp
  ];

  cmakeFlags = [
    # "-DANTLR_BUILD_CPP_TESTS=OFF"
    "-DANTLR4_INSTALL=ON"
    # "-DUTFCPP_DIR=${utf8cpp}/include"
    # "-DCMAKE_PREFIX_PATH=\"${utf8cpp}/include/utf8cpp\""
  ];

  fixupPhase = ''
    cp -r ${utf8cpp}/include/utf8cpp/* $out/include/antlr4-runtime/
  '';
}
