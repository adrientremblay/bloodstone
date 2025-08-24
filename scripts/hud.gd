extends Control

@onready var blood_bar = $BloodBar
@onready var health_bar = $HealthBar
@onready var ammo_label = $AmmoLabel
@onready var inspect_label = $InspectLabel
@onready var book_background = $BookBackground
@onready var crosshair = $Crosshair
@onready var book_title = $BookBackground/Title
@onready var book_page_left = $BookBackground/PageLeft
@onready var book_page_right = $BookBackground/PageRight
@onready var page_right_button = $BookBackground/PageRightButton
@onready var page_left_button = $BookBackground/PageLeftButton
@onready var page_flip_sound: AudioStreamPlayer = $BookBackground/PageFlip

var pages = []
var current_page = 0 # 0-indexed and the left page

func _ready() -> void:
	inspect_label.visible = false
	book_background.visible = false
	_on_player_update_ammo("Claws", 0, 0, true)

func _on_player_consumed_blood(amount: Variant) -> void:
	blood_bar.value = amount

func _on_player_update_health(health: Variant) -> void:
	$HealthBar.value = health

func _on_player_update_ammo(weapon_name: String, ammo_clip: Variant, ammo_pool: Variant, melee: bool) -> void:
	if melee:
		ammo_label.text = weapon_name + "\n" +'Ammo: ∞'
		return
	
	ammo_label.text = weapon_name + "\n" + "Ammo: " + str(ammo_clip) + "/" + str(ammo_pool)

func _on_player_can_inspect(description: String) -> void:
	inspect_label.visible = true
	inspect_label.text = description

func _on_player_cannot_inspect() -> void:
	inspect_label.visible = false

func display_book(title: String, pages: Array) -> void:
	# Show the book stuff
	book_background.visible = true
	
	# Hide the stuff that would get in the way
	crosshair.visible = false
	inspect_label.visible = false
	
	# Update the contents of the book
	book_title.text = title
	self.pages = pages
	current_page = 0
	
	update_pages()

func hide_book():
	# Hide the book stuff
	book_background.visible = false
	
	# Show the stuff that would get in the way
	crosshair.visible = true
	inspect_label.visible = true

func toggle_book(title: String, pages: Array):
	if not book_background.visible:
		display_book(title, pages)
	else:
		hide_book()
		page_flip_sound.play()

func _on_page_right_button_pressed() -> void:
	current_page += 2
	update_pages()

func update_pages() -> void:
	book_page_left.text = pages[current_page]
	if pages.size() > current_page+1:
		book_page_right.text = pages[current_page+1]
	else:
		book_page_right.text = ""
	
	# toggle the visibility of the page buttons
	if current_page + 1 < pages.size() - 1:
		page_right_button.visible = true
	else:
		page_right_button.visible = false
	
	if current_page != 0:
		page_left_button.visible = true
	else:
		page_left_button.visible = false
	
	page_flip_sound.play()

func _on_page_left_button_pressed() -> void:
	current_page -= 2
	update_pages()
