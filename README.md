Bateman
=======
Bateman is a JSON-oriented, thin wrapper around rest-client's RestClient::Resource

Features
--------
* *GET*, *POST*, *PUT*, or *DELETE* JSON payloads
* Convenience
* Do The Right Thing 80% of the time every time
* Understand and fall back to basic Content-types if application/json is not provided
* Fine-grained response handling using Bateman#resource


Usage
-----
Initialize it with a host:

    b = Bateman.new 'google.com'

You can pass through persistent [options to rest-client](https://github.com/rest-client/rest-client/blob/master/lib/restclient/request.rb):

    b = Bateman.new 'google.com, max_redirects: 3

Declare what you accept: (optional, defaults to :json, :html, :text)

    b.accept :json, :html

GET http://google.com/

    b.get '/'
    # => "<!doctype html><html ... <head><meta content=\"Search the world's information ... "

You can pass through one-time options to rest-client:

    b.get '/, max_redirects: 3

Call Bateman#resource directly for finer-grained response handling:

    b = Bateman.new 'google.com'
    res = b.resource '/'
    resp = res.get
    # check resp.code
    # check resp.headers
    # process resp.body
    # etc.

RestClient exceptions will be passed through:

    b = Bateman.new 'google.com'
    b.post '/', Hash.new.to_json

    /path/to/lib/restclient/abstract_response.rb:48:in `return!': 405 Method Not Allowed (RestClient::MethodNotAllowed)

Bateman, while focused on JSON, is aware of several content types: application/json, text/html, and text/plain.  If you call the convenience methods #get #post #put or #delete, then JSON parsing will be automatically performed for Content-type: application/json

In other words, Bateman works best with webservers that respect the *Accept:* request header and provide proper *Content-type:* response headers.
