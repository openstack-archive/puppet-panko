Puppet::Type.type(:panko_api_uwsgi_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/panko/panko-api-uwsgi.ini'
  end

end
