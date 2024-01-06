{
  stdenv
, lib
, fetchFromGitHub
, bash
, subversion
, makeWrapper
, hyprpicker
, libnotify
, wl-clipboard
}:
  stdenv.mkDerivation {
    pname = "color-picker";
    version = "4c584";
    
    src = ../scripts;
    
    buildInputs = [ bash subversion ];
    nativeBuildInputs = [ makeWrapper ];
    
    installPhase = ''
      mkdir -p $out/bin
      cp $src/color-picker.sh $out/bin/color-picker 

       wrapProgram $out/bin/color-picker \
        --prefix PATH : ${lib.makeBinPath [ bash subversion hyprpicker libnotify wl-clipboard ]}     
    '';
    
    meta = {
      description = "A simple color picker script for wayland compositors";
      homepage = "https://github.com/Daru-san/useful-scripts";
      license = lib.licenses.gpl3plus;
      maintainers = with lib.maintainers; [ Daru ];
    };
  }
