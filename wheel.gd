extends Sprite2D

@onready var wheelButton = $"../WheelButton"

var spinning = false
var spin_velocity = 0
var friction = 0.98
var WHEEL = [
	'$500', '$500', 'BANKRUPT', '$2500', '$600', '$500', '$500', 
	'$500', 'BANKRUPT', '$1500', '$400', '$300', '$300', '$300', 
	'BANKRUPT', '$600', '$300', 'LOSE A TURN', '$800', '$800', '$900',
	'$700', '$600'
]
var processItr: int = 0

func _ready():
	randomize()
	self.centered = true
	var spin_button = $"../SpinButton"
	spin_button.pressed.connect(_spin_button_pressed)
	

func _process(delta):
	if spinning:
		if spin_velocity != 0:
			var current_angle = self.rotation
			current_angle += spin_velocity * delta
			spin_velocity *= friction
			if abs(spin_velocity) < 0.01:
				spin_velocity = 0
				spinning = false
				var game = get_parent()
				game.spun(wheelButton.text)
			elif abs(spin_velocity) > 0.1 and processItr > 10:
				wheelButton.text = WHEEL[randi() % WHEEL.size()]
				processItr = 0
				
			processItr += 1
			self.rotation = current_angle

func _spin_button_pressed():
	spin_velocity = randf_range(250, 500)
	spinning = true
	var game = get_parent()
	game.disableButtons()
