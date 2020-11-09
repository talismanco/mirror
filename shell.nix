{ sources ? import ./nix {} }:
let
  inherit (sources)
    toyboxcopkgs
    nixpkgs
  ;
in
nixpkgs.mkShell rec {
  name = "mirror";
  env = nixpkgs.buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    # <toyboxcopkgs>
    toyboxcopkgs.go_1_14_4
    toyboxcopkgs.golangci-lint_1_27_0
    toyboxcopkgs.jq_1_6
    toyboxcopkgs.nodejs_12_18_3
    toyboxcopkgs.python_3_7_7
    # <nixpkgs>
    # ...
  ];
  shellHook = "unset GOPATH";
}