
require 'active_record'
require 'mysql2'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  database: '',
  username: '',
  password: '',
  host:     '127.0.0.1',
  port:     3306
)

class Issue < ActiveRecord::Base
  serialize :months

  has_many :pages

  def months_strings

    months_relationships = {
      "01" => "Janeiro",
      "02" => "Fevereiro",
      "03" => "Marco",
      "04" => "Abril",
      "05" => "Maio",
      "06" => "Junho",
      "07" => "Julho",
      "08" => "Agosto",
      "09" => "Setembro",
      "10" => "Outubro",
      "11" => "Novembro",
      "12" => "Dezembro"
    }

    # Get the months in the database
    months = self.months

    # Setup an array to hold the months strings
    months_strings = []

    # Iterate through each month in the database array
    months.each do |month|
       months_strings << months_relationships[month]
    end

    # Return as a string
    return months_strings.join('-').downcase
    
  end
end # end of Issue model

class Page < ActiveRecord::Base
  belongs_to :issue
end

issue_count = Issue.all.size 
puts "#{issue_count} issues."

puts Issue.last.pages.pluck(:filename).map { |p| "pages/#{p}" }

exit

Issue.all.each_with_index do |i, index|
  pages = i.pages.pluck(:filename).map { |p| "pages/#{p}" }
  pdf_filename = "flordelis_#{i.months_strings}_#{i.year}.pdf"

  if File.file?("pdfs/#{pdf_filename}")
    pdf_filename = "flordelis_#{i.months_strings}_#{i.id}_#{i.year}.pdf"
  end

  puts "Converting #{index + 1}/#{issue_count} to PDF: #{pdf_filename}"
  
  # Convert all images to a PDF.
  convert_script = "convert #{pages.join(' ')} -alpha remove -alpha off pdfs/#{pdf_filename}"

  system(convert_script)
end

# PDF filename structure
# flordelis_julho-agosto_2000.pdf


