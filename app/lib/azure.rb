class Azure

  # Methods list:
  # .ocr_page
  # .to_mjson
  # .to_text
  # .calc_bbox


  @ocr_endpoint = "https://westus.api.cognitive.microsoft.com/vision/v1.0/ocr"


  # Perform OCR
  def self.ocr_page(page_id)

    page = Page.find_by_id(page_id)

    # Azure settings
    uri = URI(@ocr_endpoint)
    uri.query = URI.encode_www_form({
         # Request parameters
        'language' => ENV['OCR_LANGUAGE'],
        'detectOrientation ' => 'true'
    })

    # Request
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_OCR_KEY']
    request.body = "{'Url':'" + page.get_image_url + "'}"

    # Response
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
         http.request(request)
    end

    # TODO
    # - check the reponse type, if it is valid and not an error
    # - types of errors: size, subscription invalid
    # - if an error, sleep for x seconds and retry again up to 5 times
    # and then stop

    # Store JSON response
    json = response.body.force_encoding('UTF-8')

    # Temporary file handling
    temp_export_dir = File.join(Rails.root, 'tmp', page.issue_id.to_s, ENV['AWS_S3_DIR_PAGE_CONTENTS'])
    FileUtils.mkdir_p(temp_export_dir) unless File.directory?(temp_export_dir) # Create dir if it doesn't exist
    filename = "#{page.id}_azure.json"
    temp_file = File.join(temp_export_dir, filename)

    # Write temp file
    puts "Storing temporary file..."
    File.open(temp_file, 'w') do |file| 
      file.write(json)
    end

    # Upload temp file
    puts "Uploading file to storage..."
    Storage.upload_file(temp_file, File.join(ENV['AWS_S3_DIR_PAGE_CONTENTS'], page.issue_id.to_s))

    # Storing information in table
    page_content = PageContent.new
    page_content.page_id = page_id
    page_content.content_type = 'ocr_azure'
    page_contentt.filename = filename
    page_content.file_size = File.size(temp_file)
    page_content.save

    # Delete temp file
    # the issue is that if used during issue processing,
    # there is already a function to delete all temporary files.
    # How to manage both?

  end


  # Convert to a Marchiver JSON structure
  def self.to_mjson(page_content_id)
    b = binding

    page_content = PageContent.find(page_content_id)
    page = Page.find(page_content.page_id)

    # Get the content file from Storage
    azure_json = page_content.output_stored_file
    page_width = page.width
    page_height = page.height

    # ID setup for the mJSON file
    id_area = 0
    id_line = 0

    # Azure JSON response
    json_object = JSON.parse(azure_json)
    text_regions = json_object['regions']

    # Build mJSON
    mJSON = Jbuilder.encode do |json|
      json.page do
        json.id page.id
        json.issue_id page.issue_id
        json.number page.number
        json.width page_width
        json.height page_height
        json.text_angle json_object['textAngle']
        json.orientation json_object['orientation']
      end
      json.areas text_regions do |area|
        json.id ("area_" + (id_area = id_area + 1).to_s)
        json.bbox calc_bbox(area['boundingBox'])
        json.lines area['lines'] do |line|
          json.id ("line_" + (id_line = id_line + 1).to_s)
          json.bbox calc_bbox(line['boundingBox'])
          # Get the words in a single line
          line_words = Array.new
          line['words'].each do |word|
            line_words << word['text']
          end
          text = line_words.join(' ')
          json.text text
        end
      end


    end

    return mJSON

  end

  def self.to_text(page_content_id)

    

  end



  # Function to calculate box sizes,
  # related to page
  def self.calc_bbox(bbox_measures)
    azure_bbox = bbox_measures.split(',')
    x_left = azure_bbox[0]
    y_left = azure_bbox[1]
    x_right = azure_bbox[0].to_i + azure_bbox[2].to_i
    y_right = azure_bbox[1].to_i + azure_bbox[3].to_i
    bbox = [x_left, y_left, x_right.to_s, y_right.to_s]

    return bbox
  end

end