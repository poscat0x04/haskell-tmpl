{
  inputs = {
    nixpkgs.url = "git+ssh://git@github.com/NixOS/nixpkgs?ref=nixos-unstable&shallow=1";
    flake-utils.url = "git+ssh://git@github.com/poscat0x04/flake-utils?shallow=1";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    with flake-utils;
    eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in
      with pkgs;
      {
        devShell = {{ project-name }}-dev.envFunc { withHoogle = true; };
        defaultPackage = {{ project-name }};
      }
    )
    // {
      overlay =
        self: super:
        let
          hpkgs = super.haskellPackages;
          {{ project-name }} = hpkgs.callCabal2nix "{{ project-name }}" ./. { };
        in
        with super;
        with haskell.lib;
        {
          inherit {{ project-name }};
          {{ project-name }}-dev = addBuildTools {{ project-name }} [
            haskell-language-server
            cabal-install
          ];
        };
    };
}
