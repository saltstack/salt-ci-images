source "https://rubygems.org"

gem "test-kitchen"
gem "kitchen-salt", :git => 'https://github.com/saltstack/kitchen-salt.git'
gem 'kitchen-docker', :git => 'https://github.com/test-kitchen/kitchen-docker.git'

group :windows do
  gem 'vagrant-wrapper'
  gem 'kitchen-vagrant'
  gem 'winrm', '~>2.0'
  gem 'winrm-fs', '~>1.0'
end

group :appveyor do
  gem 'test-kitchen'
  gem "kitchen-salt", :git => 'https://github.com/saltstack/kitchen-salt.git'
  gem 'kitchen-vagrant'
  gem 'winrm', '~>2.0'
  gem 'winrm-fs', '~>1.0'
end
