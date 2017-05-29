class AzureOCR < ActiveJob::Base
  queue_as :ocr_processing

  # Batch azure job, useful in development for debugging,
  # but not used in production
  def perform

    PageContent.batch_azure
    
  end
  
end