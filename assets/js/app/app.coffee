class App
	constructor: ->
		@currentPlaylist = null

		@defaultError = "Sorry, an unknown error occurred."

		# Hijack AJAX error
		$(document).ajaxError => 
			@showError()

		# Playlist form submit
		$('#playlist-selector').submit (e) =>
			e.preventDefault()
			playlistId = $('#playlist-id').val().trim()
			return $('#playlist-id').focus() unless playlistId

			@fetchPlaylist playlistId

	# Playlists
	fetchPlaylist: (id) ->
		@showLoading()
		$.getJSON "/playlist/#{id}", (json) =>
			@clearLoading()
			if json.feed
				@receivePlaylist json.feed
			else
				@showError json.errorMessage

	receivePlaylist: (json) ->
		@currentPlaylist = json
		console.log @currentPlaylist

		@clearPlaylist _.once =>
			# Show title
			$('#playlist-title').text(json.title.$t)
			# Show tagline
			$('#playlist-information').text("By ").append $('<strong>').text json.author[0].name.$t

			@showPlaylist()

	clearPlaylist: (callback) ->
		$('#playlist-title, #playlist-videos, #playlist-information').fadeOut 'fast', ->
			callback()

	showPlaylist: ->
		$('#playlist-title, #playlist-information').delay(300).fadeIn 'fast'

	# Loading / errors	
	showLoading: ->
		$('#playlist-loading-cue:hidden').slideDown 'fast'

	clearLoading: ->
		$('#playlist-loading-cue:visible').slideUp 'fast'

	hideErrors: ->
		$('#playlist-input-errors').empty()

	showError: (errorText=@defaultError) ->
		@clearLoading()
		@hideErrors()
		errorMessage = $('<li>').hide().text(errorText)
		$('#playlist-input-errors').append errorMessage
		errorMessage.slideDown 'fast'


$(document).ready ->
	PlaylistApp = new App

	if $('#playlist-id').val().trim()
		$('#playlist-selector').submit()