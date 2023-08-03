{ stdenv, fetchFromGitHub, cmake, ninja, pkg-config, python3Packages, mlir
, antlr, openblas, arrow-cpp, eigen, arrow-glib, openjdk, antlr-cpp, protobuf
, zlib, grpc, papi, spdlog, openssl, openmpi, abseil-cpp, catch2, c-ares
, nlohmann_json, utf8cpp, libuuid, libpfm, lld }:

stdenv.mkDerivation {
  pname = "daphne";
  version = "0.2";
  src = fetchFromGitHub {
    owner = "daphne-eu";
    repo = "daphne";
    rev = "0.2";
    sha256 = "sha256-ltD85uaAivhFqFUoUEdb+68+K3YHKV9oj50VT0C/PEk=";
  };
  nativeBuildInputs = [ cmake ninja pkg-config lld openjdk ];

  buildInputs = [
    nlohmann_json
    utf8cpp
    libuuid.dev
    libpfm
    abseil-cpp
    antlr-cpp
    openblas
    arrow-cpp
    arrow-glib
    eigen
    protobuf
    zlib
    # openmpi
    spdlog
    c-ares
    catch2
    mlir
    papi
    openssl
    grpc
  ];

  doCheck = false;

  configurePhase = ''
    mkdir build
    cmake -S . -G Ninja -B build\
        -DCMAKE_INSTALL_PREFIX=$out\
        -DANTLR_VERSION=${antlr.version}\
        -DANTLR4_JAR_LOCATION=${antlr}/share/java/antlr-${antlr.version}-complete.jar\
        -DCMAKE_PREFIX_PATH="${utf8cpp}/include/utf8cpp"\
  '';
  buildPhase = ''
    mkdir -p $out
    cmake --build build -j $NIX_BUILD_CORES --target daphne
  '';
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp lib/* $out/lib
    cp build/lib/* $out/lib
    cp bin/* $out/bin 
  '';

  patchPhase = ''
    substituteInPlace src/parser/metadata/MetaDataParser.h src/parser/config/ConfigParser.h --replace "include <nlohmannjson/json.hpp>" "include <nlohmann/json.hpp>"
    patch -Np1 -i ${../../patches/utf8cpp.patch} 
  '';

}
