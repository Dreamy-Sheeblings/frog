extends Node2D

@onready var tongue = $Tongue

var time: float = 0
var original_position: Vector2
var shoot_direction: Vector2
var shoot_speed := 800.0
var return_speed := 600.0
var max_distance := 300.0
var traveled_distance := 0.0

enum States {
	SWAY,
	RELEASE_OUT,
	RELEASE_BACK
}

var current_state: States = States.SWAY

func _ready() -> void:
	original_position = tongue.position
	tongue.area_entered.connect(on_tongue_area_entered)

func on_tongue_area_entered(area):
	if area.is_in_group("edibles"):
		current_state = States.RELEASE_BACK
		area.queue_free()

func _process(delta: float) -> void:
	match current_state:
		States.SWAY:
			if Input.is_action_just_pressed("ui_accept"):
				# Lock in the direction and prepare to shoot
				shoot_direction = Vector2.UP.rotated(tongue.rotation)
				traveled_distance = 0.0
				current_state = States.RELEASE_OUT
			time += delta
			var angle_degrees = sin(time * 2.0) * 60.0
			tongue.rotation_degrees = angle_degrees
		
		States.RELEASE_OUT:
			var move = shoot_direction * shoot_speed * delta
			tongue.position += move
			traveled_distance += move.length()
			
			if traveled_distance >= max_distance:
				current_state = States.RELEASE_BACK

		States.RELEASE_BACK:
			var to_origin = original_position - tongue.position
			var move = to_origin.normalized() * return_speed * delta
			if move.length() > to_origin.length():
				tongue.position = original_position
				current_state = States.SWAY
			else:
				tongue.position += move