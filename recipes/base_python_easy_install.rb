# Setup Python's easy_install

package_manager.install %w[python python-dev]

# Setup PEAK easy_install
unless which 'easy_install'
  mktempdircd do
    download 'http://peak.telecommunity.com/dist/ez_setup.py'
    sh 'python ez_setup.py'
  end
end
