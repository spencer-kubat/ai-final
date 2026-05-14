class_name ComputerPlayer
extends Player

var difficulty = ""
var isRandom: bool

func _init(playerName = "", difficulty = "easy"):
	playerName = playerName
	difficulty = difficulty
	
func smartCoinFlip() -> bool:
	#var old_difficulty = difficulty
	#var rng = RandomNumberGenerator.new()
	#difficulty = rng.randf_range(1, 10)
	#return difficulty > old_difficulty
	return true

func getPossibleLetters(guessed) -> Array[String]:
	var possible: Array[String] = []
	for l: String in "BCDFGHJKLMNPQRSTVWXYZ":
		if l not in guessed:
			possible.append(l)
	if prizeMoney >= 250:
		for v in "AEIOU":
			if v not in guessed:
				possible.append(v)
	return possible

# Helper method to compare phrase to obscuredPhrase
func checkMatch(obscured, guessed, phrase):
	for i in range(len(obscured)):
		var o = obscured[i].to_upper()
		var p = phrase[i].to_upper()
		if o != '_' and o != p:
			return false
		if o == '_' and guessed.has(p):
			return false
	return true


# CSP filter to find matching phrases
func cspFilter(obscured, guessed, phrases):
	#variables: obscuredPhrase, phrase
	#domains = {
		#obscuredPhrase: the phrase with unguessed letters as '_'
		#PHRASES: the original phrase from the file sustainability_words.txt
	#}
	#constraints = {
		#obscuredPhrase must match the phrase with guessed letters
	#}
	#Since we cannot change the obscuredPhrase, we don't need to work on a queue and 
	#"""
	var constraints = func(p):
		return p.length() == obscured.length() and checkMatch(obscured, guessed, p)
	
	# Filter phrases based on constraints
	var matches = []
	# Check if the phrase matches the obscuredPhrase
	for p in phrases:
		if constraints:
			matches.append(p)
	return matches

func mismatchHeuristic(candidate: String, obscured: String) -> int:
	var mismatches = 0
	# Use the zip_strings function to pair characters from both strings
	var zipped = zip_strings(candidate, obscured)
	for pair in zipped:
		var c = pair[0]  # Character from candidate
		var o = pair[1]  # Character from obscured
		if o != '_' and c != o:
			mismatches += 1
	
	return mismatches
	
func zip_strings(str1: String, str2: String) -> Array:
	var zipped = []
	var min_length = min(str1.length(), str2.length())
	for i in range(min_length):
		zipped.append([str1[i], str2[i]])
		
	return zipped

func letterFrequency(word, possible_letters):
	var freq = {}
	for char in word.to_upper():
		if char in possible_letters:
			freq[char] = freq.get(char, 0) + 1
	return freq

func greedy_search(candidates: Array, obscured: String, possible_letters: Array) -> String:
	# Find the best phrase with the fewest mismatches
	var best_phrase = candidates[0]
	var min_mismatches = mismatchHeuristic(best_phrase, obscured)
	
	for candidate in candidates:
		if candidate != null and candidate.strip_edges() != "":
			var mismatches = mismatchHeuristic(candidate, obscured)
			if mismatches < min_mismatches:
				best_phrase = candidate
				min_mismatches = mismatches
			
	var freqs = letterFrequency(best_phrase, possible_letters)
	if freqs.size() > 0:
		return freqs.keys()[0]  # Default to the first key
		#best_letter = freqs.keys().reduce(func(a, b):
			#return a if freqs[a] > freqs[b] else b
		#)
	return "pass"

# Uniform cost search to find the most frequent letter that is not vowel to optimal the budget of the player
func uniformCostSearch(candidates, possible_letters):
	var letter_cost = {}
	for phrase in candidates:
		for l in phrase.to_upper():
			if l in possible_letters and l not in "AEIOU":
				letter_cost[l] = letter_cost.get(l, 0) + 1

	if not letter_cost:
		return null
	return letter_cost.keys().reduce(func(a, b):
		return a if letter_cost[a] > letter_cost[b] else b
	)
	
func getMove(obscured, guessed, phrases):
	#print(f"""{self.name} has ${self.prizeMoney} | WILD cards: {self.wild_cards}
#Current Phrase:  {obscured}
#Guessed: {', '.join(sorted(guessed))}
#Guess a letter, phrase, or type 'exit' or 'pass': """, end='')

	var possible_letters = self.getPossibleLetters(guessed)
	if not possible_letters:
		print("pass")
		return "pass"

	var move
	if smartCoinFlip():
		var candidates = self.cspFilter(obscured, guessed, phrases)

		if candidates:
			if len(candidates) == 1 and self.difficulty == 10:
				move = candidates[0]
			elif self.difficulty <= 5:
				move = self.uniformCostSearch(candidates, possible_letters)
			else:
				move = self.greedy_search(candidates, obscured, possible_letters)

			if move:
				print(move)
				return move

	move = possible_letters.pick_random()
	print(move)
	return move
