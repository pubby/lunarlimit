#!/usr/bin/make -f
#
# Makefile for NES game
# Copyright 2011-2014 Damian Yerrick
# (Edited by Pubby)
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#

# These are used in the title of the NES program
title := lunarlimit
version := 0.01

# Space-separated list of assembly language files that make up the
# PRG ROM.  If it gets too long for one line, you can add a backslash
# (the \ character) at the end of the line and continue on the next.
objlist := nrom init main trig globals palette gamepad bullet rng sprites \
player trig_tables bitset enemies wave famitone2 sfx music


AS65 := ca65
LD65 := ld65
CFLAGS65 := --cpu 6502X
objdir := obj/nes
srcdir := src
imgdir := tilesets

EMU := fceux
DEBUG_EMU := wine fceux/fceux.exe

TEXT2DATA := wine tools/text2data.exe
NSF2DATA := wine tools/nsf2data.exe

.PHONY: all run clean

all: $(title).nes 

run: $(title).nes
	$(EMU) $<

debug: $(title).nes
	$(DEBUG_EMU) $<

clean:
	-rm $(objdir)/*.o $(objdir)/*.s $(objdir)/*.chr

# Rules for PRG ROM

objlistntsc := $(foreach o,$(objlist),$(objdir)/$(o).o)

map.txt $(title).nes: nrom128.cfg $(objlistntsc)
	$(LD65) -o $(title).nes -m map.txt -C $^

$(objdir)/%.o: $(srcdir)/%.s $(srcdir)/nes.inc $(srcdir)/globals.inc $(srcdir)/metasprites.inc
	$(AS65) $(CFLAGS65) $< -o $@

$(objdir)/%.o: $(objdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

# Files that depend on .incbin'd files
$(objdir)/main.o: $(srcdir)/bg.chr $(srcdir)/sprites.chr

# Rules for CHR ROM

$(title).chr: $(srcdir)/bg.chr $(srcdir)/sprites.chr
	cat $^ > $@

$(srcdir)/%.chr: $(imgdir)/%.png
	tools/pilbmp2nes.py $< $@

$(srcdir)/%.chr: $(imgdir)/%.png
	tools/pilbmp2nes.py $< $@

# cpp
chrc: chrc.cpp
	 $(CXX) -std=c++14 $< -o $@

dirc: dirc.cpp
	 $(CXX) -std=c++14 $< -o $@

trigtablegen: trigtablegen.cpp
	 $(CXX) -std=c++14 $< -o $@

$(srcdir)/trig_tables.s: trigtablegen
	./trigtablegen $@

metaspritegen: metaspritegen.cpp
	 $(CXX) -std=c++14 $< -o $@

$(srcdir)/metasprites.inc: metaspritegen
	./metaspritegen $@

wavegen: wave.cpp
	 $(CXX) -std=c++14 $< -o $@

$(srcdir)/wave.s: wavegen
	./wavegen $@
