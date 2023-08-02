{ stdenv, fetchFromGitHub, cmake, ninja, pkg-config, python3Packages, mlir, antlr, openblas, arrow-cpp, eigen, arrow-glib, openjdk, antlr-cpp, protobuf,  grpc-tools, zlib, grpc, papi, spdlog, openssl, openmpi, abseil-cpp, catch2, c-ares, nlohmann_json, utf8cpp, clang, libuuid, libpfm, lld }:

stdenv.mkDerivation {
  pname = "daphne";
  version = "0.2";
  src = fetchFromGitHub {
    owner = "daphne-eu";
    repo = "daphne";
    rev = "0.2";
    sha256 = "sha256-ltD85uaAivhFqFUoUEdb+68+K3YHKV9oj50VT0C/PEk=";
  };
  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    lld
    openjdk
  ];

  buildInputs = [
    # clang
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

  # TODO: Probably a lot of those are only buildInputs and dont need to be propagated
  # propagatedBuildInputs = [
  #   ] ++ (with python3Packages; [
  #   python
  #   numpy
  #   pandas
  # ]);

  doCheck = false;
  


  # cmakeFlags = [
  #       "-DENABLE_TESTING=OFF"
  #       "-DENABLE_INSTALL=ON"
  #       "-DANTLR_VERSION=${antlr.version}"
  #       "-DANTLR4_JAR_LOCATION=${antlr}/share/java/antlr-${antlr.version}-complete.jar"
  #       "-DCMAKE_PREFIX_PATH=${utf8cpp}/include/utf8cpp;${catch2}/include/catch2"
  #       "-DCMAKE_INCLUDE_PATH=${utf8cpp}/include/utf8cpp;${catch2}/include/catch2"
  #       "-DCMAKE_CXX_COMPILER=${clang}/bin/clang++"
  #       "-DCMAKE_C_COMPILER=${clang}/bin/clang"
  #       "-DCMAKE_LINKER=${lld}/bin/lld"

  # ];

  configurePhase = ''
    mkdir build
    cmake -S . -G Ninja -B build\
        -DCMAKE_INSTALL_PREFIX=$out\
        -DANTLR_VERSION=${antlr.version}\
        -DANTLR4_JAR_LOCATION=${antlr}/share/java/antlr-${antlr.version}-complete.jar\
        -DCMAKE_PREFIX_PATH="${utf8cpp}/include/utf8cpp"\
        # -DCMAKE_CXX_COMPILER=${clang}/bin/clang++\
        # -DCMAKE_C_COMPILER=${clang}/bin/clang\
        # -DCMAKE_LINKER=${lld}/bin/lld
  '';
  buildPhase = ''
    mkdir -p $out
    cmake --build build -j $NIX_BUILD_CORES --target daphne
  '';
  installPhase = ''
	ls
    ls build
	mkdir -p $out/bin
	mkdir -p $out/lib
	cp lib/* $out/lib
	cp build/lib/* $out/lib
	cp bin/* $out/bin 
    ls $out
    # cp -r bin $out/bin
  '';

  patchPhase = ''
    substituteInPlace src/parser/metadata/MetaDataParser.h src/parser/config/ConfigParser.h --replace "include <nlohmannjson/json.hpp>" "include <nlohmann/json.hpp>"
    patch -Np1 -i ${../../patches/utf8cpp.patch} 
  '';

}
