bateman
=======

Hopefully development will not be arrested on this gem of a JSON-parsing REST client

Bateman is a JSON-oriented, thin wrapper around rest-client's RestClient::Resource

Its main features are convenience and Doing The Right Thing 80% of the time every time.

If you need finer-grained response handling, just call Bateman#resource directly.

Initialize it with a host:

    b = Bateman.new 'google.com'

You can pass through persistent options to rest-client: [add pointer to lib/restclient/request.rb]

    b = Bateman.new 'google.com, max_redirects: 3

Declare what you accept: (optional, defaults to :json, :html, :text)

    b.accept :json, :html
    
GET /

    b.get '/'

You can pass through one-time options to rest-client:

    b.get '/, max_redirects: 3

Call #resource directly for finer-grained response handling:

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
