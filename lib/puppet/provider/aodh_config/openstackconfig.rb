Puppet::Type.type(:aodh_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/aodh/aodh.conf'
  end

end
