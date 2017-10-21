require 'spec_helper'

describe 'aodh::wsgi::apache' do

  shared_examples_for 'apache serving aodh with mod_wsgi' do
    context 'with default parameters' do
      it { is_expected.to contain_class('aodh::params') }
      it { is_expected.to contain_class('apache') }
      it { is_expected.to contain_class('apache::mod::wsgi') }
      it { is_expected.to contain_class('apache::mod::ssl') }
      it { is_expected.to contain_openstacklib__wsgi__apache('aodh_wsgi').with(
        :bind_port                   => 8042,
        :group                       => 'aodh',
        :path                        => '/',
        :servername                  => facts[:fqdn],
        :ssl                         => true,
        :threads                     => 1,
        :user                        => 'aodh',
        :workers                     => facts[:os_workers],
        :wsgi_daemon_process         => 'aodh',
        :wsgi_process_group          => 'aodh',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'app',
        :wsgi_script_source          => platform_params[:wsgi_script_source],
        :custom_wsgi_process_options => {},
        :access_log_file             => false,
        :access_log_format           => false,
      )}
    end

    context 'when overriding parameters using different ports' do
      let :params do
        {
          :servername                  => 'dummy.host',
          :bind_host                   => '10.42.51.1',
          :port                        => 12345,
          :ssl                         => false,
          :wsgi_process_display_name   => 'aodh',
          :workers                     => 37,
          :custom_wsgi_process_options => {
            'python_path' => '/my/python/path',
          },
          :access_log_file             => '/var/log/httpd/access_log',
          :access_log_format           => 'some format',
          :error_log_file              => '/var/log/httpd/error_log'
        }
      end
      it { is_expected.to contain_class('aodh::params') }
      it { is_expected.to contain_class('apache') }
      it { is_expected.to contain_class('apache::mod::wsgi') }
      it { is_expected.to_not contain_class('apache::mod::ssl') }
      it { is_expected.to contain_openstacklib__wsgi__apache('aodh_wsgi').with(
        :bind_host                 => '10.42.51.1',
        :bind_port                 => 12345,
        :group                     => 'aodh',
        :path                      => '/',
        :servername                => 'dummy.host',
        :ssl                       => false,
        :threads                   => 1,
        :user                      => 'aodh',
        :workers                   => 37,
        :wsgi_daemon_process       => 'aodh',
        :wsgi_process_display_name => 'aodh',
        :wsgi_process_group        => 'aodh',
        :wsgi_script_dir           => platform_params[:wsgi_script_path],
        :wsgi_script_file          => 'app',
        :wsgi_script_source        => platform_params[:wsgi_script_source],
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
            :httpd_service_name => 'apache2',
            :httpd_ports_file   => '/etc/apache2/ports.conf',
            :wsgi_script_path   => '/usr/lib/cgi-bin/aodh',
            :wsgi_script_source => '/usr/share/aodh/app.wsgi'
          }
        when 'RedHat'
          {
            :httpd_service_name => 'httpd',
            :httpd_ports_file   => '/etc/httpd/conf/ports.conf',
            :wsgi_script_path   => '/var/www/cgi-bin/aodh',
            :wsgi_script_source => '/usr/lib/python2.7/site-packages/aodh/api/app.wsgi'
          }

        end
      end
      it_configures 'apache serving aodh with mod_wsgi'
    end
  end

end
