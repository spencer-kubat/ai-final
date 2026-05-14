extends Control

@onready var player1Option: OptionButton = $Player1Label/Player1Option
@onready var player2Option: OptionButton = $Player2Label/Player2Option
@onready var player3Option: OptionButton = $Player3Label/Player3Option

@onready var humanName1: LineEdit = $NameLabel1/HumanName1
@onready var humanName2: LineEdit = $NameLabel2/HumanName2
@onready var humanName3: LineEdit = $NameLabel3/HumanName3

@onready var nameLabel1: Label = $NameLabel1
@onready var nameLabel2: Label = $NameLabel2
@onready var nameLabel3: Label = $NameLabel3

@onready var difficultyOption: OptionButton = $DifficultyLabel/DifficultyOption
@onready var startButton: Button = $StartButton

func _ready():
	player1Option.item_selected.connect(
		_on_player_option_selected.bind(nameLabel1))
	player2Option.item_selected.connect(
		_on_player_option_selected.bind(nameLabel2))
	player3Option.item_selected.connect(
		_on_player_option_selected.bind(nameLabel3))
		
	humanName1.text_changed.connect(_on_human_name_changed)
	humanName2.text_changed.connect(_on_human_name_changed)
	humanName3.text_changed.connect(_on_human_name_changed)
	
	startButton.pressed.connect(_on_start_button_pressed)
		
func _on_start_button_pressed():
	var gameScene = load('res://game.tscn')
	var instance = gameScene.instantiate()
	
	var difficulty: String = difficultyOption.text
	var players: Array[Player] = []
	var options: Array[OptionButton] = [player1Option, player2Option, player3Option]
	var names: Array[String] = [humanName1.text, humanName2.text, humanName3.text]
	
	for i in options.size():
		if options[i].selected == 1:
			var player = HumanPlayer.new(names[i])
			player.playerName = names[i].to_upper()
			players.append(player)
			continue
		elif options[i].selected == 2:
			var name = "Player %s (AI)" % [i + 1]
			var player = ComputerPlayer.new(name, difficulty)
			player.playerName = name.to_upper()
			player.difficulty = difficulty
			players.append(player)
				
	instance.create(difficulty, players)
	add_sibling(instance)
	self.visible = false

func _on_human_name_changed(text):
	if checkValidity():
		startButton.disabled = false
	else:
		startButton.disabled = true
	
func _on_player_option_selected(index: int, nameLabel: Label):
	if index == 1: # human
		nameLabel.visible = true
	else:
		nameLabel.visible = false
	if checkValidity():
		startButton.disabled = false
	else:
		startButton.disabled = true

func checkValidity():
	if (nameLabel1.visible and humanName1.text == "") or (nameLabel2.visible and humanName2.text == "") or (nameLabel3.visible and humanName3.text == ""):
		return false
	return true
