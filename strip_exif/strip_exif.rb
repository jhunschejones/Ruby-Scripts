#!/usr/bin/env ruby
require "open3"

def command_exists?(cmd)
  exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
  ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return true if File.executable?(exe) && !File.directory?(exe)
    end
  end
  false
end

def sanitize_image(file_path)
  unless command_exists?("exiftool")
    abort("Error: This script requires 'exiftool'. Please install it first.")
  end

  unless File.exist?(file_path)
    puts "Skipping... File not found: #{file_path}"
    return
  end

  # Photography terms map to these specific EXIF tag names
  # Note: You may also want to add -ISO if you care about exposure settings!
  tags_to_preserve = %w[
    -FocalLength
    -ExposureTime
    -ISO
    -FNumber
  ]

  puts "Sanitizing: #{file_path}..."

  # The magic happens here:
  # 1. -all=           -> Wipes every single piece of metadata.
  # 2. -tagsfromfile @ -> Looks at the current file in memory.
  # 3. [tags...]       -> Copies only these specific tags back into the clean file.
  # 4. -overwrite_original -> Prevents creating a "_original" backup file.
  command = [
    "exiftool",
    "-all=",
    "-tagsfromfile", "@",
    *tags_to_preserve,
    "-overwrite_original",
    file_path
  ]

  # Open3.capture3 safely executes the command without shell injection risks
  stdout, stderr, status = Open3.capture3(*command)

  if status.success?
    puts "  ✓ Done. Metadata stripped. Preserved Focal Length, Shutter Speed, ISO, and Aperture."
  else
    puts "  ✗ Failed to process: #{stderr.strip}"
  end
end

if ARGV.empty?
  puts "Usage: ruby strip_exif.rb <image1.jpg> <image2.jpg> ..."
else
  ARGV.each { |file| sanitize_image(file) }
end
