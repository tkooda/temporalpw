#!/usr/bin/python

## temporal.pw  -  2016-02-14  -  Thor J. Kooda

## 2016-03-26 : rewrote. move password encryption to client side, server is never sent any part of the key (browser does all encryption/decryption)

"""Provide temporary storage for encrypted passwords so they can be sent via E-Mail."""

from bottle import Bottle, request, template, abort, response, redirect
from google.appengine.ext import ndb, webapp
from Crypto.Cipher import AES
from Crypto.Hash import SHA256
from Crypto import Random
import Crypto.Util.Counter
import datetime
import string
import random
import hashlib
import base58
import os


class Password( ndb.Model ):
    """temporary storage for encrypted password"""
    ciphertext = ndb.BlobProperty( required = True )  # password only sent to server AFTER being encrypted by browser, key NEVER sent to server
    expire_date = ndb.DateTimeProperty( required = True )
    ip_hash = ndb.StringProperty()

class LetsEncrypt( ndb.Model ):
    """LetsEncrypt challenge responses"""
    response = ndb.StringProperty( required = True )
    added = ndb.DateTimeProperty( required = True, auto_now_add = True )


bottle = Bottle()


# SSL cert from letsencrypt.org
@bottle.get( "/.well-known/acme-challenge/<challenge>" )
def letsencrypt( challenge ):
#    LetsEncrypt( id = challenge, response = "test response" ).put()
    le = LetsEncrypt.get_by_id( challenge )
    if le:
        return le.response
    return abort( 404 )


@bottle.get( "/" )
def index():
    return template( "template/index", { "ip": os.environ[ "REMOTE_ADDR" ] } )


@bottle.get( "/p" )
def p():
    return template( "template/p" )


@bottle.get( "/p<redir>" )
def p_redir( redir ):
    redirect( "/p" + redir ) # redirect to catch any user mangling of URL ("/p%23...")


@bottle.get( "/about" )
def about():
    return template( "template/about" )


@bottle.post( "/new" )
def new():
    cipher = request.POST.get( "cipher" ).strip()
    days = int( request.POST.get( "days" ).strip() )
    myiponly = request.POST.get( "myiponly" )

    if len( cipher ) < 1 or len( cipher ) > 8192 \
       or days < 1 or days > 30:
        abort( 400, "invalid options" )

    ## generate unique pw_id ..
    pw_id = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(4))
    while Password.get_by_id( pw_id ):
        pw_id = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(4))

    expire = datetime.datetime.now() + datetime.timedelta( days = days )

    password = Password( id = pw_id,
                         ciphertext = cipher,
                         expire_date = expire )

    if myiponly == "true":
        ## only store a salted hash of the IP, for privacy
        ip_salt = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(4))
        password.ip_hash = ip_salt + ":" + hashlib.sha1( ip_salt + os.environ[ "REMOTE_ADDR" ] ).hexdigest()

    password.put()

    response.add_header( "Access-Control-Allow-Origin", "*" ) # for auditable version + development

    return { "pw_id": pw_id }

@bottle.post( "/upload" )
def upload():
    try:
        upload = request.POST.get( "upload" ).strip()

        password = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(16))
        iv       = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(4))

        iv = "0000000000009001"
        aes = AES.new(password, AES.MODE_CFB, IV=str.encode(iv), segment_size=8)
        cipher = base58.b58encode(aes.encrypt(upload))

        pw_id = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(4))
        while Password.get_by_id( pw_id ):
            pw_id = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(4))

        expire = datetime.datetime.now() + datetime.timedelta( 7 )
        token = "%s-%s" % (pw_id,base58.b58encode(password))
        token = token + SHA256.new(str.encode(token)).hexdigest()[0:2]
        Password( id = pw_id,
                             ciphertext = cipher,
                             expire_date = expire ).put()

        return "%s://%s/p#%s" % (request.urlparts[0],request.urlparts[1],token)
    except Exception as e:
        print (e)
    return str(e)

@bottle.get( "/get/<pw_id>" )
def get( pw_id ):
    password = Password.get_by_id( pw_id )

    if not password:
        return abort( 404 )

    if password.expire_date < datetime.datetime.now(): # delete immediately if expired
        password.key.delete()
        return abort( 404 )

    if password.ip_hash:
        ## only allow viewing from matching IP if myiponly is set..
        ip_salt, ip_hash = password.ip_hash.split( ":", 1 )
        if not ip_hash == hashlib.sha1( ip_salt + os.environ[ "REMOTE_ADDR" ] ).hexdigest():
            return abort( 404 )

    cipher = password.ciphertext

    password.key.delete() # only return encrypted password for a SINGLE viewing

    response.add_header( "Access-Control-Allow-Origin", "https://tkooda.github.io" ) # for auditable version

    return { "cipher": cipher }


@bottle.get( "/cleanup" ) # cron
def cleanup():
    keys = Password.query( Password.expire_date < datetime.datetime.now() ).fetch( keys_only = True )
    ndb.delete_multi( keys )
