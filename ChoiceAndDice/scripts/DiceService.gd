extends Node

class_name DiceService

func roll_dice(num_dice: int, sides: int, modifier: int = 0) -> Dictionary:
	var results = []
	var total = 0
	
	for i in range(num_dice):
		var roll = randi() % sides + 1
		results.append(roll)
		total += roll
	
	total += modifier
	print("Dice roll: ", results, " total: ", total, " modifier: ", modifier)
	
	return {
		"results": results,
		"modifier": modifier,
		"total": total
	}
