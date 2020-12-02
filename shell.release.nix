{ sources ? import ./nix {} }:
let
  inherit (sources)
    toyboxpkgs
    nixpkgs
  ;
in
nixpkgs.mkShell rec {
  name = "toy-mirror-rel";
  env = nixpkgs.buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    # <toyboxpkgs>
    toyboxpkgs.go_1_14_4
    toyboxpkgs.jq_1_6
    toyboxpkgs.nodejs_12_18_3
    toyboxpkgs.python_3_7_7
    # <nixpkgs>
    # ...
  ];
  shellHook = "unset GOPATH";
}