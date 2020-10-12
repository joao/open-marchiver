```
 __  __                _     _                
|  \/  | __ _ _ __ ___| |__ (_)_   _____ _ __ 
| |\/| |/ _` | '__/ __| '_ \| \ \ / / _ \ '__|
| |  | | (_| | | | (__| | | | |\ V /  __/ |   
|_|  |_|\__,_|_|  \___|_| |_|_| \_/ \___|_|   
                                                 
```   
   
Website: [http://marchiver.com](http://marchiver.com)

*This is still an early release prototype and is bound to have bugs.  
Please enter an issue or send a pull request when you encounter one. This documentation provides and overview of the project and helps to get up and running. We will be updating this repository with more features and information over time.*                

# Marchiver


Marchiver (_née_ Media Archiver) is a open source media archive management software, allowing publishers to visualize, transcribe and search their print archives, making them available online to their readers.
This a prototype, the first release

Built on native web technologies, designed responsive from the start to adapt to mobile and other future devices, it aims to be a starting point that enable news publishers, from local to international stages, to place their print media archives online.

Developed in collaboration with [Flor de Lis](http://flordelis.pt) (the oldest magazine in Portugal, published since 1925) and funded by [Google's Digital News Initiative Innovation Fund](https://digitalnewsinitiative.com/dni-fund).


### Table of Contents
* **[Overview](#overview)**  
* **[Quick Tour](#quick-tour)**  
  * **[Visualization]()**
  * **[Text Extraction](#text-extraction)**
  * **[Search]()**  
* **[Installation](#installation)**  
    * **[Local development](#local-development)**    
    * **[Production](#production)**  
* **[Support](#support)**  
* **[Thank you](#thank-you)**  
* **[License](#license)**  
* **[Copyright](#copyright)**

## Overview

The software has three main features:

1. Visualization
2. Transcription
3. Search

Each features builds upon the previous and enables the visualization and search of print archives online.

It's a Rails application, built as *monolith*, though it can run in one server or if necessary be necessary across several servers.  
A MySQL database is needed as well as an Elasticsearch service, to power search.  
We have tested it will small VPSs (2GB RAM, 1 CPU core) and it works well with archives of 25.000 to 50.000 pages, making it a good solution for smaller publishers also.

Also it needs to have at least a background worker running, to process issues uploading/processing in the background. Background funcionalities are provided using the delayed_job gem using ActiveJobs.  

##### Preparing content for upload
First it is necessary to prepare the content. Each issue scanned images have to be embeded in a PDF and the information about the date manually inputted. It is possible to do so via the admin interface, but you can use the API to batch process.

First you need to join your scanned images in a PDF for uploading. You can do so with the following command (you need to have ```imagemagick``` installed:

```
convert *tiff -alpha remove -alpha off output.pdf 
```

Replace ```*tiff``` with a list of filenames that you want to join.
You can also find a sample ruby script in ```utils/original_pages_to_pdf.rb```.

Have in mind that this isn't a normal PDF with automatically sarch enabled on the text, but a PDF container for your original images in their original sizes, which then the Marchiver application will extract and convert.

You can find in ```utils/batch_uploader.rb``` a sample script of how you can process PDF issues in bluk for uploading.

Our suggestion is that on first import you use a VM with bigger processing power, and then scale down when the issues are processed.

## Quick tour

#### Visualization

Marchiver takes the uploaded files and converts them to map tiles, to enable to be seen at high and low zoom levels, without wasting reader's bandwith and forcing him to download and wait for full-resolution downloads.

Leaflet uses some plugins, including edgebuffer, that loads an extra tile off the viewport, so as to enable more smoother panning for a user. It is currently disabled, but you can enable it in the file ```viewer_structure.js.erb```.

#### Text Extraction
The application is able to extract text from PDFs, either from scans or native PDF with text/vectores. In the file ```apps/jobs/issue_processing.rb``` it detects by checking the PDF header which type of file it is and then proceeds to adjust.

For scans it needs to OCR by default it uses Azure. Soon will open-source or Google Cloud Vision and Tesseracts Libraries, as well the native PDF text extraction egine.

There are costs of the services we tested with:

| Service              | Price         | Notes                           |
|:-------------------- |:------------- |:------------------------------- |
| Azure OCR            | $1.50/1000    | 5000 free calls/month           |
| Google Cloud Vision  | $1.50/1000    | 1000 free calls/month           |
| Tesseract            | Free          | local conversion                |

The choice to go with Azure was do the speedier, more accurate performance and less API request errors from the service.

We convert all the returned conversions to a JSON structure that internally is called mJSON, containing the lines and blocks of text. That is then used for corrections, display the content in the viewer and also is capable of building a PDF with text content, by combining an hOCR conversion with images in a PDF.

#### Search  

Search is developed upon Elasticsearch, using the Searchkick gem

You can see the configuration in the Page model and customize it to your needs.
Typeahead functionality in the search box can be added and also statistics.  
See options available [here](https://github.com/ankane/searchkick).


## Installation

We advise that you start with testing the application in your local development environment.  
Look at the ```Gemfile``` to see which dependencies are necessary, such as Rails, MySQL, Elasticsearch, imagemagick, vips, poppler-utils. If you are on macOS, use homebrew.  
  
There are two important files that need to be configured with options before running the app:  
```config/application.yml```  
```config/database.yml```  

You have example files in those directories, that you can copy and configure with your settings.

In ```config/application.yml``` you find most setting options. You will see that by default we are using Amazon S3 for file storage, but we are abstracting it using the ```Fog ruby gem```, which also supports other services as Google Cloud Storage or Dreamobjects, to you can adapt it.  
If you want to use your own storage, it's more complicated but possible to adapt. Go to ```app/lib/storage.rb``` and adapt the utilities to your need and look at ```app/jobs/issue_processing.rb``` to see how the file processing is being done now with temporary files and uploading.

### Local Development
Start local server with:  
```
make run
```

Start job queue, based on delayed_job and ActiveRecord, with:  
```
make jobs
```  

You can change the default number of background workers running by editing the `Makefile`



Jobs can be run imeddiately in Rails console by running:  
```
ExampleJob.perform_later(arg_1, arg_2)  
```



### Production
A production service should have this services running: Passenger (under Nginx or Apache), MySQL, Job Workers and Elasticsearch. They can be in the same server, or you can architect a solution that spreads this services through multiple servers.
File serving (images and other assets, is done via Amazon S3 by default).

For better performance we advise to setup caching via Cloudflare or using a CDN.

## Thank you
Ludovic Blecher, Sarah Hartley, Rebecca Young — [Google DNI Innovation Fund](https://digitalnewsinitiative.com/dni-fund)  
António Theriaga, Ana Silva, Ivo Faria, Gonçalo Vieira, João Lopes Cardoso, Manuel Oliveira, Susana Micaela — [Flor de Lis](http://flordelis.pt) + [CNE](http://escutismo.pt)  
Evan Sandhaus — [The New York Times](http://timesmachine.nytimes.com)  
Amanda Ribeiro, Amílcar Correia — [PÚBLICO](https://publico.pt)  
Ana Carvalho, Ricardo Lafuente — [Journalism++ Porto](http://www.jplusplus.org/pt/porto/)  
Hugo Sousa

## Contributing
Feel free to use this project in your archives.  
Please report any issues (which certainly there are some bugs) you find in this first release and contribute back.

## License
Marchiver is licensed under an [MIT](https://choosealicense.com/licenses/mit/) license.

## Copyright

© 2016-2017 João Antunes