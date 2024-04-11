{ config, lib, pkgs, utils, ... }:

with lib;

let
  cfg = config.services.waved;
  wavedPkg = config.services.waved.package;
in
{
  options = {
    services.waved = {
      enable = mkEnableOption (lib.mdDoc "wave server");

      package = mkOption {
        type = types.package;
        defaultText = literalExpression "pkgs.waved";
        description = lib.mdDoc "The waved package to use.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.waved =
      {
        description = "wave server for h2o_wave";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${wavedPkg}/bin/waved2";
        };
      };
  };
}
