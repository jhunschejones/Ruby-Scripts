require "fileutils"
require "shellwords"
require_relative "string_utils"

def safe_copy(file:, destination_folder:)
  base = File.basename(file, ".*")           # "example" (without extension)
  ext = File.extname(file)                   # ".txt"
  target = File.join(destination_folder, "#{base}#{ext}")
  counter = 1

  # Loop until we find a filename that doesn't exist
  while File.exist?(target) && ENV["UNSAFE_COPY"] != "true"
    target = File.join(destination_folder, "#{base}_#{counter}#{ext}")
    counter += 1
  end

  FileUtils.cp(file, target)

  target
end

def copy_file_timestamps(from_path:, to_path:)
  # Get the original file's timestamps
  original_stat = File.stat(from_path)
  created_time = original_stat.birthtime rescue nil
  modified_time = original_stat.mtime

  # Update the copied file's timestamps
  File.utime(modified_time, modified_time, to_path)

  # Preserve creation time if supported
  if created_time
    system("SetFile -d '#{created_time.strftime("%m/%d/%Y %H:%M:%S")}' #{Shellwords.escape(to_path)}")
  end
end

if ENV["UNSAFE_COPY"] == "true"
  puts "⚠️  Running in unsafe copy mode: duplicate files at the destination will be overwritten ⚠️".red
  print "Continue? (y/N): "
  answer = gets.chomp.downcase
  unless answer == "y"
    puts "Aborted 🛟"
    exit
  end
end

# change into the SD card
Dir.chdir("/Volumes/OM SYSTEM")

# Olympus / OM System has files in DCIM/100OMSYS/
if Dir.entries(".").include?("DCIM")
  # change into the main DCIM directory
  Dir.chdir("./DCIM")

  folders_count = 0 # right now we don't handle the scenario where there are
                    # multiple folders at this level, so this is a failsafe
  Dir.entries(".").each do |media_folder|
    next if media_folder[0] == "." # skip dot files

    folders_count += 1
    raise "More media folders than expected" if folders_count > 1 # bail out if we have multiple subfolders

    # navigate into the folder (e.g., 100OMSYS)
    Dir.chdir(media_folder)

    # Separate files by type and date
    photos_by_date = Hash.new { |h, key| h[key] = [] }
    videos_by_date = Hash.new { |h, key| h[key] = [] }

    Dir.entries(".").each do |file|
      next if file[0] == "." # skip dot files

      ext = File.extname(file).downcase
      created_at = File.birthtime(file).strftime("%Y-%m-%d")

      # Olympus raw images are .ORF files
      if ext == ".orf"
        photos_by_date[created_at] << file
      # Olympus videos are .MOV or .mp4 files
      elsif ext == ".mov" || ext == ".mp4"
        videos_by_date[created_at] << file
      end
    end

    # Copy photos
    photos_by_date.keys.each do |created_at|
      folder_for_date = FileUtils.mkdir_p("#{File.join(Dir.home, "Desktop")}/#{created_at}/photos")[0]
      puts "Copying photos for #{created_at}...".cyan

      photos_by_date[created_at].each do |file|
        safe_target = safe_copy(file: file, destination_folder: folder_for_date)
        copy_file_timestamps(from_path: file, to_path: safe_target)
        print "#{File.basename(safe_target)},".gray
      end
      puts ""
    end

    # Copy videos
    videos_by_date.keys.each do |created_at|
      folder_for_date = FileUtils.mkdir_p("#{File.join(Dir.home, "Desktop")}/#{created_at}/videos")[0]
      puts "Copying video files for #{created_at}...".cyan

      videos_by_date[created_at].each do |file|
        safe_target = safe_copy(file: file, destination_folder: folder_for_date)
        copy_file_timestamps(from_path: file, to_path: safe_target)
        print "#{File.basename(safe_target)},".gray
      end
      puts ""
    end
  end
end
