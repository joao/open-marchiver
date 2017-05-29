class Utils


  # List:
  # text_import_to_page
  # create_thumbnails_of_pages
  # create_open_graph_images
  # reprocess_tiles

  # import text to Page.text_content
  def self.text_import_to_page

    # Get all pages of scans PDF type
    Issue.where(:pdf_type => 'scans').pluck(:id).each do |issue_id|

      Page.where(:issue_id => issue_id).where('text_content IS NULL').each do |page|
  
        text = page.to_text

        # output to text
        page.text_content = text 
        page.save

        # import to elasticsearch
        page.reindex

        puts page.id
        puts

      end

    end

  end


  def self.create_thumbnails_of_pages
    thumb_height = 300

    Issue.pluck(:id).each do |issue_id|

      Page.where(:issue_id => issue_id).each do |page|
        puts page.id
        file_url = Storage.get_file_url('pages', issue_id, page.filename)
        page_image = MiniMagick::Image.open(file_url)
        # width x height
        page_image.resize "x#{thumb_height}"
        page_image.quality 60

        # Setup filenames and paths
        temp_filename = page.filename.split('.')[0] + "_thumb_#{thumb_height}.jpg"
        temp_filename_path = File.join(Rails.root, 'tmp', temp_filename)

        # Write temp image
        page_image.write(temp_filename_path)

        # Upload to Storage and remove the file from /tmp
        upload_directory = File.join(ENV['AWS_S3_DIR_PAGES'], issue_id.to_s)
        Storage.upload_file(temp_filename_path, upload_directory) 
        FileUtils.rm temp_filename_path
      end

    end


  end

  # Create Open Graph images for Facebook
  def self.create_open_graph_images(issue_id)
    image_width = 1200
    image_height = 630

    Page.where(:issue_id => issue_id).each do |page|
      puts page.id
      file_url = Storage.get_file_url('pages', issue_id, page.filename)
      page_image = MiniMagick::Image.open(file_url)
      # width x height
      page_image.resize "#{image_width}x"
      page_image.crop "#{image_width}x630+0+0"
      page_image.quality 60

      # Setup filenames and paths
      temp_filename = page.filename.split('.')[0] + "_open-graph.jpg"
      temp_filename_path = File.join(Rails.root, 'tmp', temp_filename)

      # Write temp image
      page_image.write(temp_filename_path)

      # Upload to Storage and remove the file from /tmp
      upload_directory = File.join(ENV['AWS_S3_DIR_PAGES'], issue_id.to_s)
      Storage.upload_file(temp_filename_path, upload_directory) 
      FileUtils.rm temp_filename_path
    end

  end

  # reprocess tiles
  def self.reprocess_tiles

  end


  # reprocess OCR to where azure returned mistakes
  def ocr_with_mistakes
    
  end

end