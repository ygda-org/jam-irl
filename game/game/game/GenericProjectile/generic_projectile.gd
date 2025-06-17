extends Area2D
## A generic projectile. Loads a resource that configures the different settings
class_name GenericProjectile

## Projectile Settings. Configure almost everything
@export var settings : ProjectileSettings
## Projectile Starting Direction. 
@export var direction : Vector2 = Vector2(1,0)

var velocity

func _ready() -> void:
	rotation = direction.angle()
	$AnimatedSprite2D.sprite_frames = settings.sprite_frames
	$AnimatedSprite2D.rotation = settings.sprite_rotation_offset
	$AnimatedSprite2D.position = settings.sprite_position_offset
	$CollisionShape2D.shape = settings.collision_shape
	velocity = transform.x * settings.speed
	# NOTE Remove this line later, DONT FORGET
	position = Vector2(300,300)

func _process(delta: float) -> void:
	position += velocity * delta
	$AnimatedSprite2D.play()

func _on_body_entered(body: Node2D) -> void:
	# TODO Add damage dealt here
	suicide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	suicide()

func suicide() -> void:
	# TODO Add the things that happen before projectile dies. Maybe a particle spawns??
	queue_free()
