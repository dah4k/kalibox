DEFAULT: poc

all: test_clearenv test_pwnkit inject.so

test: test_clearenv inject.so
	LD_PRELOAD=./inject.so ./test_clearenv

poc: test_pwnkit inject.so
	./test_pwnkit

clean:
	rm -f test_clearenv test_pwnkit inject.so

test_%: test_%.c
	gcc -Wall -g $< -o $@

inject.so: inject.c
	gcc -Wall -g -fPIC -shared $< -ldl -o $@

.PHONY: all test poc clean
