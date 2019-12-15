# spotify_genres

A script to find get a list of genres of your spotify playlist.

## Usage

1. `cp config_example.rb config.rb`
2. Head over to [Spotify](https://developer.spotify.com/) to get your `client_id` and `client_secret`
3. Fill out the config:

- Your `user_id` is your spotify user name
- The playlist uri you can find out by rightclicking on your playlist -> `Share` -> `Copy Spotify URI` -> `spotify:playlist:INSERT_THIS_PART`

4. Run `rake`
5. See results in `PLAYLIST_NAME.csv`
