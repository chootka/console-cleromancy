var fortunes = [];
var curFortune = Math.floor( Math.random()*(2) );
var mac = ["b8:27:eb:fc:95:68", "9c:f3:87:ad:eb:2c"];
$.getJSON( "data/fortunes.json", function( data ) {
    $.each( data, function( key, val ) {
        for (var i=0; i<data[key].length; i++) {
            var fortune = [];
            fortune.push("<li id='fortune0'>" + data[key][i].throw0 + "</li>");
            fortune.push("<li id='fortune1'>" + data[key][i].throw1 + "</li>");
            fortune.push("<li id='fortune2'>" + data[key][i].throw2 + "</li>");
            fortune.push("<li id='fortune3'>" + data[key][i].throw3 + "</li>");
            fortune.push("<li id='fortune4'>" + data[key][i].throw4 + "</li>");
            fortune.push("<li id='fortune5'>" + data[key][i].throw5 + "</li>");
            fortunes.push(fortune);
        }
    });
    
    $( "<ul/>", {
        "class": "fortunes",
        html: fortunes[curFortune].join( "" )
    }).appendTo( "#results" );

    $("h3").delay(3000).fadeOut(400);
    $("#fortune0").delay(5000).fadeIn(400);
    $("#fortune1").delay(7000).fadeIn(400);
    $("#fortune2").delay(9000).fadeIn(400);
    $("#fortune3").delay(11000).fadeIn(400);
    $("#fortune4").delay(13000).fadeIn(400);
    $("#fortune5").delay(15000).fadeIn(400);
});