require 'minitest/spec'
require 'minitest/autorun'

require_relative '../lib/mudbug'

describe "Mudbug#merge" do
  it "should maintain 2nd-level nested hash keys" do
    m = Mudbug.new
    m.options[:headers].must_be_instance_of Hash
    m.options[:headers][:accept].must_be_instance_of String
    default_accept = m.options[:headers][:accept]

    options = m.merge(headers: {})
    options[:headers].must_be_instance_of Hash
    options[:headers][:accept].must_equal default_accept

    options = m.merge(headers: { accept: '12345' })
    options[:headers].must_be_instance_of Hash
    options[:headers][:accept].must_equal '12345'

    distinct = { headers: { xmadeup: '12345' }, max_redirects: 5 }
    options = m.merge(distinct)
    options[:headers].must_be_instance_of Hash
    options[:headers][:accept].must_equal default_accept

    # make sure the outside hash takes precedence
    distinct.each { |key, val|
      if val.is_a?(Hash)
        val.each { |key2, val2|
          options[key][key2].must_equal val2
        }
      else
        options[key].must_equal val
      end
    }
  end
end
