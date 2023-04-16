require "fileutils"
require "httparty"
require "pcloud_api"

class Downloader
  LOCAL_FOLDER_PATH = ENV["LOCAL_FOLDER_PATH"]
  PCLOUD_FOLDER_PATH = ENV["PCLOUD_FOLDER_PATH"]

  def self.download_file(pcloud_file, path = PCLOUD_FOLDER_PATH)
    # Make a local directory if one doesn't exist yet
    subdirectory_path = "#{LOCAL_FOLDER_PATH}/#{path.gsub(PCLOUD_FOLDER_PATH, "")}".gsub("//", "/")
    unless Dir.exist?(subdirectory_path)
      puts "Creating local subdirectory #{subdirectory_path}...".green
      FileUtils.mkdir_p(subdirectory_path)
    end
    local_filepath = "#{subdirectory_path}/#{pcloud_file.name}".gsub("//", "/")

    # Local file already exists and is newer than the version in pCloud
    if ::File.exist?(local_filepath) && ::File.ctime(local_filepath) > pcloud_file.created_at
      puts "Already exists: #{pcloud_file.name}".gray
      return
    end

    ::File.open(local_filepath, "w") do |new_file|
      new_file.binmode
      puts "Downloading #{pcloud_file.name} from pCloud...".cyan
      HTTParty.get(pcloud_file.download_url, stream_body: true) do |fragment|
        new_file.write(fragment)
      end
    end
  end

  def self.download_folder(pcloud_folder)
    pcloud_folder
      .contents
      .each do |item|
        next self.download_file(item, pcloud_folder.path) if item.is_a?(Pcloud::File)
        next self.download_folder(item) if item.is_a?(Pcloud::Folder)
        puts "Unrecognized pCloud item #{item}".red
      end
  end
end