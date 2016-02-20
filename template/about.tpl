<html>
<head>
 <title>Temporal.PW - temporary secure storage for passwords</title>
 <meta name="viewport" content="width=device-width, initial-scale=1">
 <link rel="stylesheet" href="/static/bootstrap.min.css">
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
  <li>Provides secure temporary (temporal) storage for passwords so they can be securely transmitted via insecure channels (email, IM, SMS, etc.)</li><br/>
  <li>This is safer than just sending the password unencrypted or whenever end-to-end encryption isn't established / available</li><br/>
  <li>Passwords are stored encrypted with AES and cannot be decrypted without the unique URL even if the database is exposed</li><br/>
  <li>Easy to audit: only around 150 lines of (easty to read, python) code</li><br/>
  <li>Uses <a href="http://bottlepy.org/">Bottle</a> framework, <a href="https://www.dlitz.net/software/pycrypto/">PyCrypto</a>, and <a href="https://pypi.python.org/pypi/base58">Base58</a> libraries</li><br/>
  <li><a href="http://github.com/tkooda/temporalpw">100% open source</a></li><br/>
  <li>Hosted on Google's App Engine servers</li><br/>
  <li>The IP restriction option only stores a salted hash of your IP</li><br/>
  <li>Please donate a few pennies via Bitcoin to help keep this service free forever: <a href="bitcoin:1MLaaKmMbioyCKZShbyKGJztUP8M7BHRYp">1MLaaKmMbioyCKZShbyKGJztUP8M7BHRYp</a></li><br/>
</ul>

</h4>
<br/>
<center>
<a href="/">Store another password</a> | <a href="https://github.com/tkooda/temporalpw">Source</a></br>
</center>

</div>

</body>
</html>
