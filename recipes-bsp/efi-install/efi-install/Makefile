ARCH ?= $(shell uname -m | sed s,i[3456789]86,ia32,)
OBJS = efi-install.o
TARGET = efi-install.efi

SYSROOT ?= 

EFIINC = $(SYSROOT)/usr/include/efi
EFIINCS = -I$(EFIINC) -I$(EFIINC)/$(ARCH) -I$(EFIINC)/protocol
LIB  = $(SYSROOT)/usr/lib
EFILIB = $(SYSROOT)/usr/lib
EFI_CRT_OBJS = $(EFILIB)/crt0-efi-$(ARCH).o
EFI_LDS = $(EFILIB)/elf_$(ARCH)_efi.lds

CFLAGS += $(EFIINCS) -fno-stack-protector -fpic \
					-fshort-wchar -mno-red-zone -Wall 
ifeq ($(ARCH),x86_64)
  CFLAGS += -DEFI_FUNCTION_WRAPPER
endif

LDFLAGS = -nostdlib -znocombreloc -T $(EFI_LDS) -shared \
		-Bsymbolic -L $(EFILIB) -L $(LIB) $(EFI_CRT_OBJS) 

all: $(TARGET)

efi-install.so: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ -lefi -lgnuefi

%.efi: %.so
	objcopy -j .text -j .sdata -j .data -j .dynamic \
		-j .dynsym  -j .rel -j .rela -j .reloc \
		--target=efi-app-$(ARCH) $^ $@