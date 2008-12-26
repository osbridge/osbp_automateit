# Setup mail client and server
#
# NOTE: Configure "exim#aliases" fields with hash of key value pairs to setup
# aliasing. E.g., add a "root" element to define who gets root's email.

package_manager.install <<-HERE
  # User programs
  mutt mailx

  # Server programs
  exim4 exim4-base eximon4 exim4-doc-html exim4-doc-info libwww-perl
HERE

# Setup aliases
aliases = lookup('exim#aliases') rescue nil
if aliases
  raise "exim#aliases field's value must be a Hash" unless aliases.is_a?(Hash)
  modified = \
    edit :file => "/etc/aliases" do
      aliases.each_pair do |key, value|
        line = "#{key}: #{value}"
        prefix = /^#{key}:/
        unless contains?(line)
          if contains?(prefix)
            comment prefix
          end
          append line
        end
      end
    end
  sh 'newaliases' if modified
end
