# Scripts packaged in the nix format for flake users
pkgs: 
{
  hm-build = pkgs.callPackage ./nix/hm-build.nix { };
  color-picker = pkgs.callPackage ./nix/color-picker.nix { };
  nix-rebuild = pkgs.callPackage ./nix/nix-rebuild.nix { };
  default = pkgs.callPackage ./nix/default.nix;
}
