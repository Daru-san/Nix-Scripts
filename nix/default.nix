# Scripts packaged in the nix format for flake users
pkgs: 
{
  hm-build = pkgs.callPackage ./hm-build.nix { };
  colorpicker = pkgs.callPackage ./color-picker.nix { };
  nix-rebuild = pkgs.callPackage ./nix-rebuild.nix { };
}
