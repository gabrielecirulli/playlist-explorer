$(document).ready ->


	$(document).ajaxError -> showError()		

	showError = (errorText="Sorry, an unknown error occurred.") ->
		errorMessage = $('<li>').hide().text(errorText)
		$('#playlist-input-errors').empty()
			.append errorMessage
		errorMessage.slideDown 'fast'

	$('#playlist-selector').submit (e) ->
		e.preventDefault()
		playlistId = $('#playlist-id').val().trim()

		return $('#playlist-id').focus() unless playlistId

		$.getJSON "/playlist/#{playlistId}", (json) ->
			console.log json
			if json.status is 'ok'
				console.log 'okay!'
			else if json.status is 'error'					
				if json.errorMessage then showError json.errorMessage else showError()

	if window.location.hash
		$('#playlist-id').val window.location.hash.replace '#', '' 
		$('#playlist-selector').submit()