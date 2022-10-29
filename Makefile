SRC_DIR ?= src/
ISO_SRC_DIR ?= iso/
OBJ_DIR ?= tmp/
BIN_DIR ?= bin/

LINKER_SCR ?= linker.ld
TARGET_BIN ?= $(BIN_DIR)os.bin
TARGET_ISO ?= $(BIN_DIR)os.iso

LDFLAGS = --target=i686-pc-none-elf -O2\
 -ffreestanding -nostdlib

CFLAGS = --target=i686-pc-none-elf -march=i686 -O2\
 -ffreestanding -nostdlib -std=c99

.PHONY: clean iso

$(TARGET_BIN): $(BIN_DIR)\
 $(OBJ_DIR)boot.o\
 $(OBJ_DIR)kernel.o\
 $(LINKER_SCR)
	clang $(OBJ_DIR)boot.o $(OBJ_DIR)kernel.o -o $(TARGET_BIN)\
 $(LDFLAGS) -T $(LINKER_SCR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(OBJ_DIR)boot.o: $(OBJ_DIR) $(SRC_DIR)boot.s
	i686-elf-as $(SRC_DIR)boot.s -o $(OBJ_DIR)boot.o

$(OBJ_DIR)kernel.o: $(OBJ_DIR) $(SRC_DIR)kernel.c
	clang -c $(SRC_DIR)kernel.c -o $(OBJ_DIR)kernel.o $(CFLAGS)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

iso: grub.cfg $(TARGET_BIN)
	mkdir -p $(ISO_SRC_DIR)boot/grub
	cp grub.cfg $(ISO_SRC_DIR)boot/grub
	cp $(TARGET_BIN) $(ISO_SRC_DIR)boot
	grub-mkrescue $(ISO_SRC_DIR) -o $(TARGET_ISO)
#	grub-mkimage -p $(ISO_SRC_DIR) -O i386-pc -o $(TARGET_ISO)

clean:
	rm tmp/*.o
