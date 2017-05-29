class Hocr

   # hOCR with words

  def self.to_hOCR(ocr_id)
    b = binding

    ocr = Ocr.find(ocr_id)
    page = Page.find(ocr.page_id)

    azure_json = ocr.output_json
    page_width = page.width
    page_height = page.height

    # ID setup for the hOCR file
    id_block = 0
    id_par = 0
    id_line = 0
    id_word = 0

    # Templates
    template_with_words = File.join(Rails.root, 'app', 'lib', 'templates', 'hocr_template_with_words.erb')
    template_with_lines = File.join(Rails.root, 'app', 'lib', 'templates', 'hocr_template_with_lines.erb')

    # Azure JSON response
    json_object = JSON.parse(azure_json)

    language = json_object['language']
    text_regions = json_object['regions']


    # hOCR template
    erb_template = ERB.new(File.read(template_with_lines), nil, '-')


    # Pass local bindings
    erb_result = erb_template.result(binding)

    return erb_result

    # write to file
    #File.open('hocr_test.hocr2.xml', 'w') { |file| file.write(hocr_result) }
  end


  def self.calc_bbox(bbox_measures)
    azure_bbox = bbox_measures.split(',')
    x_left = azure_bbox[0]
    y_left = azure_bbox[1]
    x_right = azure_bbox[0].to_i + azure_bbox[2].to_i
    y_right = azure_bbox[1].to_i + azure_bbox[3].to_i
    bbox = [x_left, y_left, x_right.to_s, y_right.to_s]

    return bbox
  end


  def self.create_pdf(image_file, hocr_file)

  end

  def self.create_single_pdf(pdf_files)

  end


end