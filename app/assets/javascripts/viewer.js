
//= require bootstrap
//= require semantic-ui-dropdown
//= require viewer_structure.js.erb
//= require cleave.js/dist/cleave.min.js
//= require jquery.infinite-pages


// On Document Ready
$( document ).ready(function() {


  // Check if you are on the main page
  if ( $('#map').length ) {
    // Do nothing
  } else {
    // Don't execute the rest, if you are on the search page (only temporary)
    return;
  }

  // initialize dropdowns
  $('.ui.dropdown').dropdown();
  // And hide them for now
  $('.navigation .ui.dropdown').hide();
  // But show the publication anyway
  //$('#navigation .publications').show();

  // What to do on iteraction with
  // Publications dropdown
  $('.publications')
    .dropdown({
      action: 'activate',
      onChange: function(value, text, $selectedItem) {
        Viewer.current_publication_id = value;
        get_years(value);
    }
  });

  // Years dropdown
  $('.years')
    .dropdown({
      action: 'activate',
      onChange: function(value, text, $selectedItem) {
        Viewer.current_year = value;
        get_year_issues(Viewer.current_publication_id, Viewer.current_year); 
      },
      message: {
        noResults: ''
      }
  });

  // Months dropdown
  $('.months')
    .dropdown({
      action: 'activate',
      onChange: function(value, text, $selectedItem) {
        Viewer.current_month = value;
        if (!Viewer.first_load) {
          get_days();
          //console.log('loading days from inside months dropdown');
        }
      }
  });

  // Days dropdown
  $('.days')
    .dropdown({
      action: 'activate',
      onChange: function(value, text, $selectedItem) {
        if (Viewer.first_load && gon.issue.id) {
          Viewer.current_issue = gon.issue.id;
        } else {
          Viewer.current_issue = value;
          get_issue(Viewer.current_issue);
        }
      }
  });



  // Build it
  // Get publications
  get_publications();


  // UI interactions

  // Mobile Issue nav click on mobile
  $('a.issue-nav_toggle').on('click', function() {

    // Check if search is open,
    // if it is closed it
    if ( $('a.search_toggle').hasClass('active') ) {
      $('a.search_toggle').trigger('click');
    }

    $(this).toggleClass('active');
    $(this).find('span').toggleClass('glyphicon-search glyphicon-remove');
    $('.mobile_nav_issue_nav').toggleClass('show');

  });


  // Mobile Search click
  $('a.search_toggle').on('click', function() {

    // Check if nav is open,
    // if it is closed it
    if ( $('a.issue-nav_toggle').hasClass('active') ) {
      $('a.issue-nav_toggle').trigger('click');
    }

    $(this).toggleClass('active');
    $(this).find('a').toggleClass('active');
    $(this).find('span').toggleClass('glyphicon-search glyphicon-remove');

    // Desktop search icon change
    $('li.search_toggle a span').toggleClass('glyphicon-search glyphicon-remove');

  })


  // Desktop Search click
  $('li.search_toggle').on('click', function() {

    $(this).toggleClass('active');
    $(this).find('a').toggleClass('active');
    $(this).find('span').toggleClass('glyphicon-search glyphicon-remove')

    // Mobile search icon change
    $('a.search_toggle span').toggleClass('glyphicon-search glyphicon-remove');

  })

  // For back to function properly
  //window.addEventListener('popstate', function(e) {
    //Viewer.current_issue = history.state.issue
    //get_issue(Viewer.current_issue);
  //});

}); // End of Document Ready