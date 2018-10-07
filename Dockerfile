FROM google/cloud-sdk:latest
WORKDIR /app
ADD https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.6/css/bootstrap.min.css static/
ADD https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js static/
ADD https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.6/js/bootstrap.min.js static/
ADD https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/1.5.8/clipboard.min.js static/
ADD https://cdn.rawgit.com/ricmoo/aes-js/v3.1.0/index.js static/aes-js.js
ADD https://cdn.rawgit.com/45678/base58/master/Base58.js static/
ADD https://cdnjs.cloudflare.com/ajax/libs/jshashes/1.0.5/hashes.min.js static/
ADD . /app
RUN pip install -r requirements.txt -t lib/
RUN rm /app/Dockerfile
EXPOSE 8080
EXPOSE 8000
ENTRYPOINT ["/usr/bin/dev_appserver.py","--host=0.0.0.0","--admin_host=0.0.0.0","app.yaml"]