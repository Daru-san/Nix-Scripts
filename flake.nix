{
  description = "My custom scripts, for all to use!";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, ...} @ inputs: let
    inherit (self) outputs; 
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {  
    packages = forAllSystems (system: import ./packages.nix nixpkgs.legacyPackages.${system});
  };
}
