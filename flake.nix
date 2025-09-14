
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      snac2 = pkgs.stdenv.mkDerivation {
        name = "snac2";
        src = ./.;
        installPhase = ''
          make install PREFIX=$out
        '';
        buildInputs = [
          pkgs.curl.dev
        ];
      };
      snac2Module = { config, lib, ... }:
        let
          cfg = config.colonq.services.snac2;
        in {
          options.colonq.services.snac2 = {
            enable = lib.mkEnableOption "Enable snac2";
            dir = lib.mkOption {
              type = lib.types.str;
              description = "Path to the snac2 data directory";
            };
          };
          config = lib.mkIf cfg.enable {
            users.users.snac2 = {
              isSystemUser = true;
            };
            environment.systemPackages = [
              snac2
            ];
          #   systemd.services."colonq.snac2" = {
          #     wantedBy = ["network-online.target"];
          #     serviceConfig = {
          #       Restart = "on-failure";
          #       ExecStart = "${snac2}/bin/snac httpd ${cfg.dir}";
          #       User = "snac2";
          #       RuntimeDirectory = "colonq.fig-bus-sexp";
          #       RuntimeDirectoryMode = "0755";
          #       StateDirectory = "colonq.fig-bus-sexp";
          #       StateDirectoryMode = "0700";
          #       CacheDirectory = "colonq.fig-bus-sexp";
          #       CacheDirectoryMode = "0750";
          #     };
          #   };
          # };
        };
    in {
      packages.x86_64-linux = {
        default = snac2;
        inherit snac2;
      };
      nixosModules = {
        snac2 = snac2Module;
      };
    };
}
