NAME := $(notdir $(CURDIR))
export MODULE := M9

PROGRAM := $(NAME)_test
BUILD_TARGETS := $(NAME).so $(PROGRAM)
LIB_SRCS := $(wildcard *.c)
TEST_SRCS := $(wildcard tests/*.c)
TEST_DEPS := $(NAME).so
LDLIBS += -L. -l:$(NAME).so -Wl,-rpath,'$$ORIGIN'
CLEAN_FILES := $(NAME).so

$(NAME).so: $(LIB_SRCS) $(wildcard *.h) Makefile ../oslab.mk
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -shared $(LIB_SRCS) -o $@ $(LDFLAGS)

include ../oslab.mk
