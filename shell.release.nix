{ sources ? import ./nix {} }:
let
  inherit (sources)
    talismanpkgs
    nixpkgs
  ;
in
nixpkgs.mkShell rec {
  name = "release.mirror";
  env = nixpkgs.buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    # <talismanpkgs>
    talismanpkgs.go_1_14_13
    talismanpkgs.nodejs_12_18_3
    talismanpkgs.python_3_7
    # <nixpkgs>
    nixpkgs.direnv
  ];
  shellHook = "unset GOPATH";
}