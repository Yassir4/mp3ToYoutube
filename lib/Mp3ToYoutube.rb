require "Mp3ToYoutube/version"
require 'thor'
module Mp3ToYoutube
  class Mp3Uploader < Thor
    desc "hello [name]", "say my name"
    def hello(name)
      if name == "Yassir"
        puts "you are goddman right"
      else
        puts "say my name"
      end
    end
  end
end
