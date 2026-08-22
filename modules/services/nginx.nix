_: {
  flake.nixosModules.nginx =
    { config, lib, ... }:
    let
      vhostOptions = { config, ... }: {
        options = {
          enableTinyauth = lib.mkEnableOption "Enable Tinyauth auth middleware";
        };
        config = lib.mkIf config.enableTinyauth {
          locations."/tinyauth".extraConfig = ''
            internal;
            proxy_pass http://127.0.0.1:3009/api/auth/nginx;
            proxy_pass_request_body off;
            proxy_set_header Content-Length "";
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Uri $request_uri;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $remote_addr;
          '';
          locations."/" = {
            extraConfig = ''
              auth_request /tinyauth;
              auth_request_set $redirect_url $upstream_http_x_tinyauth_location;
              auth_request_set $user $upstream_http_remote_user;
              auth_request_set $groups $upstream_http_remote_groups;
              auth_request_set $name $upstream_http_remote_name;
              auth_request_set $email $upstream_http_remote_email;
              proxy_set_header Remote-User $user;
              proxy_set_header Remote-Groups $groups;
              proxy_set_header Remote-Name $name;
              proxy_set_header Remote-Email $email;
              error_page 401 403 =302 $redirect_url;
            '';
          };
        };
      };
    in
    {
      options.services.nginx.virtualHosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule vhostOptions);
      };

      config = {
        security.acme = {
          acceptTerms = true;
          defaults.email = config.systemConstants.acme_email;
        };

        services.nginx = {
          enable = true;
          recommendedGzipSettings = true;
          recommendedOptimisation = true;
          recommendedProxySettings = true;
        };

        services.nginx.virtualHosts."test.${config.systemConstants.domain_name}" = {
          enableACME = true;
          forceSSL = true;
          enableTinyauth = false;
          locations."/" = {
            proxyPass = "http://localhost:7860";
          };
        };
      };
    };
}
