{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  version = "2025.4.0";
  pname = "fsnotifier";

  src = fetchFromGitHub {
    owner = "JetBrains";
    repo = "intellij-community";
    rev = "1725b9d80229df4741d8089ba0011a8911e472d2";
    hash = "sha256-tui6ZVowb0mVZNP9usorWEmZb5gEDqKskAiaFXD/HDo=";
    sparseCheckout = [ "native/fsNotifier/linux" ];
  };

  # fix for hard-links in nix-store, https://github.com/JetBrains/intellij-community/pull/2171
  patches = [ ./fsnotifier.patch ];

  sourceRoot = "${finalAttrs.src.name}/native/fsNotifier/linux";

  buildPhase = ''
    mkdir -p $out/bin

    $CC -O2 -Wall -Wextra -Wpedantic -D "VERSION=\"${finalAttrs.version}\"" -std=c11 main.c inotify.c util.c -o fsnotifier

    cp fsnotifier $out/bin/fsnotifier
  '';

  meta = with lib; {
    homepage = "https://github.com/JetBrains/intellij-community/tree/master/native/fsNotifier/linux";
    description = "IntelliJ Platform companion program for watching and reporting file and directory structure modification";
    license = licenses.asl20;
    mainProgram = "fsnotifier";
    maintainers = with maintainers; [ fabiob ];
    platforms = platforms.linux;
  };
})
