class IssueUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  #storage :fog
  # :file because we are storing in /tmp and
  # then using /lib/storage to upload to a cloud storage



  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
     #{}"uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
     "#{Rails.root}/tmp/#{model.id}/issues/#{model.id}"
     #ENV['AWS_S3_DIR_ISSUES'] + "/#{model.id}"
  end

  def cache_dir
    # should return path to cache dir
    Rails.root.join 'tmp/uploads'
  end



  # def cache_dir
  #   '/tmp/marchiver-cache'
  # end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    #%w(jpg jpeg gif png)
    %w(pdf)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
