require 'rubygems'
require 'gosu'
require './input_functions'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Hip-hop', 'Rock', 'Jazz']

class ArtWork
	attr_accessor :bmp
	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

class Track
  attr_accessor :track_key, :name, :location
    def initialize (track_key, name, location)
      @track_key = track_key
      @name = name
      @location = location
     end
end

class Album
  attr_accessor :pri_key, :title, :artist,:artwork, :tracks
  def initialize (pri_key, title, artist,artwork, tracks)
    @pri_key = pri_key
    @title = title
	@artist = artist
	@artwork = artwork
    @tracks = tracks
   end
end

class Song
	attr_accessor :song
	def initialize (file)
		@song = Gosu::Song.new(file)
	end
end

class MusicPlayerMain < Gosu::Window

	def initialize
	    super 800, 600
			self.caption = "Extended GUI Music Player"
			@locs = [60,60]
			@font = Gosu::Font.new(25)
			@albumno = 0
			@trackno = 0
	end

	def load_album()
			def read_track (music_file, index)
				track_key = index
				track_name = music_file.gets
				track_location = music_file.gets.chomp
				track = Track.new(track_key, track_name, track_location)
				return track
			end

			def read_tracks music_file
				count = music_file.gets.to_i
				tracks = Array.new()
				index = 0
				while index < count
					track = read_track(music_file, index + 1)
					tracks << track
					index = index + 1
				end
				tracks
			end

			def read_album(music_file, index)
				album_primary_key = index
				album_title = music_file.gets.chomp
				album_artist = music_file.gets
				album_artwork = music_file.gets.chomp
				album_tracks = read_tracks(music_file)
				album = Album.new(album_primary_key, album_title, album_artist,album_artwork, album_tracks)
				return album
			end

			def read_albums(music_file)
				count = music_file.gets.to_i
				albums = Array.new()
				index = 0
					while index < count
						album = read_album(music_file, index + 1)
						albums << album

						index = index + 1
					end
				return albums
			end

			music_file = File.new("album.txt", "r")
			albums = read_albums(music_file)
			return albums
		end


	def needs_cursor?; true; end



	def draw_albums(albums)
			@bmp = Gosu::Image.new(albums[0].artwork)
			@bmp.draw(50, 50 , z = ZOrder::PLAYER)

			@bmp = Gosu::Image.new(albums[1].artwork)
			@bmp.draw(50, 310, z = ZOrder::PLAYER)

			@bmp = Gosu::Image.new(albums[2].artwork)
			@bmp.draw(310, 50 , z = ZOrder::PLAYER)

			@bmp = Gosu::Image.new(albums[3].artwork)
			@bmp.draw(310, 310, z = ZOrder::PLAYER)
	end

	def draw_background()
		draw_quad(0,0, TOP_COLOR, 0, 600, TOP_COLOR, 800, 0, BOTTOM_COLOR, 800, 600, BOTTOM_COLOR, z = ZOrder::BACKGROUND)
	end

	def draw
		albums = load_album()
		index = 0
		x = 500
		y = 0
		draw_albums(albums)
		draw_background()
		if (!@song)
				@font.draw("Welcome to Music PLayer - Please Select Album", 150 , 550, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)	
				@font.draw("Album 1: #{albums[0].title}", 70 , 20, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
				@font.draw("Album 2: #{albums[1].title}", 70 , 280, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
				@font.draw("Album 3: #{albums[2].title}", 320 , 20, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
				@font.draw("Album 4: #{albums[3].title}", 320 , 280, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
				index += 1
		else
			while index < albums[@albumno-1].tracks.length
				@font.draw("#{albums[@albumno-1].tracks[index].name}", x , y+=40, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
				if (albums[@albumno-1].tracks[index].track_key == @trackno)
					@font.draw('Playing', 200 , 500, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
					@font.draw("#{albums[@albumno-1].tracks[index].name}", 300 , 500, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
					@font.draw('From Album: ', 200 , 550, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
					@font.draw("#{albums[@albumno-1].title}", 350 ,550, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
				end
				index += 1
			end
		end
	end

	def playTrack(trackno, albumno)
		albums = load_album()
		index = 0
		while index < albums.length
			if (albums[index].pri_key == albumno)
				tracks = albums[index].tracks
				j = 0
						while j< tracks.length
								if (tracks[j].track_key == trackno)
									@song = Gosu::Song.new(tracks[j].location)
									@song.play(false)
								end
								j+=1
						end
			end
			index += 1
		end
 	end
def set_selab(mouse_x, mouse_y)
	if ((mouse_x >50 && mouse_x < 201)&& (mouse_y > 50 && mouse_y < 201 ))# True
		@albumno = 1
	end
	if ((mouse_x > 50 && mouse_x < 210) && (mouse_y > 310 && mouse_y <470))# Revolution
		@albumno = 2
	end
	if ((mouse_x > 310 && mouse_x < 470) && (mouse_y > 50 && mouse_y <210))# Nightlife
		@albumno = 3
	end
	if ((mouse_x > 310 && mouse_x < 470) && (mouse_y > 310 && mouse_y <470))# Tribute
		@albumno = 4
	end
	return @albumno
end
	def area_clicked(mouse_x, mouse_y)
		if ((mouse_x >50 && mouse_x < 201)&& (mouse_y > 50 && mouse_y < 201 ))#True
			@albumno = set_selab(mouse_x, mouse_y)
			@trackno = 1
			playTrack(@trackno, @albumno)
		end
		if ((mouse_x >201 && mouse_x < 800)&& (mouse_y > 40 && mouse_y < 60))#playfirsttrackofalbum
			@albumno = set_selab(mouse_x, mouse_y)
			@trackno = 1
			playTrack(@trackno, @albumno)
		end
		if ((mouse_x >201 && mouse_x < 800)&& (mouse_y > 90 && mouse_y < 110))#playsecondtrackofalbum
			@albumno = set_selab(mouse_x, mouse_y)
			@trackno = 2
			playTrack(@trackno, @albumno)
		end
		if ((mouse_x >201 && mouse_x < 800)&& (mouse_y > 125 && mouse_y < 145))#playthirdtrackofalbum
			@albumno = set_selab(mouse_x, mouse_y)
			@trackno = 3
			playTrack(@trackno, @albumno)
		end
		if ((mouse_x >201 && mouse_x < 800)&& (mouse_y > 170 && mouse_y < 190))#playforthtrackofalbum
			@albumno = set_selab(mouse_x, mouse_y)
			@trackno = 4
			playTrack(@trackno, @albumno)
		end
		if ((mouse_x > 50 && mouse_x < 210) && (mouse_y > 310 && mouse_y <470))#Revolution
			@albumno = 2
			@trackno = 1
			playTrack(@trackno, @albumno)
		end

		if ((mouse_x > 310 && mouse_x < 470) && (mouse_y > 50 && mouse_y <210))#Nightlife
			@albumno = 3
			@trackno = 1
			playTrack(@trackno, @albumno)
		end
		if ((mouse_x > 310 && mouse_x < 470) && (mouse_y > 310 && mouse_y <470))#Tribute
			@albumno = 4
			@trackno = 1
			playTrack(@trackno, @albumno)
		end
 end

	def button_down(id)
		case id
			when Gosu::MsLeft
				@locs = [mouse_x, mouse_y]
				set_selab(mouse_x, mouse_y)
				area_clicked(mouse_x, mouse_y)
	    end
	end
end
MusicPlayerMain.new.show if __FILE__ == $0
