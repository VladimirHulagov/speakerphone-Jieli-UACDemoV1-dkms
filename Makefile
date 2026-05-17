# Speakerphone Jieli UACDemoV1.0 - Kbuild Makefile
# Full snd-usb-audio rebuild from patched kernel source

# Match kernel 6.18 sound/usb/Makefile — all required objects
snd-usb-audio-y := card.o clock.o endpoint.o fcp.o format.o \
		helper.o implicit.o mixer.o mixer_quirks.o \
		mixer_scarlett.o mixer_scarlett2.o mixer_us16x08.o \
		mixer_s1810c.o pcm.o power.o proc.o quirks.o \
		stream.o validate.o media.o

snd-usbmidi-lib-y := midi.o

obj-m += snd-usb-audio.o
obj-m += snd-usbmidi-lib.o

# Prefix with sound/usb/ path
snd-usb-audio-y := $(addprefix sound/usb/,$(snd-usb-audio-y))
snd-usbmidi-lib-y := $(addprefix sound/usb/,$(snd-usbmidi-lib-y))
