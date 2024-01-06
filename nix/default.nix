{
  stdenv
, lib
, bash
, libnotify
}:
  stdenv.mkDerivation {
    pname = "test";
    version = "test";
    
    src = ../scripts;
    
    buildInputs = [ bash libnotify ];
    
    installPhase = ''
      mkdir -p $out
      echo "Building..." 
      sleep 3 
      printf "Build successful?"
      notify-send "Build successful!"
      rm -rf $out
    '';
    meta = {
      description = "A test";
      homepage = "https://github.com/Daru-san/useful-scripts";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [ Daru ];
    };
  }
