require 'rest-client'
require 'json'

class Bateman
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
  # passes through unknown content types as application/$type
  #
  def self.accept(*types)
    types.map { |t|
      (CONTENT[t] and CONTENT[t][:type]) or "application/#{t.to_s.downcase}"
    }
  end

  # do stuff based on response's Content-type
  #
  def self.process(resp, accept = nil)
    # do you even Content-type, bro?
    #
    ct = resp.headers[:content_type]
    unless ct
      warn "process NOOP -- no response Content-type"
      return resp.body
    end

    # warn if we got Content-type we didn't ask for
    #
    ct, charset = ct.split(';').map { |s| s.strip }
    warn "Asked for #{accept} but got #{ct}" if accept and !accept.include?(ct)

    # process the response for known content types
    #
    CONTENT.each { |sym, hsh|
      return hsh[:proc].call(resp.body) if ct == hsh[:type]
    }

    warn "process NOOP -- unrecognized Content-type: #{ct}"
    return response.body
  end

  attr_reader :options

  def initialize(host, options = nil)
    @host = host
    @options = { open_timeout: 100 }
    @options.merge!(options) if options
    accept :json, :html, :text
  end

  # Writes the Accept: header for you
  # e.g.
  # accept :json, :html  # Accept: application/json, text/html
  # accept nil           # remove Accept: header
  # TODO: automatically weight based on order
  #
  def accept(*types)
    types = types.first if types.first.is_a?(Array)
    @options[:headers] ||= {}
    return @options[:headers].delete(:accept) if types.first.nil?
    @options[:headers][:accept] = self.class.accept(*types).join(', ')
  end

  # use this method directly if you want finer-grained request and response
  # handling
  #
  def resource(path, options = {})
    path = "/#{path}" unless path[0,1] == '/'
    url = "http://#{@host}#{path}"
    options = @options.merge(options)

    RestClient::Resource.new(url, options)
  end

  def get(path, options = {})
    res = resource(path, options)
    response = res.get
    case response.code
    when 200..299
      self.class.process(response, res.headers[:accept])
    else
      raise(StatusCodeError, "GET #{path} #{resp.code}")
    end
  end

  def delete(path, options = {})
    res = resource(path, options)
    response = res.delete
    case response.code
    when 200..299
      self.class.process(response, res.headers[:accept])
    else
      raise(StatusCodeError, "DELETE #{path} #{resp.code}")
    end
  end

  # (JSON) payload required
  #
  [:post, :put].each { |meth|
    define_method(meth) { |path, payload, options={}|
      res = resource(path, options)
      response = res.send(meth, payload)
      case response.code
      when 200..299
        begin
          self.class.process(response, res.headers[:accept])
        rescue JSONParser::Error => e
          warn "rescued #{e.class}"
        end
      else
        raise(StatusCodeError, "#{meth.to_s.upcase} #{path} #{resp.code}")
      end
    }
  }
end

if __FILE__ == $0
  sites = %w{google.com yahoo.com microsoft.com amazon.com ibm.com reddit.com}
  accepts = [:json, :html, :text, :xml]
  methods = [:get, :post, :put, :delete]

  path = '/'
  payload = { 'hi' => 'mom' }.to_json

  puts "Checking Accepts across sites"
  sites.each { |site|
    b = Bateman.new(site)
    url = "http://#{site}#{path}"

    accepts.each { |acp|
      b.accept(acp)

      puts "GET #{url}  [#{acp}]"
      b.get path
    }
    puts
    puts
  }

  puts
  puts

  puts "Checking Methods across sites"
  sites.each { |site|
    b = Bateman.new(site)
    url = "http://#{site}#{path}"

    methods.each { |meth|
      args = [meth, path]
      args << payload if [:post, :put].include?(meth)

      puts "#{meth.to_s.upcase} #{url}"
      # DO IT
      begin
        b.send(*args)
      rescue RuntimeError => e
        puts e.class
      end
    }
    puts
    puts
  }
end
