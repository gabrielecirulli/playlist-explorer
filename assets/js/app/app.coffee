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

	fetchPlaylist: (id) ->
		@showLoading()
		$.getJSON "/playlist/#{id}", (json) =>
			@clearLoading()
			if json.feed
				@receivePlaylist json.feed
			else
				@showError json.errorMessage

	receivePlaylist: (json) ->
		@clearPlaylist()
		@currentPlaylist = json

		console.log 'gotta playlsit'
		console.log json

	clearPlaylist: ->
		$('#playlist-results').empty()

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

	if window.location.hash
		$('#playlist-id').val decodeURIComponent window.location.hash.replace '#', '' 
		window.location.hash = ''
		$('#playlist-selector').submit()