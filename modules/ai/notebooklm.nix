_: {
  flake.homeModules.notebooklm =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.hm.dag) entryAfter;
      binDir = "${config.home.homeDirectory}/.local/bin";

      # Playwright browsers built from nixpkgs (the official Chromium
      # binaries patched for NixOS) instead of ``playwright install``, which
      # downloads CDN builds that won't run on NixOS. Chromium + headless
      # shell only — enough for the interactive login and headless re-auth.
      #
      # The venv's playwright is pinned to the PyPI release that bundles the
      # SAME browser revisions as nixpkgs. Nixpkgs versions playtags (e.g.
      # 1.61.1) are rarely published to PyPI, so map nixpkgs -> PyPI here:
      #   1.61.1  -> 1.61.0  (both chromium rev 1228)
      # Re-check when nixpkgs updates playwright: read the rev from
      #   pkgs.playwright-driver.browsersJSON.<browser>.revision
      # and pick the PyPI release with the same revision (verify via its wheel).
      pypiPlaywrightVersion = "1.61.0"; # PyPI wheel, for pinning
      playwrightBrowsersPath = pkgs.playwright-driver.browsers.override {
        withFirefox = false;
        withWebkit = false;
        withFfmpeg = false;
      };
    in
    {
      # Point Playwright at the nixpkgs-provided browsers. The venv's
      # playwright is pinned to the matching release above, so the browser
      # revision directories (chromium-<rev>, chromium_headless_shell-<rev>)
      # always line up.
      home.sessionVariables.PLAYWRIGHT_BROWSERS_PATH = playwrightBrowsersPath;

      home.activation.setupNotebooklm = entryAfter [ "writeBoundary" ] ''
        # Unofficial NotebookLM Python API/CLI, installed as a uv tool so the
        # binaries land on ~/.local/bin (already on PATH via ~/.zshrc).
        # Idempotent: install only when missing. If nixpkgs updates playwright,
        # the version check below reinstalls with the new pinned version.
        # The [cookies] extra (rookiepy) needs Python <= 3.12, hence --python 3.12.
        notebooklm_bin="${binDir}/notebooklm"
        needs_install=0
        if [ ! -x "$notebooklm_bin" ]; then
          needs_install=1
        else
          venv_dir="$(dirname "$(dirname "$(readlink -f "$notebooklm_bin")")")"
          installed_playwright="$("$venv_dir/bin/python" -m playwright --version 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $2}')"
          if [ -z "$installed_playwright" ] || [ "$installed_playwright" != "${pypiPlaywrightVersion}" ]; then
            needs_install=1
          fi
        fi
        if [ "$needs_install" = "1" ]; then
          # uv tool install takes a single package, so pin the bundled
          # playwright with a constraints file instead.
          constraints_file="$(mktemp)"
          printf 'playwright==%s\n' "${pypiPlaywrightVersion}" > "$constraints_file"
          ${pkgs.uv}/bin/uv tool install --python 3.12 --force \
            -c "$constraints_file" 'notebooklm-py[browser,cookies]'
          rm -f "$constraints_file"
        fi
      '';
    };
}
