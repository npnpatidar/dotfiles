_: {
  flake.homeModules.chromium = _: {
    programs.chromium = {
      enable = true;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }
        { id = "nngceckbapebfimnlniiiahkandclblb"; }
        { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; }
        { id = "pkoccklolohdacbfooifnpebakpbeipc"; }
        { id = "fnaicdffflnofjppbagibeoednhnbjhg"; }
        { id = "kgcjekpmcjjogibpjebkhaanilehneje"; }
        {
          # OpenCode Browse: lets agents drive this browser (needs `browse`, see pkgs/browse.nix)
          id = "mfnicocicmmlkpjnaffgihfjhdgjkdjg";
          crxPath = builtins.fetchurl {
            name = "opencode-browse.crx";
            url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=141.0&acceptformat=crx2,crx3&x=id%3Dmfnicocicmmlkpjnaffgihfjhdgjkdjg%26uc";
            sha256 = "sha256-+RJH/KxrrWeD38EDb9tP8bm832J0yiilDWX/8XAGLu0=";
          };
          version = "0.1.5";
        }
        {
          id = "ocaahdebbfolfmndjeplogmgcagdmblk";
          crxPath = builtins.fetchurl {
            name = "chromium-web-store.crx";
            url = "https://github.com/NeverDecaf/chromium-web-store/releases/download/v1.5.4.2/Chromium.Web.Store.crx";
            sha256 = "sha256:0q3js6r6wzy0hqdjgm9n8kmwb8hn6prap7gp3vx0z3xgipgpp92c";
          };
          version = "1.5.4.2";
        }
      ];
    };
  };
}
