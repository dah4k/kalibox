all: test_clearenv test_pwnkit inject.so

test: test_clearenv inject.so
	LD_PRELOAD=./inject.so ./test_clearenv

clean:
	rm -f test_clearenv test_pwnkit inject.so

clearenv: inject.so
	LD_PRELOAD=./inject.so ls

test_%: test_%.c
	gcc -Wall $< -o $@

inject.so: inject.c
	gcc -Wall -fPIC -shared $< -ldl -o $@

.PHONY: all test clean
