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
date_string = Time.now.strftime('%m_%d_%Y')
file_basename = "#{project_name}-#{date_string}"

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
existing_builds = Dir.entries(build_dir).select { |e| e =~ /^#{file_basename}/ }.sort
last_build_number = existing_builds.empty? ? 0 : existing_builds.last.split('-').last.gsub('.zip', '').to_i
last_build_number += 1
filename = "#{file_basename}-#{last_build_number}.zip"
command = "cd \"#{build_dir}\" && zip -r \"#{filename}\" *.app *.mobileprovision *.dSYM"
puts "Executing zip command: #{command}"
puts `#{command}`

puts "Successfully built #{filename}!"
`open "#{build_dir}"`