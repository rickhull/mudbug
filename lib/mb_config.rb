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
    rescues = 0
    begin
      File.open(FILE, 'r') { |f|
        CFG.merge! JSON.parse f.read
      }
    rescue JSON::ParserError => e
      rescues += 1
      puts "#{e} (#{e.class})"
      if rescues < 2
        puts "Resetting #{FILE}"
        reset
        retry
      end
      Mudbug.lager.fatal { "MbConfig.load failed!" }
      raise e
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
