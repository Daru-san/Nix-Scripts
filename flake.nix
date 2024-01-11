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
  };
}
