# Local-only build rules: no Git commits, uploads, or submission targets.
.DEFAULT_GOAL := all
NAME ?= $(notdir $(CURDIR))
PROGRAM ?= $(NAME)
TEST_PROGRAM ?= $(NAME)_test
BUILD_TARGETS ?= $(PROGRAM)
SRCS ?= $(wildcard *.c)
TEST_SRCS ?= $(SRCS)
HEADERS := $(wildcard *.h tests/*.h) ../testkit/testkit.h
MAKE_DEPS := Makefile ../oslab.mk
CPPFLAGS += -I. -I../testkit
CFLAGS += -O2 -std=gnu2x -ggdb -Wall
OBJCOPY ?= objcopy
TEST_OBJS := $(addprefix .local-test/,$(TEST_SRCS:.c=.o))
TEST_SUPPORT := .local-test/testkit.o .local-test/runner.o

.PHONY: all run test test-verbose clean help
all: $(BUILD_TARGETS)

ifneq ($(PROGRAM),$(TEST_PROGRAM))
$(PROGRAM): $(SRCS) $(HEADERS) ../testkit/testkit.c $(MAKE_DEPS)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(SRCS) ../testkit/testkit.c -o $@ $(LDFLAGS) $(LDLIBS)

run: $(PROGRAM) $(RUN_CHECKS)
	env -u TK_RUN -u TK_VERBOSE ./$(PROGRAM) $(ARGS)
else
run: test
endif

# Rename main after compilation to preserve C's implicit return from main.
# TestKit calls the original main for SystemTest; the runner only exits,
# triggering TestKit without first starting a server or loading input files.
.local-test/%.o: %.c $(HEADERS) $(MAKE_DEPS)
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
	$(OBJCOPY) --redefine-sym main=oslab_program_main $@

.local-test/testkit.o: ../testkit/testkit.c $(HEADERS) $(MAKE_DEPS)
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
	$(OBJCOPY) --redefine-sym main=oslab_program_main $@

.local-test/runner.o: $(MAKE_DEPS)
	@mkdir -p $(@D)
	printf '%s\n' 'int main(void) { return 0; }' | $(CC) $(CPPFLAGS) $(CFLAGS) -x c -c - -o $@

$(TEST_PROGRAM): $(TEST_OBJS) $(TEST_SUPPORT) $(TEST_DEPS) $(MAKE_DEPS)
	$(CC) $(TEST_OBJS) $(TEST_SUPPORT) -o $@ $(LDFLAGS) $(LDLIBS)

# TestKit itself returns zero even when assertions fail. Preserve crashes
# and turn its FAIL reports into a failing make exit status as well.
define run_tests
	@output=$$(mktemp); \
	trap 'rm -f "$$output"' 0; \
	trap 'exit 130' 2; trap 'exit 143' 15; \
	env -u TK_VERBOSE TK_RUN=1 $(1) ./$(TEST_PROGRAM) >"$$output" 2>&1; status=$$?; \
	cat "$$output"; \
	if [ "$$status" -ne 0 ]; then exit "$$status"; fi; \
	if grep -q '^\- \[FAIL\]' "$$output"; then exit 1; fi; \
	if ! grep -q '^TestKit$$' "$$output"; then \
	    printf '%s\n' 'No TestKit cases registered; add cases to the test sources.'; \
	fi
endef

test: $(TEST_PROGRAM) $(TEST_CHECKS)
	$(call run_tests,)

test-verbose: $(TEST_PROGRAM) $(TEST_CHECKS)
	$(call run_tests,TK_VERBOSE=1)

clean:
	$(RM) $(PROGRAM) $(TEST_PROGRAM) $(CLEAN_FILES) .local-test/*.o .local-test/tests/*.o
	@rmdir .local-test/tests .local-test 2>/dev/null || true

help:
	@printf '%s\n' 'make: build' 'make run ARGS="...": run the program (M9: run tests)' 'make test: run local TestKit cases' 'make test-verbose: show failed-case output' 'make clean: remove build products'
