require 'yaml'
require 'fileutils'

BASE_PATH = './data_source/'

module PickPic
  class << self
    def run
      message = 'Type the filename of URL-list:'
      puts url_list = file_open_as_array( get_file_path message )

      message = <<-"EOS"
----------------------------------------

Type the directory name of output data:
EOS

      save_path = get_file_path(message) + "/"

      FileUtils.mkdir_p save_path unless FileTest.exist? save_path

      url_list.each { |url| Fetch.curl(url, save_path) }
    end

    def get_file_path(message)
      puts message
      gets.to_s.chomp
    end

    def file_open_as_array(file_name)
      list = []
      begin
        File::open(BASE_PATH + file_name) do |f|
          f.each { |line| list << line.to_s.chomp }
        end
      rescue => e
        p e
        file_open_as_array( get_file_path 'file_name is wrong. try again:' )
      end
      list
    end
  end

  module Fetch

    def self.curl(uri, save_path)
      ary = uri.to_s.split("/")
      save_file_name = ary[-2].to_s + "-" + ary[-1].to_s
      begin
        `curl #{ uri } -o #{ save_path + save_file_name }`
      rescue => e
        puts e
        File.open("../error.log", "a") { |f| f.write e }
      end
    end
  end
end

PickPic.run
