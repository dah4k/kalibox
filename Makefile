all:
	vagrant up

test:
	ruby tests/*

clean:
	vagrant destroy --force

.PHONY: all test clean
