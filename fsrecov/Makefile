NAME := $(notdir $(CURDIR))
export MODULE := M8


TEST_CHECKS := check-test-data

.PHONY: check-test-data
check-test-data:
	@test -f fs.img || { printf '%s\n' 'Missing fs.img: provide the FAT32 test image in this directory.'; exit 1; }

include ../oslab.mk
