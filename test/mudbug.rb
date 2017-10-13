require 'minitest/autorun'
require 'mudbug'

describe "Mudbug" do
  describe "accept_header" do
    it "must generate valid headers" do
      h = Mudbug.accept_header(:json, :xml, :html, :text, :foo)
      ary = h.split(', ')
      ary.length.must_equal 5

      # first entry does not have a qspec
      ary[0].must_equal 'application/json'

      # subsequent entries must have a qspec
      qspec = /q=\d*\.*\d/   # e.g. q=0.5

      xml_ary = ary[1].split(';')
      xml_ary[0].must_equal 'application/xml'
      xml_ary[1].must_match qspec

      html_ary = ary[2].split(';')
      html_ary[0].must_equal 'text/html'
      html_ary[1].must_match qspec

      text_ary = ary[3].split(';')
      text_ary[0].must_equal 'text/plain'
      text_ary[1].must_match qspec

      foo_ary = ary[4].split(';')
      foo_ary[0].must_equal 'application/foo'
      foo_ary[1].must_match qspec
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
      body.wont_be_nil
      body.must_be_empty
    end

    it "must process a nonempty response" do
      resp_body = 'foo: bar'
      resp = rest_client_resp(resp_body, content_type: 'text/html')
      body = Mudbug.process(resp)
      body.wont_be_nil
      body.wont_be_empty
      body.must_equal resp_body
    end

    it "must warn about missing content-type" do
      resp = rest_client_resp('')
      out, err = capture_subprocess_io do
        Mudbug.process(resp)
      end
      out.must_be_empty
      err.wont_be_empty
    end
  end
end
