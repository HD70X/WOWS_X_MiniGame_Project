extends Node

enum WeaponType {
	NONE,
	DEPTH_CHARGE_DEF,
	DEPTH_CHARGE_LAUNCHER,
	CANNON
}

enum HullTyep {
	DEFAULT,
	ENHANCE,
	ULTIMATE
}

enum EngineTyep {
	DEFAULT,
	ENHANCE,
	ULTIMATE
}

enum BridgeTyep {
	DEFAULT,
	ENHANCE,
	ULTIMATE
}

# 武器属性字典
const WEAPON_STATS = {
	WeaponType.DEPTH_CHARGE_DEF: {
		"name": "Depth Charge",
		"damage": 1,
		"cooldown": 2.0,
		"scene_path": "res://Scenes/Player/PlayerWeapon/playerWeaponChargerLauncher.tscn"
	},
	WeaponType.DEPTH_CHARGE_LAUNCHER: {
		"name": "Depth Charge Launcher",
		"damage": 1,
		"cooldown": 2.0,
		"scene_path": "res://Scenes/Player/PlayerWeapon/playerWeaponChargerLauncher.tscn"
	},
	WeaponType.CANNON: {
		"name": "Cannon",
		"damage": 1,
		"cooldown": 2.0,
		"scene_path": "res://Scenes/Player/PlayerWeapon/playerWeaponChargerLauncher.tscn"
	}
}

# 船体配件属性字典
const HULL_STATS = {
	HullTyep.DEFAULT: {
		"name": "Stock Hull",
		"hp_bonus": 50,
		"armor": 0
	},
	HullTyep.ENHANCE: {
		"name": "Enhanced Hull",
		"hp_bonus": 100,
		"armor": 0
	},
	HullTyep.ULTIMATE: {
		"name": "Ultimate Hull",
		"hp_bonus": 150,
		"armor": 0
	}
}

# 引擎配件属性字典
const ENGINE_STATS = {
	EngineTyep.DEFAULT: {
		"name": "Stock Engine",
		"speed_bonus": 100
	},
	EngineTyep.ENHANCE: {
		"name": "Enhanced Engine",
		"speed_bonus": 100
	},
	EngineTyep.ULTIMATE: {
		"name": "Ultimate Engine",
		"speed_bonus": 100
	}
}

# 舰桥配件属性字典
const BRIDGE_STATS = {
	BridgeTyep.DEFAULT: {
		"name": "Stock Bridge",
		"weapon_slot": 1
	},
	EngineTyep.ENHANCE: {
		"name": "Enhanced Bridge",
		"weapon_slot": 2
	},
	EngineTyep.ULTIMATE: {
		"name": "Ultimate Bridge",
		"weapon_slot": 3
	}
}
