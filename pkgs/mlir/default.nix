{ stdenv, fetchFromGitHub, cmake, ninja, pkg-config, clang, lld, python3, utf8cpp }:

let

  llvmsrc = fetchFromGitHub {
    owner = "llvm";
    repo = "llvm-project";
    # rev = "6d43651b3680e5d16d58296c02b0e7584f1aa7ea";
    rev = "20d454c79bbca7822eee88d188afb7a8747dac58";
    # sha256 = "sha256-hhrbGUKqpVt6vB8tFO6f4X7PSJgI/V4hxb7tgb14eBk=";
    sha256 = "sha256-zyKTTt7Cm/jrYpGIgRTE8w+rSMNUXrwZKRnv4540cpE= ";
  };
in

stdenv.mkDerivation {
  pname = "mlir";
  version = "20d454";
  src = "${llvmsrc}";

 # sourceRoot = "${src.name}/${targetDir}";
  # cmakeFlags = [
  #   "-DLLVM_ENABLE_PROJECTS=mlir"
  #   "-DCMAKE_C_COMPILER=${clang}/bin/clang"
  #   "-DCMAKE_CXX_COMPILER=${clang}/bin/clang++"
  #   "-DLLVM_ENABLE_LLD=ON"
  # ];

  buildInputs = [
    cmake
    ninja
    clang
    lld
    pkg-config
    utf8cpp
  ];

  propagatedBuildInputs = [
    python3
  ];

  configurePhase = ''
    mkdir build
    cd build
    cmake -G Ninja ../llvm \
       -DLLVM_ENABLE_PROJECTS=mlir \
       -DLLVM_BUILD_EXAMPLES=ON \
       -DLLVM_TARGETS_TO_BUILD="Native" \
       -DCMAKE_BUILD_TYPE=Release \
       -DLLVM_ENABLE_ASSERTIONS=ON \
       -DCMAKE_C_COMPILER=${clang}/bin/clang\
       -DCMAKE_CXX_COMPILER=${clang}/bin/clang++\
       -DLLVM_ENABLE_LLD=ON\
       -DCMAKE_INSTALL_PREFIX=$out

    # cmake --build . --target check-mlir
  '';

  buildPhase = ''
    echo "NIX BuildPhase"
    ls
    cmake --build . --target check-mlir
    cmake --build . --target install/strip
    ls
  '';
  installPhase = ''
    echo "NIX installPhase"
    ls $out
  '';

}
