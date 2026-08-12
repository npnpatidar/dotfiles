_: {
  flake.nixosModules.mcp = { config, ... }: {
    services.nginx.virtualHosts."mcp.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
      };
    };
  };

  flake.homeModules.mcp = { config, pkgs, ... }: {
    systemd.user.services.mcp-servers = {
      Unit.Description = "MCP Servers (SSE)";
      Service = {
        ExecStart = "${pkgs.mcp-proxy}/bin/mcp-proxy --port=8082 --transport streamablehttp --named-server-config ${config.home.homeDirectory}/.config/mcp/mcp.json";
        Restart = "on-failure";
        KillSignal = "SIGINT";
        Environment = "PATH=${pkgs.nodejs}/bin:${pkgs.uv}/bin:/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin";
      };
      Install.WantedBy = [ "default.target" ];
    };

    home.file.".config/mcp/mcp.json".text = builtins.toJSON {
      mcpServers = {
        nixos = {
          command = "uvx";
          args = [ "mcp-nixos" ];
        };
      };
    };

    home.packages = [ pkgs.mcp-proxy ];
  };
}
