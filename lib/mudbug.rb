require 'rest-client'
require 'json'
require 'lager'

class Mudbug
  def self.version
    file = File.expand_path('../../VERSION', __FILE__)
    File.read(file).chomp
  end

  extend Lager
  log_to $stderr, :warn

  class StatusCodeError < RuntimeError; end
  class ContentTypeError < RuntimeError; end

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

  # map our internal symbols to HTTP content types
  # assign q scores based on the parameter order
  # construct the right side of the Accept: header
  #
  def self.accept_header(*types)
    types.map.with_index { |t, i|
      type = CONTENT[t] ? CONTENT[t][:type] : "application/#{t.to_s.downcase}"
      quality = "q=" << sprintf("%0.1f", 1.0 - i*0.1)
      i == 0 ? type : [type, quality].join(';')
    }.join(', ')
  end

  # do stuff based on response's Content-type
  # accept is e.g. [:json, :html]
  #
  def self.process(resp, accept = nil)
    @lager.debug { "accept: #{accept}" }
    @lager.debug { "response code: #{resp.code}" }
    @lager.debug { "response headers:\n" << resp.raw_headers.inspect }

    unless (200..299).include?(resp.code)
      @lager.warn { "processing with HTTP Status Code #{resp.code}" }
    end

    # do you even Content-type, bro?
    ct = resp.headers[:content_type]
    unless ct
      @lager.warn { "abandon processing -- no response Content-type" }
      return resp.body
    end

    # get the content-type
    ct, charset = ct.split(';').map { |s| s.strip }
    @lager.info { "got charset: #{charset}; ignoring" } if charset

    # raise if we got Content-type we didn't ask for
    if accept and !accept.include?(ct)
      raise ContentTypeError, "Asked for #{accept} but got #{ct}"
    end

    # process the response for known content types
    CONTENT.each { |sym, hsh|
      return hsh[:proc].call(resp.body) if ct == hsh[:type]
    }

    @lager.warn { "abandon processing -- unrecognized Content-type: #{ct}" }
    return resp.body
  end

  attr_reader :options
  attr_accessor :host, :protocol

  def initialize(host = 'localhost', options = {})
    @host = host
    https = options.delete(:https)
    @protocol = https ? 'https' : 'http'
    @options = options
    accept :json, :html, :text
    yield self if block_given?
  end

  # Writes the Accept: header for you
  # e.g.
  # accept :json, :html  # Accept: application/json, text/html
  # accept nil           # remove Accept: header
  # Now adds q-scores automatically based on order
  # Note: the hard work is done by the class method
  #
  def accept(*types)
    types = types.first if types.first.is_a?(Array)
    @options[:headers] ||= {}
    return @options[:headers].delete(:accept) if types.first.nil?
    @options[:headers][:accept] = self.class.accept_header(*types)
  end

  # use this method directly if you want finer-grained request and response
  # handling
  # supports /path/to/res, path/to/res, http://host.com/path/to/res
  #
  def resource(path)
    uri = URI.parse(path)
    if uri.host # a full URL was passed in
      @host = uri.host
      @protocol = uri.scheme
      url = uri.to_s
    else
      path = "/#{path}" unless path[0,1] == '/'
      url = "#{@protocol}://#{@host}#{path}"
    end
    RestClient::Resource.new(url, @options)
  end

  # no payload
  #
  [:get, :delete].each { |meth|
    define_method(meth) { |path, params = {}|
      res = resource(path)
      resp = res.send(meth, params: params)
      self.class.process(resp, res.headers[:accept])
    }
  }

  # (JSON) payload required
  # if payload is a String, then assume it's already JSON
  # otherwise apply #to_json to payload automatically.  Quack.
  #
  [:post, :put].each { |meth|
    define_method(meth) { |path, payload, params = {}|
      payload = payload.to_json unless payload.is_a?(String)
      res = resource(path)
      resp = res.send(meth, payload,
                      content_type: CONTENT[:json][:type],
                      params: params)
      self.class.process(resp, res.headers[:accept])
    }
  }
end
