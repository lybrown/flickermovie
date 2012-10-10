# $Id: Makefile 36 2008-06-29 23:46:07Z lybrown $

export movie = gangnam
export audext = audc
max_frame = 4678
frames := $(shell cd orig; echo $(movie)*.png | sed s/.png/.abm/g)
frames := $(wordlist 1,$(max_frame),$(frames))

$(movie).run:
$(movie).xex: $(frames) $(movie).$(audext) movie.xex
	cp movie.xex $@

atari = altirra

%.audf: %.wav
	sox -v 0.95 $< -u -b 8 -r15600 -D -t raw $@ dcshift -0.55 remix -

%.raw: %.wav
	sox -v 0.2 $< -u -b 8 -r15600 -D $@ remix -

%.audc: %.raw
	./raw2audc $< > $@

%.ppm: orig/%.png
	convert -compress none -resize 160x240\! $< -modulate 90 -remap pal.ppm $@

%.abm: %.ppm
	./ppm2abm $< > $@

%.run: %.xex
	$(atari) $<

%.xex: %.obx
	cp $< $@

%.asm.pl: %.asm.pp
	perl -pe 's/^\s*>>>// or s/(.*)/print <<\\EOF;\n$$1\nEOF/' $< > $@

%.asm: %.asm.pl
	perl $< > $@
	
%.obx: %.asm
	xasm /l /d:pwm=$(if $(findstring audf,$(audext)),1,0) $<

clean:
	rm -f *.{obx,atr,lst} *.{tmc,tm2,pgm,wav}.asm *~

.PRECIOUS: %.obx %.lis %.atr %.xex %.ppm %.abm
