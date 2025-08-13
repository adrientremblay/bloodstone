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

func _ready() -> void:
	inspect_label.visible = false
	book_background.visible = false

func _on_player_consumed_blood(amount: Variant) -> void:
	blood_bar.value = amount

func _on_player_update_health(health: Variant) -> void:
	health_bar.value = health

func _on_player_update_ammo(ammo_clip: Variant, ammo_pool: Variant, melee: bool) -> void:
	if melee:
		ammo_label.text = ''
		return
	
	ammo_label.text = str(ammo_clip) + "/" + str(ammo_pool)

func _on_player_can_inspect(description: String) -> void:
	inspect_label.visible = true
	inspect_label.text = description

func _on_player_cannot_inspect() -> void:
	inspect_label.visible = false

func display_book(title: String, contents: String) -> void:
	# Show the book stuff
	book_background.visible = true
	
	# Hide the stuff that would get in the way
	crosshair.visible = false
	inspect_label.visible = false
	
	# Update the contents of the book
	book_title.text = title
	book_page_left.text = contents

func hide_book():
	# Hide the book stuff
	book_background.visible = false
	
	# Show the stuff that would get in the way
	crosshair.visible = true
	inspect_label.visible = true
	
