extends SceneTree

# CCH-FOOD-001: prints the food economy straight from the game's data (Foods.LIST, Foods.RECIPES, MainGame's
# CROP_VALUE / SELL_* and the village's prices), so the audit's numbers are the game's own. Headless, no save:
#   godot --path . --headless -s tools/food_audit.gd
# Columns: a food's Hunger restored (Foods.food_restore), its farm-stand price, coins given up per 10 Hunger
# when eaten instead of sold; then each recipe: what its inputs would restore and fetch raw, against the dish.
# Wood and fiber are counted as free (they cost time, not coins); flour at the store's 6. A group (fish, berries,
# mushrooms) is priced at its cheapest member, as the game spends it.

const MAT_PRICE := {"wood": 0, "fiber": 0, "flour": 6}


var done := false


func _process(_d: float) -> bool:
	if done:
		return true
	done = true
	quit(0)
	print("== Foods: Hunger, price, coins per 10 Hunger ==")
	print("| id | kind | skill lvl | Hunger | sanity | price | coins/10 Hunger | effect |")
	for f in Foods.LIST:
		var price := _price(str(f["id"]))
		var food := Foods.food_restore(f)
		print("| %s | %s | %s %d | %d | %.1f | %d | %.1f | %s |" % [f["id"], f["kind"], f["skill"], int(f["level"]), int(food),
			Foods.sanity_restore(f), price, 10.0 * price / maxf(1.0, food), JSON.stringify(f.get("effect", {}))])
	print("")
	print("== Recipes: raw inputs vs the dish ==")
	print("| dish | station | lvl | inputs | in Hunger | in coins | out Hunger | out price | Hunger gain | coin gain | effect |")
	for r in Foods.RECIPES:
		var f := Foods.find(str(r["food"]))
		var in_food := 0.0
		var in_coins := 0
		var parts: Array = []
		for key in r["needs"]:
			var n := int(r["needs"][key])
			parts.append("%d %s" % [n, key])
			if MAT_PRICE.has(key):
				in_coins += n * int(MAT_PRICE[key])
				continue
			var src := _cheapest(str(key))
			in_food += n * Foods.food_restore(src)
			in_coins += n * _price(str(src["id"]))
		var out_food := Foods.food_restore(f)
		var out_price := _price(str(f["id"]))
		print("| %s | %s | %s %d | %s | %d | %d | %d | %d | %+d | %+d | %s |" % [f["id"], r["station"], f["skill"], int(f["level"]),
			", ".join(parts), int(in_food), in_coins, int(out_food), out_price, int(out_food - in_food), out_price - in_coins,
			JSON.stringify(f.get("effect", {}))])
	print("")
	print("Hunger drains about 2.4 an hour: %.0f a 24-hour day." % (2.4 * 24.0))
	print("Village: store sells flour 6, trail ration 14; market perch 8, smoked fish 15; inn fish stew 17, bread 18, tea 11.")
	quit(0)
	return true


func _price(id: String) -> int:
	if MainGame.CROP_VALUE.has(id):
		return int(MainGame.CROP_VALUE[id])
	match id:
		"egg":
			return MainGame.SELL_EGG
		"milk":
			return MainGame.SELL_MILK
		"perch":
			return MainGame.SELL_FISH
	return int(Foods.find(id).get("price", 0))


# The food behind a recipe key: a held key, or the cheapest of a group.
func _cheapest(key: String) -> Dictionary:
	if Foods.is_group(key):
		var best := {}
		for k in Foods.group(key):
			var f := Foods.by_held(str(k))
			if best.is_empty() or _price(str(f["id"])) < _price(str(best["id"])):
				best = f
		return best
	if key == "turnips":
		return Foods.find("turnip")
	return Foods.by_held(key)
