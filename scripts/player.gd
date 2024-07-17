extends CharacterBody2D

class_name Player

const SPEED = 165.0
const JUMP_VELOCITY = -350.0

var currently_attack: bool

var health = 100
var max_health = 100
var min_health = 0
var damageable: bool
var dead: bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animatedsprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
func _ready():
	Global.playerbody = self
	currently_attack = false
	dead = false
	damageable = true
	
func _physics_process(delta):
	Global.playerdamagezone = attack_area
	Global.playerHitbox = $playerhitbox
	if not is_on_floor():
		velocity.y += gravity * delta

	if !dead:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement.
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	# Flip the sprite.
		if direction > 0:
			animatedsprite.flip_h = false
			attack_area.scale.x = 1
		if direction < 0:
			animatedsprite.flip_h = true
			attack_area.scale.x = -1
	# Animations
		
		handle_animation()
		if !currently_attack:
			if Input.is_action_just_pressed("attack"):
				currently_attack = true
			damage_dealt()
			handle_attack_animation()
		check_hitbox()
	move_and_slide()
	
func handle_animation():
	if is_on_floor() and !currently_attack:
		if !velocity:
			animatedsprite.play("idle")
		if velocity:
			animatedsprite.play("run")
	elif !is_on_floor() and !currently_attack:
		animatedsprite.play("jump")
	
func handle_attack_animation():
	if currently_attack:
		animatedsprite.play("attack")
		toggle_attack_collision()
		
func toggle_attack_collision():
	var attack_collision = attack_area.get_node("CollisionShape2D")
	attack_collision.disabled = false
	await get_tree().create_timer(0.4).timeout
	attack_collision.disabled = true

func _on_animated_sprite_2d_animation_finished():
	currently_attack = false

func damage_dealt():
	var damage_to_deal: int
	damage_to_deal = 15
	Global.playerDamageAmount = damage_to_deal

func check_hitbox():
	var hitbox_areas = $playerhitbox.get_overlapping_areas()
	var damage: int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is MagicWizard:
			damage = Global.wizardDamage
		elif hitbox.get_parent() is Fireworm:
			damage = Global.wormDamage

	if damageable:
		take_damage(damage)
		
func take_damage(damage):
	if damage != 0:
		if health > 0:
			health -= damage
			if health <= 0:
				health = 0
				dead = true
				Global.playerAlive = false
				handle_death_animation()
			print(str(self), "health:", health)
			take_damage_cooldown(1.0)

func handle_death_animation():
	animatedsprite.play("death")
	await get_tree().create_timer(3.0).timeout
	self.queue_free()
	get_tree().reload_current_scene()
	

func take_damage_cooldown(wait_time):
	damageable = false
	await get_tree().create_timer(wait_time).timeout
	damageable = true

