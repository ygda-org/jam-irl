extends Resource
## A Resource that configures different traits of a GenericProjectile
class_name ProjectileSettings

## The sprite frames
@export var sprite_frames : SpriteFrames
## Rotation offset if needed
@export var sprite_rotation_offset : float
## Position offset if needed
@export var sprite_position_offset : int
## Hitbox shape
@export var collision_shape : Shape2D
## Damage done to target when projectile collides
@export var damage_dealt : int
## Self explanitory
@export var speed : int
