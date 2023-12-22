{
		typedef struct {
			 int count;
			 const char *icon;
		} counted_icon;
		typedef struct {
			 int rect;
			 int filled
		BarElement tag_elements[LENGTH(tags)] = {0};

		x = m->ww / 2;
		for (i = 0; i < LENGTH(tags); i++) {
			if (!(occ & 1 << i))
				continue;
			counted_icon icons[10] = {0};
			int n_icons = 0;
			for (Client *c = m->clients; c; c = c->next) {
				if (c->tags & 1 << i) {
					XClassHint ch = { NULL, NULL };
					XGetClassHint(dpy, c->win, &ch);
					const char *class    = ch.res_class ? ch.res_class : broken;
					const char *instance = ch.res_name  ? ch.res_name  : broken;

					const char *icon = "";
					for (int i = 0; i < LENGTH(rules); i++) {
						const Rule *r = rules + i;
						if (!r->icon)
							continue;

						if ((r->title && strstr(c->name, r->title)) || 
							(r->class && strstr(class, r->class)) || 
							(r->instance && strstr(instance, r->instance)))	{
							icon = r->icon;
							break;
						}
					}
					int i;
					// Increment the count if the icon matches an existing icon
					for (i = 0; i < n_icons; i++) {
						if (icon == icons[i].icon) {
							icons[i].count++;
							break;
						}
					}
					// Add the icon to the end of the list if there is still room
					if (i < LENGTH(icons) && icons[i].icon == NULL) {
						icons[i].icon = icon;
						icons[i].count = 1;
						n_icons++;
					}
				}
			}
			const char *subscripts[] = {"₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉", "₀"};
			const char *superscripts[] = {" ", " ", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "ⁿ"};

			BarElement *elem = tag_elements + i;
			int n = 0;
			n = snprintf(elem->buffer + n, CHARBUFSIZE-2-n, "%s[ ", subscripts[i]);
			for (int i = 0; i < n_icons; i++) {
				counted_icon *icon = icons + i;
				if (icon->count < 1) 
					icon->count = 1;
				if (icon->count > LENGTH(superscripts)-1) 
					icon->count = LENGTH(superscripts) - 1;
				n += snprintf(elem->buffer + n, CHARBUFSIZE-2-n, "%s%s", icon->icon, superscripts[icon->count]);
				if (n >= CHARBUFSIZE - 2) break;
			}
			elem->buffer[n++] = ']';
			elem->buffer[n] = 0;
			x -= TEXTW(elem->buffer) / 2;
		}
		for (i = 0; i < LENGTH(tags); i++) {
		}
	}
	// if (n_icons > 0) {
	// 	BUFWRITE("%s[ ", subscripts[i]);
	// 	for (int i = 0; i < n_icons; i++) {
	// 		counted_icon *icon = icons + i;
	// 		const char *superscript = superscripts[CLAMP(icon->count, 1, LENGTH(superscripts)-1)];
	// 		BUFWRITE("%s%s", icon->icon, superscript);
	// 	}
	// 	data->e->buffer[n++] = ']';
	// }
	// }
