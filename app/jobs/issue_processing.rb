class IssueProcessing < ActiveJob::Base
  queue_as :default

  require 'fileutils'

  def perform(issue_id)
    pdf_to_pages(issue_id)
    create_page_thumbnails(issue_id)
    pages_to_tiles_source(issue_id)
    tile_maker(issue_id)

    # Upload folders
    folders = ['issues', 'pages', 'tiles']
    folders.each do |folder|
      puts "Uploading #{folder} to S3..."
      Storage.upload_folder(File.join(Rails.root, 'tmp', issue_id.to_s, folder), folder)
    end


    # perform OCR on those pages
    puts "Performing OCR.."
    pdf_type = Issue.find(issue_id).pdf_type # Check for issue type
    if (pdf_type == "scans")
      Page.where(:issue_id => issue_id).pluck(:id).each do |page|
        #Ocr.azure(page) # Perform Ocr
        Azure.ocr_page(page) # Perform Ocr
      end
    elsif (pdf_type == text)
      # Do nothing for now
      # Extract text
    end

    # Import Azure OCR to page.text_content and elasticsearch
    import_text_to_elasticsearch(issue_id)

    # Delete temporary directory
    delete_tmp(issue_id)

    # Update issue processing status as finished
    update_tiles_generated_status(issue_id)

  end



  # Converts original upload pdf to pages
  def pdf_to_pages(issue_id)

    issue = Issue.find(issue_id)

    export_dir = Rails.root.to_s + "/tmp/" + issue_id.to_s  + "/pages/" + issue_id.to_s + "/"
    #export_dir = File.join(Rails.root, 'tmp', issue_id, 'pages', issue_id) 

    # Create export directory if it doesn't already exist
    FileUtils.mkdir_p(export_dir) unless File.directory?(export_dir)


    # Get PDF file
    pdf_file = open(File.join(Rails.root, issue.file.url)) # Get the PDF file from /tmp
    # Set output filename
    output_filename = export_dir.to_s + issue.publication.name.downcase.parameterize.to_s + "_" + issue.id.to_s + "_" + issue.date.strftime("%d-%m-%Y").to_s

    # Check what type of PDF file it is
    # if it is a PDF with just scanned images content it won't have metadata, supposedly...
    pdf_scanned_images = PDF::Reader.new(pdf_file).metadata.blank?

    
    # If the PDF is just of scanned images without text
    if pdf_scanned_images

      issue.pdf_type = "scans"

      puts "PDF with images"
      puts "Processing PDF to PPM files..."

      # Gets images to PPM format
      pdfimages_script = "pdfimages #{pdf_file.path} #{output_filename}"

      system(pdfimages_script)

      # Converts those PPM images to JPG format
      # resizes to height of 2560px if their height is larger
      puts "Converting PPM to JPG"
      pages_ppm = Dir[export_dir.to_s + '*ppm'].sort
      pages_ppm.each do |page|
        image = MiniMagick::Image.new(page)
        # If original page scans are of bigger size than 2560px, resize them
        if image.height > 2560
          image.resize "x2560"
        end
        image.density(300) # Change density to 72dpi, but should we? Retina and original scans...
        image.format 'jpg' 
        image.write page 
      end

    else

      issue.pdf_type = "text"

      # If it is a PDF with text exported directory from a program
      # Settings for export, original pdftoppm script
      image_density = 300
      image_height = 2560

      pdftoppm_script = 'pdftoppm -jpeg -r ' + image_density.to_s + ' -scale-to ' + image_height.to_s + ' ' + pdf_file.path.to_s + ' ' + output_filename.to_s

      system(pdftoppm_script)

    end

    issue.save

    puts "Processing to pages complete."

  end


  # Create thumbnails, 300px height, variable width
  def create_page_thumbnails(issue_id)
    issue = Issue.find(issue_id)

    pages_dir = File.join(Rails.root, 'tmp', issue_id.to_s, 'pages', issue_id.to_s)
    jpeg_filename = issue.publication.name.downcase.parameterize.to_s + "_" + issue.id.to_s + "_" + issue.date.strftime("%d-%m-%Y").to_s

    pages = Dir[File.join(pages_dir, jpeg_filename + '*.jpg')].sort
    puts pages.length.to_s + ' pages.'
    puts "Creating thumbnails..."
    pages.each do |page|
      image = MiniMagick::Image.open(page)
      image.density(72)
      image.resize "x300"
      image.format 'jpg' 
      image.write page.split('.')[0] + "_thumb_300.jpg"
    end
    puts "Thumbnails created."

  end



  # Appends pages to form the world map from which tiles are generated
  def pages_to_tiles_source(issue_id)

    # Spacing in pixels for append
    spacing_size = 100

    issue = Issue.find(issue_id)

    # Settings export dirs
    pages_dir = File.join(Rails.root, 'tmp', issue_id.to_s, 'pages', issue_id.to_s)
    export_dir = File.join(Rails.root, 'tmp', issue_id.to_s, 'tiles_sources', issue_id.to_s)

    # Create export directory if it doesn't already exist
    FileUtils.mkdir_p(export_dir) unless File.exists?(export_dir)

    jpeg_filename = issue.publication.name.downcase.parameterize.to_s + "_" + issue.id.to_s + "_" + issue.date.strftime("%d-%m-%Y").to_s
    output_filename = issue.publication.name.downcase.parameterize.to_s + "_" + issue.id.to_s + "_" + issue.date.strftime("%d-%m-%Y").to_s + "_tiles_source.png"

    # Find pages to process
    # and exclude thumbnails
    pages = Dir[File.join(pages_dir, jpeg_filename + '*.jpg')].sort
    pages -= Dir[File.join(pages_dir, jpeg_filename + '*thumb*.jpg')]

    puts pages.length.to_s + ' pages to append.'
    puts "Appending..."


    MiniMagick::Tool::Convert.new do |convert|
      convert << "-size" << "#{spacing_size}x"
      
      # Pages setup
      page_counter = 1

      # Iterate over all the pages to append
      pages.each do |page|

        # Page information to store in table
        new_page = Page.new
        new_page.issue_id = issue.id
        new_page.number = page_counter
        page_size = FastImage.size(page)
        new_page.width = page_size[0]
        new_page.height = page_size[1]
        new_page.filename = page.split('/').last # Temp fix?
        new_page.file_size = File.size(page)
        new_page.save
        page_counter += 1

        # Append        
        convert << page
        unless page == pages.last # no right border on last page
          convert << "xc:none"
        end
        convert << "-background" << "transparent"
      end
      #convert << "-monitor" # is not outputting in the final and not during
      convert << "+append"
      convert << "PNG32:#{File.join(export_dir, output_filename)}"
    end

    issue.issue_map_file = output_filename
    output_size = FastImage.size(File.join(export_dir, output_filename))
    issue.width = output_size[0] # Str
    issue.height = output_size[1]
    issue.save

    puts "Appending complete."


  end




  # Make tiles
  def tile_maker(issue_id)

    issue = Issue.find(issue_id)

    tiles_source = File.join(Rails.root, 'tmp', issue_id.to_s, 'tiles_sources', issue_id.to_s, issue.issue_map_file)
    export_dir = File.join(Rails.root, 'tmp', issue_id.to_s, 'tiles', issue_id.to_s)

    puts "Processing tiles..."

    # Setup output directory
    FileUtils.mkdir_p(export_dir) unless File.directory?(export_dir)

    vips_script = 'vips dzsave ' + tiles_source + ' ' + export_dir + ' --layout google --suffix .png --background "1 1 1 1" '

    system(vips_script)

    # Set the max zoom to be at the most 9
    maxZoom = Math.log2([issue.width,issue.height].max/256).ceil
    if maxZoom > 9
      maxZoom = 9
    end

    issue.tiles_generated = false
    issue.minZoom = 0
    issue.maxZoom = maxZoom
    issue.save
    puts "Tiles ready."

  end


  # Elasticsearch import
  def import_text_to_elasticsearch(issue_id)
    Page.where(:issue_id => issue_id).each do |page|

      # Output Azure OCR to text string
      text = page.to_text

      # Save in database
      page.text_content = text 
      page.save

      # Import to elasticsearch
      page.reindex

    end
  end



  # Delete temporary directory
  def delete_tmp(issue_id)
    puts "Removing tmp directory..."
    # Remove the temp directory used for the current model processing
    # Carrierwave takes care of its own
    # Check first if the direcotry exists?
    delete_script = 'rm -rf ' + File.join(Rails.root, 'tmp', issue_id.to_s)
    system(delete_script)

  end


  # update issue in the database
  def update_tiles_generated_status(issue_id)
    puts "Updating issue #{issue_id} status..."
    issue = Issue.find(issue_id)
    issue.tiles_generated = true
    issue.save
  end


end
