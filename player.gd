class_name Player
extends Node

var playerName = ""
var prizeMoney: int = 0
var prizes = []
var half_car_count = 0
var wile_cards = 0
var moneyLabel: Label

func addMoney(amt: int):
	# Add money to the player's total
	prizeMoney += amt
	moneyLabel.text = "$ %d" % [prizeMoney]

func goBankrupt():
	prizeMoney = 0
	half_car_count = 0
	wile_cards = 0
	prizes = []
	moneyLabel.text = "$ %d" % [prizeMoney]
	
func addPrize(prize):
	prizes.append(prize)
	
func buyVowel(game, vowel):
	if prizeMoney >= get_parent().VOWEL_COST and vowel.to_upper() in get_parent().VOWELS:
		prizeMoney -= get_parent().VOWEL_COST
		# print(f"{self.name} bought a vowel: {vowel.upper()} for ${VOWEL_COST}. Remaining money: ${self.prizeMoney}")
		return true
	else:
		# print(f"{self.name} cannot afford to buy a vowel.")
		return false
