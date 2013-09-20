DOCUMENT = relatorio
export TEXINPUTS=/home/bcc/pedrovc/egressos/relatorio/pgfplots//:
export TEXDOCS=/home/bcc/pedrovc/egressos/relatorio/pgfplots//:

document : $(DOCUMENT).tex
	pdflatex $(DOCUMENT).tex

clean :
	rm -f $(DOCUMENT).aux $(DOCUMENT).bbl $(DOCUMENT).log $(DOCUMENT).out $(DOCUMENT).toc $(DOCUMENT).pdf $(DOCUMENT).blg *~

