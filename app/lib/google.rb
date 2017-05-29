class Google

  # Imports the Google Cloud client library
  # gem google-cloud-vision 0.24.0
  #require "google/cloud/vision"

  def self.ocr

    # Your Google Cloud Platform project ID
    project_id = "cloudvision-testr"

    # Instantiates a client
    # How to get a JSON keyfile for auth
    # https://cloud.google.com/vision/docs/common/auth
    vision = Google::Cloud::Vision.new project: project_id,
     keyfile: "./google-cloud_keyfile.json"


    # The name of the image file to annotate
    file_name = "./fb_illustration01.png"

    # Performs label detection on the image file
    labels = vision.image(file_name).labels

    puts "Labels:"
    labels.each do |label|
      puts label.description
    end

  end


end