{ sources ? import ./nix {} }:
let
  inherit (sources)
    toyboxpkgs
    nixpkgs
  ;
in
nixpkgs.mkShell rec {
  name = "integration.mirror";
  env = nixpkgs.buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    # <toyboxpkgs>
    toyboxpkgs.go_1_14_4
    toyboxpkgs.golangci-lint_1_27_0
    toyboxpkgs.jq_1_6
    toyboxpkgs.python_3_7_7
    # <nixpkgs>
    # ...
  ];
  shellHook = "unset GOPATH";
}