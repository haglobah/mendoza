{
  description = "A project with a devshell.";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/*.tar.gz";
    # janet-nix.url = "github:turnerdev/janet-nix";
    # janet-nix.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{
    flake-parts,
    # janet-nix,
    ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [
        inputs.devshell.flakeModule
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # packages.default = janet-nix.packages.${system}.mkJanet {
        #   name = "mdz";
        #   version = "0.0.1";
        #   src = ./.;
        #   main = ./mdz;
        # };
        devshells.default = {
          env = [
            { name = "JANET_PATH"; eval = "$PWD/.jpm"; }
            { name = "JANET_TREE"; eval = "$PWD/.jpm/jpm_tree"; }
            { name = "JANET_BUILDPATH"; eval = "$PWD/build"; }
            { name = "JANET_LIBPATH"; value = "${pkgs.janet}/lib"; }
            { name = "JANET_HEADERPATH"; value = "${pkgs.janet}/include/janet"; }
            { name = "PATH"; prefix = "$PWD/.jpm/jpm_tree/bin"; }
          ];
          packages = [
            pkgs.janet
            pkgs.jpm
            pkgs.gccgo14
            pkgs.fswatch
          ];
          commands = [
            { name = "devshell-test"; command = "echo 'Is this working?'"; help = "A command to test devshell";}
          ];
          devshell.startup.init-janet-dirs = {
            text = ''
              mkdir -p $JANET_TREE
              mkdir -p $JANET_BUILDPATH
            '';
          };
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
