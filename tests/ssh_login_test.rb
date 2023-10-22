require 'test/unit'
require 'net/ssh'
require 'open3'

class SSHLoginTest < Test::Unit::TestCase
    def setup
        @default_username = 'vagrant'
        @default_password = 'vagrant'
        @guest_addr = '127.0.0.1'
        @guest_port = 2222

        @vagrant_insecure_key = '~/.vagrant.d/insecure_private_key'
        @vagrant_new_key = File.join(
            File.dirname(__FILE__),
            '../.vagrant/machines/default/virtualbox/private_key')

        @remote_cmd = 'id'
        @expected = "uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant),4(adm),20(dialout),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),106(netdev),118(wireshark),121(bluetooth),134(scanner),141(vboxsf),142(kaboxer)\n"
    end

    def teardown
    end

    def test_ssh_with_default_username_password_is_denied
        assert_raise Net::SSH::AuthenticationFailed do
            ssh = Net::SSH.start(
                @guest_addr,
                @default_username,
                :port => @guest_port,
                :password => @default_password,
                :non_interactive => true,
            )
            result = ssh.exec!(@remote_cmd)
            puts result
            ssh.close
        end
    end

    def test_ssh_with_insecure_key_is_denied
        assert_raise Net::SSH::AuthenticationFailed do
            ssh = Net::SSH.start(
                @guest_addr,
                @default_username,
                :port => @guest_port,
                :non_interactive => true,
                :keys_only => true,
                :keys => [ @vagrant_insecure_key ]
            )
            result = ssh.exec!(@remote_cmd)
            puts result
            ssh.close
        end
    end

    def test_ssh_with_new_key_is_allowed
        ssh = Net::SSH.start(
            @guest_addr,
            @default_username,
            :port => @guest_port,
            :non_interactive => true,
            :keys_only => true,
            :keys => [ @vagrant_new_key ]
        )
        result = ssh.exec!(@remote_cmd)
        assert_equal @expected, result
        ssh.close
    end

    def test_ssh_with_insecure_key_is_denied_2
        cmd = "ssh -T -F none -i #{@vagrant_insecure_key} -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p #{@guest_port} #{@default_username}@#{@guest_addr} -- #{@remote_cmd}"
        Open3.popen3(cmd) do |stdin, stdout, stderr|
            error_msg = stderr.read
            assert_match "Permission denied", error_msg
        end
    end

    def test_ssh_with_new_key_is_allowed_2
        cmd = "ssh -T -F none -i #{@vagrant_new_key} -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p #{@guest_port} #{@default_username}@#{@guest_addr} -- #{@remote_cmd}"
        Open3.popen3(cmd) do |stdin, stdout, stderr|
            result = stdout.read
            assert_equal @expected, result
        end
    end
end
