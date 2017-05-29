class S3DirDeleter < ApplicationJob
  queue_as :default

  def perform(issue_id)

    folders = [ENV['AWS_S3_DIR_ISSUES'], ENV['AWS_S3_DIR_PAGES'], ENV['AWS_S3_DIR_TILES'], ENV['AWS_S3_DIR_PAGE_CONTENTS']]
    folders.each do |folder|
      Storage.remove_folder(File.join(folder, issue_id.to_s))
    end

  end

end