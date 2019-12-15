require 'rspotify'
require 'byebug'
require 'config'

def with_progress(string)
  print string
  yield
  print "\n"
end

def progress!
  print '.'
end

RSpotify.authenticate(CONFIG[:client_id], CONFIG[:cleint_secret])

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

puts 'Collecting genres'
# genres = artists.map