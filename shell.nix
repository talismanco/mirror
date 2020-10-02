{ sources ? import ./nix {} }:
let
  inherit (sources)
    lunarispkgs
    nixpkgs
  ;
in
nixpkgs.mkShell rec {
  name = "mirror";
  env = nixpkgs.buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    # <lunarispkgs>
    lunarispkgs.go_1_14_4
    lunarispkgs.golangci-lint_1_27_0
    lunarispkgs.helm_3_2_1
    lunarispkgs.jq_1_6
    lunarispkgs.nodejs_12_18_3
    lunarispkgs.python_3_7_7
    lunarispkgs.skaffold_1_10_1
    # <nixpkgs>
    # ...
  ];
  shellHook = "unset GOPATH";
} 