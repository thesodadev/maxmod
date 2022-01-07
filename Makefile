# There potential problem with common source files 
# they need to be build for each platform independetly
# as a workaround use `make clean` before each build

# Lib version 1.0.12 

TARGET ?= ARM9

# Toolchain
LD = arm-none-eabi-gcc
AS = arm-none-eabi-as
AR = arm-none-eabi-gcc-ar

ARCHFLAGS = -mthumb \
  			-mthumb-interwork \
			-DSYS_NDS
ARFLAGS = -rcs

COMMON_SRC_DIR = source
COMMON_SRC_FILES = $(wildcard $(COMMON_SRC_DIR)/*.s)

ifeq ($(TARGET),ARM9)
	BIN_NAME = libmm9.a

	GFX_DIR = res/gfx
	FONTS_DIR = res/fonts
	ARM9_SRC_DIR = source/arm9

	SRC_FILES = $(wildcard $(ARM9_SRC_DIR)/*.s)

	ARCHFLAGS += -march=armv5te \
				 -mtune=arm946e-s \
				 -DSYS_NDS9
else
	BIN_NAME = libmm7.a

	ARM7_SRC_DIR = source/arm7
	SRC_FILES = $(wildcard $(ARM7_SRC_DIR)/*.s)

	ARCHFLAGS += -march=armv4t \
				 -mcpu=arm7tdmi \
				 -mtune=arm7tdmi \
				 -DSYS_NDS7
endif

OBJ_FILES += $(patsubst %.s,%.o, $(patsubst %.c,%.o, $(COMMON_SRC_FILES) $(SRC_FILES)))

ASFLAGS = -x assembler-with-cpp \
		  $(ARCHFLAGS)

# Build rules
$(BIN_NAME): $(OBJ_FILES)
	$(AR) $(ARFLAGS) $@ $^

%.o: %.s
	$(CC) $(ASFLAGS) -c $< -o $@

# General rules
.PHONY: all clean rebuild install

all: $(BIN_NAME)

clean:
	rm -rf $(OBJ_FILES) $(BIN_NAME)

rebuild: clean all

PREFIX ?= /usr/lib

install:
	install -d $(DESTDIR)$(PREFIX)/arm-none-eabi/include/maxmod
	cp -fr include/* $(DESTDIR)$(PREFIX)/arm-none-eabi/include/maxmod
	chmod -R 644 $(DESTDIR)$(PREFIX)/arm-none-eabi/include/maxmod
	install -d $(DESTDIR)$(PREFIX)/arm-none-eabi/lib
	install -m 644 $(BIN_NAME) $(DESTDIR)$(PREFIX)/arm-none-eabi/lib
