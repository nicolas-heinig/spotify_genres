require 'rspotify'
require 'byebug'
require_relative './config'

def with_progress(string)
  print string
  yield
  print "\n"
end

def progress!
  print '.'
end

begin
  RSpotify.authenticate(CONFIG[:client_id], CONFIG[:client_secret])
rescue RestClient::BadRequest
  puts 'Problem with authenticating with spotify'
end

playlist = RSpotify::Playlist.find(CONFIG[:user_id], CONFIG[:playlist_uri])

tracks = []

offset = 0
current_tracks = playlist.tracks

with_progress 'Collecting tracks' do
  until current_tracks.empty?
    tracks << current_tracks
    offset += 100
    current_tracks = playlist.tracks(offset: offset)
    progress!
  end
end

tracks.flatten!

puts 'Collecting artists'
artists = tracks.map(&:artists).flatten

genres = []
with_progress 'Collecting genres' do
  artists.each do |artist|
    genres << artist.genres
    progress!
  end
end
genres.flatten!

puts 'Weighting Genres...'
weighted_genres = {}
genres.each do |genre|
  if weighted_genres.key?(genre)
    weighted_genres[genre] += 1
  else
    weighted_genres[genre] = 1
  end
end

sorted = weighted_genres.sort_by { |_k, v| v }.reverse

File.open("#{playlist.name}.csv", 'a+') do |f|
  f.puts("GENRE,FREQUENCY")
  sorted.each { |genre, frequency| f.puts("#{genre},#{frequency}") }
end
