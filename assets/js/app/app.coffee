$(document).ready ->
	$(@).ajaxError -> showError()		

	showError = (errorText="Sorry, an unknown error occurred.") ->
		errorMessage = $('<li>').hide().text(errorText)
		$('#playlist-input-errors').empty()
			.append errorMessage
		errorMessage.slideDown 'fast'

	$('#playlist-selector').submit (e) ->
		e.preventDefault()
		playlistId = $('#playlist-id').val().trim()

		return $('#playlist-id').focus() unless playlistId

		$('#playlist-loading-cue').slideDown 'fast'

		$.getJSON "/playlist/#{playlistId}", (json) ->
			$('#playlist-loading-cue').slideUp 'fast'
			if json.status is 'ok'
				console.log json
			else if json.status is 'error'					
				if json.errorMessage then showError json.errorMessage else showError()

	if window.location.hash
		$('#playlist-id').val decodeURIComponent window.location.hash.replace '#', '' 
		window.location.hash = ''
		$('#playlist-selector').submit()