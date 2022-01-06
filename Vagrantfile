# -*- mode: ruby -*-
# vi: set ft=ruby :

@enable_gui = false
if ARGV.include?('--gui')
    @enable_gui = true
    ARGV.delete('--gui')
elsif ENV["VBOX_GUI"] =~ /1|yes|true/i
    @enable_gui = true
end

Vagrant.configure("2") do |config|
    config.vm.box = "kalilinux/rolling"

    config.vm.provider "virtualbox" do |vb|
        vb.name = "kalibox"
        vb.gui = @enable_gui
        vb.linked_clone = true
        vb.memory = 2048
        vb.cpus = 1
    end

    # SSH Hardening
    # - Enable PubkeyAuthentication
    # - Disable PasswordAuthentication
    # - Disable ChallengeResponseAuthentication
    # - UsePAM is required for account and session check, but without PasswordAuth or CRAM
    # - Disable RootLogin
    config.vm.provision "shell", inline: <<-SHELL
        sed -i -E \
            -e 's/^#?PubkeyAuthentication .*/PubkeyAuthentication yes/' \
            -e 's/^#?PasswordAuthentication .*/PasswordAuthentication no/' \
            -e 's/^#?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' \
            -e 's/^#?UsePAM .*/UsePAM yes/' \
            -e 's/^#?PermitRootLogin .*/PermitRootLogin no/' \
            /etc/ssh/sshd_config
        systemctl restart sshd
    SHELL
end
