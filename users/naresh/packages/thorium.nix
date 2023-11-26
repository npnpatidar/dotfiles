{ pkgs ? import <nixpkgs> { } }:
let
  pname = "thorium-browser";
  sname = "thorium";
  version = "117.0.5938.157";
  name = "${pname}-${version}";
  rev = "1"; # Update this when you make changes to the derivation
  src = pkgs.fetchurl {
    url = "https://github.com/Alex313031/thorium/releases/download/M${version}/Thorium_Browser_${version}_x64.AppImage";
    sha256 = "sha256-dlfClBbwSkQg4stKZdSgNg3EFsWksoI21cxRG5SMrOM=";
  };
  appimageContents = pkgs.appimageTools.extractType2 { inherit name src; };
in
pkgs.appimageTools.wrapType2 {
  name = name;
  src = src;
  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${sname}
    install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D ${appimageContents}/${sname}.png $out/share/icons/hicolor/512x512/apps/${sname}.png
  '';
}
