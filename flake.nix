{
  description = "Flake utils demo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devShell.url = "github:numtide/devshell";
    devShell.inputs.nixpkgs.follows = "nixpkgs";
     };
  outputs = { self, nixpkgs, flake-utils, devShell, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs =  nixpkgs.legacyPackages.${system};
        qmk_source =  pkgs.fetchgit {
          url = "https://github.com/qmk/qmk_firmware.git";
          rev = "refs/heads/master";
          sha256 = "sha256-Qt/QGTMoZ+WcmDqvJ6G26K+awVnOIJNfdF78QzXqbpI=";
          fetchSubmodules = true;
leaveDotGit = true;
          };
        wf36 = pkgs.callPackage ./waterfowl-36 {inherit pkgs qmk_source;};
      in
      {
        devShell = {};
        packages = rec {
          waterfowl-36 = wf36;
          hello = pkgs.hello;
          default = hello;
        };
        apps = rec {
          hello = flake-utils.lib.mkApp { drv = self.packages.${system}.hello; };
          default = hello;
        };
      }
    );
}
