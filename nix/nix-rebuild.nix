{
  stdenv
, lib
, bash
, subversion
, makeWrapper
}:
  stdenv.mkDerivation {
    pname = "nix-rebuild";
    version = "15f71";
    
    src = ../scripts;
    
    buildInputs = [ bash subversion ];
    nativeBuildInputs = [ makeWrapper ];
    
    installPhase = ''
      mkdir -p $out/bin
      cp $src/nix-rebuild.sh $out/bin/nix-rebuild

       wrapProgram $out/bin/nix-rebuild \
        --prefix PATH : ${lib.makeBinPath [ bash subversion]}     
    '';
    
    meta = {
      description = "A simple script that simplifies nixos configuration build operations";
      homepage = "https://github.com/Daru-san/useful-scripts";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [ Daru ];
    };
  }
