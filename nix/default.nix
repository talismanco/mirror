{ sources ? import ./sources.nix }:
let
  overlay = _: pkgs: { 
    inherit (import sources.niv {}) niv;
  };
in
rec {
  lunarispkgs = import sources.lunarispkgs;
  nixpkgs = import sources.nixpkgs {
    overlays = [ overlay ]; 
    config = {};
  };
}
