# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = "kalilinux/rolling"

    config.vm.provider "virtualbox" do |vb|
        vb.name = "kalibox"
        vb.gui = false unless ENV["VBOX_GUI"].to_i > 0
        vb.linked_clone = true
        vb.memory = 2048
        vb.cpus = 1
    end
end
