# ./main.rb explanation
#
# Required state: `./tmp/stats.json`: JSON chart data generated by generated by
# https://jpdb-stats.herokuapp.com based on exported reviews JSON from jpdb.io
#
# Output state: NONE, prints study minutes by date to standard out

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

puts "Here are your jpdb.io daily study time stats:".cyan
daily_study_time_entries = []
timestamps.each_with_index do |timestamp, index|
  daily_study_time_entries << "Date: #{timestamp}, Total minutes: #{daily_study_minutes[index]}"
  puts "#{"Date:".gray} #{timestamp}#{", Total minutes:".gray} #{daily_study_minutes[index].to_s.bold}"
end

File.open("./tmp/daily_study_time.txt", "w+") do |f|
  f.puts(daily_study_time_entries)
end
