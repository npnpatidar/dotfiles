# { pkgs, lib, ... }:

# let
#   pname = "ubports-installer";
#   version = "0.9.7-beta";
#   name = "${pname}-${version}";

#   src = pkgs.fetchurl {
#     url = "https://github.com/ubports/ubports-installer/releases/download/${version}/ubports-installer_${version}_linux_x86_64.AppImage";
#     sha256 = "B8s6H6Qmx5O+GrpFr3dHHujcDc0fwWFwRJkX6PXRYfU=";
#   };

#   appimageContents = pkgs.appimageTools.extractType2 { inherit name src; };
# in
# pkgs.appimageTools.wrapType2 rec {
#   inherit name src;

#   extraInstallCommands = ''
#     mv $out/bin/${name} $out/bin/${pname}
#     install -m 444 -D ${appimageContents}/ubports-installer.desktop $out/share/applications/${pname}.desktop

#     install -m 444 -D ${appimageContents}/${pname}.png $out/share/icons/hicolor/512x512/apps/${pname}.png

#     substituteInPlace $out/share/applications/${pname}.desktop \
#     	--replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
#   '';

#   meta = with lib; {
#     description = "A friendly cross-platform Installer for Ubuntu Touch.";
#     homepage = "https://devices.ubuntu-touch.io/installer";
#     license = licenses.gpl3;
#     maintainers = [ ];
#     platforms = [ "x86_64-linux" ];
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
