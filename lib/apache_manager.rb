class ApacheManager
  attr_accessor :interpreter
  attr_accessor :mod_extensions
  attr_accessor :config_basedir
  attr_accessor :mods_enabled
  attr_accessor :mods_available
  attr_accessor :sites_enabled
  attr_accessor :sites_available
  attr_accessor :service

  # Initialize an ApacheManager instance for managing an Apache web server.
  #
  # Arguments:
  # * interpreter: An AutomateIt interpreter.
  #
  # Options:
  # * config_basedir: Base directory containing Apache configurations, e.g., "/etc/apache2"
  # * mod_extensions: File extensions used by mods, e.g., ["conf", "load"]
  # * mods_available: Directory with mods available, e.g., "/etc/apache2/mods_available"
  # * mods_enabled: Directory with mods enabled
  # * service: Name of Apache server, e.g., "apache2"
  # * sites_available: Directory with sites available, e.g., "/etc/apache2/sites_available"
  # * sites_enabled: Directory with sites enabled
  def initialize(interpreter, opts={})
    self.interpreter = interpreter
    self.config_basedir = opts[:config_basedir] || '/etc/apache2'
    self.mod_extensions = opts[:mod_extensions] || ['conf', 'load']
    self.mods_available = opts[:mods_available] || "#{self.config_basedir}/mods-available"
    self.mods_enabled = opts[:mods_enabled] || "#{self.config_basedir}/mods-enabled"
    self.service = opts[:service] || "apache2"
    self.sites_available = opts[:sites_available] || "#{self.config_basedir}/sites-available"
    self.sites_enabled = opts[:sites_enabled] || "#{self.config_basedir}/sites-enabled"
  end

  # Enable Apache +mods+. Returns those enabled or false if no change.
  def enable_modules(*mods)
    modified = []
    mods = [mods].flatten
    mods.each do |mod|
      self.mod_extensions.each do |extension|
        source = "#{self.mods_available}/#{mod}.#{extension}"
        target = "#{self.mods_enabled}/#{mod}.#{extension}"
        if File.exist?(source) && interpreter.ln_s(source, target)
          modified << mod
        end
      end
    end
    return(modified.empty? ? false : modified.uniq)
  end
  alias :enable_module :enable_modules

  # Disable Apache +mods+. Returns those disabled or false if no change.
  def disable_modules(*mods)
    modified = []
    mods = [mods].flatten
    mods.each do |mod|
      self.mod_extensions.each do |extension|
        target = "#{self.mods_enabled}/#{mod}.#{extension}"
        if File.exist?(source) && interpreter.rm(target)
          modified << mod
        end
      end
    end
    return(modified.empty? ? false : modified.uniq)
  end
  alias :disable_module :disable_modules

  # Enable Apache +sites+. Returns those enabled or false if no change.
  def enable_sites(*sites)
    modified = []
    sites = [sites].flatten
    sites.each do |site|
      source = "#{self.sites_available}/#{site}"
      target = "#{self.sites_enabled}/#{site}"
      if File.exist?(source) && interpreter.ln_s(source, target)
        modified << site
      end
    end
    return(modified.empty? ? false : modified.uniq)
  end
  alias :enable_site :enable_sites

  # Disable Apache +sites+. Returns those disabled or false if no change.
  def disable_sites(*sites)
    modified = []
    sites = [sites].flatten
    sites.each do |site|
      target = "#{self.sites_enabled}/#{site}"
      if File.exist?(source) && interpreter.rm(source, target)
        modified << site
      end
    end
    return(modified.empty? ? false : modified.uniq)
  end
  alias :disable_site :disable_sites

  # Install Apache +site+. Returns true if installed.
  #
  # Options:
  # * user
  # * group
  # * mode
  # * enable
  # * source
  # * target
  # * template
  def install_site(site, opts={})
    user = opts[:user] || "root"
    group = opts[:group] || "root"
    mode = opts[:mode] || 0444
    enable = opts[:enable] != false
    source = opts[:source] || "#{interpreter.dist}/#{self.sites_available}/#{site}"
    target = opts[:target] || "#{self.sites_available}/#{site}"
    template = opts[:template] || false
    params = opts[:params] || {}

    modified = false
    if template
      template_source = template == true ? "#{source}.erb" : template
      modified |= interpreter.render(template_source, target, :user => user, :group => group, :mode => mode, :params => params)
    else
      modified |= interpreter.cp(source, target, :user => user, :group => group, :mode => mode)
    end
    if enable
      modified |= self.enable_site(site)
    end
    return modified
  end

  # Uninstall Apache +site+
  #
  # Options:
  # * disable
  # * target
  def uninstall_site(site, opts={})
    disable = opts[:disable] != false
    target = opts[:target] || "#{self.sites_available}/#{site}"
    if disable
      modified |= self.disable_site(site)
    end
    modified |= interpreter.rm(site)
    return modified
  end

  # Reload Apache web server using "force-reload".
  def reload
    return interpreter.service_manager.tell(self.service, "force-reload")
  end
end
