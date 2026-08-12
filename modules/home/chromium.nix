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
