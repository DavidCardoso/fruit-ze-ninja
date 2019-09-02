extends RigidBody2D

const HALF_SCREEN = 640
const INI_POS_Y = 800

var sliced = false

signal fruit_sliced
signal fruit_dropped

onready var shape = self.get_node("Shape")
onready var sprite0 = self.get_node("Sprite0")
onready var body1 = self.get_node("Body1")
onready var body2 = self.get_node("Body2")
onready var sprite1 = body1.get_node("Sprite1")
onready var sprite2 = body2.get_node("Sprite2")

func _ready():
	randomize()
	generate(get_pos())
	set_process(true)

func _process(delta):
	# lose life
	if !self.sliced and get_pos().y > self.INI_POS_Y:
		emit_signal("fruit_dropped")
		queue_free()
	
	# increase score
	if self.sliced and body1.get_pos().y > self.INI_POS_Y and body2.get_pos().y > self.INI_POS_Y:
		queue_free()

func generate(iniPos):
	set_pos(iniPos)
	var iniSpeed = Vector2(0, rand_range(-1000, -800))
	
	# is the fruit in left side of the screen?
	if iniPos.x < self.HALF_SCREEN:
		# rotate the fruit to left
		iniSpeed = iniSpeed.rotated(deg2rad(rand_range(0, -30)))
	else:
		# rotate the fruit to right
		iniSpeed = iniSpeed.rotated(deg2rad(rand_range(0, 30)))
	
	set_linear_velocity(iniSpeed)
	set_angular_velocity(rand_range(-20, 20))

func slice():
	if self.sliced:
		return
	
	self.sliced = true
	emit_signal("fruit_sliced")
	
	# hide the main body
	set_mode(MODE_KINEMATIC)
	sprite0.queue_free()
	shape.queue_free()
	
	# configure the left side of the fruit
	body1.set_mode(MODE_RIGID)
	body1.set_angular_velocity(get_angular_velocity())
	body1.apply_impulse(Vector2(0, 0), Vector2(-200, 0).rotated(get_rot()))
	
	# configure the right side of the fruit
	body2.set_mode(MODE_RIGID)
	body2.set_angular_velocity(get_angular_velocity())
	body2.apply_impulse(Vector2(0, 0), Vector2(200, 0).rotated(get_rot()))

func _on_Timer_timeout():
	slice()
