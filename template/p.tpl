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
  ZeroClipboard.config( { swfPath: "./ZeroClipboard.swf" } );
  var client = new ZeroClipboard($("#btnCopy"));
  client.on("copy", function (event) {
      var copiedValue = $('#txtTestInput').val();
      var clipboard = event.clipboardData;
      clipboard.setData("text/plain", copiedValue);
      alert( 'Copied ' + copiedValue + ' to the clipboard');
  });
})
</script>

<center>
<div class="container text-center center-block" align="center">
<br/>
<input type="text" class="input-lg col-lg-5 col-centered text-center" value="https://temporal.pw/p/{{token}}" readonly>
<span class="input-group-btn">
  <button id="btnCopy" class="btn btn-primary">Copy to clipboard</button>
  </span>
<br/>

<h2>Your password is:</h2>

<hr>
<h1>{{cleartext}}</h1>
<hr>

<br/>
<br/>
<h4>
This password can be viewed up to <b>{{views}}</b> more times before it expires in <b>{{days}}</b> days.<br/>
</h4>
<br/>

<a href="/">Store another password</a> | <a href="/about">About</a> | <a href="https://github.com/tkooda/temporalpw">Source</a></br>

</div>

</center>
</body>
</html>
