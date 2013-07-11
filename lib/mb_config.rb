require 'mudbug'

module MbConfig
  FILE = File.expand_path '~/.mudbug'
  CFG = {}

  def self.[] key
    CFG[key]
  end

  def self.[]= key, value
    CFG[key] = value
  end

  def delete key
    CFG.delete key
  end

  def self.save
    raise "unable to write to #{FILE}" unless File.writable? FILE
    File.open(FILE, 'w') { |f| f.write CFG.to_json }
  end

  def self.load
    if available?
      begin
        File.open(FILE, 'r') { |f|
          CFG.merge! JSON.parse f.read
        }
      rescue JSON::ParserError => e
        puts "#{e} (#{e.class})"
        puts "Resetting #{FILE}"
        reset
      end
    end
  end

  def self.reset
    raise "unable to write to #{FILE}" unless File.writable? FILE
    File.open(FILE, 'w') { |f| f.write '{}' }
  end

  def self.available?
    File.exists?(FILE) and File.readable?(FILE)
  end

  def self.dump
    JSON.pretty_generate CFG
  end
end

MbConfig.load
