NAME := $(notdir $(CURDIR))
export MODULE := M6

CFLAGS += -pthread
LDLIBS += -pthread -lm

TEST_CHECKS := check-test-data
RUN_CHECKS := check-test-data

.PHONY: check-test-data
check-test-data:
	@test -f gpt2_124M.bin || { printf '%s\n' 'Missing gpt2_124M.bin: provide the GPT-2 checkpoint in this directory.'; exit 1; }

include ../oslab.mk
