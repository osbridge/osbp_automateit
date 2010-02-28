# Use existing gems
filename = "/usr/local/lib/ruby/site_ruby/1.8/rubygems.rb"
if File.exist?(filename)
  edit filename do
    manipulate do |buffer|
      unless contains? /GEM_PATH hacked/
        buffer.sub!(
          %r{(^\n)},
          %{\\1# GEM_PATH hacked\nENV['GEM_PATH'] ||= '/usr/lib/ruby/gems/1.8'\n\n})
      end
      buffer
    end
  end
end
