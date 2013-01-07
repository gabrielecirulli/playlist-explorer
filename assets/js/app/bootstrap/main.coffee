$(document).ready ->
	app = new PlaylistApp

	if $('#playlist-id').val().trim()
		$('#playlist-selector').submit()