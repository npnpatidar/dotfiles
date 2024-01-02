# with import <nixpkgs> { };

# { lib
# , stdenv
# , fetchurl
# , dpkg
# , wrapGAppsHook
# , autoPatchelfHook
# , udev
# , gtk3
# , lttng-ust
# , openssl_3_1
# }:

{ pkgs, }:

pkgs.stdenv.mkDerivation rec {
  pname = "xdapp";
  version = "8.0.26";

  src = pkgs.fetchurl {
    url = "https://github.com/subhra74/xdm/releases/download/8.0.26/xdman_gtk_8.0.26_amd64.deb";
    hash = "sha256-FykAFy0e2YdaBbLBdMSLBzh+G9Gzlzl5wxtpkV9qYL8=";
    # url = "https://github.com/subhra74/xdm/releases/download/8.0.29/xdman_gtk_8.0.29_amd64.deb";
    # hash = "sha256-Nlm7LbAlHI3w+lAeUxhf0Dx7Fde1jCKitguTFEtrnhE=";
  };

  unpackPhase = "dpkg-deb -x $src .";

  dontStrip = true;
  nativeBuildInputs = with pkgs;[
    dpkg
    wrapGAppsHook
    autoPatchelfHook
  ];

  buildInputs = with pkgs;[
    gtk3
    lttng-ust
    stdenv.cc.cc
    openssl_3_2

  ];
  runtimeDependencies = with pkgs;[
    (lib.getLib udev)
    gtk3
  ];

  installPhase = ''

   export GTK_PATH="$out/xdman"
    mkdir -p $out/bin
    cp -r opt/xdman $out
    cp -r usr/share $out
    ln -s $out/xdman/xdm-app $out/bin/${pname}

    substituteInPlace $out/share/applications/xdm-app.desktop \
      --replace 'Exec=env GTK_USE_PORTAL=1 /opt/xdman/xdm-app' 'Exec=env GTK_USE_PORTAL=1 ${pname}' \
      --replace "Icon=/opt/xdman/xdm-logo.svg" "Icon=$out/xdman/xdm-logo.svg"


       patchelf --set-rpath "$out/xdman" "$out/xdman/xdm-app"
  '';


  postFixup = ''
    patchelf --replace-needed liblttng-ust.so.0 liblttng-ust.so $out/xdman/libcoreclrtraceptprovider.so
    patchelf --add-needed libssl.so \
             $out/xdman/*System.Security.Cryptography.Native.OpenSsl.so
  '';

  meta = with pkgs.lib; {
    description = "Powerful download accelerator and video downloader";
    homepage = "https://github.com/subhra74/xdm";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "xdm";
    maintainers = with maintainers; [ ];
  };

}
