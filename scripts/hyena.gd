extends CharacterBody2D

class_name hyena

const speed = 30
var chasing: bool

var health = 100
var max_health = 100
var min_health = 0

var dead: bool = false
var taking_damage: bool = false
var dealing_damage = 25
var is_dealing_damage: bool = false

var dir: Vector2
const gravity = 900
var knockback_force = 200
var roaming: bool = true
func _ready():
	chasing = false

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	move(delta)
	move_and_slide()

func move(delta):
	if !dead:
		if!chasing:
			velocity += dir * speed * delta
		roaming = true
	elif dead:
		velocity.x = 0

func _on_timer_timeout():
	$Timer.wait_time = choose([1.0, 1.5, 2])
	if !chasing:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()
