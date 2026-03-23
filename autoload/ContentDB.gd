extends Node

var flowers: Dictionary = {}
var customers: Dictionary = {}
var locations: Dictionary = {}
var order_templates: Dictionary = {}
var upgrades: Dictionary = {}
var dialogue_events: Dictionary = {}
var journal_entries: Dictionary = {}


func _ready() -> void:
	_build_flowers()
	_build_customers()
	_build_locations()
	_build_order_templates()
	_build_upgrades()
	_build_dialogue_events()
	_build_journal_entries()


func get_flower(id: String) -> FlowerData:
	return flowers.get(id)


func get_customer(id: String) -> CustomerData:
	return customers.get(id)


func get_location(id: String) -> LocationData:
	return locations.get(id)


func get_order_template(id: String) -> OrderTemplateData:
	return order_templates.get(id)


func get_upgrade(id: String) -> UpgradeData:
	return upgrades.get(id)


func get_flowers_by_tag(tag: String) -> Array:
	var result := []
	for f in flowers.values():
		if f.color_tag == tag or f.flower_type == tag:
			result.append(f)
	return result


func get_unlocked_flowers(unlocked_ids: Array) -> Array:
	var result := []
	for id in unlocked_ids:
		if flowers.has(id):
			result.append(flowers[id])
	return result


func _build_flowers() -> void:
	var data := [
		["daisy_yellow", "Yellow Daisy", "Daisy", "Yellow", 10, "A cheerful yellow daisy.", ["cheerful", "bright"]],
		["daisy_white", "White Daisy", "Daisy", "White", 10, "A soft white daisy.", ["gentle", "classic"]],
		["tulip_pink", "Pink Tulip", "Tulip", "Pink", 15, "A lovely pink tulip.", ["elegant", "delicate"]],
		["wildflower_yellow", "Yellow Wildflower", "Wildflower", "Yellow", 8, "A wild yellow flower.", ["rustic", "cheerful"]],
		["rose_red", "Red Rose", "Rose", "Red", 25, "A classic red rose.", ["elegant", "striking"]],
		["rose_white", "White Rose", "Rose", "White", 25, "A pure white rose.", ["elegant", "classic"]],
		["lavender_purple", "Purple Lavender", "Lavender", "Purple", 18, "Fragrant purple lavender.", ["gentle", "restful"]],
		["sunflower_yellow", "Sunflower", "Sunflower", "Yellow", 20, "A bold bright sunflower.", ["bright", "warm"]],
		["lily_white", "White Lily", "Lily", "White", 22, "An elegant white lily.", ["elegant", "classic"]],
		["bluebell_blue", "Bluebell", "Bluebell", "Blue", 14, "A delicate woodland bluebell.", ["gentle", "delicate"]],
		["peony_pink", "Pink Peony", "Peony", "Pink", 28, "A lush pink peony.", ["elegant", "abundant"]],
		["poppy_red", "Red Poppy", "Poppy", "Red", 12, "A vibrant red poppy.", ["bright", "rustic"]],
		["carnation_pink", "Pink Carnation", "Carnation", "Pink", 16, "A classic pink carnation.", ["classic", "cheerful"]],
		["marigold_orange", "Orange Marigold", "Marigold", "Orange", 14, "A warm orange marigold.", ["warm", "rustic"]],
		["chrysanthemum_yellow", "Yellow Chrysanthemum", "Chrysanthemum", "Yellow", 18, "A golden chrysanthemum.", ["warm", "abundant"]],
		["clover_green", "Green Clover Bloom", "Clover", "Green", 6, "A humble green clover.", ["rustic", "modest"]],
	]
	for d in data:
		var f := FlowerData.new()
		f.id = d[0]
		f.display_name = d[1]
		f.flower_type = d[2]
		f.color_tag = d[3]
		f.base_value = d[4]
		f.description = d[5]
		flowers[f.id] = f


