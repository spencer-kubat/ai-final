extends Node2D

@onready var announcementLabel: Label = $Announcer/Announcement 
@onready var spinButton: Button = $SpinButton
@onready var passButton: Button = $PassButton
@onready var alphabet: GridContainer = $Alphabet
@onready var phraseGrid: GridContainer = $Phrase
@onready var guessButton: Button = $GuessButton
@onready var guessInput: LineEdit = $GuessButton/GuessInput

var difficultyLevel: int
var phrase: String
var player: Player
var spinAmount: int
var players: Array[Player]
var guessedLetters: String = ""
var VOWEL_COST = 250
var VOWELS = "AEIOU"
var PHRASES = []

func makeAnnouncement(text: String) -> void:
	announcementLabel.text = ""
	for i in text.length():
		announcementLabel.text += text[i]
		await get_tree().create_timer(0.03).timeout

func spun(spinValue: String) -> void:
	spinValue = spinValue.lstrip("$")
	var isInt = spinValue.is_valid_int()
	if isInt:
		spinAmount = spinValue.to_int()
		if player is ComputerPlayer:
			var move: String = getComputerMove()
			if move.to_upper() == "PASS":
				passButton.emit_signal("pressed")
			elif move.length() > 1:
				guessInput.text = move
				guess()
				return
			else:
				var alphabetLetters = alphabet.get_children()
				for al in alphabetLetters:
					var letter: Button = al
					if letter.text == move:
						await selectLetter(letter)
						if (phraseFinished()):
							guessInput.text = phrase
							await guess()
						return
						
			return
		else:
			var announce = "Waiting for %s to select letter" % [player.playerName]
			await makeAnnouncement(announce)
		updateAlphabet()
		passButton.disabled = false
	else:
		var actionText = "lost a turn"
		if spinValue == "BANKRUPT":
			player.goBankrupt()
			actionText = "gone Bankrupt"
		var nextPlayer = getNextPlayer()
		var announce = "%s has %s! %s turn" % [player.playerName, actionText, nextPlayer.playerName]
		await makeAnnouncement(announce)
		nextPlayer()	

func guess():
	disableButtons()
	disableAlphabet()
	var guess = guessInput.text.to_upper()
	var announce = "%s won with a prize of $%d!" % [player.playerName, player.prizeMoney]
	var nextPlayer = getNextPlayer()
	if guess != phrase:
		announce = "Incorrect guess, %s turn" % [nextPlayer.playerName]
	await makeAnnouncement(announce)
	if guess != phrase:
		nextPlayer()
		
func phraseFinished() -> bool:
	var phraseButtons = phraseGrid.get_children()
	for i in phrase.length():
		var phraseButton: Button = phraseButtons[i]
		if phraseButton.text == "":
			return false
	return true

func updateAlphabet():
	var alphabetLetters = alphabet.get_children()
	for al in alphabetLetters:
		var letterButton: Button = al
		if letterButton.text not in guessedLetters:
			letterButton.disabled = false
			letterButton.pressed.connect(selectLetter.bind(letterButton))

func selectLetter(letterButton: Button):
	disableAlphabet()
	var selectedLetter: String = letterButton.text
	if selectedLetter in VOWELS and player.prizeMoney < VOWEL_COST:
		var announce = "You cannot afford a vowel"
		await makeAnnouncement(announce)
		updateAlphabet()
		return
	
	if player is ComputerPlayer:
		var announce = "%s selected the letter %s" % [player.playerName, selectedLetter]
		await makeAnnouncement(announce)
		await get_tree().create_timer(1).timeout
	guessedLetters = guessedLetters + selectedLetter
	if selectedLetter in phrase:
		var earned: int = 0
		var phraseButtons = phraseGrid.get_children()
		
		for i in phrase.length():
			if phrase[i] == selectedLetter:
				var phraseButton: Button = phraseButtons[i]
				phraseButton.text = selectedLetter
				earned += spinAmount
		
		var announce = "%s earned $ %d! Spin the wheel or solve." % [player.playerName, earned]
		if selectedLetter in VOWELS:
			earned = -VOWEL_COST
			announce = "%s bought a vowel. Select another letter or solve." % [player.playerName]
			
		player.addMoney(earned)
		await makeAnnouncement(announce)
		
		if player is ComputerPlayer:
			await get_tree().create_timer(1).timeout
			spinButton.emit_signal("pressed")
			return
		
		guessInput.editable = true
		
		# if buying vowel, allow another selection
		if selectedLetter in VOWELS: 
			updateAlphabet()
			return
	else:
		var nextPlayer = getNextPlayer()
		var announce = "Letter not in phrase, %s turn" % [nextPlayer.playerName]
		await makeAnnouncement(announce)
		nextPlayer()

	spinButton.disabled = false
	
