{ lib, stdenv
, fetchFromGitHub
, autoreconfHook, zlib, gtest, buildPackages
, fetchpatch
, ...
}:

stdenv.mkDerivation rec {
  pname = "protobuf";
  version = "3.15.8";

  # make sure you test also -A pythonPackages.protobuf
  src = fetchFromGitHub {
    owner = "protocolbuffers";
    repo = "protobuf";
    rev = "v${version}";
    sha256="sha256-G+fU6YWfpkRDJ9Xf+/zLmd52/1vTtPoZdugZDLtCc+A=";
  };

  patches = [../../patches/0003-protobuf-override.patch  (fetchpatch {
        url = "https://github.com/protocolbuffers/protobuf/commit/a7324f88e92bc16b57f3683403b6c993bf68070b.patch";
        sha256 = "sha256-SmwaUjOjjZulg/wgNmR/F5b8rhYA2wkKAjHIOxjcQdQ=";
      })];
  postPatch = ''
    rm -rf gmock
    cp -r ${gtest.src}/googlemock gmock
    cp -r ${gtest.src}/googletest googletest
    chmod -R a+w gmock
    chmod -R a+w googletest
    ln -s ../googletest gmock/gtest
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace src/google/protobuf/testing/googletest.cc \
      --replace 'tmpnam(b)' '"'$TMPDIR'/foo"'
  '';

  nativeBuildInputs = [ autoreconfHook buildPackages.which buildPackages.stdenv.cc  ];

  buildInputs = [ zlib ];
  # configureFlags = if buildProtobuf == null then [] else [ "--with-protoc=${buildProtobuf}/bin/protoc" ];

  enableParallelBuilding = true;

  doCheck = true;

  dontDisableStatic = true;

  meta = {
    description = "Google's data interchange format";
    longDescription =
      ''Protocol Buffers are a way of encoding structured data in an efficient
        yet extensible format. Google uses Protocol Buffers for almost all of
        its internal RPC protocols and file formats.
      '';
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    homepage = "https://developers.google.com/protocol-buffers/";
  };

  passthru.version = version;
}
