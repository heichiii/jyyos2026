NAME := $(notdir $(CURDIR))
export MODULE := M5

SRCS := $(wildcard *.c tests/*.c)
CFLAGS += -pthread
LDLIBS += -pthread
BUILD_TARGETS := $(NAME) check
TEST_CHECKS := check
CLEAN_FILES := malloc-check

.PHONY: check
check: $(wildcard *.c *.h) Makefile ../oslab.mk
	$(CC) $(CPPFLAGS) -DFREESTANDING -ffreestanding -static -nostdlib -nostartfiles -no-pie -o malloc-check $(wildcard *.c)
	$(RM) malloc-check

include ../oslab.mk
