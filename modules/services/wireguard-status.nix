{
  flake.nixosModules.wireguard-status =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    with lib;
    let
      inherit (config.systemConstants) domain_name;
      wgC = config.systemConstants.wireguard;

      stateDir = "/var/lib/wg-status";

      # pubkey -> { name, address } map so the status JSON shows friendly names.
      namesJson = pkgs.writeText "wg-names.json" (
        builtins.toJSON (
          listToAttrs (
            map (
              p:
              nameValuePair p.publicKey {
                inherit (p) name;
                address = p.ip;
              }
            ) ([ wgC.hub ] ++ wgC.peers)
          )
        )
      );

      statusScript = pkgs.writeShellScript "wg-status-json.sh" ''
        set -euo pipefail
        tmp="$STATE_DIRECTORY/status.json.tmp"
        ${pkgs.wireguard-tools}/bin/wg show ${wgC.interface} dump | tail -n +2 |
          ${pkgs.jq}/bin/jq -Rs --slurpfile names ${namesJson} '
            split("\n") | map(select(length > 0)) | map(split("\t"))
            | map({
                publicKey: .[0],
                endpoint: (.[2] | if . == "(none)" then null else . end),
                latestHandshake: (.[4] | tonumber),
                transferRx: (.[5] | tonumber),
                transferTx: (.[6] | tonumber)
              })
            | map(. + {
                online: ((now - .latestHandshake) < 180),
                name: ($names[0][.publicKey].name // "unknown"),
                address: ($names[0][.publicKey].address // null)
              })
            | sort_by(.address)' > "$tmp"
        mv "$tmp" "$STATE_DIRECTORY/status.json"
      '';

      # Note: ''${ inside the markup below escapes a literal JS "${" so Nix does
      # not interpolate it.
      indexHtml = ''
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>WireGuard — ${wgC.hub.name}</title>
          <style>
            :root { color-scheme: dark; }
            body {
              font-family: system-ui, sans-serif;
              background: #11131a;
              color: #d7dae0;
              margin: 2rem auto;
              max-width: 56rem;
              padding: 0 1rem;
            }
            h1 { font-size: 1.3rem; font-weight: 600; }
            .sub { color: #7c8494; font-size: .85rem; margin-bottom: 1.5rem; }
            table { width: 100%; border-collapse: collapse; font-size: .9rem; }
            th, td { text-align: left; padding: .55rem .75rem; border-bottom: 1px solid #23262f; }
            th { color: #7c8494; font-weight: 500; font-size: .78rem; text-transform: uppercase; letter-spacing: .05em; }
            td.num, th.num { text-align: right; font-variant-numeric: tabular-nums; }
            .dot { display: inline-block; width: .6rem; height: .6rem; border-radius: 50%; margin-right: .45rem; }
            .on  { background: #3fb96a; box-shadow: 0 0 6px #3fb96a88; }
            .off { background: #4a4f5c; }
            .muted { color: #7c8494; }
            footer { margin-top: 1.5rem; color: #565b68; font-size: .78rem; }
          </style>
        </head>
        <body>
          <h1>WireGuard nodes</h1>
          <div class="sub">hub: ${wgC.hub.name} (${wgC.hub.ip}) · ${wgC.endpoint}:${toString wgC.port}</div>
          <table id="t">
            <thead><tr>
              <th>Node</th><th>Tunnel IP</th><th>Endpoint</th>
              <th class="num">Received</th><th class="num">Sent</th><th>Last handshake</th>
            </tr></thead>
            <tbody><tr><td colspan="6" class="muted">loading…</td></tr></tbody>
          </table>
          <footer>auto-refreshes every 10 s · online = handshake within 3 min</footer>
          <script>
            const fmtBytes = n => {
              if (!n) return '<span class="muted">0 B</span>';
              const u = ['B', 'KB', 'MB', 'GB', 'TB'];
              let i = 0; while (n >= 1000 && i < u.length - 1) { n /= 1000; i++; }
              return n.toFixed(n >= 100 ? 0 : 1) + '&nbsp;' + u[i];
            };
            const ago = t => {
              if (!t) return '<span class="muted">never</span>';
              const s = Math.max(0, Date.now() / 1000 - t);
              if (s < 60) return Math.floor(s) + ' s ago';
              if (s < 3600) return Math.floor(s / 60) + ' min ago';
              if (s < 86400) return Math.floor(s / 3600) + ' h ago';
              return Math.floor(s / 86400) + ' d ago';
            };
            async function refresh() {
              try {
                const peers = await (await fetch('/status.json', { cache: 'no-store' })).json();
                document.querySelector('#t tbody').innerHTML = peers.map(p => `
                  <tr>
                    <td><span class="dot ''${p.online ? 'on' : 'off'}"></span>''${p.name}</td>
                    <td class="muted">''${p.address ?? '?'}</td>
                    <td class="muted">''${p.endpoint ?? '—'}</td>
                    <td class="num">''${fmtBytes(p.transferRx)}</td>
                    <td class="num">''${fmtBytes(p.transferTx)}</td>
                    <td>''${ago(p.latestHandshake)}</td>
                  </tr>`).join("");
              } catch (e) {
                document.querySelector('#t tbody').innerHTML =
                  '<tr><td colspan="6" class="muted">failed to load status.json</td></tr>';
              }
            }
            refresh();
            setInterval(refresh, 10000);
          </script>
        </body>
        </html>
      '';

      webRoot = "${pkgs.writeTextDir "index.html" indexHtml}";

      # The nginx module's enableTinyauth attaches its auth_request block to the
      # "/" location only; an exact-match location needs it spelled out again to
      # keep the JSON behind auth too.
      tinyauthExtra = ''
        auth_request /tinyauth;
        auth_request_set $redirect_url $upstream_http_x_tinyauth_location;
        error_page 401 403 =302 $redirect_url;
      '';
    in
    {
      services.oink.domains = [
        {
          domain = "${domain_name}";
          subdomain = "wg";
        }
      ];

      systemd.services.wireguard-status = {
        description = "Dump WireGuard peer status as JSON";
        after = [ "wireguard-${wgC.interface}.service" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          StateDirectory = "wg-status";
          ExecStart = statusScript;
        };
      };

      systemd.timers.wireguard-status = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1min";
          OnUnitActiveSec = "15s";
          AccuracySec = "5s";
          Unit = "wireguard-status.service";
        };
      };

      services.nginx.virtualHosts."wg.${domain_name}" = {
        enableACME = true;
        forceSSL = true;
        enableTinyauth = true;
        root = webRoot;
        locations."= /status.json".extraConfig = ''
          ${tinyauthExtra}
          alias ${stateDir}/status.json;
          add_header Cache-Control "no-store";
        '';
      };

      environment.systemPackages = [ pkgs.wireguard-tools ];
    };
}
