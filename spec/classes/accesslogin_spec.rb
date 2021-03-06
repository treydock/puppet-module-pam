require 'spec_helper'
describe 'pam::accesslogin' do
  describe 'access.conf' do
    context 'with default values on supported platform' do
      let(:facts) do
        {
          :osfamily                   => 'RedHat',
          :operatingsystemmajrelease  => '5',
        }
      end

      it { should contain_class('pam') }

      it {
        should contain_file('access_conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/security/access.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => [ 'Package[pam]', 'Package[util-linux]' ],
        })
      }

      it "should contain default allowed_users" do
        verify_contents(subject, 'access_conf', [
          '+ : root : ALL',
          '- : ALL : ALL',
        ])
      end
    end

    context 'with multiple users on supported platform expressed as an array' do
      let(:facts) do
        {
          :osfamily                   => 'RedHat',
          :operatingsystemmajrelease  => '5',
        }
      end
      let(:pre_condition) do
          'class {"pam": allowed_users => ["foo","bar"] }'
      end

      it { should contain_class('pam') }

      it {
        should contain_file('access_conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/security/access.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => [ 'Package[pam]', 'Package[util-linux]' ],
        })
      }

      it "should contain allowed_users" do
        verify_contents(subject, 'access_conf', [
          '+ : foo : ALL',
          '+ : bar : ALL',
          '- : ALL : ALL',
        ])
      end
    end

    context 'with hash entry containing string values' do
      let(:facts) do
        {
          :osfamily                   => 'RedHat',
          :operatingsystemmajrelease  => '5',
        }
      end
      let(:pre_condition) do
          'class {"pam": allowed_users => {"username1" => "cron", "username2" => "tty0"} }'
      end

      it "should contain allowed_users" do
        verify_contents(subject, 'access_conf', [
          '+ : username1 : cron',
          '+ : username2 : tty0',
          '- : ALL : ALL',
        ])
      end
    end

    context 'with hash entry containing array of values' do
      let(:facts) do
        {
          :osfamily                   => 'RedHat',
          :operatingsystemmajrelease  => '5',
        }
      end
      let(:pre_condition) do
          'class {"pam": allowed_users => {"username" => ["cron", "tty0"]} }'
      end

      it "should contain allowed_users" do
        verify_contents(subject, 'access_conf', [
          '+ : username : cron tty0',
          '- : ALL : ALL',
        ])
      end
    end

    context 'with hash entry containing no value should default to "ALL"' do
      let(:facts) do
        {
          :osfamily                   => 'RedHat',
          :operatingsystemmajrelease  => '5',
        }
      end
      let(:pre_condition) do
          'class {"pam": allowed_users => {"username" => {} }}'
      end

      it "should contain allowed_users" do
        verify_contents(subject, 'access_conf', [
          '+ : username : ALL',
          '- : ALL : ALL',
        ])
      end
    end

    context 'with hash entries containing string, array and empty hash' do
      let(:facts) do
        {
          :osfamily                   => 'RedHat',
          :operatingsystemmajrelease  => '5',
        }
      end
      let(:pre_condition) do
          'class {"pam": allowed_users => {"username" => "tty5", "username1" => ["cron", "tty0"], "username2" => "cron", "username3" => "tty0", "username4" => {}}}'
      end

      it "should contain allowed_users" do
        verify_contents(subject, 'access_conf', [
          '+ : username : tty5',
          '+ : username1 : cron tty0',
          '+ : username2 : cron',
          '+ : username3 : tty0',
          '+ : username4 : ALL',
          '- : ALL : ALL',
        ])
      end
    end

    context 'with custom values on supported platform' do
      let(:facts) do
        {
          :osfamily                   => 'RedHat',
          :operatingsystemmajrelease  => '5',
        }
      end

      let(:params) do
        {
          :access_conf_path     => '/custom/security/access.conf',
          :access_conf_owner    => 'guido',
          :access_conf_group    => 'guido',
          :access_conf_mode     => '0777',
        }
      end

      it { should contain_class('pam') }

      it {
        should contain_file('access_conf').with({
          'ensure'  => 'file',
          'path'    => '/custom/security/access.conf',
          'owner'   => 'guido',
          'group'   => 'guido',
          'mode'    => '0777',
          'require' => [ 'Package[pam]', 'Package[util-linux]' ],
        })
      }
    end
  end
end
