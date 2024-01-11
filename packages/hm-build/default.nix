{
  stdenv
, lib
, bash
, subversion
, makeWrapper
, libnotify
}:
  stdenv.mkDerivation {
    pname = "hm-build";
    version = "96d3a";
    
    src = ../../scripts;
    
    buildInputs = [ bash subversion ];
    nativeBuildInputs = [ makeWrapper ];
    
    installPhase = ''
      mkdir -p $out/bin
      cp $src/hm-build.sh $out/bin/hm-build 

       wrapProgram $out/bin/hm-build \
        --prefix PATH : ${lib.makeBinPath [ bash subversion libnotify ]}     
    
    '';
    meta = {
      description = "A simple script that simplifies home manager build operations";
      homepage = "https://github.com/Daru-san/useful-scripts";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [ Daru ];
    };
  }
