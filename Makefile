start:
	vagrant up

stop:
	vagrant halt

test:
	ruby tests/*

distclean:
	vagrant destroy --force

.PHONY: start stop test distclean
