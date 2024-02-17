# { stdenv, fetchurl, sane-backends, qtbase, qtsvg, nss, autoPatchelfHook, lib, wrapQtAppsHook }:

{ pkgs, }:
pkgs.stdenv.mkDerivation rec {
  pname = "masterpdfeditor";
  version = "5.9.20";

  src = pkgs.fetchurl {
    url = "https://code-industry.net/public/master-pdf-editor-${version}-qt5.x86_64.tar.gz";
    # sha256 = "sha256-c5DYS0PQemZ8Sql2KjnuMspCLDJzU95rsbuIdoxWDM0="; #5.9.35
    # sha256 = "sha256-CbrhhQJ0iiXz8hUJEi+/xb2ZGbunuPuIIgmCRgJhNVU="; # 5.9.82
    sha256 = "sha256-CkNg27w6XQ2eAjhA4h8z2RNDM3B2leN9Q3J6TUXPSGs=";
  };

  nativeBuildInputs = with pkgs; [ autoPatchelfHook libsForQt5.qt5.wrapQtAppsHook ];

  buildInputs = with pkgs;[ nss pkcs11helper libsForQt5.qt5.qtbase libsForQt5.qt5.qtsvg sane-backends stdenv.cc.cc ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall

    p=$out/opt/masterpdfeditor
    mkdir -p $out/bin

    substituteInPlace masterpdfeditor5.desktop \
      --replace 'Exec=/opt/master-pdf-editor-5' "Exec=$out/bin" \
      --replace 'Path=/opt/master-pdf-editor-5' "Path=$out/bin" \
      --replace 'Icon=/opt/master-pdf-editor-5' "Icon=$out/share/pixmaps"

    install -Dm644 -t $out/share/pixmaps      masterpdfeditor5.png
    install -Dm644 -t $out/share/applications masterpdfeditor5.desktop
    install -Dm755 -t $p                      masterpdfeditor5
    # install -Dm644 license.txt $out/share/$name/LICENSE
    ln -s $p/masterpdfeditor5 $out/bin/masterpdfeditor5
    cp -v -r stamps templates lang fonts $p

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Master PDF Editor";
    homepage = "https://code-industry.net/free-pdf-editor/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ cmcdragonkai ];
  };
}
