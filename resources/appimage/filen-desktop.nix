{ pkgs ? import <nixpkgs> { } }:
let
  pname = "filen-desktop";
  version = "2.0.24";
  rev = "1"; # Update this when you make changes to the derivation
  src = pkgs.fetchurl {
    url = "https://cdn.filen.io/desktop/release/filen_x86_64.AppImage";
    sha256 = "sha256-5vkndT9V/81fUdzS+KTfAjPAGO0IJRx8QhNxBNG8nnU=";
  };
  appimageContents = pkgs.appimageTools.extractType2 { inherit name src; };
  name = "${pname}-${version}";
in
pkgs.appimageTools.wrapType2 {
  name = name;
  src = src;
  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/${pname}.png $out/share/icons/hicolor/512x512/apps/${pname}.png

    substituteInPlace $out/share/applications/${pname}.desktop \
    	--replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
  '';
}
