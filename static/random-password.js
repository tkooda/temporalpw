// attempt to generate cryptographically secure random byte, with optional max for using as a charset index
function getRandomByte( max = 256 ) {
    // http://caniuse.com/#feat=getrandomvalues
    if ( window.crypto && window.crypto.getRandomValues ) {
        var a = new Uint8Array( 1 );
        while ( true ) {
            window.crypto.getRandomValues( a );
            if ( a[0] <= max ) return a[0];
        }
    } else if ( window.msCrypto && window.msCrypto.getRandomValues ) {
        var a = new Uint8Array( 1 );
        while ( true ) {
            window.msCrypto.getRandomValues( a );
            if ( a[0] <= max ) return a[0];
        }
    } else {
        return Math.floor( Math.random() * max );
    }
};

function generatePassword( minLength = 20, maxLength = 30, charset = "abcdefghijknopqrstuvwxyzACDEFGHJKLMNPQRSTUVWXYZ2345679" ) {
    if ( minLength > maxLength) maxLength = minLength;
    var randomLength = Math.floor( Math.random() * ( maxLength - minLength ) ) + minLength,
        password = "";
    for ( var i = 0, maxIndex = charset.length; i < randomLength; i++ ) {
        password += charset.charAt( getRandomByte( maxIndex ) );
    }
    return password;
};

