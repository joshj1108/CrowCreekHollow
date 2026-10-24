class_name ProgressionSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _stat_value(stat: String) -> int:
	match stat:
		"house_stage":
			return m.house_stage
		"lantern_tier":
			return m.lantern_tier
		"story":
			return m.quests_done.size()
	if stat.begins_with("level_"):
		return _level(stat.trim_prefix("level_"))
	return int(m.stats.get(stat, 0))


# Story chapters run in order, so only the first unfinished one can complete.
# Adds one to a counter the questline reads. Saves from before a counter existed start it at zero.
func _bump(stat: String) -> void:
	m.stats[stat] = int(m.stats.get(stat, 0)) + 1


func _check_story() -> void:
	var finished := false
	for q in m.STORY:
		if m.quests_done.has(q["id"]):
			continue
		if _stat_value(q["stat"]) < q["goal"]:
			break
		m.quests_done[q["id"]] = true
		_grant_reward(q["reward"])
		m._show_message("Chapter complete: %s. Reward: %s" % [q["title"], _reward_text(q["reward"])])
		finished = true
	# The next chapter is announced straight away, so the player always knows what to do next.
	if finished:
		m._show_quest_prompt()


func _check_achievements() -> void:
	for a in m.ACHIEVEMENTS:
		if m.achievements_done.has(a["id"]):
			continue
		if _stat_value(a["stat"]) >= a["goal"]:
			m.achievements_done[a["id"]] = true
			m.play_sfx("chime")
			_grant_reward(a["reward"])
			m._show_message("Achievement: %s. Reward: %s" % [a["title"], _reward_text(a["reward"])])


func _grant_reward(reward: Dictionary) -> void:
	if reward.has("seeds"):
		m.inventory["seeds"] += reward["seeds"]
	if reward.has("pumpkin_seeds"):
		m.inventory["pumpkin_seeds"] += reward["pumpkin_seeds"]
	for mat in ["wood", "fiber", "resin"]:
		if reward.has(mat):
			m.materials[mat] += reward[mat]
	if reward.has("coins"):
		m.money += reward["coins"]
	if reward.has("xp"):
		_grant_xp(reward["skill"], reward["xp"])


func _reward_text(reward: Dictionary) -> String:
	var parts: Array = []
	if reward.has("seeds"):
		parts.append("%d turnip seeds" % reward["seeds"])
	if reward.has("pumpkin_seeds"):
		parts.append("%d pumpkin seeds" % reward["pumpkin_seeds"])
	for mat in ["wood", "fiber", "resin"]:
		if reward.has(mat):
			parts.append("%d %s" % [reward[mat], mat])
	if reward.has("coins"):
		parts.append("%d coins" % reward["coins"])
	if reward.has("xp"):
		parts.append("%d %s XP" % [reward["xp"], reward["skill"]])
	return ", ".join(parts)


# Each level costs more XP than the last. Reaching level L takes 50 * (L - 1) * L XP in total:
# level 2 at 100, level 3 at 300, level 4 at 600, level 5 at 1000, level 6 at 1500.
func _level(skill: String) -> int:
	var xp := int(m.skill_xp[skill])
	var n := int(floor((-1.0 + sqrt(1.0 + 4.0 * float(xp) / 50.0)) / 2.0))
	return n + 1


# The XP needed to reach a level, counted from the start.
func _xp_for_level(level: int) -> int:
	return 50 * (level - 1) * level


# How far through the current level the skill is, from 0.0 to 1.0.
func _level_progress(skill: String) -> float:
	var level := _level(skill)
	var start := _xp_for_level(level)
	var span := _xp_for_level(level + 1) - start
	return clampf(float(int(m.skill_xp[skill]) - start) / float(span), 0.0, 1.0)


func _grant_xp(skill: String, amount: int) -> void:
	m.skill_xp[skill] += amount
