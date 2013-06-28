require 'rest-client'
require 'json'

class JSONResource
  def initialize(host, options = nil)
    @host = host
    @options = { open_timeout: 100 }
    @options.merge!(options) if options
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

  # TODO: Request headers
  #       set Accept headers so we "force" JSON response
  #       also drive Substratum REST API development to "Do the right thing"

  # TODO: Response headers
  #       parse JSON based on the Content-type

  # "always" a JSON response body
  def get(path, options = {})
    resp = resource(path, options).get
    case resp.code
    when 200..299
      JSON.parse(resp.body, symbolize_names: true)
    else
      raise "can't handle #{resp.code}"
    end
  end

  # don't care about response
  def delete(path, options = {})
    resp = resource(path, options).delete
    case resp.code
    when 200..299
      resp.body
    else
      raise "can't handle #{resp.code}"
    end
  end

  # attempt to parse JSON, might just be text body
  [:post, :put].each { |meth|
    define_method(meth) { |path, payload, options={}|
      resp = resource(path, options).send(meth, payload)
      case resp.code
      when 200..299
        # attempt JSON parse
        begin
          JSON.parse(resp.body, symbolize_names: true)
        rescue JSON::ParserError
          resp.body
        end
      else
        raise "can't handle #{resp.code}"
      end
    }
  }
end
