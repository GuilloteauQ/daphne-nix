{stdenv, fetchFromGitHub, fetchFromGitLab, fetchurl, cmake, ninja, pkg-config, lld, clang, catch2, nlohmann_json, bash, ncurses, toybox}:

let
    sources = [
        {
          name = "papi";
          version = "7.0.1";
          repo = "papi-7.0.1";
          src = fetchFromGitHub {
            owner = "icl-utk-edu";
            repo = "papi";
            rev = "papi-7-0-1-t";
            sha256 = "sha256-H+f4S7MGtwewZwjhEIW2UE0i1wP7IlM6Emk3C6UbUII=";
            };
        }
        {
          name = "catch2";
          version = "2.13.8";
          repo = "catch2";
          src = fetchFromGitHub {
            owner = "catchorg";
            repo = "catch2";
            rev = "v2.13.8";
            sha256 = "sha256-jOA2TxDgaJUJ2Jn7dVGZUbjmphTDuVZahzSaxfJpRqE=";
            };
        }
        {
          name = "openBlas";
          repo = "openBLAS";
          version = "0.3.23";
          src = fetchFromGitHub {
            owner = "xianyi";
            repo = "OpenBLAS";
            rev = "v0.3.23";
            sha256 = "sha256-zhC9XTb+su6XfAW1vGbLB6mA+hwD2m5Cd/ppdt2nmOI=";
            };
        }
        {
          name = "absl";
          repo = "abseil-cpp";
          version = "20211102.0";
          src = fetchFromGitHub {
            owner = "abseil";
            repo = "abseil-cpp";
            rev = "20211102.0";
            sha256 = "sha256-sSXT6D4JSrk3dA7kVaxfKkzOMBpqXQb0WbMYWG+nGwk=";
            };
        }
        {
          name = "grpc";
          version = "1.38.0";
          repo = "grpc";
          src = fetchFromGitHub {
            owner = "grpc";
            repo = "grpc";
            rev = "v1.38.0";
            sha256 = "sha256-mdhX+dNeJXmozlTOrf6XlmdbyhZQ/3Qc7eNTBO0AySo=";
            fetchSubmodules = true;
            };
        }
        {
          name = "arrow";
          version = "12.0.0";
          repo = "apache-arrow-12.0.0";
          src = fetchFromGitHub {
            owner = "apache";
            repo = "arrow";
            rev = "apache-arrow-12.0.0";
            sha256 = "sha256-c07HrEKMMrdBoRTPM3iPQm9GTNbgrVNd3fMdXxs6FKU=";
            };
        }
        {
          name = "spdlog";
          version = "1.11.0";
          repo = "spdlog-12.0.0";
          src = fetchFromGitHub {
            owner = "gabime";
            repo = "spdlog";
            rev = "v1.11.0";
            sha256 = "sha256-kA2MAb4/EygjwiLEjF9EA7k8Tk//nwcKB1+HlzELakQ=";
            };
        }
        {
          name = "eigen";
          version = "3.4.0";
          repo = "eigen-3.4.0";
          src = fetchFromGitLab {
            owner = "libeigen";
            repo = "eigen";
            rev = "3.4.0";
            sha256 = "sha256-1/4xMetKMDOgZgzz3WMxfHUEpmdAm52RqZvz6i0mLEw=";
            };
        }
        {
          name = "antlr";
          version = "4.9.2";
          repo = "antlr4-cpp-runtime-4.9.2-source";
          src = "${fetchFromGitHub {
            owner = "antlr";
            repo = "antlr4";
            rev = "4.9.2";
            sha256 = "sha256-t9QFvIkqmiNPcMwEDJwPgvTzhI9eIi/I8zEK4QV9+GY=";
          }}/runtime/Cpp";
        }

   ]; 

   install_deps = builtins.concatStringsSep ";" (builtins.map (x: "cp -r ${x.src} thirdparty/sources/${x.repo}; touch thirdparty/flags/${x.name}_v${x.version}.download.v1.success") sources); 

    antlr_jar = fetchurl {
                 url = "https://www.antlr.org/download/antlr-4.9.2-complete.jar";
                 sha256 = "sha256-uxF7FHZpHcKRWjGO/Tb4lXwK2TRH+x2sARB+sV/hN80=";
              };

in
stdenv.mkDerivation {
  pname = "daphne-lazy";
  version = "0.2";
  src = fetchFromGitHub {
    owner = "daphne-eu";
    repo = "daphne";
    rev = "0.2";
    sha256 = "sha256-ltD85uaAivhFqFUoUEdb+68+K3YHKV9oj50VT0C/PEk=";
    fetchSubmodules = true;
  };
  configurePhase = ''
    mkdir -p thirdparty/sources;
    mkdir -p thirdparty/flags;
    mkdir -p thirdparty/installed/include
    mkdir -p thirdparty/download-cache

    ${install_deps} 

    cp ${antlr_jar} thirdparty/download-cache
    cp ${catch2}/include/catch2/catch.hpp thirdparty/installed/include
    touch thirdparty/flags/catch2_v2.13.8.install.v1.success
    cp -r ${nlohmann_json}/include/nlohmann thirdparty/installed/nlohmann
    touch thirdparty/flags/nlohmannjson_v3.10.5.install.v1.success
    
  '';

  buildPhase = ''
   ${bash}/bin/bash build.sh
  '';
  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    lld
    clang
    ncurses
    toybox
  ];

}

