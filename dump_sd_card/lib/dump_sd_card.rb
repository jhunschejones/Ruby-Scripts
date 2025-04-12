require "fileutils"
require "shellwords"
require_relative "string_utils"

def safe_copy(file:, destination_folder:)
  base = File.basename(file, ".*")           # "example" (without extension)
  ext = File.extname(file)                   # ".txt"
  target = File.join(destination_folder, "#{base}#{ext}")
  counter = 1

  # Loop until we find a filename that doesn't exist
  while File.exist?(target)
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

# change into the SD card
Dir.chdir("/Volumes/Untitled")

# logic for videos
if Dir.entries(".").include?("PRIVATE")
  files_by_date = Hash.new { |h, key| h[key] = [] }

  # navigate into the folder where all the video files are
  Dir.chdir("./PRIVATE/M4ROOT/CLIP")

  Dir.entries(".").each do |video_file|
    next if video_file[0] == "." # skip dot files

    created_at = File.birthtime(video_file).strftime("%Y-%m-%d")
    files_by_date[created_at] << video_file
  end

  files_by_date.keys.each do |created_at|
    folder_for_date = FileUtils.mkdir_p("#{File.join(Dir.home, "Desktop")}/#{created_at}/videos")[0]
    puts "Copying video files for #{created_at}...".cyan

    files_by_date[created_at].each do |file|
      safe_target = safe_copy(file: file, destination_folder: folder_for_date)
      copy_file_timestamps(from_path: file, to_path: safe_target)
      print "#{File.basename(safe_target)},".gray
    end
    puts ""
  end
end

# change back into the main SD card directory
Dir.chdir("/Volumes/Untitled")

# logic for photos
if Dir.entries(".").include?("DCIM")
  # change into the main photos directory
  Dir.chdir("./DCIM")

  folders_count = 0 # right now we don't handle the scenario where there are
                    # multiple folders at this level, so this is a failsafe
  Dir.entries(".").each do |photos_folder|
    next if photos_folder[0] == "." # skip dot files

    folders_count +=1
    raise "More photos folders than expected" if folders_count > 1 # bail out if we have multiple base-level photos folders

    # navigate into the photos folder with an funny number in the name
    Dir.chdir(photos_folder)

    files_by_date = Hash.new { |h, key| h[key] = [] }
    Dir.entries(".").each do |photo_file|
      next if photo_file[0] == "." # skip dot files

      created_at = File.birthtime(photo_file).strftime("%Y-%m-%d")
      files_by_date[created_at] << photo_file
    end

    files_by_date.keys.each do |created_at|
      folder_for_date = FileUtils.mkdir_p("#{File.join(Dir.home, "Desktop")}/#{created_at}/photos")[0]
      puts "Copying photos for #{created_at}...".cyan

      files_by_date[created_at].each do |file|
        safe_target = safe_copy(file: file, destination_folder: folder_for_date)
        copy_file_timestamps(from_path: file, to_path: safe_target)
        print "#{File.basename(safe_target)},".gray
      end
      puts ""
    end
  end
end
