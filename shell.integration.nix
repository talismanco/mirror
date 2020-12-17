{ sources ? import ./nix {} }:
let
  inherit (sources)
    talismanpkgs
    nixpkgs
  ;
in
nixpkgs.mkShell rec {
  name = "integration.mirror";
  env = nixpkgs.buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    # <talismanpkgs>
    talismanpkgs.go_1_14_4
    talismanpkgs.golangci-lint_1_27_0
    talismanpkgs.jq_1_6
    talismanpkgs.python_3_7_7
    # <nixpkgs>
    # ...
  ];
  shellHook = "unset GOPATH";
}