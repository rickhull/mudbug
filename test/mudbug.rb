require 'minitest/autorun'
require 'mudbug'

describe "Mudbug" do

  #
  # class methods
  #

  describe "accept_header" do
    it "must generate valid headers" do
      h = Mudbug.accept_header(:json, :xml, :html, :text, :foo)
      ary = h.split(', ')
      expect(ary.length).must_equal 5

      # first entry does not have a qspec
      expect(ary[0]).must_equal 'application/json'

      # subsequent entries must have a qspec
      qspec = /q=\d*\.*\d/   # e.g. q=0.5

      xml_ary = ary[1].split(';')
      expect(xml_ary[0]).must_equal 'application/xml'
      expect(xml_ary[1]).must_match qspec

      html_ary = ary[2].split(';')
      expect(html_ary[0]).must_equal 'text/html'
      expect(html_ary[1]).must_match qspec

      text_ary = ary[3].split(';')
      expect(text_ary[0]).must_equal 'text/plain'
      expect(text_ary[1]).must_match qspec

      foo_ary = ary[4].split(';')
      expect(foo_ary[0]).must_equal 'application/foo'
      expect(foo_ary[1]).must_match qspec
    end
  end

  describe "process" do
    def http_response(body, opts = {})
      opts[:http_ver] ||= 1.1
      opts[:status_code] ||= '200 OK'
      opts[:conn] ||= 'close'
      headers = ["HTTP/#{opts[:http_ver]} #{opts[:status_code]}",
                 "Content-Length: #{body.length}",
                 "Connection: #{opts[:conn]}"]
      headers << "Content-type: #{opts[:content_type]}" if opts[:content_type]
      [headers, '', '', body].join("\n")
    end

    def dummy_io(str)
      Net::BufferedIO.new(StringIO.new(str.gsub("\n", "\r\n")))
    end

    def net_http_resp(body, opts = {})
      Net::HTTPResponse.read_new(dummy_io(http_response(body, opts)))
    end

    def rest_client_resp(body, opts = {})
      req = RestClient::Request.new(method: 'get', url: 'http://google.com/')
      RestClient::Response.create(body, net_http_resp(body, opts), req)
    end

    it "must process an empty response" do
      empty_resp = rest_client_resp('', content_type: 'text/html')
      body = Mudbug.process(empty_resp)
      expect(body).wont_be_nil
      expect(body).must_be_empty
    end

    it "must process a nonempty response" do
      resp_body = 'foo: bar'
      resp = rest_client_resp(resp_body, content_type: 'text/html')
      body = Mudbug.process(resp)
      expect(body).wont_be_nil
      expect(body).wont_be_empty
      expect(body).must_equal resp_body
    end

    it "must warn about missing content-type" do
      resp = rest_client_resp('')
      out, err = capture_subprocess_io do
        Mudbug.process(resp)
      end
      expect(out).must_be_empty
      expect(err).wont_be_empty
    end

    it "must faithfully yield valid JSON" do
      data = { "hi" => "mom" }
      resp = rest_client_resp(data.to_json, content_type: 'application/json')
      expect(Mudbug.process(resp)).must_equal data
    end
  end

  #
  # instance methods
  #

  describe "initalize" do
    it "must allow https" do
      mb = Mudbug.new 'localhost', https: true
      expect(mb.protocol).must_equal 'https'
      expect(mb.options[:https]).must_be_nil
    end
  end

  describe "resource" do
    it "must handle various path formulations" do
      paths = %w[/path/to/res path/to/res http://localhost/path/to/res]
      mb = Mudbug.new 'localhost'
      paths.each { |p|
        res = mb.resource(p)
        expect(res).wont_be_nil
        expect(res.url).must_equal 'http://localhost/path/to/res'
      }
    end

    it "must update the host when provided" do
      mb = Mudbug.new
      expect(mb.host).must_equal 'localhost'
      res = mb.resource('http://localghost/path/to/res')
      expect(res.url).must_equal 'http://localghost/path/to/res'
      expect(mb.host).must_equal 'localghost'
    end

    it "must respect https" do
      mb = Mudbug.new
      expect(mb.protocol).wont_equal 'https'
      res = mb.resource('https://localhost/')
      expect(mb.protocol).must_equal 'https'
      expect(res.url).must_equal 'https://localhost/'
      res = mb.resource('/foo')
      expect(res.url).must_equal 'https://localhost/foo'
    end
  end

  describe "accept" do
    before do
      @mb = Mudbug.new
    end

    it "must accept nil to remove accept headers" do
      expect(@mb.options[:headers][:accept]).wont_be_nil
      @mb.accept nil
      expect(@mb.options[:headers][:accept]).must_be_nil
    end

    it "must accept some known symbols" do
      [:json, :html, :text].each { |sym|
        @mb.accept sym
        expect(@mb.options[:headers][:accept]).must_equal Mudbug.accept_header(sym)
      }
    end

    it "must accept an array" do
      ary = [:json, :html, :text]
      @mb.accept ary
      ah = @mb.options[:headers][:accept]
      expect(ah).must_be_kind_of String
      expect(ah.split(', ').length).must_equal ary.length
    end

    it "must accept unknown symbols and strings" do
      [:foo, 'foo'].each { |unk|
        @mb.accept unk
        ah = @mb.options[:headers][:accept]
        expect(ah).must_be_kind_of String
        expect(ah).must_equal Mudbug.accept_header unk
        expect(ah).must_equal "application/#{unk}"
      }
    end
  end
end
