#vim: set et ts=4 sw=4:
{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, base, random, stdenv, ncurses }:
      mkDerivation {
        pname = "alphabetorder";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [
          base random ncurses
        ];
        homepage = "http://github.com/zenhoth/alphabetorder#readme";
        description = "Simple interactive \"game\" to test your knowledge of English letter ordering";
        license = stdenv.lib.licenses.gpl3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  drv = haskellPackages.callPackage f {};

in

  if pkgs.lib.inNixShell then drv.env else drv
