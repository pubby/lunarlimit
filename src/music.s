;this file for FamiTone2 library generated by text2data tool
.export music_data
music_data:
	.byte 1
	.word @instruments
	.word @samples-3
	.word @song0ch0,@song0ch1,@song0ch2,@song0ch3,@song0ch4,307,256

@instruments:

@samples:
@env0:
	.byte $c0,$00,$00


@song0ch0:
	.byte $fb,$06
@song0ch0loop:
@ref0:
	.byte $f9,$85
	.byte $fd
	.word @song0ch0loop

@song0ch1:
@song0ch1loop:
@ref1:
	.byte $f9,$85
	.byte $fd
	.word @song0ch1loop

@song0ch2:
@song0ch2loop:
@ref2:
	.byte $f9,$85
	.byte $fd
	.word @song0ch2loop

@song0ch3:
@song0ch3loop:
@ref3:
	.byte $f9,$85
	.byte $fd
	.word @song0ch3loop

@song0ch4:
@song0ch4loop:
@ref4:
	.byte $f9,$85
	.byte $fd
	.word @song0ch4loop
