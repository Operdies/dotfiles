#pragma once

/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
	((hex >> 16) & 0xFF) / 255.0f, \
	((hex >> 8) & 0xFF) / 255.0f, \
	(hex & 0xFF) / 255.0f }

#define col(name, code) static const float col_##name[] = COLOR(((code << 8) | 0xff))

col(Rosewater, 0xf5e0dc);
col(Flamingo, 0xf2cdcd);
col(Pink, 0xf5c2e7);
col(Mauve, 0xcba6f7);
col(Red, 0xf38ba8);
col(Maroon, 0xeba0ac);
col(Peach, 0xfab387);
col(Yellow, 0xf9e2af);
col(Green, 0xa6e3a1);
col(Teal, 0x94e2d5);
col(Sky, 0x89dceb);
col(Sapphire, 0x74c7ec);
col(Blue, 0x89b4fa);
col(Lavender, 0xb4befe);
col(Text, 0xcdd6f4);
col(Subtext1, 0xbac2de);
col(Subtext0, 0xa6adc8);
col(Overlay2, 0x9399b2);
col(Overlay1, 0x7f849c);
col(Overlay0, 0x6c7086);
col(Surface2, 0x585b70);
col(Surface1, 0x45475a);
col(Surface0, 0x313244);
col(Base, 0x1e1e2e);
col(Mantle, 0x181825);
col(Crust, 0x11111b);
