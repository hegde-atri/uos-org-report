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

        # Platform-specific packages
        platformSpecificPkgs =
          if pkgs.stdenv.isDarwin then
            [
              pkgs.fswatch # macOS
              (pkgs.emacs.override { withNativeCompilation = false; })
            ]
          else
            [
              pkgs.inotify-tools
              pkgs.emacs
            ]; # Linux
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              # Core tools
              gnumake
            ]
            ++ platformSpecificPkgs
            ++ (with pkgs; [
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

              libgccjit

              # Optional but useful tools
              pandoc
            ]);

          shellHook = ''
            echo "LaTeX development environment loaded!"
            echo "Available commands:"
            echo "  make watch  - Watch for changes and recompile"
            echo "  make pdf    - One-time PDF compilation"
            echo "  make clean  - Clean up generated files"

            # Create platform-specific watch command
            if [[ "$(uname)" == "Darwin" ]]; then
              echo ""
              echo "📝 macOS detected! Use this watch command in your Makefile:"
              echo "watch:"
              echo "	while true; do \\"
              echo "		fswatch -1 ./chapters/*.org ./appendices/*.org *.org; \\"
              echo "		make pdf; \\"
              echo "	done"
            fi
          '';
        };
      }
    );
}
