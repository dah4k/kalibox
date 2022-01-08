# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'securerandom'

@enable_gui = false
if ARGV.include?('--gui')
    @enable_gui = true
    ARGV.delete('--gui')
elsif ENV["VBOX_GUI"] =~ /1|yes|true/i
    @enable_gui = true
end

SecretPassword = File.join(File.dirname(__FILE__), "secrets/password")
if File.exist?(SecretPassword)
    @username_password = open(SecretPassword).read
else
    @username_password = "vagrant:" << SecureRandom.hex << "\n"
    open(SecretPassword, "w", 0600) {|f| f.write(@username_password)}
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

    # Disable default sharing current directory
    config.vm.synced_folder ".", "/vagrant", disabled: true

    # SSH Hardening
    # - Enable PubkeyAuthentication
    # - Disable PasswordAuthentication
    # - Disable ChallengeResponseAuthentication
    # - UsePAM is required for account and session check, but without PasswordAuth or CRAM
    # - Disable RootLogin
    config.vm.provision "SSH Hardening", type: "shell", inline: <<-SHELL
        sed -i -E \
            -e 's/^#?PubkeyAuthentication .*/PubkeyAuthentication yes/' \
            -e 's/^#?PasswordAuthentication .*/PasswordAuthentication no/' \
            -e 's/^#?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' \
            -e 's/^#?UsePAM .*/UsePAM yes/' \
            -e 's/^#?PermitRootLogin .*/PermitRootLogin no/' \
            /etc/ssh/sshd_config
        systemctl restart sshd
    SHELL

    # Change user password
    config.vm.provision "Change user password", type: "shell",
        inline: "chpasswd <<< #{@username_password}"

    # Fix Kali ZSH ^P history-search
    config.vm.provision "Fix Kali ZSH ^P", type: "shell", inline: <<-SHELL
        sed -i -E \
            -e 's/^zle -N toggle_oneline_prompt/#zle -N toggle_oneline_prompt/' \
            -e 's/^bindkey .P toggle_oneline_prompt/#bindkey ^P toggle_oneline_prompt/' \
            /etc/skel/.zshrc \
            /etc/zsh/newuser.zshrc.recommended \
            /root/.zshrc \
            /home/vagrant/.zshrc
    SHELL

    # Start client VPN service
    # Reference: https://wiki.archlinux.org/title/OpenVPN#Starting_OpenVPN
    ClientOVPN = File.join(File.dirname(__FILE__), "secrets/client.ovpn")
    if File.exist? ClientOVPN
        # File provision "SCP" as user and cannot write directly to /etc
        config.vm.provision "Upload VPN config to /tmp", type: "file",
            source: ClientOVPN, destination: "/tmp/client.ovpn"

        config.vm.provision "Configure client VPN", type: "shell", inline: <<-SHELL
            chown root:root /tmp/client.ovpn
            chmod 0660 /tmp/client.ovpn
            mv /tmp/client.ovpn /etc/openvpn/client/client.conf
        SHELL

        config.vm.provision "Start client VPN service", type: "shell", inline: <<-SHELL
            systemctl enable openvpn-client@client.service
            systemctl start openvpn-client@client.service
        SHELL
    end
end
