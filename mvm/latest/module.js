( function() {
  $( ".payload" ).css ( {
    "display":"none",
    "width":"400px",
    "height":"450px",
    "border-style":"solid",
    "border-width":"1px",
    "border-color":"black",
    "background-color":"white",
    "position":"relative",
    "left":"-20px",
    "top":"-500px",
    "z-index":"1000",
  } );
  $( ".sptn" ).css ( {
      "cursor":"help",
      "text-decoration":"underline",
  } );
  var state = 0;
  var tn;
  $( ".sptn" ).click( function() {
    var ticket = $( this ).text();
    if ( ( tn != null && tn != $( this ).text() ) || state == 0 ) {
      tn = ticket;
      myWin = window.open ( "http://unidb.org/cgi-bin/get_issue.pl?ticket=" + ticket,
                            "CTS Ticket",
                            "toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, copyhistory=yes, width=400, height=500");
      myWin.focus();
      state = 1;
    } else { 
      myWin.close();
      state = 0;
      tn = null;
    }
  });
}) ( );

      

<div id="RemoveRecordFromDashboardDisplayDiv" class=PopBox style="width:480px; display:none; visibility:hidden;">
 <h4>Remove Record From Dashboard Display</h4>
 <p>Please provide a reason for removing record from the dashboard display:</p>
 <form method=POST action="">
  <textarea type=text name="QBU_Comments" id="QBU_Comments" cols=60 rows=10></textarea>
  <div style="float:right; padding-top:24px; margin-right:6px">
   <input type=button value="Submit" onclick="RemoveRecordFromDashboardDisplay(this.form)">
   <input type=button value="Cancel" onclick="HidePopupDiv(this)">

  </div>
 </form>       
</div>