Bateman
=======
Bateman is a JSON-oriented, thin wrapper around [rest-client](https://github.com/rest-client/rest-client)'s [RestClient::Resource](https://github.com/rest-client/rest-client#usage-activeresource-style)

Features
--------
* *GET*, *POST*, *PUT*, or *DELETE* JSON payloads
* Convenience
* Do The Right Thing 80% of the time every time
* Simple *Accept:* headers with automatic q-score weighting
* Understand and fall back to basic Content-types if application/json is not provided
* Fine-grained response handling using Bateman#resource

Quick Start
-----------
Initialize it with a host:

    b = Bateman.new 'ip.jsontest.com'

The convenience methods *#get*, *#post*, *#put*, or *#delete* return the response body.  If the response has a *Content-type:* **application/json** header, then JSON parsing will be automatically performed on the response body, with the resulting object returned.

    response = b.get '/'
    # => {"ip"=>"12.34.56.78"}

    response.class
    # => Hash

Usage
-----
You can pass through persistent [options to rest-client](https://github.com/rest-client/rest-client/blob/master/lib/restclient/request.rb):

    b = Bateman.new 'google.com', max_redirects: 3

Declare what you accept: (optional, default shown)

    b.accept :json, :html, :text

You can pass through per-request [options to rest-client](https://github.com/rest-client/rest-client/blob/master/lib/restclient/request.rb)

    b.get '/', max_redirects: 3
    # => "<!doctype html><html ... <head><meta content=\"Search the world's information ... "

[RestClient exceptions](https://github.com/rest-client/rest-client/blob/master/lib/restclient/exceptions.rb) will be passed through.  POST and PUT payloads will be sent as strings.  Non-string payloads will be converted to JSON by calling #to_json.

    b = Bateman.new 'plus.google.com'
    b.post '/', { 'hi' => 'mom' }, max_redirects: 3

    /path/to/lib/restclient/abstract_response.rb:48:in `return!': 405 Method Not Allowed (RestClient::MethodNotAllowed)

    # lawyer up
    # hit gym
    Bateman.new('facebook.com').delete '/'

     /path/to/lib/restclient/abstract_response.rb:39:in `return!': 301 Moved Permanently (RestClient::MovedPermanently)

Careful with that axe, Eugene
-----------------------------
Call Bateman#resource directly for finer-grained response handling:

    resp = Bateman.new('google.com').resource('/').get
    # check resp.code
    # check resp.headers
    # process resp.body
    # etc.

Here is the heart of the Bateman's [response processing](https://github.com/rickhull/bateman/blob/master/lib/bateman.rb#L37):

    # this structure declares what we support in the request Accept: header
    # and defines automatic processing of the response based on the
    # response Content-type: header
    #
    CONTENT = {
      json: {
        type: 'application/json',
        proc: proc { |text| JSON.parse(text, symobolize_names: true) },
      },
      html: {
        type: 'text/html',
        proc: proc { |text| text },
      },
      text: {
        type: 'text/plain',
        proc: proc { |text| text },
      },
    }

Funny, that
-----------
Bateman works best with webservers that respect the *Accept:* request header and provide proper *Content-type:* response headers.

[RFC 2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html)

> If no Accept header field is present, then it is assumed that the client accepts all media types. If an Accept header field is present, and if the server cannot send a response which is acceptable according to the combined Accept field value, then the server SHOULD send a 406 (not acceptable) response.

Examples
--------
* accepts_and_methods [sample script](https://github.com/rickhull/bateman/blob/master/examples/accepts_and_methods.rb)
* accepts_and_methods [sample output](https://github.com/rickhull/bateman/blob/master/examples/accepts_and_methods.txt)
