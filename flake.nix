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
        makefileContent = ''
          .PHONY: watch
          watch:
          	while true; do \
          		inotifywait -e modify -r ./chapters/*.org ./appendices/*.org *.org; \
          		make pdf; \
          	done

          .PHONY: pdf
          pdf:
          	emacs --batch main.org -l org \
          		--eval "(require 'ox-latex)" \
          		--eval "(add-to-list 'org-latex-classes \
          			'(\"report\" \
          			\"\\\\documentclass{report}\" \
          			(\"\\\\chapter{%s}\" . \"\\\\section*{%s}\") \
          			(\"\\\\section{%s}\" . \"\\\\subsection*{%s}\") \
          			(\"\\\\subsection{%s}\" . \"\\\\subsubsection*{%s}\") \
          			(\"\\\\subsubsection{%s}\" . \"\\\\paragraph*{%s}\") \
          			(\"\\\\paragraph{%s}\" . \"\\\\subparagraph*{%s}\")))" \
          		--eval "(setq org-latex-pdf-process \
          			'(\"pdflatex -shell-escape -interaction nonstopmode -output-directory . %f\" \
          			\"biber %b\" \
          			\"pdflatex -shell-escape -interaction nonstopmode -output-directory . %f\" \
          			\"pdflatex -shell-escape -interaction nonstopmode -output-directory . %f\"))" \
          		--eval "(org-latex-export-to-pdf)"

          .PHONY: clean
          clean:
          	rm -f *.aux *.log *.out *.toc *.pdf *.bbl *.blg *.fls *.fdb_latexmk *.lot *.lof chapters/*.tex
        '';
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
            if [ ! -f Makefile ]; then
              echo "${makefileContent}" > Makefile
              echo "Created new Makefile"
            else
              echo "Makefile already exists"
            fi

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
