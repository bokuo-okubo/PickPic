require 'yaml'
require 'fileutils'
require 'thwait'
require 'net/http'
require 'uri'
require 'logger'

BASE_PATH = './data_source/'

class << Thread
  alias_method :original_new, :new

  def Thread.new(*args, &block)
    if Thread.main[:max_concurrent] and Thread.main[:max_concurrent] > 0 then
      while(Thread.list.size >= Thread.main[:max_concurrent]) do
        Thread.pass
      end
    end
    printf "."
    Thread.original_new(args,&block)
  end

  def Thread.max_concurrent=(num)
    Thread.main[:max_concurrent]=num
  end
end


module Filer
  def get_file_path(message)
    puts message
    gets.to_s.chomp
  end

  def write_file(str, file_path, mode: 'w')
    begin
      File.open(file_path, mode) { |f| f.write str}
    rescue => e
      puts e
    end
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

class Logger
  @logger
  def self.log(err)
    self.create.fatal(err)
  end
  private
  def self.create
    @logger ||= Logger.new('error.log')
  end
end

module PickPic
  extend Filer

  class << self
    def run
      message = 'Type the filename of URL-list:'
      puts url_list = file_open_as_array( get_file_path message )
      puts '----------------------------------------'
      puts "url count is: #{url_list.length}"
      message ="Type the directory name of output data:"
      save_path = get_file_path(message) + "/"

      FileUtils.mkdir_p save_path unless FileTest.exist? save_path

      threads = []
      puts 'work in multi-thread'
      url_list.each do |url|
        Thread.max_concurrent = 10
        threads << Thread.new do |th|
          response = Fetch.curl(url)
          url.split("/").last
          filename = url.split("/").last
          begin
            write_file(response.body, save_path + filename)
          rescue => e
            Logger.log(e)
          end
        end
      end
      ThreadsWait.all_waits(*threads) { |th| printf "." }
      puts "\ndone!"
    end
  end

  module Fetch
    def self.curl(uri, save_path = nil)
      uri = URI.parse(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      begin
        request = Net::HTTP::Get.new(uri.request_uri)
      rescue => e
        Logger.log(e)
      end
      request.basic_auth('4d', '4d')
      response = http.request(request)
    end
  end
end
PickPic.run
