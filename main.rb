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

def sample?
  ARGV[0] == 'sample'
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

artists = nil
if sample?
  puts 'Collecting artists'
  artists_ids = tracks
    .map(&:artists)
    .flatten
    .shuffle
    .take(50)
    .map(&:id)

  artists = RSpotify::Artist.find(artists_ids)
else
  puts 'Collecting artists'
  artists = tracks.map(&:artists).flatten
end

genres = []
with_progress 'Collecting genres' do
  artists.each do |artist|
    genres << artist.genres
    progress!
  rescue RestClient::TooManyRequests
    puts "\n\n"
    puts 'Too many request loading the genres.'
    puts 'Try again later or use `rake sample` for long playlists!'
    abort
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

filename = sample? ? "#{playlist.name} Sample.csv" : "#{playlist.name}.csv"

puts "Writing #{filename}"
File.open(filename, 'a+') do |f|
  f.puts("GENRE,FREQUENCY")
  sorted.each { |genre, frequency| f.puts("#{genre},#{frequency}") }
end

puts 'DONE'
