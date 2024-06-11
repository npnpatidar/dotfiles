# file: modules/globals.nix
# { config, lib, ... }:
#
# {
#   config = {
#     domain_name = "naresh.world";
#     email_domain = "whatiscenter@disroot.org";
#   };
# }
#
{ config, lib, options, ... }:

{
  options.globals = {
    domain_name = lib.mkOption {
      type = lib.types.string;
      default = "example.com";
      description = "Domain name";
    };
  };

  config.globals = {
    domain_name = "naresh.world";
  };
}
