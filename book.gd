class_name Book extends Inspectable

@export_multiline var contents: String

var CHARACTERS_PER_PAGE = 500

func get_pages() -> Array:
	var pages = []
	var current_page = ""
	var words = contents.split(" ")
	var current_page_length = 0
	
	for word in words:
		var word_length = word.length()
		if word.contains('\n'):
			word_length += 50 * word.count('\n')
		
		if current_page.length() + word_length > CHARACTERS_PER_PAGE:
			pages.append(current_page)
			current_page = ""
			current_page_length = 0
			
		current_page += " " + word
		current_page_length += word_length + 1
	
	if current_page != "":
		pages.append(current_page)
	
	return pages
