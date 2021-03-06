require 'mudbug'

sites = %w{google.com yahoo.com microsoft.com amazon.com ibm.com reddit.com}
accepts = [:json, :html, :text, :xml]
http_methods = [:get, :post, :put, :delete]

path = '/'

unless ARGV.shift == 'skip'
  puts
  puts "Checking Accepts across sites"
  puts "============================="
  sites.each { |site|
    mb = Mudbug.new(site)
    url = "http://#{site}#{path}"

    accepts.each { |acp|
      mb.accept(acp)

      puts "GET #{url}  [#{acp}]"
      begin
        mb.get path
      rescue RuntimeError => e
        puts "#{e} (#{e.class})"
      end
    }
    puts
  }

  puts
  puts
end

payload = { 'hi' => 'mom' }.to_json

unless ARGV.shift == 'skip'
  puts "Checking HTTP methods across sites"
  puts "=================================="
  puts "POST/PUT payload = #{payload.to_json}"
  puts
  sites.each { |site|
    mb = Mudbug.new(site)
    url = "http://#{site}#{path}"

    http_methods.each { |meth|
      args = [meth, path]
      args << payload if [:post, :put].include?(meth)

      print "#{meth.to_s.upcase} #{url} "
      begin
        mb.send(*args)
        puts
      rescue RuntimeError => e
        puts "#{e} (#{e.class})"
      end
    }
    puts
  }
end

puts "DONE"
