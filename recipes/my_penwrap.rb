# Enable/disable penwrap, a pen TCP proxy wrapper

# Install
penwrap_service = "penwrap"
package_manager.install "pen"
penwrap = "/etc/init.d/#{penwrap_service}"
cp(dist+penwrap, penwrap)

if tagged?(:standby)
  # Shutoff apache, but only if it's already enabled
  apache_service = "apache2"
  if service_manager.enabled?(apache_service)
    service_manager.stop(apache_service)
    service_manager.disable(apache_service)
  end

  # Startup penwrap
  service_manager.enable(penwrap_service)
  service_manager.start(penwrap_service)
else
  # Shutoff penwrap
  service_manager.stop(penwrap_service)
  service_manager.disable(penwrap_service)
end
