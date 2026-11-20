{ pkgs }:

# browse: MCP server + relay for the "OpenCode Browse" Chromium extension.
# Self-updating upstream, so pin the version and disable its updater here.
pkgs.stdenv.mkDerivation rec {
  pname = "browse";
  version = "0.1.5";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@opencode/browse-linux-x64/-/browse-linux-x64-${version}.tgz";
    hash = "sha256-i6c/FjIqQlRMrTqXSQv9FJV7l7EItY9DkT5soIijzdc=";
  };

  sourceRoot = "package";

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = with pkgs; [ stdenv.cc.cc.lib ];

  installPhase = ''
    install -Dm755 bin/browse $out/bin/browse
    wrapProgram $out/bin/browse --set OPENCODE_BROWSER_AUTO_UPDATE off
  '';

  meta = with pkgs.lib; {
    description = "Let coding agents drive your real Chromium browser";
    homepage = "https://opencode.ai/product/browse";
    license = licenses.mit;
    mainProgram = "browse";
    platforms = [ "x86_64-linux" ];
  };
}
