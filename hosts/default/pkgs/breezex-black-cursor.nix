{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname   = "breezex-black-cursor";
  version = "2.0.1";

  src = fetchurl {
    url    = "https://github.com/ful1e5/BreezeX_Cursor/releases/download/v2.0.1/BreezeX-Black.tar.xz";
    sha256 = "0cy2dk8c6yisnp5ksnswg9hq07jbyyq42a32xq4k85s86x97afvp";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/icons
    tar -xf $src -C $out/share/icons
  '';

  meta.description = "BreezeX Black cursor theme";
}
