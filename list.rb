require 'bundler/setup'

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'pry'
require 'pry-byebug'

get "/" do  
  # My first try

  @files = []

  Dir.foreach("public") do |file|
    @files << file if File.file?("public/#{file}")
  end

  @files.sort! do |a, b|
    params["order"] == "descending" ? b <=> a : a <=> b
  end

  # After reading hint about glob

  # @files = Dir.glob("*", base: "public").select do |filename|
  #   File.file?("public/#{filename}")
  # end.sort! do |a, b|
  #   params["order"] == "descending" ? b <=> a : a <=> b
  # end

  # LS solution

  # @files = Dir.glob("public/*").map {|file| File.basename(file) }.sort
  # @files.reverse! if params[:sort] == "desc"
  
  erb :index, layout: false
end