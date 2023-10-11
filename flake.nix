{
  description = "A very basic flake";

  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.SDL2 pkgs.SDL2_image pkgs.racket ];
        LD_LIBRARY_PATH =
          pkgs.lib.makeLibraryPath [ pkgs.SDL2 pkgs.SDL2_image pkgs.libGL ];
      };
    };
}
