# Flexible LaTeX Makefile
# Examples:
#   make                # build all PDFs for all *.tex
#   make paper          # build paper.pdf from paper.tex
#   make slides notes   # build slides.pdf and notes.pdf
#   make clean          # remove aux files
#   make distclean      # remove aux + PDFs

# Config
LATEX      := pdflatex
BIBTEX     := bibtex
LATEXFLAGS := -interaction=nonstopmode -halt-on-error

# Exclude fragments or inputs you don't want compiled to PDFs
EXCLUDES   :=

# All .tex files (minus excludes) -> PDFs
TEX     := $(filter-out $(EXCLUDES), $(wildcard *.tex))
ALLPDFS := $(TEX:.tex=.pdf)

.PHONY: all clean distclean help

# Default: build everything if no explicit targets are given
all: $(ALLPDFS)

# Allow "make name" to mean "make name.pdf"
%: %.pdf
	@:

# Core rule: build a PDF from a matching .tex
%.pdf: %.tex
	@echo "==> Building $@"
	@if command -v latexmk >/dev/null 2>&1; then \
	  latexmk -pdf -interaction=nonstopmode -halt-on-error "$<"; \
	else \
	  $(LATEX) $(LATEXFLAGS) "$<"; \
	  if grep -qiE "(Citation|There were undefined references)" "$*.log"; then \
	    if grep -qiE "\\\\citation|\\\\bibdata|\\\\bibstyle" "$*.aux"; then \
	      $(BIBTEX) "$*"; \
	    fi; \
	    $(LATEX) $(LATEXFLAGS) "$<"; \
	    $(LATEX) $(LATEXFLAGS) "$<"; \
	  fi; \
	fi

# Cleaning
clean:
	@echo "==> Cleaning auxiliary files"
	@rm -f *.aux *.bbl *.blg *.idx *.ind *.lof *.lot *.toc *.acn *.acr *.alg \
	       *.glg *.glo *.gls *.ist *.fls *.log *.out *.synctex.gz *.fdb_latexmk \
	       *.run.xml *.nav *.snm *.vrb

distclean: clean
	@echo "==> Removing generated PDFs"
	@rm -f $(ALLPDFS)

help:
	@echo "Targets:"
	@echo "  make                Build all PDFs for all *.tex"
	@echo "  make <name> [...]   Build <name>.pdf from <name>.tex"
	@echo "  make clean          Remove LaTeX auxiliary files"
	@echo "  make distclean      Remove auxiliaries and PDFs"
