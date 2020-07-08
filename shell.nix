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
  buildInputs = with lunarispkgs; [
    go_1_14_4
    golangci-lint_1_27_0
    helm_3_2_1
    jq_1_6
    python_3_7_7
    skaffold_1_10_1
  ];
  shellHook = "unset GOPATH";
}