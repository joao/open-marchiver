class CorrectorController < ApplicationController
  # Specify a different parent layout
  layout "corrector"

  # Reset the app locale, as ActiveAdmin is always in English
  before_action :reset_app_locale

  # User needs to be authenticated
  before_action :authenticate_user!


  # Main page
  def index

    @user = User.find(current_user.id)

    publication_id = nil
    # Original
    #@issue = Issue.of_scans_type.order("RAND()").first
    #@page = Page.where(:issue_id => @issue.id, :number => 1).order("RAND()").first
    @page = Page.without_corrections.order("RAND()").first
    @issue = Issue.find(@page.issue)

    # Dev version
    # where you set the issue number and the page number,
    # to be the cover/first page with less lines
    #@issue = Issue.find(118)
    #@page = Page.where(:issue_id => @issue.id).where(:number => 1).first
    @issue_number_of_pages = @issue.number_of_pages

    random_page_content_id = PageContent.where(:page_id => @page.id).first.id
    # TODO
    #@mjson = Azure.to_mjson(random_page_content_id)
    @mjson = Page.find(@page.id).to_mjson


    current_page_information(publication_id, @issue.id, @page.number, random_page_content_id)

    # Meta
    @page_title = "Corrector"

    respond_to do |format|
      format.html # corrector/index.html.erb
    end
  end



  # Create new correction
  def create

    @mjson_correction = params[:correction].as_json
    
    # Parse correction to variables
    page_id = @mjson_correction['page']['id']
    issue_id = @mjson_correction['page']['issue_id']
    upload_directory = "#{ENV['AWS_S3_DIR_PAGE_CONTENTS']}/#{issue_id}"
    filename = "#{page_id}_correction.json"

    # Upload correction JSON file
    Storage.upload_data(filename, upload_directory, @mjson_correction.to_json)
    file_size = Storage.get_file_size(ENV['AWS_S3_DIR_PAGE_CONTENTS'], issue_id, filename)

    # Create entry in Database
    new_correction = PageContent.new
    new_correction.page_id = @mjson_correction['page']['id']
    new_correction.content_type = "correction"
    new_correction.filename = filename
    new_correction.user_id = current_user.id
    new_correction.file_size = file_size
    new_correction.save


    # upload mjson file
    # place entry in correction table
    # Page.reindex for elasticsearch
    # return success status

    respond_to do |format|
      format.js # corrector/new.html.erb ???
    end

  end



  # Profile
  def profile

    @user = User.find(current_user.id)

    # Meta
    @page_title = "Corrector - " + t('profile')

    respond_to do |format|
      format.html # corrector/profile.html.erb
    end
  end


  # Score
  def score

    @user = User.find(current_user.id)

    @total_pages = Page.of_scans_type.size
    @total_pages_to_correct = Page.of_scans_type.size
    @total_pages_corrected = Page.with_corrections.size
    @total_user_pages_corrected = PageContent.where(:content_type => 'correction').where(:user_id => current_user.id).size


    # Meta
    @page_title = "Corrector - " + t('score')

    respond_to do |format|
      format.html # corrector/score.html.erb
    end
  end



  # Help
  def help

    @user = User.find(current_user.id)

    # Meta
    @page_title = "Corrector - " + t('help')

    respond_to do |format|
      format.html # corrector/help.html.erb
    end
  end


  private

   # Geth the current information and output to a inline JS object in the returned page
   # This should be instead in a controller helper, as it is shared among several
   def current_page_information(publication_id, issue_id, page_id, page_content_id)
  
    if publication_id
      publication = Publication.find(publication_id)
      publication_name = publication.name
      publication_frequency = publication.frequency
    end
    
    if issue_id
      issue = Issue.find(issue_id)
      year = issue.date.year
      month = "%.2d" % issue.date.month.to_i
      day = issue.date.day
      #pages_widths_and_heights = issue.pages_widths_and_heights
      number_of_pages = issue.pages.size # get it from the pages_widths array, no need for another DB call

      unless publication_id
        publication_id = issue.publication_id
        publication = Publication.find(publication_id)
        publication_name = publication.name
        publication_frequency = publication.frequency
      end

    end

    # Pass the information to inline JS in this page
    gon.push({
      :publication => {
        :id => publication_id,
        :name => publication_name,
        :frequency => publication_frequency
      },
      :issue => {
        :id => issue_id,
        :date => {
          :year => year,
          :month => month,
          :day => day
        },
        :number_of_pages => number_of_pages,
        #:pages_widths_and_heights => pages_widths_and_heights,
        :page => page_id
      },
      :page_content_id => page_content_id
    })

  end

end
