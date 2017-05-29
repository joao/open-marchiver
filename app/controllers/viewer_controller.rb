class ViewerController < ApplicationController

  # Viewer Index
  def index

    # Get params from URL
    publication_id = params[:publication_id]
    issue_id = params[:issue_id]
    page_number = params[:page_id]

    get_url_information(publication_id, issue_id, page_number)


    respond_to do |format|
      format.html # viewer/index.html.erb
    end

  end



  # Search functionality, supplied via JS and partials
  def search
    @publications = Publication.all.select(:id, :name)

    # Get the Publication ID
    publication_id = params[:publication_id] || Publication.first.id

    # Get oldest and news dates of issues belong to a publication
    if Rails.env.development? # only in development for now
      issue_dates = Issue.date_edges(publication_id) # All issues
    else
      issue_dates = Issue.of_scans_type.date_edges(publication_id) # Only issues of scan type for now
    end

    # Fill the dates from the params and not from the DB,
    # if it's a search reload
    @oldest_issue_date = issue_dates[0].to_time.strftime('%d/%m/%Y')
    @newest_issue_date = issue_dates[1].to_time.strftime('%d/%m/%Y')
    @from_date = params[:from_date] || @oldest_issue_date
    @to_date = params[:to_date] || @newest_issue_date

    respond_to do |format|
      #format.html # viewer/search.html.erb
      format.js # viewer/search.js.erb
    end

  end


  # Gets the search results and paginates them
  def search_results

    publication_id = params[:publication_id] || Publication.first.id
    pagination_page = params[:page] || 0
    from_date = Date.parse(params[:from_date], '%d/%m/%Y')
    to_date = Date.parse(params[:to_date], '%d/%m/%Y')
    sort_attribute = params[:sort_attribute] || '_score'
    sort_direction = params[:sort_direction] || 'desc'

    @results = Page.search_by_date_interval(params[:term], publication_id, pagination_page, from_date, to_date, sort_attribute, sort_direction )


    respond_to do |format|
      format.js # viewer/search_results.js.erb
    end

  end

  private

  # Geth the current information and output to a inline JS object in the returned page
  def get_url_information(publication_id, issue_id, page_number)
  
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

      if page_number
        if page_number.to_i > number_of_pages.to_i
          page_number = number_of_pages.to_i
        end
        
        page = Page.where(:issue_id => issue_id).where(:number => page_number).first
        page_id = page.id
        page_og_image_url = page.get_og_image_url
      else
        page_number = 1
        page = Page.where(:issue_id => issue_id).where(:number => page_number).first
        page_id = page.id
        page_og_image_url = page.get_og_image_url
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
        :page => page_number,
        :page_id => page_id
      }
    })

    # The Viewer URL doesn't always have a issue and page params,
    # so that case to be taken care of.
    # OG params have also to be server-side rendered.
    # TODO: needs to adapt better if it is a daily publication
    if (issue_id && page_number)
      page_title = "#{publication_name} - #{month}/#{year} - #{t('viewer.page')} #{page_number.to_i}"
      page_og_url = "#{ENV['MARCHIVER_URL']}#{issue_id}/#{page_number}"
      page_og_description = page.text_content ? page.text_content.slice(0,300) : ''
    elsif (issue_id)
      page_title = "#{publication_name} - #{month}/#{year}"
      page_og_url = "#{ENV['MARCHIVER_URL']}#{issue_id}"
      page_og_description = page.text_content ? page.text_content.slice(0,300) : ''
    else
      page_title = ''
      page_og_url = ''
      page_og_description = ''
      page_og_image_url = ''
    end

    set_meta_tags index: true,
                  follow: true,
                  title: page_title,
                  description: page_og_description.slice(0,160),
                  og: {
                    title:        page_title,
                    author:       publication_name,
                    description:  page_og_description,
                    type:         'article',
                    url:          page_og_url,
                    image: {
                      _: page_og_image_url,
                      width:      1200,
                      height:     630
                    }
                  },
                  twitter: {
                    card:         'summary_large_image',
                    url:          page_og_url,
                    title:        page_title,
                    description:  page_og_description,
                    image:        page_og_image_url
                  }

  end


end
