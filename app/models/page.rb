class Page < ApplicationRecord

  belongs_to :issue
  has_many :page_content, :dependent => :destroy

  # Elastic Search
  searchkick language: ENV["ELASTICSEARCH_LANGUAGE"], highlight: [:text], callbacks: false, batch_size: 200
  # searchkick batch_size reindex defaults to 1000,
  # useful to know and downsize for elasticsearch with lower memory
  # word_start: [:text] needed for autocomplete to work
  # match: :phrase to match a phrase, but this breaks highlights
  # more options: https://github.com/ankane/searchkick
  
  @highlight_characters_length = 200

  # Fields to index
  def search_data
    {
      text: text_content,
      date: issue.date,
      publication_id: issue.publication_id
    }
  end


  # Search only highlights
  def self.search_highlight(term, page = 0, sort = '_score', direction = 'desc')
    order = { "#{sort}" => "#{direction}" }

    pages = Page.search term, fields: [:text], highlight: {fields: {text: {fragment_size: @highlight_characters_length}}}, misspellings: {below: 5}, order: order, page: page, per_page: 10
    return pages

  end

  # Search by date interval
  def self.search_by_date_interval(term, publication_id, page = 0, from_date, to_date, sort, direction)

    order = { "#{sort}" => "#{direction}" }

    pages = Page.search term, fields: [:text], highlight: {fields: {text: {fragment_size: @highlight_characters_length}}}, where: {date: {gte: from_date, lte: to_date }, publication_id: publication_id}, misspellings: false, order: order, page: page, per_page: 8
    # misspellings: {below: 0} or false

    return pages

  end

  # Reset the elasticsearch index
  def self.elasticsearch_reset
    Page.searchkick_index.delete
  end

  # Output elasticsearch stats
  def self.elasticsearch_stats
    uri = "#{ENV["ELASTICSEARCH_URL"]}/_cat/indices?h=index,store.size&bytes=M&format=json"
    stats = Net::HTTP.get(URI.parse(uri))
    return JSON.parse(stats)
  end



  # Scopes
  # With text content extracted
  scope :with_content, -> {
    joins(:page_content)
  }

  # Without content extrected
  scope :without_content, -> {
    left_outer_joins(:page_content).where(page_contents: { id: nil } )
  }

  # Without text content in elasticsearch
  scope :without_text_content, -> {
    where(text_content: nil)
  }

  # Pages with OCR performed
  scope :with_ocr, -> {
    joins(:page_content).where(page_contents: {content_type: ['ocr_azure', 'ocr_google', 'tesseract'] })
  }

  # Pages without OCR performed
  scope :without_ocr, -> {
    left_outer_joins(:page_content).where(page_contents: { id: nil } )
  }

  # Pages where Azure returned an error
  # 111 bytes is the size of an error 500 on their side
  # need to had error verification
  scope :with_azure_error, -> {
    left_outer_joins(:page_content).where(page_contents: { file_size: 111 } )
  }

  # Azure OCR returned empty (file_size = 58)
  # Most are covers, blank pages or low resolutions pages 
  scope :with_empty_ocr, -> {
    left_outer_joins(:page_content).where(page_contents: { file_size: 58 } )
  }

  # Pages with corrections
  scope :with_corrections, -> {
    joins(:page_content).where(page_contents: {content_type: 'correction' })
  }

  # Pages without corrections
  # used for random page in Corrector
  scope :without_corrections, -> {
    joins(:page_content).where(page_contents: {content_type: ['ocr_azure', 'ocr_google', 'tesseract', 'pdf_text'] })
  }




  # Methods

  # Get the original image URL
  def get_image_url
    image_url = Storage.get_file_url(ENV['AWS_S3_DIR_PAGES'], self.issue_id, self.filename )
    return image_url
  end

  # Get the thumbnail URL
  def get_thumbnail_url
    thumb_filename = self.filename.split('.')[0] + "_thumb_300.jpg"
    thumbnail_url = Storage.get_file_url(ENV['AWS_S3_DIR_PAGES'], self.issue_id, thumb_filename )
    return thumbnail_url
  end

   # Get the Open Graph URL
  def get_og_image_url
    og_image_filename = self.filename.split('.')[0] + "_open-graph.jpg"
    og_image_url = Storage.get_file_url(ENV['AWS_S3_DIR_PAGES'], self.issue_id, og_image_filename )
    return og_image_url
  end


  # Get the file size
  def get_file_size
    file = Storage.get_file(ENV['AWS_S3_DIR_PAGES'], self.issue_id, self.filename )
    return file.content_length
  end

  # Return PageContent converted to mJSON
  def to_mjson
    # Check first for a correction
    page_content = self.correction_existent_check

    if page_content.content_type == 'ocr_azure'
      return Azure.to_mjson(page_content.id)
    elsif page_content.content_type == 'ocr_google'
      # still to be implemented
      return
    elsif page_content.content_type == 'ocr_tesseract'
      # still to be implemented
      return
    elsif page_content.content_type == 'pdf_text'
      # still to be implemented
      return
    elsif page_content.content_type == 'correction'
      # Already stored in mJSON format
      return Storage.get_file(ENV['AWS_S3_DIR_PAGE_CONTENTS'], issue_id, page_content.filename).body.force_encoding('UTF-8')
    else
      return "No text extraction exists for this page"
    end
  end

  # to Text
  # always converts from mjson to text
  def to_text
    json_object = JSON.parse(self.to_mjson)

    text_output = []
    json_object['areas'].each do |area|
      area['lines'].each do |line|
        text_output << line['text']
      end
    end

    return text_output.join(' ')
  end

  # Import text content to column,
  # from new corrections or OCR
  # and reindex to elasticsearch
  def import_text_content
    self.text_content = self.to_text
    self.save

    # Reindex to elasticsearch
    self.reindex
  end 

  # Check if there is a correction of this page,
  # if so, use it, else use the text extracted
  def correction_existent_check
    # Check first if there is a correction
    page_content = PageContent.where(:page_id => self.id).where(:content_type => 'correction').order(id: :asc).last

    # If there isn't a correction,
    # Go to the ocr or text extraction
    if !page_content 
      page_content = PageContent.where(:page_id => self.id).first
    end

    return page_content
  end


  # Return file_size in MB
  def get_file_size_in_mb
    mb = ::ApplicationController.helpers.number_to_human_size(self.file_size, precision: 2) 
    return mb
  end

  # Check if there are page duplicates
  # Might happen if the IssueProcessing job stalls
  def self.check_duplicates
    return Page.select(:filename).group(:filename).having("count(*) > 1").size
  end

  # Check if there are 'lost' pages not belonging to any issue
  def self.check_not_in_issues
    return Page.where('issue_id NOT IN (SELECT id FROM issues)')
  end

  # IDs of all pages that are scans PDFs
  def self.of_scans_type
    return Page.joins(:issue).where("issues.pdf_type = 'scans'").pluck(:id)
  end

  # IDs of all pages that are of text PDFs
  def self.of_text_type
    return Page.joins(:issue).where("issues.pdf_type = 'text'").pluck(:id)
  end

  # Number of page that are scanned
  def self.number_of_scan_type
    return Page.joins(:issue).where("issues.pdf_type = 'scans'").size
  end


  # Number of PDF pages
  def self.number_of_text_type
    return Page.joins(:issue).where("issues.pdf_type = 'text'").size
  end


  
end
