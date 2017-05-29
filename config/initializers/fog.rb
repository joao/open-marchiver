STORAGE_CREDENTIALS = credentials = {
      :provider   => 'AWS',
      :aws_access_key_id     => ENV['AWS_S3_KEY'],
      :aws_secret_access_key => ENV['AWS_S3_SECRET'],
      :region                => ENV['AWS_S3_REGION']
    }

# Documentation on using the 'fog' gem with other providers
# http://fog.io/storage/

# Google example
# connection = Fog::Storage.new({
#   :provider                         => 'Google',
#   :google_storage_access_key_id     => YOUR_SECRET_ACCESS_KEY_ID,
#   :google_storage_secret_access_key => YOUR_SECRET_ACCESS_KEY
# })


# Local Storage
# connection = Fog::Storage.new({
#   :provider   => 'Local',
#   :local_root => '~/fog',
#   :endpoint   => 'http://example.com'
# })