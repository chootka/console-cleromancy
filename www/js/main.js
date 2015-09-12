$.getJSON( "data/fortunes.json", function( data ) {
  var fortunes = [];
  $.each( data, function( key, val ) {
    fortunes.push( "<li id='" + key + "'>" + val + "</li>" );
  });
 
  $( "<ul/>", {
    "class": "fortunes",
    html: fortunes.join( "" )
  }).appendTo( "#results" );
});