{ config, pkgs, sticky-fingers-pkg, ... }:

{
  # ─── sticky-fingers ───────────────────────────────────────────────────────────
  # Auto-starts on boot. Logs every keystroke (with per-line timestamps on Enter)
  # to /run/sticky-fingers/session.log — tmpfs, root-owned, 600. Wiped on reboot.
  #
  # Read with: sudo cat /run/sticky-fingers/session.log
  # Filter:    sudo awk '$1 >= "09:00:00" && $1 <= "12:00:00"' /run/sticky-fingers/session.log
  systemd.services.sticky-fingers = {
    description = "sticky-fingers (per-boot keystroke logger, tmpfs)";
    after       = [ "multi-user.target" ];
    wantedBy    = [ "multi-user.target" ];

    serviceConfig = {
      Type           = "simple";
      ExecStartPre   = "${pkgs.coreutils}/bin/install -d -m 700 -o root -g root /run/sticky-fingers";
      ExecStart      = "${sticky-fingers-pkg}/bin/sticky-fingers";
      Restart        = "on-failure";
      RestartSec     = "2s";

      # Hardening — root needed for /dev/input, but everything else is locked down.
      ProtectSystem            = "strict";
      ProtectHome              = true;
      ReadWritePaths           = [ "/run/sticky-fingers" ];
      PrivateTmp               = true;
      PrivateNetwork           = true;
      NoNewPrivileges          = true;
      ProtectKernelTunables    = true;
      ProtectKernelModules     = true;
      ProtectKernelLogs        = true;
      ProtectControlGroups     = true;
      RestrictNamespaces       = true;
      LockPersonality          = true;
      RestrictRealtime         = true;
      SystemCallArchitectures  = "native";
    };
  };
}
