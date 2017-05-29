class PageContent < ApplicationRecord
  extend Enumerize

  # Relationships
  belongs_to :page
  belongs_to :user, optional: true # Rails 5 new way


  # Page Content Types
  enumerize :content_type, in: [ :ocr_azure, :ocr_google, :ocr_tesseract, :pdf_text, :correction ]


  # STILL TO OPEN-SOURCE
  # 1. PDF to Text
  # 2. Google OCR
  # 3. Tesseract OCR



  # Return file stored in S3
  def output_stored_file
    issue_id = self.page.issue_id
    filename = self.filename
    content = Storage.get_file(ENV['AWS_S3_DIR_PAGE_CONTENTS'], issue_id, filename)
    json = content.body
    return json
  end



  # Batch Azure OCR for all pages
  # Backgroung job
  def self.batch_azure
    pages = Page.without_ocr.of_scans_type
    pages_size = pages.size

    Parallel.each(pages, in_threads: 4) do |page_id|
      Ocr.azure(page_id)
      puts pages_size = pages_size - 1
    end

  end


end
