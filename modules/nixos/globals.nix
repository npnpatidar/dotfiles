{ config, lib, options, ... }:

{
  options.globals = {
    domain_name = lib.mkOption {
      type = lib.types.string;
      default = "naresh.world";
      description = "Domain name";
    };

    default_user = lib.mkOption {
      type = lib.types.string;
      default = "naresh";
      description = "Default user";
    };
    home_directory = lib.mkOption
      {
        type = lib.types.string;
        default = "/home/${config.globals.default_user}";
        description = "home directory";
      };
    data_directory = lib.mkOption
      {
        type = lib.types.string;
        default = "${config.globals.home_directory}/Data";
        description = "Data folder in home directory";
      };
  };

  config.globals = {
    domain_name = "naresh.world";
    default_user = "naresh";
    data_directory = "/home/naresh/Data";
  };
}
