# Setup common Ruby packages

package_manager.install <<-HERE, :with => :gem, :docs => false
  ruby-debug
HERE

package_manager.install "rails", :version => "2.1.2", :with => :gem, :docs => false
