{ sources ? import ./sources.nix }:
let
  overlay = _: pkgs: { 
    inherit (import sources.niv {}) niv;
  };
in
rec {
  talismanpkgs = import sources.talismanpkgs;
  nixpkgs = import sources.nixpkgs {
    overlays = [ overlay ]; 
    config = {};
  };
}
