$.getJSON( "data/fortunes.json", function( data ) {
  var fortunes = [];
  $.each( data, function( key, val ) {
    var fortune = [];
    $(val).each( data, function( key, val ) {
        fortune.push( "<li id='" + key + "'>" + val + "</li>" );
    }
    fortunes.push(fortune);
  });
 
  $( "<ul/>", {
    "class": "fortunes",
    html: fortunes.join( "" )
  }).appendTo( "#results" );
});