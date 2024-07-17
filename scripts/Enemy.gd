extends CharacterBody2D

class_name Enemy

var speed = 55
var chasing: bool

var player: CharacterBody2D
var player_in_area = false

var health = 100
var max_health = 100
var min_health = 0

var dead: bool = false
var taking_damage: bool = false
var dealing_damage = 25
var is_dealing_damage: bool = false

var dir: Vector2
const gravity = 900
var knockback_force = -50

var death_anim_played = false


func _physics_process(delta):

	chasing = true
	
	player = Global.playerbody
	Global.Damagezone = $dealDamageArea
	
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	move(delta)
	move_and_slide()
	handle_animation()

func move(_delta):
	player = Global.playerbody
	if not dead:
		if taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity = knockback_dir
		elif chasing and not dead:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			velocity.y = 150
			dir.x = abs(velocity.x) / velocity.x
		
	elif dead:
		velocity.x = 0

func handle_animation():
	var animatedsprite = $AnimatedSprite2D
	if not dead and not taking_damage and not is_dealing_damage:
		animatedsprite.play("run")
		if dir.x < 0:
			animatedsprite.flip_h = true
			Global.Damagezone.scale.x = -1
		elif dir.x > 0:
			animatedsprite.flip_h = false
			Global.Damagezone.scale.x = 1
	elif not dead and taking_damage and not is_dealing_damage:
		animatedsprite.play("hurt")
		await get_tree().create_timer(0.45).timeout
		taking_damage = false
	elif dead:
		if not death_anim_played:
			animatedsprite.play("death")
			death_anim_played = true
		await get_tree().create_timer(2).timeout
		handle_death()
	elif not dead and is_dealing_damage:
		animatedsprite.play("attack")

func handle_death():
	self.queue_free()

func _on_hitbox_area_entered(area):
	if area == Global.playerdamagezone:
		var damage = Global.playerDamageAmount
		take_damage(damage)

func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= 0:
		health = 0
		dead = true
	print(str(self), "health:", health)

func _on_deal_damage_area_area_entered(area):
	if area == Global.playerHitbox:
		is_dealing_damage = true
		await get_tree().create_timer(1).timeout
		is_dealing_damage = false
