#/usr/bin/env ruby
# This script can be used as a "Run Script" target in XCode to create
# builds for Two Toasters clients with one click. It generates sane filenames,
# ensures you are building properly, and creates a zip containing the apps
# and mobile provisioning profiles needed to install.
# And finally opens the build directory so you can send it out.
build_dir = ENV['TARGET_BUILD_DIR']
platform_name = ENV['PLATFORM_NAME']
configuration = ENV['CONFIGURATION']
config_build_dir = ENV['CONFIGURATION_BUILD_DIR']
project_name = ENV['PROJECT']

version = `agvtool vers -terse`.chomp

# Very that we are on the right platform
if platform_name != 'iphoneos'
  puts "Cannot generate client build on Simulator. Switch to Device and rebuild"
  exit 1
end

# Verify we are on the right configuration
if configuration != 'Release'
  puts "Cannot generate client on Debug. Switch to Release configuration and rebuild"
  exit 1
end

# We are all good, proceed with generating the build
puts "Compressing builds and provisioning profile..."
filename = "#{project_name}-#{version}.zip"
command = "cp Resources/*.mobileprovision #{build_dir}"
puts "Executing zip command: #{command}"
puts `#{command}`
command = "cd \"#{build_dir}\" && zip -r \"#{filename}\" *.app *.mobileprovision *.dSYM"
puts "Executing zip command: #{command}"
puts `#{command}`

puts "Successfully built #{filename}!"
`open "#{build_dir}"`
`agvtool bump`
