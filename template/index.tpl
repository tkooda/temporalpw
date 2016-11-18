<html>
<head>
 <title>Temporal.PW - Temporary secure storage for passwords</title>
 <meta name="viewport" content="width=device-width, initial-scale=1">
 <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.6/css/bootstrap.min.css">
 <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js" crossorigin="anonymous" integrity="sha384-K+ctZQ+LL8q6tP7I94W+qzQsfRV2a+AfHIi9k8z8l9ggpc8X+Ytst4yBo/hH+8Fk"></script>
 <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.6/js/bootstrap.min.js" crossorigin="anonymous" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS"></script>
 <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/1.5.8/clipboard.min.js" crossorigin="anonymous" integrity="sha384-6IvGwMLZzeEDqfqkglJOV5PIsjfAnO7VLUOZKdFasr8OfwhrG5BU1xnrmfYhIJbA"></script>
 <script type="text/javascript" src="https://cdn.rawgit.com/ricmoo/aes-js/v2.0.0/index.js" crossorigin="anonymous" integrity="sha384-PXzFVs1Uwmv9IgXZtHWck4jUzla5FSGAFTRAuiXE3i2yjh7QbVhl6R52oYVRLmTE"></script>
 <script type="text/javascript" src="https://cdn.rawgit.com/45678/base58/master/Base58.js" crossorigin="anonymous"></script>
 <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jshashes/1.0.5/hashes.min.js" crossorigin="anonymous" integrity="sha384-tARwkAjXmhKdUTDed6+4lbwtffWZDOIw7AiDtqp/Zubhc9EK/JvPrX9g27RolaxX"></script>
 <script type="text/javascript" src="https://cdn.rawgit.com/tkooda/temporalpw/master/static/random-password.js" crossorigin="anonymous" integrity="sha384-/7FPV70hkdAoFrKjuFUVI42WgJQEkmSV/0VRJyXRWF2qBlUSmp9mE4V6nMNJLZBt"></script>
 <link rel="shortcut icon" type="image/png" href="data:image/png;base64,iVBORw0KGgo=">
</head>
<body>

