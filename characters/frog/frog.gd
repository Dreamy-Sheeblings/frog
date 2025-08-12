extends Node2D

@onready var tongue = $TongueHead
@onready var tongue_cls = $TongueHead/Cls
@onready var tongue_line = $TongueLine
@onready var body_anim = $Body
@onready var tongue_head_state_sprite = $TongueHead/StateSprite

var time: float = 0
var original_position: Vector2
var shoot_direction: Vector2
var shoot_speed := 800.0
var return_speed := 1000.0
var max_distance := 310.0
var traveled_distance := 0.0

var out_stuck_rage := 100
var stuck_area: Area2D

enum States {
	SWAY,
	RELEASE_OUT,
	RELEASE_BACK,
	STUCK
}

var current_state: States = States.SWAY
var viewport_rect: Rect2

func _ready() -> void:
	viewport_rect = get_viewport().get_visible_rect()
	original_position = tongue.position
	tongue.area_entered.connect(on_tongue_area_entered)

func on_tongue_area_entered(area):
	if area.is_in_group("edibles"):
		current_state = States.RELEASE_BACK
		area.queue_free()
	if area.is_in_group("stuck"):
		out_stuck_rage = 50
		stuck_area = area
		current_state = States.STUCK

func _process(delta: float) -> void:
	tongue_line.points = [Vector2(0, -8), to_local(tongue_cls.global_position)]
	match current_state:
		States.SWAY:
			body_anim.play("idle")
			tongue_head_state_sprite.play("target")
			tongue_line.visible = false
			tongue_cls.disabled = true
			if Input.is_action_just_pressed("ui_accept"):
				# Lock in the direction and prepare to shoot
				shoot_direction = Vector2.UP.rotated(tongue.rotation)
				traveled_distance = 0.0
				current_state = States.RELEASE_OUT
			time += delta
			var angle_degrees = sin(time * 2.0) * 60.0
			tongue.rotation_degrees = angle_degrees
		
		States.RELEASE_OUT:
			body_anim.play("eat")
			tongue_head_state_sprite.play("lick")
			tongue_line.visible = true
			tongue_cls.disabled = false
			var move = shoot_direction * shoot_speed * delta
			tongue.position += move
			traveled_distance += move.length()
			
			if traveled_distance >= max_distance:
				current_state = States.RELEASE_BACK

		States.RELEASE_BACK:
			tongue_head_state_sprite.play("lick")
			tongue_line.visible = true
			out_stuck_rage = 100
			tongue_cls.disabled = true
			var to_origin = original_position - tongue.position
			var move = to_origin.normalized() * return_speed * delta
			if move.length() >= to_origin.length():
				tongue.position = original_position
				current_state = States.SWAY
			else:
				tongue.position += move

		States.STUCK:
			tongue_head_state_sprite.play("lick")
			tongue_line.visible = true
			tongue_cls.disabled = true
			out_stuck_rage -= 1
			if out_stuck_rage >= 100:
				stuck_area.queue_free()
				current_state = States.RELEASE_BACK
			if Input.is_action_just_pressed("ui_accept"):
				out_stuck_rage += 25