class Storage

  # Methods fo interact with folders and files
  # Stored in Amazon S3, Google Cloud Storage or DreamObjects
  #
  # Marchiver storage structure
  # issues, pages, tiles, contents
  #
  # Methods list:
  # get_file
  # get_file_url
  # download_file
  # upload_file
  # upload_data
  # upload_folder
  # rename_file
  # remove_file
  # remove_folder


  # Connection setup
  @connection = Fog::Storage.new(STORAGE_CREDENTIALS)
  @bucket = ENV['AWS_S3_BUCKET']

  # Download the file
  # Use methods on it, like: body, content_length
  def self.get_file(folder, issue_id, filename)
    object = File.join(folder, issue_id.to_s, filename)
    @connection.directories.get(@bucket).files.get(object)
  end

  # Get a signed URL for file stored in a Cloud servie
  # Time to expire of 3h
  def self.get_file_url(folder, issue_id, filename)
    object = File.join(folder, issue_id.to_s, filename)
    time_to_expire = Time.now.to_i + 10800
    @connection.directories.new(:key => @bucket).files.new(:key => object).url(time_to_expire)
  end

  # Get a file size
  def self.get_file_size(folder, issue_id, filename)
    object = File.join(folder, issue_id.to_s, filename)
    @connection.directories.get(@bucket).files.get(object).content_length
  end


  # Upload a file
  def self.upload_file(file, destination_folder)
    dir = @connection.directories.new(:key => @bucket)
    filename = File.join(destination_folder, file.split('/').last )
    File.open(file) { |f| dir.files.create(:key => filename, :body => f) }
  end

  # Upload data and store it in a file
  def self.upload_data(filename, destination_folder, data)
    dir = @connection.directories.new(:key => @bucket)
    filename = File.join(destination_folder, filename)
    dir.files.create(:key => filename, :body => data)
  end

  # Upload a folders contents
  def self.upload_folder(source_folder, destination_folder)
    dir = @connection.directories.new(:key => @bucket)

    files = Dir.glob(File.join(source_folder, '**/*')).reject { |f| File.directory?(f) }

    # Use multiple threads to speed up uploading
    Parallel.each(files, in_threads: 10) do |file|
      filename = File.join(destination_folder, file.sub(source_folder, '') ) # removes absolute path
      File.open(file) { |f| dir.files.create(:key => filename, :body => f) }
    end
  end


  # Rename a file
  def self.rename_file(current_filename, new_filename)
    @connection.copy_object(@bucket, current_filename, @bucket, new_filename)
    Storage.remove_file(current_filename)
  end


  # Remove a file
  def self.remove_file(filename)
    file = @connection.directories.new(:key => @bucket).files.new(:key => filename)
    file.destroy
  end


  # Remove a folder
  def self.remove_folder(folder)

    files_to_delete = 1
    while files_to_delete != 0 do
      files = @connection.directories.get(@bucket, prefix: File.join(folder)).files.map{ |file| file.key }
      files_to_delete = files.count
      @connection.delete_multiple_objects(@bucket, files) unless files.empty?
    end

  end


end