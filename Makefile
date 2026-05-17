\
# Speakerphone Jieli UACDemoV1.0 DKMS Makefile
# Rebuilds snd-usb-audio from kernel source with Jieli quirk

KVER ?= $(shell uname -r)
KBUILD := /lib/modules/$(KVER)/build

# Locate kernel source tree
KSRC := $(shell readlink -f /lib/modules/$(KVER)/source 2>/dev/null)
ifeq ($(wildcard $(KSRC)/sound/usb/card.c),)
  KSRC := /usr/src/linux-$(KVER)
endif
ifeq ($(wildcard $(KSRC)/sound/usb/card.c),)
  KSRC := $(wildcard /usr/src/linux-source-$(KVER))
endif
ifeq ($(wildcard $(KSRC)/sound/usb/card.c),)
  # Try extracting from .tar.xz
  ifneq ($(wildcard /usr/src/linux-source-$(firstword $(subst ., ,$(KVER))).tar.xz),)
    $(shell mkdir -p /tmp/speakerphone-ksrc && \
      tar -xf /usr/src/linux-source-$(firstword $(subst ., ,$(KVER))).tar.xz \
        -C /tmp/speakerphone-ksrc --strip-components=1 --wildcards '*/sound/usb' 2>/dev/null)
    KSRC := /tmp/speakerphone-ksrc
  endif
endif

ifeq ($(wildcard $(KSRC)/sound/usb/card.c),)
  $(error Kernel source not found. Install: apt install linux-source-$(KVER) or ensure /lib/modules/$(KVER)/source exists)
endif

PWD := $(shell pwd)
BUILD_DIR := $(PWD)/_kbuild

.PHONY: all clean modules prepare

all: modules

modules: prepare
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
