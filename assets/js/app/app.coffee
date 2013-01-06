class App
	constructor: ->
		@currentPlaylist = null

		@playlistDisplayElements = $('#playlist-title, #playlist-information, #playlist-videos')

		@loadingMessageTimeout = null # Also used to keep track of loading
		@defaultLoadingMessage = "Loading..."
		@loadingMessageAddendum = "(it takes a while)"

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
		return unless @showLoading()
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
			$.each json.entry, (index, video) ->
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
		return false if @loadingMessageTimeout?
		$('#playlist-loading-cue:hidden').text(@defaultLoadingMessage).slideDown 'fast'
		@loadingMessageTimeout = setTimeout @extendLoading, 5000

	extendLoading: =>
		$('#playlist-loading-cue').text("#{@defaultLoadingMessage} #{@loadingMessageAddendum}")

	clearLoading: ->
		$('#playlist-loading-cue:visible').slideUp 'fast'
		clearTimeout @loadingMessageTimeout
		@loadingMessageTimeout = null

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