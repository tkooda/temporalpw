#!/usr/bin/python

## temporal.pw  -  2016-02-14  -  Thor J. Kooda

"""Temporary storage of cleartext passwords for easier transmission."""

from bottle import Bottle, request, template, redirect, abort
from Crypto import Random
from Crypto.Cipher import AES
from Crypto.Hash import SHA
from base58 import b58encode, b58decode
from google.appengine.ext import ndb, webapp
import datetime
import os

# http://stackoverflow.com/questions/14716338/pycrypto-how-does-the-initialization-vector-work  - no iv for aes needed
IV = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" # guard against ID/Key collisions in a loop so that we don't need to encode a unique IV along with the key, which would result in a URL token that's twice as long
MAX_SECRET = 1024
MAX_VIEWS = 50
MAX_DAYS = 30

class Password( ndb.Model ):
    """temporary storage for encrypted password.  ID is only the first half of the key."""
    ciphertext = ndb.BlobProperty( required = True )
    remaining_views = ndb.IntegerProperty( required = True )
    expire_date = ndb.DateTimeProperty( required = True )
    ip_hash = ndb.StringProperty()

bottle = Bottle()


@bottle.get( "/" )
def index():
    return template( "template/index", { "ip": os.environ[ "REMOTE_ADDR" ] } )


@bottle.get( "/about" )
def about():
    return template( "template/about" )


@bottle.post( "/new" )
def new():
    secret = request.POST.get( "secret" ).strip()
    views = int( request.POST.get( "views" ).strip() )
    days = int( request.POST.get( "days" ).strip() )
    myiponly = request.POST.get( "myiponly" )
    
    if len( secret ) < 1 or len( secret ) > MAX_SECRET \
       or views < 1 or views > MAX_VIEWS \
       or days < 1 or days > MAX_DAYS:
        abort( 400, "invalid options" )
    
    key = Random.get_random_bytes( AES.block_size )
    encoded_key = b58encode( key )
    
    ## loop to avoid duplicate keys and the need for unique IVs
    while Password.get_by_id( encoded_key[ : len( encoded_key ) / 2 ] ):
        key = Random.get_random_bytes( AES.block_size )
        encoded_key = b58encode( key )
    
    ciphertext = AES.new( key, AES.MODE_CFB, IV ).encrypt( secret )
    expire = datetime.datetime.now() + datetime.timedelta( days = days )
    
    password = Password( id = encoded_key[ : len( encoded_key ) / 2 ], # only store first half of the key!
                         ciphertext = ciphertext,
                         remaining_views = views + 1,
                         expire_date = expire )
    if myiponly:
        ip_salt = SHA.new( Random.get_random_bytes( 8 ) ).hexdigest()[ : 8 ]
        password.ip_hash = ip_salt + ":" + SHA.new( ip_salt + os.environ[ "REMOTE_ADDR" ] ).hexdigest()
    
    password.put()
    
    redirect( "/p/" + encoded_key )


@bottle.get( "/<action>/<token>" ) # /p/ or /d/
def action( action, token ):
    if action != "p" and action != "d":
        return abort( 404 )
    
    try:
        if len( token ) < 10 or len( token ) > 30: # tokens likely between 16 and 21 bytes
            raise ValueError( "invalid token length" )
        decoded = b58decode( token )
    except:
        return template( "template/generic", { "title": "This URL is invalid",
                                               "message": "This URL is invalid, please re-check the URL." } )
    
    password = Password.get_by_id( token[ : len( token ) / 2 ] )
    if not password:
        return template( "template/generic", { "title": "This password has expired",
                                               "message": "This password has expired." } )
    
    if password.remaining_views < 1 or password.expire_date < datetime.datetime.now():
        password.key.delete() # delete expired immediatley, don't wait for cron
        return template( "template/generic", { "title": "This password has expired",
                                               "message": "This password has expired." } )
    
    if password.ip_hash:
        ip_salt, ip_hash = password.ip_hash.split( ":", 1 )
        if not ip_hash == SHA.new( ip_salt + os.environ[ "REMOTE_ADDR" ] ).hexdigest():
            return template( "template/generic", { "title": "Access denied",
                                                   "message": "This password is not accessible from your IP." } )
        ip_str = "only from " + os.environ[ "REMOTE_ADDR" ]
    else:
        ip_str = "from any IP"
    
    if action == "d": # user requested deletion
        password.key.delete()
        return template( "template/generic", { "title": "Password deleted",
                                               "message": "Password deleted" } )
    
    password.remaining_views -= 1
    password.put()
    
    try:
        cleartext = AES.new( decoded, AES.MODE_CFB, IV ).decrypt( password.ciphertext )
    except:
        return template( "template/generic", { "title": "This URL is invalid",
                                               "message": "This URL is invalid, please re-check the URL." } )
    
    days = password.expire_date - datetime.datetime.now()
    return template( "template/p", { "token": token,
                                     "cleartext": cleartext,
                                     "views": password.remaining_views,
                                     "days": days.days,
                                     "ip_str": ip_str } )


@bottle.error( 404 )
def error_404( error ):
    """Return a custom 404 error."""
    return template( "template/404" )


@bottle.get( "/cleanup" )
def cleanup():
    keys = Password.query( ndb.OR( Password.remaining_views < 1,
                                   Password.expire_date < datetime.datetime.now() ) ).fetch( keys_only = True )
    ndb.delete_multi( keys )
