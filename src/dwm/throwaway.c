#include <stdio.h>
#include <stdlib.h>

int main(void) {
	char lookup[] = { ['0'] = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

	char ch;
	int acc = 0;
	int mult = 1;
	while ((ch = fgetc(stdin))) {
		if (ch >= '0' && ch <= '9') {
			acc = (acc * 10) + lookup[ch];
		} else {
			printf("Number: %d\n", mult * acc);
			acc = 0;
			mult = ch == '-' ? -1 : 1;
		}
		if (ch == EOF)
			break;
	}
	return 0;
}
