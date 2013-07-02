Bateman
=======
Bateman is a JSON-oriented, thin wrapper around [rest-client](https://github.com/rest-client/rest-client)'s [RestClient::Resource](https://github.com/rest-client/rest-client#usage-activeresource-style)

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

    b = Bateman.new 'google.com', max_redirects: 3

Declare what you accept: (optional, default shown)

    b.accept :json, :html, :text

You can pass through per-request [options to rest-client](https://github.com/rest-client/rest-client/blob/master/lib/restclient/request.rb)

GET http://google.com/

    b.get '/', max_redirects: 3
    # => "<!doctype html><html ... <head><meta content=\"Search the world's information ... "

[RestClient exceptions](https://github.com/rest-client/rest-client/blob/master/lib/restclient/exceptions.rb) will be passed through.  POST and PUT payloads will be sent as Strings.  Non-String payloads will be converted to JSON by calling #to_json.

POST http://plus.google.com/

    b = Bateman.new 'plus.google.com'
    b.post '/', { 'hi' => 'mom' }

    /path/to/lib/restclient/abstract_response.rb:48:in `return!': 405 Method Not Allowed (RestClient::MethodNotAllowed)

DELETE http://facebook.com/

    # lawyer up
    # hit gym
    Bateman.new('facebook.com').delete '/'

     /path/to/lib/restclient/abstract_response.rb:39:in `return!': 301 Moved Permanently (RestClient::MovedPermanently)

Call Bateman#resource directly for finer-grained response handling:

    resp = Bateman.new('google.com').resource('/').get
    # check resp.code
    # check resp.headers
    # process resp.body
    # etc.

Bateman, while focused on JSON, is aware of several content types:
* :json - application/json
* :html - text/html
* :text - text/plain

If you call the convenience methods *#get*, *#post*, *#put*, or *#delete*, then JSON parsing will be automatically performed for responses with *Content-type:* application/json.

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

Examples
--------
* accepts_and_methods [sample script](https://github.com/rickhull/bateman/blob/master/examples/accepts_and_methods.rb)
* accepts_and_methods [sample output](https://github.com/rickhull/bateman/blob/master/examples/accepts_and_methods.txt)
