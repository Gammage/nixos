{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  obs-studio,
  qt6Packages,
}:

stdenv.mkDerivation rec {
  pname = "obs-aitum-stream-suite";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "Aitum";
    repo = "obs-aitum-stream-suite";
    tag = version;
    hash = "sha256-m4T2ieWLRDywH+eP3mAdi3qG5EBJQIT4p1+nmSDUNMw=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    curl
    obs-studio
    qt6Packages.qtbase
  ];

  cmakeFlags = [
    "-DBUILD_OUT_OF_TREE=On"
    (lib.cmakeBool "QT_FIND_PRIVATE_MODULES" true)
    (lib.cmakeOptionType "string" "CMAKE_CXX_FLAGS"
      "-Wno-error=deprecated-declarations")
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Aitum Stream Suite plugin for OBS Studio";
    homepage = "https://github.com/Aitum/obs-aitum-stream-suite";
    license = lib.licenses.gpl2Plus;
    inherit (obs-studio.meta) platforms;
  };
}
