{ sources ? import ./sources.nix }:
let
  overlay = _: pkgs: { 
    inherit (import sources.niv {}) niv;
  };
in
rec {
  toyboxcopkgs = import sources.toyboxcopkgs;
  nixpkgs = import sources.nixpkgs {
    overlays = [ overlay ]; 
    config = {};
  };
}
