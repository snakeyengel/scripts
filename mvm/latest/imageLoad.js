( function ( ) {

    var querystring=document.location.search;
  
    if ( /dlta=mog/.test(querystring ) ) {
      // GRID EDIT PAGE ========================
      alert ( "You are on the Grid Edit Page" );
  
    } else if ( /a=er/.test( querystring ) ) {
      // EDIT RECORD PAGE ======================
      alert ( "You are on the Edit Record Page" );
  
    } else if ( /GenNewRecord/.test( querystring ) ) {
      // ADD RECORD PAGE =======================
      alert ( "You are on the Add Record Page" );
  
    } else if ( /a=dr/.test( querystring ) ) {
      // DISPLAY RECORD PAGE
      $( "img[qbu=module]" ).closest( "td" ).css( "background-color", "#FFFFFF" );
      alert( "You are on the Display Record Page" );
  
    } else if ( /a=q/.test( querystring ) ) {
      // REPORT PAGE ===========================
      alert ( "You are on the Report Listing Page" );
  
    } else {
      // OTHER PAGE ============================
      alert ( "You are on the Some Other Page" );
    }
  }
) ( );

