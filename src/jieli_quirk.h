/* Jieli Technology UACDemoV1.0 Speakerphone (4c4a:4155) */
{
	USB_AUDIO_DEVICE(0x4c4a, 0x4155),
	QUIRK_DRIVER_INFO {
		.vendor_name = "Jieli Technology",
		.product_name = "Speakerphone",
		QUIRK_DATA_COMPOSITE {
			{ QUIRK_DATA_STANDARD_AUDIO(1) },
			{ QUIRK_DATA_STANDARD_AUDIO(2) },
			{ QUIRK_DATA_IGNORE(3) },
			QUIRK_COMPOSITE_END
		}
	}
},
