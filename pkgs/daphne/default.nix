{ stdenv, fetchFromGitHub, cmake, ninja, pkg-config, python3Packages, mlir
, antlr, openblas, arrow-cpp, eigen, arrow-glib, openjdk, antlr-cpp, protobuf
, zlib, grpc, papi, spdlog, openssl, openmpi, abseil-cpp, catch2, c-ares
, nlohmann_json, utf8cpp, libuuid, libpfm, lld, hwloc }:

stdenv.mkDerivation {
  pname = "daphne";
  version = "20230927-master";
  src = fetchFromGitHub {
    owner = "daphne-eu";
    repo = "daphne";
    rev = "02c0686c001c18e27b5ea51f38733dcb1e0a8d54";
    sha256 = "sha256-WF+1vp5R2iWoSEPtD8s6VACdcTy1zN0FhF5+Xgm1O+Q=";
  };
  nativeBuildInputs = [ cmake ninja pkg-config lld openjdk ];

  buildInputs = [
    hwloc
    nlohmann_json
    utf8cpp
    libuuid
    libpfm
    abseil-cpp
    antlr-cpp
    openblas
    arrow-cpp
    arrow-glib
    eigen
    zlib
    spdlog
    c-ares
    catch2
    mlir
    papi
  ];

  propagatedBuildInputs = [
    openmpi
    protobuf
    grpc
    openssl
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
    cmake --build build -j $NIX_BUILD_CORES --target DistributedWorker
  '';
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp lib/* $out/lib
    cp build/lib/* $out/lib
    cp bin/* $out/bin 
  '';

  preFixup = ''rm -rf "$(pwd)" && mkdir "$(pwd)" '';
  patchPhase = ''
    substituteInPlace src/parser/metadata/MetaDataParser.h src/parser/config/ConfigParser.h --replace "include <nlohmannjson/json.hpp>" "include <nlohmann/json.hpp>"
    patch -Np1 -i ${../../patches/utf8cpp.patch} 
  '';

}