func _build_customers() -> void:
	var data := [
		["florist_mentor", "Florist Mentor", "Mentor", "town_square"],
		["red_fox", "Red Fox", "Customer", "fox_house"],
		["white_tailed_deer", "White-Tailed Deer", "Customer", "deer_house"],
		["rabbit", "Rabbit", "Customer", "library"],
		["otter", "Otter", "Customer", "lakeside_dock"],
		["bear", "Bear", "Customer", "bakery"],
		["sparrow", "Sparrow", "Customer", "town_square"],
	]
	for d in data:
		var c := CustomerData.new()
		c.id = d[0]
		c.display_name = d[1]
		c.role = d[2]
		c.default_location_id = d[3]
		customers[c.id] = c


func _build_locations() -> void:
	var data := [
		["flower_shop", "Flower Shop", Vector2(960, 600), "Your cozy flower shop.", true],
		["fox_house", "Fox House", Vector2(400, 300), "Red Fox's warm burrow.", true],
		["deer_house", "Deer House", Vector2(1500, 300), "White-Tailed Deer's clearing.", true],
		["town_square", "Town Square", Vector2(960, 350), "The bustling center of town.", true],
		["player_home", "Home", Vector2(960, 800), "Your cozy home.", true],
		["library", "Library", Vector2(300, 600), "The quiet village library.", false],
		["lakeside_dock", "Lakeside Dock", Vector2(1600, 700), "The peaceful lakeside dock.", false],
		["bakery", "Bakery", Vector2(600, 200), "The warm village bakery.", false],
	]
	for d in data:
		var l := LocationData.new()
		l.id = d[0]
		l.display_name = d[1]
		l.world_position = d[2]
		l.description = d[3]
		locations[l.id] = l


