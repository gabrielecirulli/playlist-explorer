class App
	constructor: ->
		@currentPlaylist = null

		@playlistDisplayElements = $('#playlist-title, #playlist-information, #playlist-videos')

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

		@clearPlaylist =>
			# Show title
			$('#playlist-title').text(json.title.$t)
			# Show tagline
			$('#playlist-information').text("By ").append $('<strong>').text json.author[0].name.$t

			# Fill videos
			videoContainer = $('#playlist-videos')
			_.each json.entry, (video) ->
				videoContainer.append $('<div>').text video.title.$t

			@showPlaylist()

	clearPlaylist: (callback) ->
		@playlistDisplayElements.fadeOut 'fast', ->
			$(@).empty()

		@playlistDisplayElements.promise().done ->
			callback()

	showPlaylist: ->
		@playlistDisplayElements.delay(300).fadeIn 'slow'

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