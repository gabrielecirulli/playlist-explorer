$(document).ready ->
	PlaylistApp = new App

	if $('#playlist-id').val().trim()
		$('#playlist-selector').submit()