LIBPS4	:= $(PS4SDK)/libPS4

CC	:= gcc
OBJCOPY	:= objcopy
RM	:= rm
ODIR	:= build
SDIR	:= source
IDIR	:= include
IDIRS	:= -I$(LIBPS4)/include -I$(IDIR)
LDIRS	:= -L$(LIBPS4)
MAPFILE := $(shell basename "$(CURDIR)").map

# Compiler flags
OPTIMIZATION := -Os
STANDARDS    := -std=c11 -fno-builtin -nostartfiles -nostdlib
WARNINGS     := -Wno-unused-const-variable -Wall -Wextra # -Werror
ARCH_FLAGS   := -masm=intel -march=btver2 -mtune=btver2 -m64 -mabi=sysv -mcmodel=small -fpie
CFLAGS       := $(IDIRS) $(OPTIMIZATION) $(STANDARDS) $(WARNINGS) $(ARCH_FLAGS) -ffunction-sections -fdata-sections

LFLAGS	:= $(LDIRS) -Xlinker -T $(LIBPS4)/linker.x -Xlinker -Map=$(MAPFILE) -Wl,--build-id=none -Wl,--gc-sections -Wl,-z,noexecstack

CFILES	:= $(wildcard $(SDIR)/*.c)
SFILES	:= $(wildcard $(SDIR)/*.s)
OBJS	:= $(patsubst $(SDIR)/%.c, $(ODIR)/%.o, $(CFILES)) $(patsubst $(SDIR)/%.s, $(ODIR)/%.o, $(SFILES))

LIBS	:= -lPS4

TARGET = $(shell basename "$(CURDIR)").bin

$(TARGET): $(ODIR) $(OBJS)
	$(CC) $(LIBPS4)/crt0.s $(ODIR)/*.o -o temp.t $(CFLAGS) $(LFLAGS) $(LIBS)
	$(OBJCOPY) -O binary temp.t "$(TARGET)"
	rm -f temp.t

$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) -c -o $@ $< $(CFLAGS)

$(ODIR)/%.o: $(SDIR)/%.s
	$(CC) -c -o $@ $< $(CFLAGS)

$(ODIR):
	@mkdir $@

.PHONY: clean

clean:
	@$(RM) -rf "$(TARGET)" "$(MAPFILE)" $(ODIR)
