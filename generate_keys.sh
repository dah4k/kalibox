#!/bin/sh
# Copyright 2024 dah4k
# SPDX-License-Identifier: MIT-0

ssh-keygen -t ed25519 -C "vagrant@localhost" -f "secrets/id_ed25519"
