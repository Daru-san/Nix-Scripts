{
  description = "My custom scripts, for all to use!";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      # # Configure Snowfall Lib, all of these settings are optional.
      # snowfall = {
      #   # Tell Snowfall Lib to look in the `./nix/` directory for your
      #   # Nix files.
      #   root = ./nix;
      #
      #   namespace = "scripts";
      #
      #   meta = {
      #     name = "useful-scripts-flake";
      #     title = "Useful-Scripts";
      #   };
      # };
  };
}
