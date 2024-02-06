# { lib
# , stdenv
# , fetchzip
# , libusb1
# , glibc
# , libGL
# , xorg
# , makeWrapper
# , qtx11extras
# , wrapQtAppsHook
# , autoPatchelfHook
# , libX11
# , libXtst
# , libXi
# , libXrandr
# , libXinerama
# }:


{ pkgs, }:

let
  dataDir = "var/lib/xppend1v2";
in
pkgs.stdenv.mkDerivation rec {
  pname = "xp-pen-deco-01-v2-driver";
  version = "3.4.9-231023";

  src = pkgs.fetchzip {
    url = "https://download01.xp-pen.com/file/2023/11/XPPenLinux${version}.tar.gz";
    name = "xp-pen-deco-01-v2-driver-${version}.tar.gz";
    sha256 = "sha256-A/dv6DpelH0NHjlGj32tKv37S+9q3F8cYByiYlMuqLg=";
  };

  nativeBuildInputs = with pkgs; [
    qt6.wrapQtAppsHook
    autoPatchelfHook
    makeWrapper
  ];

  dontBuild = true;

  dontWrapQtApps = true; # this is done manually

  buildInputs = with pkgs; [
    libusb1
    xorg.libX11
    xorg.libXtst
    xorg.libXi
    xorg.libXrandr
    xorg.libXinerama
    glibc
    libGL
    stdenv.cc.cc.lib
    libsForQt5.qt5.qtx11extras
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{opt,bin}
    cp -r App/usr/lib/pentablet/{PenTablet,resource.rcc,conf} $out/opt
    chmod +x $out/opt/PenTablet
    cp -r App/lib $out/lib
    sed -i 's#usr/lib/PenTablet#${dataDir}#g' $out/opt/PenTablet

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/opt/PenTablet $out/bin/xp-pen-deco-01-v2-driver \
      "''${qtWrapperArgs[@]}" \
      --run 'if [ "$EUID" -ne 0 ]; then echo "Please run as root."; exit 1; fi' \
      --run 'if [ ! -d /${dataDir} ]; then mkdir -p /${dataDir}; cp -r '$out'/opt/conf /${dataDir}; chmod u+w -R /${dataDir}; fi'
  '';

  meta = with pkgs.lib; {
    homepage = "https://www.xp-pen.com/product/461.html";
    description = "Drivers for the XP-PEN Deco 01 v2 drawing tablet";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ virchau13 ];
    license = licenses.unfree;
  };
}
