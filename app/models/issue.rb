class Issue < ApplicationRecord

  # Relationships
  belongs_to :publication
  has_many :pages, :dependent => :destroy

  # Validations
  validates_presence_of :publication, :date, :file, on: :create

  # Uploads
  mount_uploader :file, IssueUploader
  #serialize :files

  # Background job to process tiles
  after_create do |issue|
    IssueProcessing.perform_later(issue.id)
    #PdfToPages.perform_later(issue.id)
    #PagesToTilesSource.perform_later(issue.id)
    #TileMaker.perform_later(issue.id)
    #S3IssueAssetsUploader.perform_later(issue.id)
    #IssueProcessingCleanup.set(wait: 12.hours).perform_later(issue.id)
  end

  # Background job to delete tiles from S3
  before_destroy do |issue|
    S3DirDeleter.perform_later(issue.id)
  end

  # Elasticsearch methods
  # Reindex all the pages of an issue,
  # by importing them from self.text_content
  def self.reindex_pages(issue_id)
    pages = Page.where(:issue_id => issue_id)
    pages.each do |page|
      page.reindex
    end
  end


  # Scopes
  # Issues with original scanned images
  scope :of_scans_type, -> {
    where(pdf_type: 'scans')
  }

  # Issues that are original PDF, exported with text,
  # from DP software such as InDesign
  scope :of_text_type, -> {
    where(pdf_type: 'text')
  }


  # Set a default value for an Active Admin form
  #after_initialize :set_default_title

  # Methods
  def name
    self.publication.name.to_s
  end

  def name_plus_date
    return self.publication.name.to_s + " - " + date_output
  end

  def date_output
    return self.date.strftime("%d %b, %Y").to_s
  end

  def self.of_year(publication_id, year)
    date = DateTime.new(year.to_i)
    boy = date.beginning_of_year
    eoy = date.end_of_year
    where("publication_id = publication_id and date >= ? and date <= ?", boy, eoy)
  end

  # Old versions of methods ###################

  def self.old_of_month(month)
    dt = DateTime.new(month.to_i)
    bom = dt.beginning_of_month
    eom = dt.end_of_month
    where("date >= ? and date <= ?", bom, eom)
  end

  def self.old_of_year(year)
    dt = DateTime.new(year.to_i)
    boy = dt.beginning_of_year
    eoy = dt.end_of_year
    where("date >= ? and date <= ?", boy, eoy)
  end

  ####################################

  # Get all issues of a publication published in a certain month/year 
  def self.of_year_and_month(publication_id, year, month)
    date = DateTime.new(year.to_i, month.to_i, 1)
    bom = date.beginning_of_month
    eom = date.end_of_month
    where("publication_id = publication_id and date >= ? and date <= ?", bom, eom)
      .order('date DESC')
      .pluck(:id, :date)
  end

  def content_type
    self.file.content_type
  end

  def self.of_publication(publication_name)
    publication_id = Publication.where(:name => publication_name)
    where(:publication_id => publication_id)
  end

  # Unique years of a publication
  # Find via publication.id
  def self.unique_years(publication_id)
    # MySQL
    where(:publication_id => publication_id, :tiles_generated => true).pluck("DISTINCT YEAR(date)").sort.reverse
  end

  # Unique months of a publication and year
  # Find via publication.id
  def self.unique_months(publication_id, year)
    # MySQL
    of_year(publication_id, year).pluck("DISTINCT MONTH(date)").sort
    #of_year(publication_id, year).where(:publication_id => publication_id).pluck("DISTINCT YEAR(date)").sort
  end

  # Unique years of a publication
  # Find via publication.name
  def self.unique_years_by_publication_name(publication_name)
    publication_id = Publication.where(:name => publication_name)
    # MySQL
    where(:publication_id => publication_id).pluck("DISTINCT YEAR(date)").sort
  end
 
  # Get oldest and newest issue dates
  def self.date_edges(publication_id)
    oldest_issue = Issue.where(:publication_id => publication_id).order('date asc').limit(1).first.date
    newest_issue = Issue.where(:publication_id => publication_id).order('date desc').limit(1).first.date
    return [oldest_issue, newest_issue]
  end


  # API Helper Methods

  # Get the number of pages of an issue
  def number_of_pages
    Page.where(:issue_id => self.id).size
  end

  # Get a page width
  # assumes all pages of the issue have the same width
  def page_width
    Page.where(:issue_id => self.id).first.width
  end

  # Get all the pages width
  # Because lots of times it can ve a variable
  def pages_widths_and_heights
    self.pages.map {|p| [p.width, p.height] }
  end


  protected
  def set_default_title
    self.publication ||= Publication.first
  end


end
