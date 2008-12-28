# Setup GitHub RubyGem repository

unless `gem sources`.match(/gems.github.com/m)
  sh "gem sources -a http://gems.github.com"
end
