
CarrierWave.configure do |config|
  
  # config.fog_provider = 'fog/aws' 

  # config.fog_credentials = {
  #   :provider   => 'AWS',
  #   :aws_access_key_id     => ENV['AWS_S3_KEY'],
  #   :aws_secret_access_key => ENV['AWS_S3_SECRET'],
  #   :region                => ENV['AWS_S3_REGION']
  # }

  # config.storage = :fog

  # config.cache_dir = "#{Rails.root}/tmp/uploads"  # Lets also CarrierWave work on heroku

  # config.fog_directory = ENV['AWS_S3_BUCKET']

  # For testing, upload files to local `tmp` folder.
  # if Rails.env.development?
  #   config.storage = :file
  #   config.enable_processing = false
  #   config.root = "#{Rails.root}/tmp"
  # else
  #   config.storage = :fog
  # end

  # File uploading

  # These permissions will make dir and files available only to the user running
  # the servers
  config.permissions = 0600
  config.directory_permissions = 0700
  config.storage = :file
  # This avoids uploaded files from saving to public/ and so
  # they will not be available for public (non-authenticated) downloading
  config.root = Rails.root

end