{ stdenv, fetchFromGitHub, cmake, ninja, pkg-config, clang, lld, python3
, utf8cpp }:

let

  llvmsrc = fetchFromGitHub {
    owner = "llvm";
    repo = "llvm-project";
    rev = "20d454c79bbca7822eee88d188afb7a8747dac58";
    sha256 = "sha256-zyKTTt7Cm/jrYpGIgRTE8w+rSMNUXrwZKRnv4540cpE= ";
  };

in stdenv.mkDerivation {
  pname = "mlir";
  version = "20d454";
  src = "${llvmsrc}";

  buildInputs = [ cmake ninja clang lld pkg-config utf8cpp ];

  propagatedBuildInputs = [ python3 ];

  configurePhase = ''
    mkdir build
    cmake -G Ninja -S llvm -B build \
       -DLLVM_ENABLE_PROJECTS=mlir \
       -DLLVM_BUILD_EXAMPLES=OFF \
       -DLLVM_TARGETS_TO_BUILD="Native" \
       -DCMAKE_BUILD_TYPE=Release \
       -DLLVM_ENABLE_ASSERTIONS=ON \
       -DCMAKE_C_COMPILER=${clang}/bin/clang\
       -DCMAKE_CXX_COMPILER=${clang}/bin/clang++\
       -DLLVM_ENABLE_LLD=ON\
       -DLLVM_ENABLE_RTTI=ON \
       -DCMAKE_INSTALL_PREFIX=$out
  '';

  buildPhase = ''
    cmake --build build --target check-mlir
    cmake --build build --target install/strip
  '';
  installPhase = ''
    echo "NIX installPhase"
  '';

}
