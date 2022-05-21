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
    config.vm.box_version = "2022.1.0"

    config.vm.provider "virtualbox" do |vb|
        vb.name = "kalibox"
        vb.gui = @enable_gui
        vb.linked_clone = true
        vb.memory = 2048
        vb.cpus = 1
    end

    # Disable default sharing current directory
    config.vm.synced_folder ".", "/vagrant", disabled: true

    # Reconfigure Grub
    # Faster boot time by eliminating Grub default 5 seconds timeout.
    # Known limitation: First VM boot is still 5 delayed.
    config.vm.provision "Reconfigure Grub", type: "shell",
        inline: <<-SHELL
            sed -i -e 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
            update-grub
        SHELL

    # SSH Hardening
    # - Enable PubkeyAuthentication
    # - Disable PasswordAuthentication
    # - Disable ChallengeResponseAuthentication
    # - UsePAM is required for account and session check, but without PasswordAuth or CRAM
    # - Disable RootLogin
    config.vm.provision "SSH Hardening", type: "shell",
        inline: <<-SHELL
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
    config.vm.provision "Fix Kali ZSH ^P", type: "shell",
        inline: <<-SHELL
            sed -i -E \
                -e 's/^zle -N toggle_oneline_prompt/#zle -N toggle_oneline_prompt/' \
                -e 's/^bindkey .P toggle_oneline_prompt/#bindkey ^P toggle_oneline_prompt/' \
                /etc/skel/.zshrc \
                /etc/zsh/newuser.zshrc.recommended \
                /root/.zshrc \
                /home/vagrant/.zshrc
        SHELL

    if @enable_gui
        # Enable LightDM Auto-Login
        config.vm.provision "Enable LightDM Auto-Login (GUI VM)", type: "shell",
            inline: <<-SHELL
                sed -i -E \
                    -e 's/^#?autologin-user=.*/autologin-user=vagrant/' \
                    /etc/lightdm/lightdm.conf
                systemctl enable lightdm
                systemctl restart lightdm
            SHELL
    else
        # Disable LightDM service
        # Headless VM does not need LightDM and Xorg to be running.
        config.vm.provision "Disable LightDM service (Headless VM)", type: "shell",
            inline: <<-SHELL
                systemctl disable lightdm
                systemctl stop lightdm
            SHELL
    end

    # Personalize user workspace
    # - Remove PulseAudio and PipeWire (CPU and Memory savings)
    # - Remove Nano (Vi is good enough)
    # - Install favorite tools (ie. Ripgrep and Fd-Find)
    # - Fix borken and install GDB
    # - Hush login to hide Python2 message
    # - Upload dotfiles
    config.vm.provision "Personalize installed packages", type: "shell",
        inline: <<-SHELL
            DEBIAN_FRONTEND=noninteractive apt-get autoremove \
                --quiet=2 \
                --assume-yes \
                pulseaudio pipewire nano
            DEBIAN_FRONTEND=noninteractive apt-get install \
                --quiet=2 \
                --assume-yes \
                --no-install-recommends \
                ripgrep fd-find
        SHELL
    config.vm.provision "Fix and Install GDB", type: "shell",
        inline: <<-SHELL
            DEBIAN_FRONTEND=noninteractive apt-get -y update
            DEBIAN_FRONTEND=noninteractive apt-get -y --fix-broken install
            DEBIAN_FRONTEND=noninteractive apt-get -y install gdb
        SHELL
    config.vm.provision "Hush login", type: "shell", privileged: false,
        inline: "touch /home/vagrant/.hushlogin"
    config.vm.provision "Upload .bash_aliases", type: "file",
        source: "dotfiles/bash_aliases", destination: "/home/vagrant/.bash_aliases"
    config.vm.provision "Upload .vimrc", type: "file",
        source: "dotfiles/vimrc", destination: "/home/vagrant/.vimrc"
    config.vm.provision "Upload .Xmodmap", type: "file",
        source: "dotfiles/Xmodmap", destination: "/home/vagrant/.Xmodmap"

    # Start client VPN service
    # Reference: https://wiki.archlinux.org/title/OpenVPN#Starting_OpenVPN
    ClientOVPN = File.join(File.dirname(__FILE__), "secrets/client.ovpn")
    if File.exist? ClientOVPN
        # File provision "SCP" as user and cannot write directly to /etc
        config.vm.provision "Upload VPN config to /tmp", type: "file",
            source: ClientOVPN, destination: "/tmp/client.ovpn"

        config.vm.provision "Configure client VPN", type: "shell",
            inline: <<-SHELL
                chown root:root /tmp/client.ovpn
                chmod 0660 /tmp/client.ovpn
                mv /tmp/client.ovpn /etc/openvpn/client/client.conf
            SHELL

        # Known issue: Systemd sometime writes info message to stderr.
        # Vagrant displays anything from stderr in red color.
        # They are not real errors and may be safely ignored.
        config.vm.provision "Start client VPN service", type: "shell",
            inline: <<-SHELL
                systemctl enable openvpn-client@client.service
                systemctl start openvpn-client@client.service
            SHELL
    end
end
