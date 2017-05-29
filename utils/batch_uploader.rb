
# Batch uploader example
require 'rest-client'


# Adapt this file to parse a file structure containing PDFs,
# in which the file strcuture contains information,
# regarding the publishing date or other.
#
# Internally Marchier checks if its a native PDF file or
# an enclosure for scanned images.
#
# Be aware that the server will start running jobs in the background,
# to process the issues, so it might become unresponsive, it depends
# of the server capacity and how many job workers you define to run
# in the background.

# Months in portuguese, easly change to english
months = {
      "01" => "janeiro",
      "02" => "fevereiro",
      "03" => "marco",
      "04" => "abril",
      "05" => "maio",
      "06" => "junho",
      "07" => "julho",
      "08" => "agosto",
      "09" => "setembro",
      "10" => "outubro",
      "11" => "novembro",
      "12" => "dezembro"
    }

# Using this script outside of the rails directory,
# set the env variables directly

api_endpoint = "#{ENV['MARCHIVER_URL']}/api/v1/issues.json"

publication_id = 1 # Set manually to your Publication ID
api_auth_token = ENV['API_AUTH_TOKEN']

files = Dir.glob("*.pdf").select {|f| !File.directory? f}
files_size = files.size

files.each_with_index do |issue, i|
  issue_year = File.basename(issue, ".*").split(//).last(4).join
  issue_month_string = issue.gsub('flordelis_', '')[0...-9].to_s.gsub(/ *\d+$/, '').gsub("_", "").split('-')[0]

  issue_month = months.invert[issue_month_string]
  
  date = "#{issue_year}-#{issue_month}-01 00:00:01"

  file_to_upload = issue

  puts "#{i+1}/#{files_size}: #{file_to_upload} - #{date}"
  #puts "#{date}  #{file_to_upload}"


  RestClient.log = 'stdout'
  RestClient.post api_endpoint, {:publication_id => publication_id, :date => date, :api_auth_token => api_auth_token, :file => File.new(file_to_upload, 'rb'), :multipart => true}

  sleep 1

end
