#!/usr/bin/python

## temporal.pw  -  2016-02-14  -  Thor J. Kooda

"""Temporary storage of cleartext passwords for easier transmission."""

from bottle import Bottle, request, template, redirect, abort
from Crypto import Random
from Crypto.Cipher import AES
from base58 import b58encode, b58decode
from google.appengine.ext import ndb
import datetime

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

bottle = Bottle()


@bottle.get( "/" )
def index():
    return template( "template/index" )


@bottle.get( "/about" )
def about():
    return template( "template/about" )


@bottle.post( "/new" )
def new():
    secret = request.POST.get( "secret" ).strip()
    views  = int( request.POST.get( "views"  ).strip() )
    days   = int( request.POST.get( "days"   ).strip() )
    
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
                         remaining_views = views,
                         expire_date = expire )
    password.put()
    
    redirect( "/p/" + encoded_key )


@bottle.get( "/p/<token>" )
def p( token ):
    try:
        if len( token ) < 10 or len( token ) > 30: # tokens likely between 16 and 21 bytes
            raise ValueError( "invalid token length" )
        decoded = b58decode( token )
    except:
        abort( 400, template( "template/invalid" ) )
    
    password = Password.get_by_id( token[ : len( token ) / 2 ] )
    if not password:
        return template( "template/expired" )
    
    if password.remaining_views < 1 or password.expire_date < datetime.datetime.now():
        password.key.delete() # delete expired immediatley, don't wait for cron
        return template( "template/expired" )
    
    password.remaining_views -= 1
    password.put()
    
    cleartext = AES.new( decoded, AES.MODE_CFB, IV ).decrypt( password.ciphertext )
    
    return template( "template/p", { "token": token,
                                     "cleartext": cleartext,
                                     "views": password.remaining_views,
                                     "expire": password.expire_date } )


@bottle.error( 404 )
def error_404( error ):
    """Return a custom 404 error."""
    return template( "template/404" )

