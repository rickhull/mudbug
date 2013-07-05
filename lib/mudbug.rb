require 'rest-client'
require 'json'
require 'lager'

class Mudbug
  extend Lager
  log_to $stderr, :warn

  def self.version
    vpath = File.join(File.dirname(__FILE__), '..', 'VERSION')
    File.read(vpath).chomp
  end

  class StatusCodeError < RuntimeError; end

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
  #
  def self.process(resp, accept = nil)
    @lager.debug { "response code: #{resp.code}" }
    @lager.debug { "response headers:\n" << resp.raw_headers.inspect }

    unless (200..299).include?(resp.code)
      @lager.warn { "processing with HTTP Status Code #{resp.code}" }
    end

    # do you even Content-type, bro?
    ct = resp.headers[:content_type]
    unless ct
      @lager.warn { "abort processing -- no response Content-type" }
      return resp.body
    end

    # warn if we got Content-type we didn't ask for
    ct, charset = ct.split(';').map { |s| s.strip }
    if accept and !accept.include?(ct)
      @lager.warn { "Asked for #{accept} but got #{ct}" }
    end

    # process the response for known content types
    CONTENT.each { |sym, hsh|
      return hsh[:proc].call(resp.body) if ct == hsh[:type]
    }

    @lager.warn { "abort processing -- unrecognized Content-type: #{ct}" }
    return resp.body
  end

  attr_reader :options
  attr_accessor :host

  def initialize(host, options = {})
    # note, not yet logging at instance layer
    # @lager = self.class.lager
    @host = host
    @options = options
    accept :json, :html, :text
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
  #
  def resource(path, options = {})
    path = "/#{path}" unless path[0,1] == '/'
    RestClient::Resource.new "http://#{@host}#{path}", @options.merge(options)
  end

  # no payload
  #
  [:get, :delete].each { |meth|
    define_method(meth) { |path, options = {}|
      res = resource(path, options)
      self.class.process(res.send(meth), res.headers[:accept])
    }
  }

  # (JSON) payload required
  # if payload is a String, then assume it's already JSON
  # otherwise apply #to_json to payload automatically.  Quack.
  #
  [:post, :put].each { |meth|
    define_method(meth) { |path, payload, options={}|
      payload = payload.to_json unless payload.is_a?(String)
      res = resource(path, options)
      self.class.process(res.send(meth, payload), res.heads[:accept])
    }
  }
end
