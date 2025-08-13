class_name Book extends Inspectable

@export_multiline var contents: String

var CHARACTERS_PER_PAGE = 200

func get_pages() -> Array:
	var pages = []
	var current_page = ""
	var words = contents.split(" ")
	
	for word in words:
		if current_page.length() + word.length() > CHARACTERS_PER_PAGE:
			pages.append(current_page)
			current_page = ""
			
		current_page += " " + word
	
	if current_page != "":
		pages.append(current_page)
	
	return pages
