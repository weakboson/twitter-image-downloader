#!/usr/bin/env ruby

require 'faraday'

class Twimg
  require 'uri'

  attr_reader :image_id, :filename, :orig_uri, :body, :path_and_query

  def initialize(uri, connection: nil)
    # https://pbs.twimg.com/media/D5HeJIdUYAEogZw?format=jpg&name=medium
    _scheme, _user, host, _port, _registry, path, _opaque, query, _ = URI.split uri.chomp

    @f_conn = connection || Faraday.new(url: "https://#{host}", headers: {user_agent: "Mozilla/5.0 (X11; CrOS x86_64 12105.11.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.10 Safari/537.36" })

    @image_id = path.split('/').last

    ary = URI.decode_www_form query
    format = ary.assoc('format').last

    @filename = "#{image_id}.#{format}"

    @path_and_query = "/media/#{image_id}?format=#{format}&name=orig"

    @orig_uri =  "https://pbs.twimg.com#{path_and_query}"
  end

  def fetch
    @res = @f_conn.get(path_and_query)
  end

  def status
    fetch unless @res
    @res.status
  end

  def save(directory: "./")
    fetch unless @res
    File.open(File.join(directory, filename), "wb") {|f| f << @res.body }
  end
end

conn = Faraday.new(url: 'https://pbs.twimg.com')

STDIN.each do |uri|
  img = Twimg.new(uri, connection: conn)
  img.save(directory: "./dl")
  if img.status == 200
    STDOUT.puts img.orig_uri
  else
    STDERR.puts img.orig_uri
  end
  # STDOUT.puts "uri: #{img.orig_uri} / file: #{img.filename}/ path_and_query: #{img.path_and_query}"
  sleep 1
end
