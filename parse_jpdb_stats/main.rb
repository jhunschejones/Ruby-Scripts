require "json"

# Some styled CLI output options
class String
  def red;     "\e[31m#{self}\e[0m" end
  def green;   "\e[32m#{self}\e[0m" end
  def black;   "\e[30m#{self}\e[0m" end
  def magenta; "\e[35m#{self}\e[0m" end
  def brown;   "\e[33m#{self}\e[0m" end
  def blue;    "\e[34m#{self}\e[0m" end
  def cyan;    "\e[36m#{self}\e[0m" end
  def gray;    "\e[37m#{self}\e[0m" end
  def bold;    "\e[1m#{self}\e[22m" end
end

stats_file_path = File.expand_path("./tmp/stats.json")
raise "Missing #{stats_file_path}" unless File.exists?(stats_file_path)
stats_file = File.read(stats_file_path)
stats_json = JSON.parse(stats_file)
timestamps = stats_json
  .dig("response", "time_daily", "figure", "data", 0, "x")
  .map { |timestamp| timestamp.split("T")[0] } # just show date
  .reverse # show newest date first
daily_study_minutes = stats_json
  .dig("response", "time_daily", "figure", "data", 0, "y")
  .reverse # show newest date first

puts "Here is your jpdb.io daily study time by day:".cyan
timestamps.each_with_index do |timestamp, index|
  puts "#{"Date:".gray} #{timestamp}#{", Total minutes:".gray} #{daily_study_minutes[index].to_s.bold}"
end
