# Define compilation type
OSTYPE  = odgcw0
TARGET = spout/spout.dge

CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CC  := $(CROSS_COMPILE)gcc
LD  := $(CROSS_COMPILE)gcc

F_OPTS = -falign-functions -falign-loops -falign-labels -falign-jumps \
  -ffast-math -fsingle-precision-constant -funsafe-math-optimizations \
  -fomit-frame-pointer -fno-builtin -fno-common \
  -fstrict-aliasing  -fexpensive-optimizations \
  -finline -finline-functions -fpeel-loops

CC_OPTS	= -O2 -mips32 -mhard-float -G0 $(F_OPTS)

CFLAGS      = -DOPENDINGUX $(CC_OPTS)
LDFLAGS     = $(CC_OPTS) -lSDL 

# Files to be compiled
OBJS        = src/spout.o src/piece.o

# Rules to make executable
all: $(OBJS)
	$(LD) -s $(LDFLAGS) -o $(TARGET) $^

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

src/spout.o: src/piece.h src/font.h src/sintable.h
src/piece.c: src/piece.h

ipk: all
	@rm -rf /tmp/.spout-ipk/ && mkdir -p /tmp/.spout-ipk/root/home/retrofw/games/spout /tmp/.spout-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r spout/spout.elf spout/spout.png spout/spout.man.txt /tmp/.spout-ipk/root/home/retrofw/games/spout
	@cp spout/spout.lnk /tmp/.spout-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" spout/control > /tmp/.spout-ipk/control
	@cp spout/conffiles /tmp/.spout-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.spout-ipk/control.tar.gz -C /tmp/.spout-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.spout-ipk/data.tar.gz -C /tmp/.spout-ipk/root/ .
	@echo 2.0 > /tmp/.spout-ipk/debian-binary
	@ar r spout/spout.ipk /tmp/.spout-ipk/control.tar.gz /tmp/.spout-ipk/data.tar.gz /tmp/.spout-ipk/debian-binary

opk: all
	@mksquashfs \
	spout/default.retrofw.desktop \
	spout/spout.dge \
	spout/spout.png \
	spout/spout.man.txt \
	spout/spout.opk \
	-all-root -noappend -no-exports -no-xattrs

clean:
	rm -f $(TARGET) src/*.o
