X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

# includes and libs
INCS = -I${X11INC}
LIBS = -L${X11LIB} -lX11 -lXi

CFLAGS   = -std=c99 -pedantic -Wall -Wno-deprecated-declarations -Os ${INCS} ${CPPFLAGS} -D_POSIX_C_SOURCE
LDFLAGS  = ${LIBS}

CC = cc

xautobacklight: xautobacklight.c