func passTurn():
	disableAlphabet()
	disableButtons()
	var nextPlayer: Player = getNextPlayer()
	var prevPlayer = player.playerName
	var announce = "%s passes. %s, please spin the wheel" % [prevPlayer, nextPlayer.playerName]
	await makeAnnouncement(announce)
	nextPlayer()
	
func getNextPlayer() -> Player:
	var playerIndex = players.find(player)
	var nextPlayer: Player = players[0]
	if (playerIndex + 1) < players.size():
		nextPlayer = players[playerIndex + 1]
	return nextPlayer
	
func nextPlayer():
	player = getNextPlayer()
	guessInput.text = ""
	if player is ComputerPlayer:
		disableAlphabet()
		disableButtons()
		spinButton.emit_signal("pressed")
	else:
		spinButton.disabled = false
		passButton.disabled = false
		guessInput.editable = true
		
func disableAlphabet():
	var alphabetLetters = alphabet.get_children()
	for al in alphabetLetters:
		var letter: Button = al
		letter.disabled = true

func disableButtons():
	spinButton.disabled = true
	passButton.disabled = true
	guessButton.disabled = true
	guessInput.editable = false
		
func getComputerMove() -> String:
	var computerPlayer: ComputerPlayer = player as ComputerPlayer
	var possible_letters: Array[String] = computerPlayer.getPossibleLetters(guessedLetters)
	if not possible_letters:
		return "PASS"

	var move: String = ""
	if computerPlayer.smartCoinFlip():
		var obscured = ""
		for p in phrase:
			if p in guessedLetters or p == "-" or p == " ":
				obscured = obscured + p
			else:
				obscured = obscured + "_"	
		var candidates = computerPlayer.cspFilter(obscured, guessedLetters, PHRASES)
		if candidates:
			if len(candidates) == 1 and difficultyLevel == 10:
				return candidates[0]
			elif difficultyLevel <= 5:
				move = computerPlayer.uniformCostSearch(candidates, possible_letters)
				print("ucs")
				print(move)
			else:
				move = computerPlayer.greedy_search(candidates, obscured, possible_letters)
				print("greedy")
				print(move)

			if move != null:
				return move

	move = possible_letters.pick_random()
	return move
		
func create(difficulty: String, players: Array[Player]):
	self.players = players
	self.player = players[0]
	
	var file = FileAccess.open("res://sustainability_words.txt", FileAccess.READ)
	PHRASES = file.get_as_text().split("\n")
	
	var lengthLimit = 48
	difficultyLevel = 8
	if difficulty.to_upper() == "EASY":
		difficultyLevel = 1
		lengthLimit = 12
	elif difficulty.to_upper() == "MEDIUM":
		difficultyLevel = 5
		lengthLimit = 24
		
	var subPhrases = Array(PHRASES).filter(func(p): return p.length() <= lengthLimit)
	randomize()  # Seed the random number generator
	phrase = subPhrases[randi() % subPhrases.size()]
	phrase = phrase.to_upper()
	var phraseGrid: GridContainer = $Phrase
	var phraseButtons = phraseGrid.get_children()
	for i in phrase.length():
		var phraseButton: Button = phraseButtons[i]
		if phrase[i] == "-":
			phraseButton.text = "-"
			phraseButton.disabled = false
		elif phrase[i] != " ":
			phraseButton.text = ""
			phraseButton.disabled = false
			
	print(phrase)

func _ready():
	var player1NameLabel = $Player1NameLabel
	var player2NameLabel = $Player2NameLabel
	var player3NameLabel = $Player3NameLabel
	
	if players.size() > 0:
		player1NameLabel.text = players[0].playerName
		players[0].moneyLabel = $Player1NameLabel/Player1MoneyLabel
		players[0].moneyLabel.text = "$ 0"
	if players.size() > 1:
		player2NameLabel.text = players[1].playerName
		players[1].moneyLabel = $Player2NameLabel/Player2MoneyLabel
		players[1].moneyLabel.text = "$ 0"
	if players.size() > 2:
		player3NameLabel.text = players[2].playerName
		players[2].moneyLabel = $Player3NameLabel/Player3MoneyLabel
		players[2].moneyLabel.text = "$ 0"
	
	passButton.pressed.connect(passTurn)
	var quitButton = $QuitButton
	quitButton.pressed.connect(quitGame)
	
	guessInput.text_changed.connect(onGuessInputChanged)
	guessButton.pressed.connect(guess)
	guessButton.disabled = true
	guessInput.editable = false
	
	var announce = "%s, please spin the wheel" % [players[0].playerName]
	await makeAnnouncement(announce)
	if players[0] is ComputerPlayer:
		spinButton.emit_signal("pressed")


func onGuessInputChanged(text: String):
	if (guessInput.editable and text != ""):
		guessButton.disabled = false
	else:
		guessButton.disabled = true

func quitGame():
	get_tree().quit()
	
