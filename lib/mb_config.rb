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

  def self.delete key
    CFG.delete key
  end

  # write CFG to FILE
  #
  def self.save
    File.open(FILE, 'w') { |f| f.write CFG.to_json }
  end

  # call reset as necessary
  #
  def self.load
    reset unless File.exists?(FILE)
    begin
      File.open(FILE, 'r') { |f|
        CFG.merge! JSON.parse f.read
      }
    rescue JSON::ParserError => e
      puts "#{e} (#{e.class})"
      puts "Resetting #{FILE}"
      reset
      # recursion; depends on .reset writing parseable JSON to stop
      load
    end
  end

  # write an empty hash/object
  #
  def self.reset
    File.open(FILE, 'w') { |f| f.write '{}' }
  end

  # dump the current CFG (may differ from FILE contents!)
  #
  def self.dump
    JSON.pretty_generate CFG
  end
end

MbConfig.load