func _build_order_templates() -> void:
	var _t1 := _make_template("tmpl_yellow_daisy", "routine", [1, 2, 3],
		[_req("ColorTag", "Yellow", 1), _req("FlowerType", "Daisy", 1)],
		20, 35, 1, ["red_fox"], ["fox_house"],
		["I need a cheerful bouquet with at least one yellow flower and one daisy.",
		 "Could you put together something bright with a yellow daisy?"])

	var _t2 := _make_template("tmpl_white_gentle", "routine", [1, 2, 3],
		[_req("ColorTag", "White", 1), _req("FlowerType", "Daisy", 1)],
		25, 40, 1, ["white_tailed_deer"], ["deer_house"],
		["Could I have something soft and gentle? Please include at least one white flower and one daisy.",
		 "Something white and calming would be lovely."])

	var _t3 := _make_template("tmpl_pink_simple", "routine", [1, 2],
		[_req("ColorTag", "Pink", 1)],
		15, 25, 1, ["florist_mentor"], ["town_square"],
		["Let us keep it simple today. I would like one pink flower.",
		 "Something pink and simple please."])

	var _t4 := _make_template("tmpl_two_colors", "routine", [2, 3],
		[_req("ColorTag", "Yellow", 1), _req("ColorTag", "White", 1)],
		30, 50, 1, ["rabbit", "florist_mentor"], ["library", "town_square"],
		["I would love a bouquet with both yellow and white flowers.",
		 "Could you mix some yellow and white together?"])

	var _t5 := _make_template("tmpl_roses", "routine", [2, 3],
		[_req("FlowerType", "Rose", 1)],
		25, 45, 1, ["red_fox", "sparrow"], ["fox_house", "town_square"],
		["I am looking for something with roses.",
		 "Roses would be perfect for what I have in mind."])

	var _t6 := _make_template("tmpl_elegant", "routine", [2, 3],
		[_req("ColorTag", "White", 1), _req("ColorTag", "Pink", 1)],
		35, 55, 1, ["white_tailed_deer", "rabbit"], ["deer_house", "library"],
		["Something elegant with white and pink would be wonderful.",
		 "I need an elegant arrangement."])

	var _t7 := _make_template("tmpl_warm_rustic", "routine", [2, 3],
		[_req("ColorTag", "Yellow", 1), _req("ColorTag", "Orange", 1)],
		30, 50, 1, ["bear", "otter"], ["bakery", "lakeside_dock"],
		["Something warm and rustic would be great.",
		 "I want warm colors — yellows and oranges."])

	var _t8 := _make_template("tmpl_abundant", "routine", [3],
		[_req("ColorTag", "Yellow", 2), _req("FlowerType", "Daisy", 1)],
		45, 70, 2, ["bear"], ["bakery"],
		["I need a big, abundant bouquet with plenty of yellow and at least one daisy.",
		 "Make it generous — lots of yellow!"])

	var _t9 := _make_template("tmpl_lively", "routine", [2, 3],
		[_req("ColorTag", "Red", 1), _req("ColorTag", "Yellow", 1)],
		35, 55, 1, ["otter", "sparrow"], ["lakeside_dock", "town_square"],
		["Something lively and colorful! Red and yellow please.",
		 "Bright and cheerful — mix red and yellow for me!"])

	var _t10 := _make_template("tmpl_purple_gentle", "routine", [2, 3],
		[_req("ColorTag", "Purple", 1)],
		20, 35, 1, ["white_tailed_deer", "rabbit"], ["deer_house", "library"],
		["Something with purple tones would be soothing.",
		 "Lavender or something purple please."])

	var _t11 := _make_template("tmpl_celebration", "routine", [3],
		[_req("ColorTag", "Pink", 1), _req("ColorTag", "Red", 1), _req("ColorTag", "White", 1)],
		50, 80, 2, ["sparrow", "red_fox"], ["town_square", "fox_house"],
		["A celebration bouquet — pink, red, and white all together!",
		 "I need something festive with pink, red, and white."])

	var _t12 := _make_template("tmpl_blue_delicate", "routine", [2, 3],
		[_req("ColorTag", "Blue", 1)],
		20, 35, 1, ["rabbit", "white_tailed_deer"], ["library", "deer_house"],
		["Do you have anything blue? Bluebells would be lovely.",
		 "Something delicate and blue please."])

	# Story / special templates
	var _s1 := _make_template("story_mentor_memorial", "story", [2],
		[_req("ColorTag", "White", 2), _req("FlowerType", "Lily", 1)],
		60, 60, 3, ["florist_mentor"], ["town_square"],
		["There is a memorial coming up. I need two white flowers and a lily. It means a great deal."],
		5)

	var _s2 := _make_template("story_fox_showcase", "story", [2],
		[_req("FlowerType", "Rose", 1), _req("ColorTag", "Red", 1)],
		50, 50, 2, ["red_fox"], ["fox_house"],
		["I am setting up a showcase for my craft stall. I need something striking with a rose and red accents."],
		3)

	var _s3 := _make_template("story_deer_remembrance", "story", [2, 3],
		[_req("ColorTag", "White", 1), _req("ColorTag", "Purple", 1)],
		45, 45, 2, ["white_tailed_deer"], ["deer_house"],
		["I would like something for a remembrance. White and purple, if you have them."],
		4)

	var _s4 := _make_template("story_final_celebration", "story", [3],
		[_req("ColorTag", "Pink", 1), _req("ColorTag", "Yellow", 1), _req("ColorTag", "White", 1), _req("FlowerType", "Rose", 1)],
		100, 100, 5, ["florist_mentor"], ["town_square"],
		["The village celebration is here. I need your finest work — pink, yellow, white, and a rose."],
		8)


func _make_template(id: String, rtype: String, phases: Array, reqs: Array[OrderRequirementData],
		rmin: int, rmax: int, rrep: int, custs: Array, dests: Array,
		texts: Array, min_rep: int = 0) -> OrderTemplateData:
	var t := OrderTemplateData.new()
	t.id = id
	t.request_type = rtype
	t.allowed_phases = phases
	t.requirements = reqs
	t.reward_money_min = rmin
	t.reward_money_max = rmax
	t.reward_reputation = rrep
	t.preferred_customer_ids.assign(custs)
	t.destination_pool.assign(dests)
	t.request_texts.assign(texts)
	t.min_reputation = min_rep
	order_templates[t.id] = t
	return t


func _req(rtype: String, val: String, amt: int) -> OrderRequirementData:
	var r := OrderRequirementData.new()
	r.requirement_type = rtype
	r.target_value = val
	r.amount = amt
	return r


