# This file is a placeholder.
#
# On each target machine, generate the real version with:
#
#   sudo nixos-generate-config --root /mnt
#
# That command inspects the hardware (CPU, GPU, disks, filesystems, boot
# partition) and writes two files:
#   /mnt/etc/nixos/hardware-configuration.nix   ← auto-generated, hardware-specific
#   /mnt/etc/nixos/configuration.nix            ← template (ignore; use ours instead)
#
# Copy the generated hardware-configuration.nix into this directory and it
# will be picked up by flake.nix automatically.
#
# ─── AMD + NVIDIA desktop notes ───────────────────────────────────────────
# For a machine with an AMD CPU/iGPU and NVIDIA dGPU (e.g. RTX 2070 Super),
# add these to your generated hardware-configuration.nix:
#
#   hardware.nvidia = {
#     modesetting.enable    = true;
#     powerManagement.enable = false;
#     open                  = false;   # use proprietary driver, not open kernel module
#     nvidiaSettings        = true;
#     package               = config.boot.kernelPackages.nvidiaPackages.stable;
#   };
#
#   services.xserver.videoDrivers = [ "nvidia" ];
#
#   hardware.graphics = {
#     enable      = true;
#     enable32Bit = true;
#   };
#
# For AMD iGPU alongside NVIDIA dGPU, also ensure:
#   boot.initrd.kernelModules = [ "amdgpu" ];
#
# ──────────────────────────────────────────────────────────────────────────

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # Replace this file with the output of nixos-generate-config on the target machine.
}
