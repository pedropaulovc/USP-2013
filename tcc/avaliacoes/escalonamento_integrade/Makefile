DOCUMENT = escalonamento_integrade

document : $(DOCUMENT).tex
#	pdflatex $(DOCUMENT).tex
#	bibtex $(DOCUMENT).aux
	pdflatex $(DOCUMENT).tex
	pdflatex $(DOCUMENT).tex

clean :
	rm -f $(DOCUMENT).aux $(DOCUMENT).bbl $(DOCUMENT).log $(DOCUMENT).out $(DOCUMENT).toc $(DOCUMENT).pdf $(DOCUMENT).blg *~

