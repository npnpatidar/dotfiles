{ pkgs
,
}:

pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "n8n";
  version = "1.51.0";

  src = pkgs.fetchFromGitHub {
    owner = "n8n-io";
    repo = "n8n";
    rev = "n8n@${finalAttrs.version}";
    hash = "sha256-dSM4uYDP/5n7uSUHJ7mRcQQPMxpMayHyxhiqooAs9Uo=";
  };

  pnpmDeps = pkgs.pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-FjK8QcdfZkSSUNruX+DeHI4wAIUbWnL2HahwQaDqv04=";
  };

  nativeBuildInputs = with pkgs;[
    pnpm.configHook
    python3 # required to build sqlite3 bindings
    nodePackages.node-gyp # required to build sqlite3 bindings
    cacert # required for rustls-native-certs (dependency of turbo build tool)
    makeWrapper
  ] ++ pkgs.lib.optional pkgs.stdenv.isDarwin [ pkgs.xcbuild ];

  buildInputs = with pkgs; [
    nodejs
    libkrb5
    libmongocrypt
    postgresql
  ];

  buildPhase = ''
    runHook preBuild

    pushd node_modules/sqlite3
    node-gyp rebuild
    popd

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{lib,bin}
    cp -r {packages,node_modules} $out/lib

    makeWrapper $out/lib/packages/cli/bin/n8n $out/bin/n8n \
      --set N8N_RELEASE_TYPE "stable"   \
      --set N8N_PAYLOAD_SIZE_MAX 64

    runHook postInstall
  '';

  # makes libmongocrypt bindings not look for static libraries in completely wrong places
  BUILD_TYPE = "dynamic";

  passthru = {
    tests = pkgs.nixosTests.n8n;
  };

  dontStrip = true;

  meta = with pkgs.lib; {
    description = "Free and source-available fair-code licensed workflow automation tool";
    longDescription = ''
      Free and source-available fair-code licensed workflow automation tool.
      Easily automate tasks across different services.
    '';
    homepage = "https://n8n.io";
    changelog = "https://github.com/n8n-io/n8n/releases/tag/${finalAttrs.src.rev}";
    maintainers = with pkgs.maintainers; [
      freezeboy
      gepbird
      k900
    ];
    license = licenses.sustainableUse;
    mainProgram = "n8n";
    platforms = pkgs.lib.platforms.unix;
  };
})
