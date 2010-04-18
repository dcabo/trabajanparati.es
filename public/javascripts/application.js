// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Pretty print a number by inserting ',' thousand separator
function formatNumber(i) {
    if (i == null) return "";
    
    var s = Math.abs(i) + '';
    var leftovers = s.length % 3;
    var formatted = leftovers > 0 ? s.substring(0, leftovers) : '';

    for ( var pos=leftovers; pos<s.length; pos+=3 ) {
        if ( formatted.length > 0 )
            formatted += ',';   
        formatted += s.substring(pos, pos+3);
    }
    return (i<0 ? '-' : '') + formatted;
}