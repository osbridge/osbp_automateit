# Setup additional Apache features

mods = %w[
  vhost_alias
]

mods.each do |mod|
  %w[conf load].each do |ext|
    source = "/etc/apache2/mods-available/#{mod}.#{ext}"
    target = "/etc/apache2/mods-enabled/#{mod}.#{ext}"
    if File.exist?(source)
      ln_s source, target
    end
  end
end
