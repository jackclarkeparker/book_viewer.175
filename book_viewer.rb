require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

helpers do
  def in_paragraphs(text)
    result = ''
    
    text.split("\n\n").each_with_index do |para, index|
      result << "<p id='#{index + 1}'>#{para}</p>"
    end

    result
  end

  def highlight_query_matches(text)
    text.gsub(@query, %(<strong>#{@query}</strong>))
  end
end

def each_chapter
  @contents.each_with_index do |name, idx|
    number = idx + 1
    text = File.read("data/chp#{number}.txt")
    yield name, number, text
  end
end

def find_matching_chapters
  results = []

  return results if !@query || @query.empty?

  each_chapter do |name, number, text|
    if text.include? @query
      matching_paragraphs = find_matching_paragraphs(text)
      results << {
        name: name,
        number: number,
        matching_paragraphs: matching_paragraphs
      }
    end
  end

  results
end

def find_matching_paragraphs(text)
  matches = []

  text.split("\n\n").each_with_index do |paragraph, idx|
    matches << [paragraph, idx + 1] if paragraph.include?(@query)
  end

  matches
end

before do
  @contents = File.readlines("data/toc.txt")
  @query = params[:query]
end

get "/" do  
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  @title = @contents[number - 1]
  @text = File.read("data/chp#{number}.txt")

  redirect "/" unless (1..@contents.size).cover?(number)

  erb :chapter
end

get "/search" do
  @title = "Search"
  @results = find_matching_chapters

  erb :search
end

not_found do
  redirect "/"
end
