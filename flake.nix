{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.flake-utils.url = github:poscat0x04/flake-utils;

  outputs = { self, nixpkgs, flake-utils, ... }: with flake-utils;
    eachDefaultSystem (
      system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
        in
          with pkgs;
          {
            devShell = {{ project-name }}-dev.envFunc { withHoogle = true; };
            defaultPackage = {{ project-name }};
          }
    ) // {
      overlay = self: super:
        let
          hpkgs = super.haskellPackages;
          {{ project-name }} = hpkgs.callCabal2nix "{{ project-name }}" ./. {};
        in
          with super; with haskell.lib;
          {
            inherit {{ project-name }};
            {{ project-name }}-dev = addBuildTools {{ project-name }} [
              haskell-language-server
              cabal-install
            ];
          };
    };
}
