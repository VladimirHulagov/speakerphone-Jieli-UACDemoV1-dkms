# Speakerphone Jieli UACDemoV1.0 - Kbuild Makefile
snd-usb-audio-y := card.o clock.o endpoint.o format.o \
		helper.o implicit.o mixer.o mixer_quirks.o \
		pcm.o power.o proc.o quirks.o stream.o validate.o

snd-usbmidi-lib-y := midi.o

obj-m += snd-usb-audio.o
obj-m += snd-usbmidi-lib.o

snd-usb-audio-y := $(addprefix sound/usb/,$(snd-usb-audio-y))
snd-usbmidi-lib-y := $(addprefix sound/usb/,$(snd-usbmidi-lib-y))
