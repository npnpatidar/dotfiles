# Cap journal growth on all hosts; unbounded logs filled the root filesystem on alma.
_: {
  flake.nixosModules.journald = _: {
    services.journald.settings.Journal = {
      SystemMaxUse = "200M";
      MaxRetentionSec = "2week";
    };
  };
}
