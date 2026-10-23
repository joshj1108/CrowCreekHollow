class_name Appearance
extends RefCounted

## The farmer's look. Each part is one choice from a short list. Saves store the choices, not
## colours, so the figure looks the same every time the game loads. The first choice of every part is
## the look the farmer had before there were choices.

const PARTS := {
	"hat_style": ["Straw hat", "Felt hat", "Knit cap", "Bandana", "Bare head"],
	"hat_colour": ["Straw", "Brown", "Grey", "Red", "Black"],
	"skin": ["Fair", "Light", "Tan", "Brown", "Deep", "Rosy"],
	"eyes": ["Dark brown", "Blue", "Green", "Grey", "Hazel"],
	"hair_style": ["Short", "Long", "Bun", "Shaggy"],
	"hair_colour": ["Dark brown", "Black", "Blonde", "Auburn", "Grey", "Plum"],
	"facial_hair": ["Clean shaven", "Stubble", "Moustache", "Full beard"],
	"shirt": ["Red", "Green", "Violet", "Cream", "Teal", "Maroon"],
	"pants": ["Blue", "Brown", "Charcoal", "Rust", "Forest", "Khaki"],
	"boots": ["Dark brown", "Black", "Tan", "Grey"],
}

const COLOURS := {
	"hat_colour": [Color("d8b050"), Color("6a4a2a"), Color("6f7378"), Color("a8382c"), Color("222222")],
	"skin": [Color("f2c9a0"), Color("e0ab80"), Color("c58c5e"), Color("8d5a3a"), Color("5c3a24"), Color("ffd4c0")],
	"eyes": [Color("2a1f16"), Color("3b6a9a"), Color("4f7a3a"), Color("6a6f78"), Color("7a5a2a")],
	"hair_colour": [Color("5a3a22"), Color("1f1a18"), Color("d8b060"), Color("8a2e1a"), Color("b8b8b8"), Color("4a2e5a")],
	"shirt": [Color("c8553d"), Color("4d7a4a"), Color("6a4f8a"), Color("d9c8a0"), Color("3f6f7a"), Color("8a3a3a")],
	"pants": [Color("3d5a80"), Color("5a4a30"), Color("4a4a4a"), Color("6b3f2a"), Color("2f4a3a"), Color("7a6a4a")],
	"boots": [Color("3a2418"), Color("1a1a1a"), Color("7a5030"), Color("5a5a5a")],
}


# The default choice for every part.
static func default_choices() -> Dictionary:
	var out := {}
	for key in PARTS:
		out[key] = 0
	return out


# Any saved or incoming choices, with missing parts defaulted and out-of-range values clamped.
static func clean(choices: Variant) -> Dictionary:
	var out := default_choices()
	if typeof(choices) == TYPE_DICTIONARY:
		for key in PARTS:
			if choices.has(key):
				out[key] = clampi(int(choices[key]), 0, (PARTS[key] as Array).size() - 1)
	return out


static func count(key: String) -> int:
	return (PARTS[key] as Array).size()


static func label(key: String, index: int) -> String:
	return str((PARTS[key] as Array)[index])


static func colour(key: String, index: int) -> Color:
	return (COLOURS[key] as Array)[index]
