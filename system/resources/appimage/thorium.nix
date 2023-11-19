# let
#   pname = "thorium";
#   version = "117.0.5938.157";
#   rev = "1"; # Update this when you make changes to the derivation

# in
# { pkgs ? import <nixpkgs> { } }:
# pkgs.appimageTools.wrapType2 {
#   name = "thorium_browser";
#   src = pkgs.fetchurl {
#     url = "https://github.com/Alex313031/thorium/releases/download/M${version}/Thorium_Browser_${version}_x64.AppImage";
#     sha256 = "sha256-dlfClBbwSkQg4stKZdSgNg3EFsWksoI21cxRG5SMrOM=";
#   };
# }


{ pkgs ? import <nixpkgs> { } }:

pkgs.appimageTools.wrapType2 rec {
  pname = "thorium";
  version = "117.0.5938.157";
  name = "thorium_browser";
  src = pkgs.fetchurl {
    url = "https://github.com/Alex313031/thorium/releases/download/M${version}/Thorium_Browser_${version}_x64.AppImage";
    sha256 = "sha256-dlfClBbwSkQg4stKZdSgNg3EFsWksoI21cxRG5SMrOM=";
  };
  appimageContents = pkgs.appimageTools.extractType2 { inherit name src; };

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/thorium.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D ${appimageContents}/${pname}.png $out/share/icons/hicolor/512x512/apps/${pname}.png
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
  '';

  meta = {
    description = "thorium";
    homepage = "https://devices.ubuntu-touch.io/installer";
    license = pkgs.lib.licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
