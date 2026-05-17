# Speakerphone Jieli UACDemoV1.0 DKMS Makefile
# Rebuilds snd-usb-audio from kernel source with Jieli quirk

KVER ?= $(shell uname -r)
KBUILD := /lib/modules/$(KVER)/build
KMAJ := $(firstword $(subst ., ,$(KVER))).$(word 2,$(subst ., ,$(KVER)))

# Locate kernel source tree — try multiple locations
KSRC ?= $(shell for d in \
	/lib/modules/$(KVER)/source \
	/lib/modules/$(KVER)/build \
	/usr/src/linux-source-$(KVER) \
	/usr/src/linux-source-$(KMAJ) \
	/usr/src/linux-$(KVER); do \
		if [ -f "$$d/sound/usb/card.c" ]; then echo "$$d"; break; fi; \
	done)

ifeq ($(KSRC),)
  $(error Kernel source with sound/usb/card.c not found)
endif

PWD := $(shell pwd)
BUILD_DIR := $(PWD)/_kbuild

.PHONY: all clean modules

all: modules

modules: prepare
	@echo "==> Building snd-usb-audio from $(KSRC)"
	$(MAKE) -C $(KBUILD) M=$(BUILD_DIR)/sound/usb \
		CONFIG_SND_USB_AUDIO=m \
		CONFIG_SND_USB_AUDIO_MIDI_V2=n \
		CONFIG_SND_USB_AUDIO_USE_MEDIA_CONTROLLER=n \
		modules

prepare: $(BUILD_DIR)/sound/usb/card.c

$(BUILD_DIR)/sound/usb/card.c:
	@echo "==> Using kernel source: $(KSRC)"
	mkdir -p $(BUILD_DIR)
	cp -rL $(KSRC)/sound/usb $(BUILD_DIR)/sound/usb
	@# Insert Jieli quirk into quirks-table.h before #undef lines
	python3 $(PWD)/src/inject_quirk.py $(BUILD_DIR)/sound/usb/quirks-table.h $(PWD)/src/jieli_quirk.h

clean:
	rm -rf $(BUILD_DIR)
