# Copyright 2024 dah4k
# SPDX-License-Identifier: EPL-2.0

start:
	vagrant up

stop:
	vagrant halt

test:
	ruby tests/*

distclean:
	vagrant destroy --force

.PHONY: start stop test distclean
