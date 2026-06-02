{ pkgs }: {
  sticky-fingers = pkgs.rustPlatform.buildRustPackage {
    pname   = "sticky-fingers";
    version = "0.1.0";
    src     = ../sticky-fingers;
    cargoLock.lockFile = ../sticky-fingers/Cargo.lock;
    # Strip + LTO already in Cargo.toml release profile.
    meta.description = "Hyper-lightweight evdev keystroke logger";
  };
}
