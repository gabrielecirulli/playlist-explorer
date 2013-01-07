class App
	constructor: ->
		@currentPlaylist = null
		@currentVideo = null

		@playlistDisplayElements = $('#playlist-title, #playlist-information, #playlist-videos')

		@loadingMessageTimeout = null # Also used to keep track of loading
		@defaultLoadingMessage = "Loading..."
		@loadingMessageAddition = "(it takes a while)"

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

		console.log @currentPlaylist

		@clearPlaylist =>
			# Show title
			$('#playlist-title').text(json.title.$t)
			
			# Show tagline
			authorUrl = "http://youtube.com/user/#{json.author[0].uri.$t.split('/').pop()}"
			$('#playlist-information').addClass('author').html @makeByAuthor(authorUrl, json.author[0].name.$t, true)

			# Fill videos
			videoContainer = $('#playlist-videos')
			$.each json.entry, (index, video) =>
				if video.app$control? and video.app$control.yt$state? and video.app$control.yt$state.name == 'deleted'
					return false

				videoDiv = $('<div>').addClass 'video'
				videoThumb = $('<div>').addClass('thumbnail').append $('<img>').attr 'src', video.media$group.media$thumbnail[0].url

				videoDetails = $('<div>').addClass 'details'
				videoTitle = $('<div>').addClass('title').append @makeLink video.link[0].href, video.title.$t, true
				videoBy = $('<div>').addClass('author').html @makeByAuthor video.link[0].href, video.media$group.media$credit[0].yt$display, true
				
				videoDetails.append videoTitle, videoBy
				videoDiv.append videoThumb, videoDetails
				videoDiv.click (e) => @selectVideo video.media$group.yt$videoid.$t, videoDiv, e

				videoContainer.append videoDiv

			@showPlaylist()

	clearPlaylist: (callback) ->
		@playlistDisplayElements.fadeOut 'fast', ->
			$(@).empty()

		@playlistDisplayElements.promise().done ->
			callback()

	showPlaylist: ->
		@playlistDisplayElements.delay(300).fadeIn 'slow'

	# Showing videos
	selectVideo: (videoId, videoDiv, e) ->
		if $(e.target).parents('.author').size()
			return true
		e.preventDefault()
		$('.video.active').removeClass 'active'
		@clearVideo()
		if @currentVideo is videoId
			@currentVideo = null
			return
			
		videoDiv.addClass 'active'
		@showVideo(videoId)

		console.log 'showvideo ' + videoId

	clearVideo: ->
		console.log 'clear video'

	showVideo: (videoId) ->
		@currentVideo = videoId		
		console.log 'show video ' + videoId

	# Loading / errors	
	showLoading: ->
		return false if @loadingMessageTimeout?
		@hideErrors()
		$('#playlist-loading-cue:hidden').text(@defaultLoadingMessage).slideDown 'fast'
		@loadingMessageTimeout = setTimeout @extendLoading, 5000

	extendLoading: =>
		$('#playlist-loading-cue').text("#{@defaultLoadingMessage} #{@loadingMessageAddition}")

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

	# Utility
	makeLink: (url, text, blank=false) ->
		attr = href: url
		attr.target = '_blank' if blank
		$('<a>').attr(attr).text(text)

	makeByAuthor: (url, author, blank=false) ->
		$('<span>').text('By ').append @makeLink url, author, blank


$(document).ready ->
	PlaylistApp = new App

	if $('#playlist-id').val().trim()
		$('#playlist-selector').submit()