class PdfText


  def self.extract_text(page_id)
    

  end 

  # Convert PDF text to mJSON
  def self.to_mjson(issue_id)
    # https://linux.die.net/man/1/pdftotext
    # Call to system:
    # pdftotext -bbox-layout
    
    # 1. Get the issue original PDF from S3
    # 2. Get the number of pages
    # 3. pdftotext -f page_number -bbox-layout output_file
    # 4. open output_file and parse to mjson
    # 5. upload original output_file to ocr, with type pdf text
    # 6. upload mjson file
    # 7. update Page.text_content
    # 8. delete temporary local files



  end


  # Convert from PDF to text
  def self.to_text

  end 



end