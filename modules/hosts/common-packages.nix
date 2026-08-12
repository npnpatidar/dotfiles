_: {
  flake.homeModules.common-packages = { pkgs, lib, ... }: {
    home.packages = with pkgs; [
      ranger
      devenv
      ttop
      mc
      links2
      screenfetch
      sops
      # OCR for Hindi+English scanned PDFs. Enables Devanagari (hin) alongside
      # English (eng) plus orientation/script detection (osd). Usage:
      #   tesseract scan.png out -l hin+eng
      (tesseract.override {
        enableLanguages = [
          "eng"
          "hin"
          "osd"
        ];
      })
      nil
      podman-tui
      ncdu
      nethogs
      fd
      ripgrep
      tree-sitter
      zlib
      fastfetch
      wget
      nixpkgs-fmt
      glow
      openssl
      systemctl-tui
      # standard replacements for busybox applets
      procps # ps, top, free, watch, pgrep, pkill, w, sysctl, pmap, uptime, vmstat
      less
      which
      iputils # ping, ping6, arping, tracepath
      netcat-gnu # nc
      diffutils
      vim # vi
      lsof
      (lib.hiPrio psmisc) # pstree, killall, fuser (shadows the standalone pstree package)
      tree
      unzip
      bc
      net-tools # netstat, ifconfig, route, hostname
      bind.dnsutils # nslookup, dig, host
      python312
    ];
  };
}
