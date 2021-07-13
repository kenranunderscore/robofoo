with import <nixos> { };

pkgs.mkShell {
  buildInputs = with pkgs; [ sbcl pkgs.SDL2 pkgs.SDL2_image ];
  LD_LIBRARY_PATH =
    lib.makeLibraryPath [ pkgs.SDL2 pkgs.SDL2_image pkgs.libGL ];
}
