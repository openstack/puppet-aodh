require 'spec_helper'

describe 'aodh::wsgi::apache' do

  shared_examples_for 'apache serving aodh with mod_wsgi' do
    context 'with default parameters' do
      it { is_expected.to contain_class('aodh::params') }
      it { is_expected.to contain_openstacklib__wsgi__apache('aodh_wsgi').with(
        :bind_port                   => 8042,
        :group                       => 'aodh',
        :path                        => '/',
        :priority                    => 10,
        :servername                  => facts[:fqdn],
        :ssl                         => false,
        :threads                     => 1,
        :user                        => 'aodh',
        :workers                     => facts[:os_workers],
        :wsgi_daemon_process         => 'aodh',
        :wsgi_process_group          => 'aodh',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'app',
        :wsgi_script_source          => platform_params[:wsgi_script_source],
        :custom_wsgi_process_options => {},
        :access_log_file             => nil,
        :access_log_format           => nil,
      )}
    end

    context 'when overriding parameters using different ports' do
      let :params do
        {
          :servername                  => 'dummy.host',
          :bind_host                   => '10.42.51.1',
          :port                        => 12345,
          :ssl                         => true,
          :wsgi_process_display_name   => 'aodh',
          :workers                     => 37,
          :custom_wsgi_process_options => {
            'python_path' => '/my/python/path',
          },
          :access_log_file             => '/var/log/httpd/access_log',
          :access_log_format           => 'some format',
          :error_log_file              => '/var/log/httpd/error_log',
          :wsgi_script_dir             => '/var/lib/openstack/cgi-bin/aodh',
          :wsgi_script_source          => '/my/path/app.wsgi',
          :vhost_custom_fragment       => 'Timeout 99'
        }
      end
      it { is_expected.to contain_class('aodh::params') }
      it { is_expected.to contain_openstacklib__wsgi__apache('aodh_wsgi').with(
        :bind_host                 => '10.42.51.1',
        :bind_port                 => 12345,
        :group                     => 'aodh',
        :path                      => '/',
        :servername                => 'dummy.host',
        :ssl                       => true,
        :threads                   => 1,
        :user                      => 'aodh',
        :workers                   => 37,
        :vhost_custom_fragment     => 'Timeout 99',
        :wsgi_daemon_process       => 'aodh',
        :wsgi_process_display_name => 'aodh',
        :wsgi_process_group        => 'aodh',
        :wsgi_script_dir           => '/var/lib/openstack/cgi-bin/aodh',
        :wsgi_script_file          => 'app',
        :wsgi_script_source        => '/my/path/app.wsgi',
        :custom_wsgi_process_options => {
          'python_path' => '/my/python/path',
        },
        :access_log_file           => '/var/log/httpd/access_log',
        :access_log_format         => 'some format',
        :error_log_file            => '/var/log/httpd/error_log'
      )}
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :os_workers     => 8,
          :concat_basedir => '/var/lib/puppet/concat',
          :fqdn           => 'some.host.tld'
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            :wsgi_script_path   => '/usr/lib/cgi-bin/aodh',
            :wsgi_script_source => '/usr/bin/aodh-api'
          }
        when 'RedHat'
          {
            :wsgi_script_path   => '/var/www/cgi-bin/aodh',
            :wsgi_script_source => '/usr/bin/aodh-api'
          }

        end
      end
      it_configures 'apache serving aodh with mod_wsgi'
    end
  end

end
