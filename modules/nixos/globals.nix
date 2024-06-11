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
