{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "reader";
  version = "0.4.4";

  src = pkgs.fetchurl {
    url = "https://github.com/mrusme/${pname}/releases/download/v${version}/${pname}_${version}_linux_amd64.tar.gz";
    sha256 = "2195d52e14715c741081fdecef7444c7a46ec168a180b935e76156dce520aa5a";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ pkgs.unzip ];

  installPhase = ''
    mkdir -p $out/bin
    cp reader $out/bin/
  '';

  meta = {
    description = "A minimal command line reader offering better readability of web pages on the CLI.";
    platforms = pkgs.lib.platforms.all;
  };
}

