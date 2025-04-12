default:  watch

.PHONY: watch
watch:
	while true; do \
		inotifywait -e modify -r ./chapters/*.org ./appendices/*.org *.org; \
		make pdf; \
	done

.PHONEY: watch-mac
watch-mac:
	while true; do \
		fswatch -1 ./chapters/*.org ./appendices/*.org *.org; \
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
	rm -f *.aux *.log *.out *.toc *.pdf *.bbl *.blg *.fls *.fdb_latexmk *.lot *.lof chapters/*.tex *.run.xml

.PHONY: help
help: ## Display this help screen
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
