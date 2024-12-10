{
  description = "LaTeX development environment with auto-compilation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Core tools
            gnumake
            inotify-tools
            # LaTeX environment
            (texlive.combine {
              inherit (texlive)
                scheme-full
                minted
                biblatex
                biber
                biblatex-ieee
                logreq
                latexmk
                ;
            })
            # For org-mode export
            emacs
            # Optional but useful tools
            pandoc
          ];

          shellHook = ''
            echo "LaTeX development environment loaded!"
            echo "Available commands:"
            echo "  make watch  - Watch for changes and recompile"
            echo "  make pdf    - One-time PDF compilation"
            echo "  make clean  - Clean up generated files"
          '';
        };
      }
    );
}
