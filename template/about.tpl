<html>
<head>
 <title>Temporal.PW - temporary secure storage for passwords</title>
 <meta name="viewport" content="width=device-width, initial-scale=1">
 <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.6/css/bootstrap.min.css">
</head>
<body>

<style type="text/css">
  body { background: #d3d3d3 !important; }
</style>

<div class="container">

<h1>About <a href="/">temporal.pw</a> :</h1>
<h4>
<br/>
<ul>
  <li>Provides secure, private, temporary (temporal) encrypted storage for passwords so they can be safely transmitted via insecure channels (email, IM, SMS, etc.)</li><br/>
  <li>This is safer than just sending the password unencrypted or whenever end-to-end encryption isn't established / available.</li><br/>
  <li>Passwords are only stored AFTER being encrypted by the browser using AES, and the (random 128 bit) decryption key is NEVER sent to the server.</li><br/>
  <li>The passwords are not accessible after their expiration date, and are delieted immediately after being viewed a single time.</li><br/>
  <li><a href="http://github.com/tkooda/temporalpw">100% open source</a>.</li><br/>
  <li>Easy to audit: only a few hundred lines of python and JavaScript.</li><br/>
  <li>Uses common <a href="http://bottlepy.org/">Bottle</a> framework, <a href="https://www.dlitz.net/software/pycrypto/">PyCrypto</a>, and <a href="https://pypi.python.org/pypi/base58">Base58</a> libraries for the backend, and <a href="https://jquery.com/">jQuery</a>, <a href="http://getbootstrap.com/">bootstrap</a>, and <a href="http://zeroclipboard.org/">ZeroClipboard</a> for the frontend.</li><br/>
  <li>If you'd like to help keep this service free forever: you can send a few pennies via Bitcoin to: <a href="bitcoin:1MLaaKmMbioyCKZShbyKGJztUP8M7BHRYp">1MLaaKmMbioyCKZShbyKGJztUP8M7BHRYp</a></li><br/>
</ul>

</h4>
<br/>
<center>
<a href="/">Store another password</a> | <a href="https://github.com/tkooda/temporalpw">Source</a></br>
</center>

</div>

</body>
</html>
