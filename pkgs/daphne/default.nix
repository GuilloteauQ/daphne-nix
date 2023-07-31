{ stdenv, fetchFromGitHub, cmake, ninja, pkg-config, python3Packages, mlir, antlr4_9, openblas, arrow-cpp, eigen, arrow-glib, openjdk, antlr-cpp, protobuf,  grpc-tools, zlib, grpc, papi, spdlog, openssl, openmpi, abseil-cpp_202111, catch2 }:

stdenv.mkDerivation {
  pname = "daphne";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "daphne-eu";
    repo = "daphne";
    # rev = "0.1";
    rev = "fedc4cfaf50f4a2a211b9a25f8390f3be16795b6";
    # sha256 = "sha256-EHsY3N6/x96j4M/lAwKszQ31a5nWPjTZTaa9IfaIlrc=";
    sha256 = "sha256-l9Zz1I/dcHQc/S4AdHQhMRsRkxpO5uOsB5xb7ChbYqI=";
  };

  buildInputs = [
    cmake
    ninja
    pkg-config
    catch2
  ];

  cmakeFlags = [
    "-DANTLR_VERSION=${antlr4_9.version}"
    "-DANTLR4_JAR_LOCATION=${antlr4_9}/share/java"
  ];

  patchPhase = ''
    cp ${antlr4_9}/share/java/* .
  '';

  propagatedBuildInputs = with python3Packages; [
    abseil-cpp_202111
    mlir
    antlr4_9
    antlr-cpp
    openblas
    arrow-cpp
    arrow-glib
    eigen
    openjdk
    protobuf
    grpc-tools
    zlib
    grpc
    papi
    openssl
    openmpi
    spdlog

    python
    numpy
    pandas
  ];

}
