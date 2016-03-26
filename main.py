#!/usr/bin/python

## temporal.pw  -  2016-02-14  -  Thor J. Kooda

## 2016-03-26 : rewrote, move password encryption to client side, server is never sent any part of the key (browser does all encryption/decryption)

"""Provide temporary URLs for viewing encrypted passwords."""

from bottle import Bottle, request, template, abort
from Crypto import Random ## FIXME: use 'random' instead, so no extra lib needed
from Crypto.Hash import SHA ## FIXME: use hashlib instead, so no extra lib needed
from base58 import b58encode, b58decode
from google.appengine.ext import ndb, webapp
import datetime
import os

MAX_CIPHER = 1024
MAX_DAYS = 30

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


@bottle.get( "/about" )
def about():
    return template( "template/about" )


@bottle.post( "/new" )
def new():
    cipher = request.POST.get( "cipher" ).strip()
    days = int( request.POST.get( "days" ).strip() )
    myiponly = request.POST.get( "myiponly" )
    
    if len( cipher ) < 1 or len( cipher ) > MAX_CIPHER \
       or days < 1 or days > MAX_DAYS:
        abort( 400, "invalid options" )
    
    ## generate unique pw_id ..
    pw_id = b58encode( Random.get_random_bytes( 4 ) )
    while Password.get_by_id( pw_id ):
        pw_id = b58encode( Random.get_random_bytes( 4 ) )
    
    expire = datetime.datetime.now() + datetime.timedelta( days = days )
    
    password = Password( id = pw_id,
                         ciphertext = cipher,
                         expire_date = expire )
    if myiponly:
        ## only store a salted hash of the IP, for privacy
        ip_salt = SHA.new( Random.get_random_bytes( 8 ) ).hexdigest()[ : 4 ]
        password.ip_hash = ip_salt + ":" + SHA.new( ip_salt + os.environ[ "REMOTE_ADDR" ] ).hexdigest()
    
    password.put()
    
    return { "pw_id": pw_id }


@bottle.get( "/p" )
def index():
    return template( "template/p" )


## tkooda : 2016-03-26 : unused..
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
        if not ip_hash == SHA.new( ip_salt + os.environ[ "REMOTE_ADDR" ] ).hexdigest():
            return abort( 404 )
    
    cipher = password.ciphertext
    
    password.key.delete() # only return encrypted password for a SINGLE viewing
    
    return { "cipher": cipher }


@bottle.error( 404 )
def error_404( error ):
    """Return a custom 404 error."""
    return template( "template/404" )


@bottle.get( "/cleanup" )
def cleanup():
    keys = Password.query( Password.expire_date < datetime.datetime.now() ).fetch( keys_only = True )
    ndb.delete_multi( keys )
