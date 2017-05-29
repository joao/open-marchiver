class Publication < ApplicationRecord
  extend Enumerize
  
  # Relationships
  has_many :issues, dependent: :destroy
  has_many :pages, through: :issues

  # Validations
  validates_presence_of :name, :description
  validates_uniqueness_of :name

  # Publication Frequency types
  enumerize :frequency, in: [ :daily, :monthly, :other ], default: :daily


  # Defaults
  # Publications returned in default alphabeticall order
  default_scope { order(name: :asc) }


  # Scopes
  # Publications with issues and tiles generated
  scope :with_issues, -> { where('EXISTS(SELECT 1 FROM issues WHERE publication_id = publications.id AND tiles_generated = 1)') }

  scope :without_issues, -> { where('NOT EXISTS(SELECT 1 FROM issues WHERE publication_id = publications.id)') }


  # Methods
  # Unique years of a publication
  # Find via publication.id
  def self.unique_years(publication_id)
    if Rails.env.development?
      Issue.unique_years(publication_id)
    else
      Issue.of_scans_type.unique_years(publication_id)
    end
  end

end