func _build_upgrades() -> void:
	var data := [
		["greenhouse_beds_1", "greenhouse", "Extra Flower Beds", "Add 2 more growing slots.", 50, 0, [], "greenhouse_slots", 2],
		["greenhouse_beds_2", "greenhouse", "Expanded Greenhouse", "Add 2 more growing slots.", 120, 2, ["greenhouse_beds_1"], "greenhouse_slots", 2],
		["greenhouse_speed_1", "greenhouse", "Fertile Soil", "Flowers grow 1 day faster.", 80, 1, [], "growth_speed", 1],
		["greenhouse_yield_1", "greenhouse", "Rich Harvest", "Harvest 1 extra flower per slot.", 100, 2, [], "harvest_yield", 1],
		["shop_bouquet_1", "shop", "Larger Bouquets", "Unlock 6th bouquet slot.", 60, 1, [], "bouquet_slots", 1],
		["shop_premium_1", "shop", "Premium Orders", "Unlock higher-value orders.", 100, 3, [], "premium_orders", 1],
		["travel_speed_1", "travel", "Bicycle", "Travel faster on the map.", 40, 0, [], "travel_speed", 1],
		["unlock_library", "travel", "Unlock Library", "Deliver to the village library.", 30, 1, [], "unlock_location", 0],
		["unlock_dock", "travel", "Unlock Lakeside Dock", "Deliver to the lakeside dock.", 40, 2, [], "unlock_location", 0],
		["unlock_bakery", "travel", "Unlock Bakery", "Deliver to the village bakery.", 50, 3, [], "unlock_location", 0],
	]
	for d in data:
		var u := UpgradeData.new()
		u.id = d[0]
		u.category = d[1]
		u.display_name = d[2]
		u.description = d[3]
		u.cost_money = d[4]
		u.cost_reputation = d[5]
		u.prerequisites.assign(d[6])
		u.effect_type = d[7]
		u.effect_value = d[8]
		upgrades[u.id] = u


func _build_dialogue_events() -> void:
	var events := [
		_evt("evt_mentor_intro", "day", "1", "florist_mentor", [
			"Welcome to our little village! I used to run the flower shop.",
			"I am glad someone is taking it over. Let me show you around.",
			"Start by collecting flowers in the greenhouse, then come to the shop."
		], "", "", "mentor_intro_done"),
		_evt("evt_fox_first_order", "relationship_level", "red_fox:1", "red_fox", [
			"Oh, you are the new florist! I have heard good things already.",
			"I need something cheerful for my craft stall. Can you help?"
		]),
		_evt("evt_deer_trust", "relationship_level", "white_tailed_deer:2", "white_tailed_deer", [
			"You have been very kind with your flowers.",
			"There is something I have been meaning to ask...",
			"Could you make something for a remembrance? It would mean a lot."
		]),
		_evt("evt_rabbit_intro", "story_flag", "unlock_library_done", "rabbit", [
			"Oh! A delivery? For me?",
			"I... do not get many visitors. Thank you.",
			"If you ever need anything, I keep a tidy collection of books on flowers."
		]),
		_evt("evt_otter_intro", "story_flag", "unlock_dock_done", "otter", [
			"Hey there! Fresh flowers for the docks? What a treat!",
			"I run deliveries around the lake. We should swap stories sometime."
		]),
		_evt("evt_bear_intro", "story_flag", "unlock_bakery_done", "bear", [
			"Well now. Flowers at the bakery. That is... really nice.",
			"My wife used to keep flowers on the counter. Thank you for this."
		]),
		_evt("evt_mentor_handoff", "relationship_level", "florist_mentor:4", "florist_mentor", [
			"You have grown so much. The shop is truly yours now.",
			"I could not be more proud. The village needed someone like you.",
			"There is one more thing — the village celebration is coming up.",
			"I want you to create the centerpiece. You have earned it."
		], "", "", "final_event_unlocked"),
	]
	for e in events:
		dialogue_events[e.id] = e


func _evt(id: String, trig_type: String, trig_val: String, speaker: String,
		lines: Array, reward_type: String = "", reward_id: String = "",
		flag: String = "") -> DialogueEventData:
	var e := DialogueEventData.new()
	e.id = id
	e.trigger_type = trig_type
	e.trigger_value = trig_val
	e.speaker_id = speaker
	e.lines.assign(lines)
	e.unlock_reward_type = reward_type
	e.unlock_reward_id = reward_id
	e.set_story_flag = flag
	return e


func _build_journal_entries() -> void:
	pass
