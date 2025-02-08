with import <nixpkgs> { };

pkgs.mkShell rec {
  packages = [
    pkgs.hugo
    pkgs.go
    # pkgs.dart-sass
  ];
}