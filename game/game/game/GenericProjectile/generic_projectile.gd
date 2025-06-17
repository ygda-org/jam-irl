extends Area2D
## A generic projectile. Loads a resource that configures the different settings
class_name GenericProjectile

## Projectile Settings. Configure almost everything
@export var settings : ProjectileSettings
## Projectile Starting Direction. 
@export var direction : Vector2 = Vector2(1,0)

var velocity
@export var ignored_body = null

func _ready() -> void:
	
	#$VisibleOnScreenNotifier2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	#self.body_entered.connect(_on_body_entered.bind(Node2D))
	
	rotation = direction.angle()
	$Anim.sprite_frames = settings.sprite_frames
	$Anim.rotation = settings.sprite_rotation_offset
	$DamageArea.affiliation = settings.affiliation
	$DamageArea.damage = settings.damage_dealt
	$DamageArea/CollisionShape2D.shape = settings.collision_shape
	$CollisionShape2D.shape = settings.collision_shape

func _process(delta: float) -> void:
	velocity = transform.x * settings.speed
	position += velocity * delta
	$Anim.play()

func _on_body_entered(body: Node2D) -> void:
	#GlobalLog.log("The following body entered: " + str(body))
	if body == ignored_body:
		return
	
	suicide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	suicide()

func suicide() -> void:
	# TODO Add the things that happen before projectile dies. Maybe a particle spawns??
	rpc("_suicide")
	_suicide()
	
@rpc("authority")
func _suicide() -> void:
	queue_free()