<style type="text/css">
  body { background: #d3d3d3 !important; }
  h1 { font-family: 'Cooper Black', serif; }
</style>

<script language="javascript">
if (window.location.protocol != "https:")
    window.location.href = "https:" + window.location.href.substring(window.location.protocol.length); // fix github.io redirecting directories w/out trailing slash to http

var has_url = false;

function generate_url() {
  var secret = document.getElementById( "secret" ).value;
  if ( secret == null || secret == "" ) {
    return false;
  }
  
  // generate random key byte array ..
  var crypto = window.crypto || window.msCrypto;
  if ( ! crypto ) throw new Error( "Your browser does not support window.crypto or window.msCrypto." );
  var key = new Uint8Array( 16 );
  crypto.getRandomValues( key );  // generate random 128 bit AES key
  
  // encode key byte array ..
  var encoded_key = Base58.encode( key );
  
  // convert password string to byte array, never send this to the server unencrypted ..
  var password_bytes = aesjs.util.convertStringToBytes( secret );
  
  // encrypt password ..
  var aesCtr = new aesjs.ModeOfOperation.ctr( key, new aesjs.Counter( 5 ) );
  var encrypted_bytes = aesCtr.encrypt( password_bytes );
  
  // encode encrypted password ..
  var encoded_encrypted_bytes = Base58.encode( encrypted_bytes );
  
  $.post( "https://temporal.pw/new",
          { cipher: encoded_encrypted_bytes, // ONLY send encrypted password to server, NEVER send the key or unencrypted password!
            days: document.getElementById( "days" ).value,
            myiponly: document.getElementById( "myiponly" ).checked },
          function( data, status ) { got_id( data, status, encoded_key ) } ); // encryption key is never sent to server, it's only provided to this ajax success callback so the browser can build the secret URL
  
  return false;
};


function got_id( data, status, encoded_key ) {
  var SHA256 = new Hashes.SHA256;
  
  $("#docs").text( "This URL can be used ONCE to view the password:" );
  
  var token = data.pw_id + "-" + encoded_key;
  
  document.getElementById( "secret" ).value = "https://Temporal.PW/p#" + token + SHA256.hex( token ).substr( 0, 2 );
  $("#secret").attr( "readonly", true );
  
  var info = "(this URL will expire in " + document.getElementById( "days" ).value + " days";
  if ( document.getElementById( "myiponly" ).checked ) {
    info = info + ", and it is only viewable from this same IP address";
  }
  $("#settings").html( info + ")<br/>" );
  $("#warning").addClass("hidden");
  $("#genPassword").addClass("hidden");
  $("#getUrlButton").addClass("hidden");
  
  has_url = true;
  
  return false;
};


$(document).ready(function(){
  // popup temporary tooltip when clicking copy button ..
  var clipboard = new Clipboard( "#clip-btn" );
  clipboard.on( "success", function(e) {
    if ( has_url ) {
      $( "#clip-btn" ).tooltip( "enable" ).attr( "title", "URL copied to clipboard" ).tooltip( "fixTitle" ).tooltip( "show" );
    } else {
      if ( document.getElementById( "secret" ).value != null && document.getElementById( "secret" ).value != "" ) {
        $( "#clip-btn" ).tooltip( "enable" ).attr( "title", "Password copied to clipboard" ).tooltip( "fixTitle" ).tooltip( "show" );
      }
    }
  });
  $( "#clip-btn" ).mouseleave( function() {
    $( "#clip-btn" ).tooltip( "disable" );
  });
  
  // make get URL button clickable upon input ..
  $("#getUrlButton").prop( "disabled", true );
  $("#secret").on( "input", function() {
    if ( $( this ).val().length )
        $("#getUrlButton").prop( "disabled", false );
    else
        $("#getUrlButton").prop( "disabled", true );
  });
  
});

$(document).on('click','input[type=text]',function(){ this.select(); });

</script>

<div class="container text-center">

<br/>
<br/>
<h1>E-Mail passwords securely with <a href="/">Temporal.PW</a></h1>
<br/>
<br/>

<div class="form-group">
<form role="form" id="myForm" name="myForm" action="">

<label for="inputlg"><h2><div id="docs">Enter a password to create a temporary secure URL for:</div></h2></label>
<div class="col-xs-8 col-xs-offset-2 text-center">
  <div class="input-group">
    <input type="text" id="secret" name="secret" placeholder="Enter a password" class="form-control input-lg text-center">
    <span class="input-group-addon">
      <button type="button" id="clip-btn" data-clipboard-target="#secret">
        <img src="static/clippy.svg" width="20" alt="Copy to clipboard">
      </button>
    </span>
  </div>
  <div id="genPassword">or: <button type="button" id="generate" class="btn btn-primary btn-xs" onclick="document.getElementById('secret').value = generatePassword(); $('#getUrlButton').prop( 'disabled', false );">Generate a random password</button> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</div>
</div>

<br/>
<br/>
<br/>
<br/>
<br/>

<h4>
<span id="settings">
<div>
Make this URL expire in <select name="days" id="days">
  <option value="1">1</option>
  <option value="2">2</option>
  <option value="3" selected>3</option>
  <option value="4">4</option>
  <option value="5">5</option>
  <option value="6">6</option>
  <option value="7">7</option>
  <option value="8">8</option>
  <option value="9">9</option>
  <option value="10">10</option>
  <option value="15">15</option>
  <option value="20">20</option>
  <option value="30">30</option>
</select> days.
</div>

<div class="checkbox">
 <label><input type="checkbox" name="myiponly" id="myiponly">Only allow it to be viewed from my current IP address<br/>
 <small>(useful for sending a password to someone in the same office / network)</small></label>
</div>

</span>

<br/>
</h4>

<input type="submit" id="getUrlButton" class="btn btn-success btn-lg" value="Get temporary URL for this password" onclick="return generate_url();">
</form>

</div>

<br/>
<span id="warning">
(Do not include any information that identifies what the password is for)<br/>
</span>
<br/>

<a href="/">Send another password</a> | <a href="/about">About</a> | <a href="https://github.com/tkooda/temporalpw">Source</a></br>

</div>

</body>
</html>
