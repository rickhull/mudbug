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
end
