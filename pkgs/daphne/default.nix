{ stdenv, fetchFromGitHub, cmake, ninja, pkg-config, python3Packages, mlir, antlr, openblas, arrow-cpp, eigen, arrow-glib, openjdk, antlr-cpp, protobuf,  grpc-tools, zlib, grpc, papi, spdlog, openssl, openmpi, abseil-cpp_202111, catch2, c-ares, nlohmann_json, utf8cpp, clang, libuuid, libpfm, lld }:

stdenv.mkDerivation {
  pname = "daphne";
  version = "0.2";
  src = fetchFromGitHub {
    owner = "daphne-eu";
    repo = "daphne";
    rev = "0.2";
    # rev = "fedc4cfaf50f4a2a211b9a25f8390f3be16795b6";
    # sha256 = "sha256-EHsY3N6/x96j4M/lAwKszQ31a5nWPjTZTaa9IfaIlrc=";
    sha256 = "sha256-ltD85uaAivhFqFUoUEdb+68+K3YHKV9oj50VT0C/PEk=";
  };

  buildInputs = [
    cmake
    ninja
    pkg-config
    catch2
    nlohmann_json
    clang
    lld
    # utf8cpp

  ];

  cmakeFlags = [
    "-DANTLR_VERSION=${antlr.version}"
    "-DANTLR4_JAR_LOCATION=${antlr}/share/java/antlr-${antlr.version}-complete.jar"
    "-DCMAKE_PREFIX_PATH=\"${utf8cpp}/include/utf8cpp\""
    "-DCMAKE_INCLUDE_PATH=\"${utf8cpp}/include/utf8cpp\""
    "-DCMAKE_CXX_COMPILER=${clang}/bin/clang++"
    "-DCMAKE_C_COMPILER=${clang}/bin/clang"
    "-DCMAKE_LINKER=${lld}/bin/lld"
  ];

  # enableParallelBuilding = false;

  patchPhase = ''
    cp ${antlr}/share/java/* .
    mkdir include
    cp -r ${nlohmann_json}/include/* include/
    substituteInPlace src/parser/metadata/MetaDataParser.h src/parser/config/ConfigParser.h --replace "include <nlohmannjson/json.hpp>" "include <nlohmann/json.hpp>"

  '';

  propagatedBuildInputs = with python3Packages; [
    (abseil-cpp_202111.overrideAttrs (finalAttrs: previousAttrs: {
        patches = [ ../../patches/0002-absl-stdmax-params.patch ];
    }))
    mlir
    antlr
    antlr-cpp
    openblas
    arrow-cpp
    arrow-glib
    eigen
    openjdk
    protobuf
    # grpc-tools
    zlib
    grpc
    papi
    openssl
    openmpi
    spdlog
    c-ares
    nlohmann_json
    libuuid.dev
    libpfm

    python
    numpy
    pandas
  ];

}
