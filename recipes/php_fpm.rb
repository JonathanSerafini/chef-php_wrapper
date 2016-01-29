# Install the PHP FPM package
package node[:php][:fpm_package]

# Ensure any change to the .ini file triggers a reload of php-fpm
ini = resources(template: "#{node[:php][:conf_dir]}/php.ini")
ini.notifies :reload, "service[#{node[:php][:fpm_service]}]"

# Install the PHP FPM configuration file
template node[:php][:fpm_service_conf] do
  source  "fpm.conf.erb"
  mode    00644
  notifies :restart, "service[#{node[:php][:fpm_service]}]"
end

# Override the upstart service script on ubuntu to resolve broken restart
template "/etc/init/php5-fpm.conf" do
  source  "fpm.upstart.conf.erb"
  mode    00644
  notifies :restart, "service[#{node[:php][:fpm_service]}]"
  only_if do
    'ubuntu' == node['platform']
  end
end

# Create php_pool resources from attributes
node[:php][:fpm_pools].each do |name, hash|
  php_pool name do
    load_properties(hash)
  end
end

# Register the PHP FPM service
service node[:php][:fpm_service] do
  supports start: true, stop: true, restart: true, reload: true
  action [:enable,:start]
end
