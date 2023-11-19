# thorium.nix

{ lib, fetchurl, appimageTools, ... }:

let
  pname = "thorium";
  version = "117.0.5938.157";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/Alex313031/thorium/releases/download/M${version}/Thorium_Browser_${version}_x64.AppImage";
    sha256 = "sha256-dlfClBbwSkQg4stKZdSgNg3EFsWksoI21cxRG5SMrOM=";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in
appimageTools.wrapType2 rec {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/thorium.desktop $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/${pname}.png $out/share/icons/hicolor/512x512/apps/${pname}.png

    lib.substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' "Exec=${pname} %U"
  '';

  meta = with lib; {
    description = "Fastest Browser";
    homepage = "https://devices.ubuntu-touch.io/installer";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
