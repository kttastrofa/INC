PROJECT = 'latex_and_Makefile' 
MAIN = article
TEX_SOURCES = Makefile \
              $(MAIN).tex \
                section1.tex \
                section2.tex \
                section3.tex \
              references.bib \
              mystyle.sty 

FIGURES := $(shell find images/* -type f)

SHELL=/bin/bash
DATE = $(shell date +"%d%b%Y")
OPT = --interaction=nonstopmode

all: $(MAIN).pdf

final: final.pdf
	$(MAKE) clean

final.pdf: cover.pdf $(MAIN).pdf 
	pdftk cover.pdf $(MAIN).pdf cat output final.pdf

$(MAIN).pdf: $(TEX_SOURCES) $(FIGURES)
	pdflatex $(MAIN)
	makeindex $(MAIN)
	bibtex $(MAIN)
	pdflatex $(MAIN)
	pdflatex $(MAIN)
	@#latexmk -pdf -pvc -pdflatex="pdflatex $(OPT)" $(MAIN) 


once: 
	pdflatex $(MAIN)

clean: 
	-rm -f $(MAIN).{pdf,log,blg,bbl,aux,out,toc,idx,bcf,run.xml,ind,ilg,fls,fdb_latexmk} final.pdf

targz:
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) clean
	tar czf $(PROJECT)_$(DATE).tgz $(TEX_SOURCES) $(FIGURES) cover.pdf

zip:
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) clean
	zip -q $(PROJECT)_$(DATE).zip $(TEX_SOURCES) $(FIGURES) cover.pdf
	
.PHONY: clean all
