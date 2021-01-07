{ sources ? import ./sources.nix }:
let
  overlay = _: pkgs: { 
    inherit (import sources.niv {}) niv;
  };
in
rec {
  toyboxpkgs = import sources.toyboxpkgs;
  nixpkgs = import sources.nixpkgs {
    overlays = [ overlay ]; 
    config = {};
  };
}
