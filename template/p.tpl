<html>
<head>
 <title>Temporal.PW - temporary secure storage for passwords</title>
 <meta name="viewport" content="width=device-width, initial-scale=1">
 <link rel="stylesheet" href="/static/bootstrap.min.css">
 <script src="/static/jquery.min.js"></script>
 <script src="/static/bootstrap.min.js"></script>
 <script type="text/javascript" src="/static/ZeroClipboard.min.js"></script>
</head>
<body>

<style type="text/css">
  body { background: #d3d3d3 !important; }
  .col-centered { float: none; margin: 0 auto; }
</style>

<script>
$(document).ready(function(){

  ZeroClipboard.config( { swfPath: "/static/ZeroClipboard.swf" } );

  var clientURL = new ZeroClipboard($("#btnURL"));
  var clientPass = new ZeroClipboard($("#btnPass"));

  var $bridge = $("#global-zeroclipboard-html-bridge");

  clientURL.on("copy", function(event, data) {
      var copiedValue = $('#url').val();
      var clipboard = event.clipboardData;
      clipboard.setData("text/plain", copiedValue);
  });
  clientURL.on("aftercopy", function() {
    $bridge.data("placement", "right").tooltip("enable").attr("title", "Copied URL!").tooltip("fixTitle").tooltip("show");
  });
  
  clientPass.on("copy", function(event, data) {
      var copiedValue = $('#password').text();
      var clipboard = event.clipboardData;
      clipboard.setData("text/plain", copiedValue);
  });
  clientPass.on("aftercopy", function() {
    $bridge.data("placement", "right").tooltip("enable").attr("title", "Copied password!").tooltip("fixTitle").tooltip("show");
  });
  
  $('.mytooltip').mouseleave( function() {
    $bridge.tooltip("disable");
  });

});
</script>

<center>
<div class="container text-center center-block" align="center">
<br/>
<input type="text" id="url" class="input-lg col-lg-5 col-centered text-center" value="https://temporal.pw/p/{{token}}" readonly>
<span class="input-group-btn">
  <button id="btnURL" class="btn btn-primary mytooltip" data-placement="right">Copy temporary URL to clipboard</button>
</span>

<br/>

<h2>Your password is:</h2>

<hr>
<h1><span id="password" style="font-family: monospace">{{cleartext}}</span></h1>
<hr>
<span class="input-group-btn">
  <button id="btnPass" class="btn btn-primary mytooltip" data-placement="right">Copy Password to clipboard</button>
</span>

<br/>
<br/>
<h4>
This password can be viewed up to <b>{{views}}</b> more times ({{ip_str}}) before it expires in <b>{{days}}</b> days.<br/>
<br/>
Or, you can <a href="/d/{{token}}">Delete it now</a>.<br/>
</h4>
<br/>
<br/>

<a href="/">Store another password</a> | <a href="/about">About</a> | <a href="https://github.com/tkooda/temporalpw">Source</a></br>

</div>

</center>
</body>
</html>
