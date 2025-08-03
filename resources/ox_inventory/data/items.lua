return {
	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			image = 'burger_chicken.png',
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

	['bandage'] = {
		label = 'Bandage',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
		},
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
		}
	},

	['parachute'] = {
		label = 'Parachute',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Lockpick',
		weight = 160,
	},

	['phone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['sphone'] = {
		label = 'SPhone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['iphone'] = {
		label = 'IPhone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
		}
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'Bulletproof Vest',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},

	['mastercard'] = {
		label = 'Fleeca Card',
		stack = false,
		weight = 10,
		client = {
			image = 'card_bank.png'
		}
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

	-- Drugs

	["watering_can"] = {
  	label = "Watering can",
  	weight = 500,
  	stack = false,
  	close = false,
  	description = "Simple watering can",
  	client = {
  		image = "watering_can.png",
  	}
  },
  
  ["fertilizer"] = {
  	label = "Fertilizer",
  	weight = 500,
  	stack = false,
  	close = false,
  	description = "Fertilizer",
  	client = {
  		image = "fertilizer.png",
  	}
  },
  
  ["advanced_fertilizer"] = {
  	label = "Advanced fertilizer",
  	weight = 500,
  	stack = false,
  	close = false,
  	description = "Fertilizer with the litte extra",
  	client = {
  		image = "advanced_fertilizer.png",
  	}
  },
  
  ["liquid_fertilizer"] = {
  	label = "Liquid Fertilizer",
  	weight = 200,
  	stack = false,
  	close = false,
  	description = "Basicly Water with nutrations",
  	client = {
  		image = "liquid_fertilizer.png",
  	}
  },
  
  ["weed_lemonhaze_seed"] = {
  	label = "Weed Lemonhaze Seed",
  	weight = 20,
  	stack = true,
  	close = true,
  consume = 0,
  	description = "Weed Lemonhaze Seed",
  	client = {
  		image = "weed_lemonhaze_seed.png",
  	},
  	server = {
  		export = "it-drugs.useSeed"
  	}
  },
  
  ["weed_lemonhaze"] = {
  	label = "Weed Lemonhaze",
  	weight = 20,
  	stack = true,
  	close = false,
  	description = "Weed Lemonhaze",
  	client = {
  		image = "weed_lemonhaze.png",
  	},
  },
  
  ["weed_og_seed"] = {
  	label = "Weed Og Seed",
  	weight = 20,
  	stack = true,
  	close = true,
  consume = 0,
  	description = "Weed Og Seed",
  	client = {
  		image = "weed_og_seed.png",
  	},
  	server = {
  		export = "it-drugs.useSeed"
  	}
  },
  
  ["weed_og"] = {
  	label = "weed Og",
  	weight = 20,
  	stack = true,
  	close = false,
  	description = "weed Og",
  	client = {
  		image = "weed_og.png",
  	},
  },
  
  ["weed_purple_haze_seed"] = {
  	label = "Weed Purple Haze Seed",
  	weight = 20,
  	stack = true,
  	close = true,
  consume = 0,
  	description = "Weed Purple Haze Seed",
  	client = {
  		image = "weed_purple_haze_seed.png",
  	},
  	server = {
  		export = "it-drugs.useSeed"
  	}
  },
  
  ["weed_purple_haze"] = {
  	label = "weed Purple Haze",
  	weight = 20,
  	stack = true,
  	close = false,
  	description = "weed Purple Haze",
  	client = {
  		image = "weed_purple_haze.png",
  	},
  },
  
  ["weed_white_widow_seed"] = {
  	label = "Weed White Widow Seed",
  	weight = 20,
  	stack = true,
  	close = true,
  consume = 0,
  	description = "Weed White Widow Seed",
  	client = {
  		image = "weed_white_widow_seed.png",
  	},
  	server = {
  		export = "it-drugs.useSeed"
  	}
  },
  
  ["weed_white_widow"] = {
  	label = "weed White Widow",
  	weight = 20,
  	stack = true,
  	close = false,
  	description = "weed White Widow",
  	client = {
  		image = "weed_white_widow.png",
  	}
  },
  
  ["weed_blueberry_seed"] = {
  	label = "Weed Blueberry Seed",
  	weight = 20,
  	stack = true,
  	close = true,
  consume = 0,
  	description = "Weed Blueberry Seed",
  	client = {
  		image = "weed_blueberry_seed.png",
  	},
  	server = {
  		export = "it-drugs.useSeed"
  	}
  },
  
  ["weed_blueberry"] = {
  	label = "weed Blueberry",
  	weight = 20,
  	stack = true,
  	close = false,
  	description = "weed Blueberry",
  	client = {
  		image = "weed_blueberry.png",
  	}
  },
  
  ["coca_seed"] = {
  	label = "Coca Seed",
  	weight = 20,
  	stack = true,
  	close = true,
  consume = 0,
  	description = "Coca Seed",
  	client = {
  		image = "coca_seed.png",
  	},
  	server = {
  		export = "it-drugs.useSeed"
  	}
  },
  
  ["coca"] = {
  	label = "Coca",
  	weight = 20,
  	stack = true,
  	close = false,
  	description = "Coca",
  	client = {
  		image = "coca.png",
  	}
  },
  
  ["paper"] = {
  	label = "Paper",
  	weight = 50,
  	stack = true,
  	close = false,
  	description = "Paper",
  	client = {
  		image = "paper.png",
  	}
  },
  
  ["nitrous"] = {
  	label = "Nitrous",
  	weight = 500,
  	stack = false,
  	close = false,
  	description = "Nitrous",
  	client = {
  		image = "nitrous.png",
  	}
  },
  
  ["weed_processing_table"] = {
  	label = "Weed Processing Table",
  	weight = 1000,
  	stack = false,
  	close = true,
  consume = 0,
  	description = "Process some weed",
  	client = {
  		image = "weed_processing_table.png",
  	},
  	server = {
  		export = "it-drugs.placeProcessingTable"
  	}
  },
  
  ["cocaine_processing_table"] = {
  	label = "Cocaine Processing Table",
  	weight = 1000,
  	stack = false,
  	close = true,
  	description = "Process some cocaine",
  consume = 0,
  	client = {
  		image = "cocaine_processing_table.png",
  	},
  	server = {
  		export = "it-drugs.placeProcessingTable"
  	}
  },
  
  ["cocaine"] = {
  	label = "Kanthari",
  	weight = 20,
  	stack = true,
  	close = true,
  	description = "A little bag of cocaine",
  	consume = 0,
  	server = {
  		export = "it-drugs.takeDrug"
  	},
  	client = {
  		image = "kanthari.png",
  	},
  },
  
  ["joint"] = {
  	label = "Sambharam",
  	weight = 10,
  	stack = true,
  	close = true,
  	description = "Joint",
  	consume = 0,
  	server = {
  		export = "it-drugs.takeDrug"
  	},
  	client = {
  		image = "sambharam.png",
  	}
  },
	
}
