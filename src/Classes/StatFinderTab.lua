-- Path of Building
--
-- Module: Stat Finder Tab
-- Allows user to search stat mod sources
--

-- Layout constants (shared across Draw, DrawConfig, DrawItems, DrawCalcs, etc.)=========================================================================================================================================

local LAYOUT = {
	-- general section
	subSectionVerticalOffset = 24,
	subSectionHorizontalOffset = 14,

	-- Search settings section
	searchSettingsSectionHeight = 720,
	searchSettingsSectionWidth = 400,

	-- Section widths (heights are auto-calculated from checkbox count)
	itemSectionWidth = 175,
	modTypeSectionWidth = 185,
	modSourceSectionWidth = 185,
	otherStatSourceSectionWidth = 185,

	-- checkbox
	checkboxSize = 20,
	topCheckboxVerticalOffset = 16,
	topCheckboxHorizontalOffset = -8,
	subCheckboxVerticalOffset = 8,

}

-- DATA setup ===========================================================================================================================================================================================================

-- Node IDs below this value are normal passive tree nodes; IDs at or above are cluster jewel nodes
local CLUSTER_NODE_OFFSET = 65536

-- List of stats which are supported by the tool, each entry contains:
--   label: the name of the stat, displayed in the dropdown menu
--   groups: list of stat mod groups flat/inc/more
--      property: if its searchFlat/searchInc/searchMore related info
--      names: names of the mod groups that have such types of mods
--      essenceTypes: if some mod from this group is result of essence crafting, essenceType number(s) of those essences
local supportedStatsList = {
	{
		label = "Select a stat...",
		groups = {}
	},
	{
		label = "Attack Speed",
		groups = {
			{property = "searchFlat", names = {}, essenceTypes = {}},
			-- todo: do we want to somehow distinguish the local and global mods?
			-- todo: what about the insanity essence mods and desolation essence 
			-- ""AttackAndCastSpeedDuringFlaskEffect", "AttackCastSpeedPerNearbyEnemy" -- essence of desolation
			-- "LocalIncreasedAttackSpeedAddedChaos" -- incursion mod
			{property = "searchInc", names = {"LocalIncreasedAttackSpeed", "IncreasedAttackSpeed", "SocketedGemsHaveMoreAttackAndCastSpeed",
											  "IncreasedAttackSpeedSupported", "IncreasedAttackAndCastSpeedSupported", "AttackSpeedDuringFlaskEffect",
											  "LocalIncreasedAttackSpeedMultistrike", "LocalIncreasedAttackSpeedFasterAttacks", "LocalIncreasedAttackSpeedOnslaught",
											  "AttackSpeedDoubleDamage", "AttackSpeedKilledRecently", "AttackSpeedHitRecently", "LocalIncreasedPhysicalDamagePercentAndAttackSpeed",
											  "AttackSpeedWithFortify", "AttackSpeedIfEnemyKilledRecently", "IncreasedAttackAndCastSpeedSupportedMaven"}, essenceTypes = {15, 21}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Cast Speed",
		groups = {
			{property = "searchFlat", names = {}, essenceTypes = {}},
			-- "AttackAndCastSpeedDuringFlaskEffect", "AttackCastSpeedPerNearbyEnemy" -- essence of desolation
			-- "IncreasedCastSpeedAddedChaos" -- incursion mod
			-- "AttackAndCastSpeed" -- not sure what is this
			{property = "searchInc", names = {"IncreasedCastSpeed", "IncreasedCastSpeedFishing", "SocketedGemsHaveMoreAttackAndCastSpeed",
											  "IncreasedCastSpeedSupported", "IncreasedAttackAndCastSpeedSupported", "CastSpeedDuringFlaskEffect",
											  "IncreasedCastSpeedSpellEcho", "IncreasedCastSpeedFasterCasting", "IncreasedCastSpeedTwoHandedAvoidInterruption",
											  "IncreasedCastSpeedTwoHandedKilledRecently", "CastSpeedIfEnemyKilledRecently", "IncreasedAttackAndCastSpeedSupportedMaven"}, essenceTypes = {15,16,21}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Life",
		groups = {
			-- "IncreasedLifeAndPercent" -- incursion mod
			{property = "searchFlat", names = {"IncreasedLife", "LocalBaseArmourAndLife", "LocalBaseEvasionRatingAndLife", "LocalBaseEnergyShieldAndLife", "LocalBaseWardAndLife",
											   "LocalBaseArmourEnergyShieldAndLife", "LocalBaseArmourEvasionRatingAndLife", "LocalBaseEvasionRatingEnergyShieldAndLife"}, essenceTypes = {2}},
			{property = "searchInc", names = {"MaximumLifeIncreasePercent"}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Mana",
		groups = {
			-- "IncreasedManaAndPercent", "IncreasedManaAndOnHit", "IncreasedManaAndRegen", "IncreasedManaAndReservation", "IncreasedManaAndCost", "IncreasedManaAndCostNew", "IncreasedManaAndDegenGracePeriod", "IncreasedManaAndBaseCost" -- incursion
			{property = "searchFlat", names = {"IncreasedMana", "LocalBaseEnergyShieldAndMana", "WeaponSpellDamageAndMana", "TwoHandedWeaponSpellDamageAndMana", "MinionDamageOnWeaponAndMana"}, essenceTypes = {16}},
			{property = "searchInc", names = {"MaximumManaIncreasePercent", "MaximumManaIncreaseShaper", "MaximumManaIncreasePercentMaven"}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Energy Shield",
		groups = {
			-- "EnergyShieldAndPercent", "EnergyShieldAndRegen",  -- incursion mod
			{property = "searchFlat", names = {"EnergyShield", "LocalEnergyShield", "LocalBaseArmourAndEnergyShield", "LocalBaseEvasionRatingAndEnergyShield",
											   "LocalBaseArmourEnergyShieldAndLife", "LocalBaseEnergyShieldAndLife", "LocalBaseEnergyShieldAndMana", }, essenceTypes = {1}},
			{property = "searchInc", names = {"GlobalEnergyShieldPercent", "LocalEnergyShieldPercent", "LocalArmourAndEnergyShield", "LocalEvasionAndEnergyShield",
											  "LocalArmourAndEvasionAndEnergyShield", "LocalEnergyShieldAndStunRecoveryPercent", "LocalArmourAndEnergyShieldAndStunRecovery",
											  "LocalEvasionAndEnergyShieldAndStunRecovery", "LocalArmourAndEvasionAndEnergyShieldAndStunRecovery", "MaximumEnergyShieldFromBodyArmour"}, essenceTypes = {1}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Fire Resistance",
		groups = {
			-- "FireResistancePhysTakenAsFire", "FireResistanceLeech", "FireResistanceAilments", "FireResistanceEnemyLeech" -- incursion mod
			{property = "searchFlat", names = {"FireResistance",  "AllResistances", "MaximumResistances", "AllResistancesMaven"}, essenceTypes = {5}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Cold Resistance",
		groups = {
			-- "ColdResistancePhysTakenAsCold", "ColdResistanceLeech", "ColdResistanceAilments", "ColdResistanceEnemyLeech" -- incursion mod
			{property = "searchFlat", names = {"ColdResistance", "AllResistances", "MaximumResistances", "AllResistancesMaven"}, essenceTypes = {0}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Lightning Resistance",
		groups = {
			-- "LightningResistancePhysTakenAsLightning", "LightningResistanceLeech", "LightningResistanceAilments", "LightningResistanceEnemyLeech" -- incursion mod
			{property = "searchFlat", names = {"LightningResistance", "AllResistances", "MaximumResistances", "AllResistancesMaven", "MaximumLightningResistance"}, essenceTypes = {10}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Chaos Resistance",
		groups = {
			-- "ChaosResistanceDamageOverTime" -- incursion mod
			{property = "searchFlat", names = {"ChaosResistance", "ChaosResistanceWhileUsingFlask", "MaximumChaosResistance", "MaximumResistances", ""}, essenceTypes = {19, 23}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Evasion Rating",
		groups = {
			{property = "searchFlat", names = {"EvasionRating", "LocalEvasionRating", "LocalBaseArmourAndEvasionRating", "LocalBaseEvasionRatingAndEnergyShield",
											   "LocalBaseArmourEvasionRatingAndLife", "LocalBaseEvasionRatingEnergyShieldAndLife", "LocalBaseEvasionRatingAndLife"}, essenceTypes = {}},
			{property = "searchInc", names = {"LocalEvasionRatingIncreasePercent", "LocalArmourAndEvasion", "LocalEvasionAndEnergyShield", "LocalArmourAndEvasionAndEnergyShield",
											  "LocalEvasionRatingAndStunRecoveryIncreasePercent", "LocalArmourAndEvasionAndStunRecovery", "LocalEvasionAndEnergyShieldAndStunRecovery",
											  "LocalArmourAndEvasionAndEnergyShieldAndStunRecovery", "GlobalEvasionRatingPercent"}, essenceTypes = {11}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Armour",
		groups = {
			-- LocalPhysicalDamageReductionRatingPercentAndBlockChance -- ??
			{property = "searchFlat", names = {"PhysicalDamageReductionRating", "LocalPhysicalDamageReductionRating", "LocalBaseArmourAndEvasionRating", "LocalBaseArmourAndEnergyShield", "LocalBaseArmourEvasionRatingAndLife",
											   "LocalBaseArmourEnergyShieldAndLife", "LocalBaseArmourAndLife"}, essenceTypes = {}},
			{property = "searchInc", names = {"GlobalPhysicalDamageReductionRatingPercent", "LocalPhysicalDamageReductionRatingPercent", "LocalArmourAndEnergyShield", "LocalArmourAndEvasion",
											  "LocalArmourAndEvasionAndEnergyShield", "LocalPhysicalDamageReductionRatingAndStunRecoveryPercent", "LocalArmourAndEnergyShieldAndStunRecovery",
											  "LocalArmourAndEvasionAndStunRecovery", "LocalArmourAndEvasionAndEnergyShieldAndStunRecovery", "GlobalPhysicalDamageReductionRatingPercent",  }, essenceTypes = {17}}, 
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Critical Strike Multiplier",
		groups = {
			{property = "searchFlat", names = {"CriticalStrikeMultiplier", "CriticalStrikeMultiplierWithBows", "SocketedSpellCriticalMultiplier", "SocketedAttackCriticalMultiplier",
											   "CriticalStrikeMultiplierSupported", "CriticalMultiplierSupportedTwoHanded", "CriticalStrikeMultiplierIfBlockedRecentlyUber",
											   "CriticalStrikeChanceTwoHandedCritMultiRecently", "CriticalStrikeMultiplierAgainstEnemiesOnFullLife", "LocalIncreasedPhysicalDamagePercentAndCritMulti",
											   "CriticalStrikeMultiplierIfEnemySlainRecently", "CriticalStrikeMultiplierAgainstEnemiesOnFullLife"}, essenceTypes = {18}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Critical Strike Chance",
		groups = {
			{property = "searchFlat", names = {"SocketedSkillsCriticalChance", "SocketedSpellCriticalStrikeChance", "SocketedAttackCriticalStrikeChance",
											   "AdditionalCriticalStrikeChanceWithAttacks", "AdditionalCriticalStrikeChanceWithSpells", }, essenceTypes = {22}},
			{property = "searchInc", names = {"CriticalStrikeChance", "CriticalStrikeChanceWithBows", "SpellCriticalStrikeChance", "LocalCriticalStrikeChance",
											  "CriticalStrikeChanceSupported", "CriticalStrikeChanceTwoHandedCritChanceRecently", "CriticalStrikeChanceSpellsSupported",
											  "CriticalStrikeChanceSpellsTwoHandedPowerCharge", "CriticalStrikeChanceIfNoCriticalStrikeDealtRecentlyUber",
											  "CriticalStrikeChanceAgainstPoisonedEnemies", "CriticalChanceAgainstBlindedEnemies", "CriticalStrikeChanceIfKilledRecently",
											  "CritChanceShockedEnemies", "LocalIncreasedPhysicalDamagePercentAndCritChance"}, essenceTypes = {13, 18}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Movement Speed",
		groups = {
			{property = "searchFlat", names = {}, essenceTypes = {}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Intelligence",
		groups = {
			{property = "searchFlat", names = {"Intelligence", "DexterityAndIntelligence", "HybridStrInt", "HybridDexInt", "StrengthIntelligenceForJewel", "StrengthAndIntelligence"}, essenceTypes = {24}},
			{property = "searchInc", names = {"PercentageIntelligence", "PercentageIntelligenceMaven"}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Strength",
		groups = {
			{property = "searchFlat", names = {}, essenceTypes = {}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Dexterity",
		groups = {
			{property = "searchFlat", names = {}, essenceTypes = {}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Physical Damage",
		groups = {
			{property = "searchFlat", names = {}, essenceTypes = {}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
}

-- Unified mapping from weightKey strings to both filter properties and display item types.
-- weightKey in files like ModExplicit contains array of "item types" like helmet or ring_crusader, then there is array called weightVal which contains the info about weight of the specific mod on that "item type"
-- This is mapping from the weightKey to :
--   filter: name of search filter, which affects the given "item type" (if searchHelmetMods filter is false, we don't care about "helmet" or "helmet_crusader"...)
--   types: an array of display item type names (e.g., {"Ring"})
-- *Note: Attribute-based armor keys (str_armour, dex_armour, etc.) apply to all four armor slots (body armour, helmet, gloves, boots), not just body armour.
local WEIGHT_KEY_INFO = {
	-- Accessories
	["amulet"] = {filter = "searchAmuletMods", types = {"Amulet"}},
	["belt"] = {filter = "searchBeltMods", types = {"Belt"}},
	["ring"] = {filter = "searchRingMods", types = {"Ring"}},
	-- Armour slots
	["body_armour"] = {filter = "searchBodyArmourMods", types = {"Body Armour"}},
	["boots"] = {filter = "searchBootsMods", types = {"Boots"}},
	["gloves"] = {filter = "searchGlovesMods", types = {"Gloves"}},
	["helmet"] = {filter = "searchHelmetMods", types = {"Helmet"}},
	-- Attribute-based armour (applies to all 4 armor slots)
	["dex_armour"] = {filter = {"searchBodyArmourMods", "searchHelmetMods", "searchGlovesMods", "searchBootsMods"}, types = {"Body Armour", "Helmet", "Gloves", "Boots"}},
	["int_armour"] = {filter = {"searchBodyArmourMods", "searchHelmetMods", "searchGlovesMods", "searchBootsMods"}, types = {"Body Armour", "Helmet", "Gloves", "Boots"}},
	["str_armour"] = {filter = {"searchBodyArmourMods", "searchHelmetMods", "searchGlovesMods", "searchBootsMods"}, types = {"Body Armour", "Helmet", "Gloves", "Boots"}},
	["dex_int_armour"] = {filter = {"searchBodyArmourMods", "searchHelmetMods", "searchGlovesMods", "searchBootsMods"}, types = {"Body Armour", "Helmet", "Gloves", "Boots"}},
	["str_dex_armour"] = {filter = {"searchBodyArmourMods", "searchHelmetMods", "searchGlovesMods", "searchBootsMods"}, types = {"Body Armour", "Helmet", "Gloves", "Boots"}},
	["str_int_armour"] = {filter = {"searchBodyArmourMods", "searchHelmetMods", "searchGlovesMods", "searchBootsMods"}, types = {"Body Armour", "Helmet", "Gloves", "Boots"}},
	["str_dex_int_armour"] = {filter = {"searchBodyArmourMods", "searchHelmetMods", "searchGlovesMods", "searchBootsMods"}, types = {"Body Armour", "Helmet", "Gloves", "Boots"}},
	["ward_armour"] = {filter = {"searchBodyArmourMods", "searchHelmetMods", "searchGlovesMods", "searchBootsMods"}, types = {"Body Armour", "Helmet", "Gloves", "Boots"}},
	-- Influence-specific armour
	["body_armour_adjudicator"] = {filter = "searchBodyArmourMods", types = {"Body Armour"}},
	["body_armour_basilisk"] = {filter = "searchBodyArmourMods", types = {"Body Armour"}},
	["body_armour_crusader"] = {filter = "searchBodyArmourMods", types = {"Body Armour"}},
	["body_armour_elder"] = {filter = "searchBodyArmourMods", types = {"Body Armour"}},
	["body_armour_eyrie"] = {filter = "searchBodyArmourMods", types = {"Body Armour"}},
	["body_armour_shaper"] = {filter = "searchBodyArmourMods", types = {"Body Armour"}},
	["helmet_adjudicator"] = {filter = "searchHelmetMods", types = {"Helmet"}},
	["helmet_basilisk"] = {filter = "searchHelmetMods", types = {"Helmet"}},
	["helmet_crusader"] = {filter = "searchHelmetMods", types = {"Helmet"}},
	["helmet_elder"] = {filter = "searchHelmetMods", types = {"Helmet"}},
	["helmet_eyrie"] = {filter = "searchHelmetMods", types = {"Helmet"}},
	["helmet_shaper"] = {filter = "searchHelmetMods", types = {"Helmet"}},
	["boots_adjudicator"] = {filter = "searchBootsMods", types = {"Boots"}},
	["boots_basilisk"] = {filter = "searchBootsMods", types = {"Boots"}},
	["boots_crusader"] = {filter = "searchBootsMods", types = {"Boots"}},
	["boots_elder"] = {filter = "searchBootsMods", types = {"Boots"}},
	["boots_eyrie"] = {filter = "searchBootsMods", types = {"Boots"}},
	["boots_shaper"] = {filter = "searchBootsMods", types = {"Boots"}},
	["gloves_adjudicator"] = {filter = "searchGlovesMods", types = {"Gloves"}},
	["gloves_basilisk"] = {filter = "searchGlovesMods", types = {"Gloves"}},
	["gloves_crusader"] = {filter = "searchGlovesMods", types = {"Gloves"}},
	["gloves_elder"] = {filter = "searchGlovesMods", types = {"Gloves"}},
	["gloves_eyrie"] = {filter = "searchGlovesMods", types = {"Gloves"}},
	["gloves_shaper"] = {filter = "searchGlovesMods", types = {"Gloves"}},
	-- Influence-specific accessories
	["belt_adjudicator"] = {filter = "searchBeltMods", types = {"Belt"}},
	["belt_basilisk"] = {filter = "searchBeltMods", types = {"Belt"}},
	["belt_crusader"] = {filter = "searchBeltMods", types = {"Belt"}},
	["belt_elder"] = {filter = "searchBeltMods", types = {"Belt"}},
	["belt_eyrie"] = {filter = "searchBeltMods", types = {"Belt"}},
	["belt_shaper"] = {filter = "searchBeltMods", types = {"Belt"}},
	["shield_adjudicator"] = {filter = "searchShieldMods", types = {"Shield"}},
	["shield_basilisk"] = {filter = "searchShieldMods", types = {"Shield"}},
	["shield_crusader"] = {filter = "searchShieldMods", types = {"Shield"}},
	["shield_elder"] = {filter = "searchShieldMods", types = {"Shield"}},
	["shield_eyrie"] = {filter = "searchShieldMods", types = {"Shield"}},
	["shield_shaper"] = {filter = "searchShieldMods", types = {"Shield"}},
	["ring_adjudicator"] = {filter = "searchRingMods", types = {"Ring"}},
	["ring_basilisk"] = {filter = "searchRingMods", types = {"Ring"}},
	["ring_crusader"] = {filter = "searchRingMods", types = {"Ring"}},
	["ring_elder"] = {filter = "searchRingMods", types = {"Ring"}},
	["ring_eyrie"] = {filter = "searchRingMods", types = {"Ring"}},
	["ring_shaper"] = {filter = "searchRingMods", types = {"Ring"}},
	["amulet_adjudicator"] = {filter = "searchAmuletMods", types = {"Amulet"}},
	["amulet_basilisk"] = {filter = "searchAmuletMods", types = {"Amulet"}},
	["amulet_crusader"] = {filter = "searchAmuletMods", types = {"Amulet"}},
	["amulet_elder"] = {filter = "searchAmuletMods", types = {"Amulet"}},
	["amulet_eyrie"] = {filter = "searchAmuletMods", types = {"Amulet"}},
	["amulet_shaper"] = {filter = "searchAmuletMods", types = {"Amulet"}},
	["quiver_adjudicator"] = {filter = "searchQuiverMods", types = {"Quiver"}},
	["quiver_basilisk"] = {filter = "searchQuiverMods", types = {"Quiver"}},
	["quiver_crusader"] = {filter = "searchQuiverMods", types = {"Quiver"}},
	["quiver_elder"] = {filter = "searchQuiverMods", types = {"Quiver"}},
	["quiver_eyrie"] = {filter = "searchQuiverMods", types = {"Quiver"}},
	["quiver_shaper"] = {filter = "searchQuiverMods", types = {"Quiver"}},
	-- Weapons - one handed
	["axe"] = {filter = "searchAxeMods", types = {"Axe (1H)", "Axe (2H)"}},
	["claw"] = {filter = "searchClawMods", types = {"Claw"}},
	["dagger"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["mace"] = {filter = "searchMaceMods", types = {"Mace (1H)", "Mace (2H)"}},
	["rapier"] = {filter = "searchSwordMods", types = {"Rapier"}},
	["sceptre"] = {filter = "searchSwordMods", types = {"Sceptre"}},
	["sword"] = {filter = "searchSwordMods", types = {"Sword (1H)", "Sword (2H)"}},
	["wand"] = {filter = "searchWandMods", types = {"Wand"}},
	-- Weapons - two handed
	["bow"] = {filter = "searchBowMods", types = {"Bow"}},
	["staff"] = {filter = "searchStaffMods", types = {"Staff"}},
	-- Influence-specific weapons
	["axe_adjudicator"] = {filter = "searchAxeMods", types = {"Axe (1H)"}},
	["axe_basilisk"] = {filter = "searchAxeMods", types = {"Axe (1H)"}},
	["axe_crusader"] = {filter = "searchAxeMods", types = {"Axe (1H)"}},
	["axe_elder"] = {filter = "searchAxeMods", types = {"Axe (1H)"}},
	["axe_eyrie"] = {filter = "searchAxeMods", types = {"Axe (1H)"}},
	["axe_shaper"] = {filter = "searchAxeMods", types = {"Axe (1H)"}},
	["2h_axe_adjudicator"] = {filter = "searchAxeMods", types = {"Axe (2H)"}},
	["2h_axe_basilisk"] = {filter = "searchAxeMods", types = {"Axe (2H)"}},
	["2h_axe_crusader"] = {filter = "searchAxeMods", types = {"Axe (2H)"}},
	["2h_axe_elder"] = {filter = "searchAxeMods", types = {"Axe (2H)"}},
	["2h_axe_eyrie"] = {filter = "searchAxeMods", types = {"Axe (2H)"}},
	["2h_axe_shaper"] = {filter = "searchAxeMods", types = {"Axe (2H)"}},
	["bow_adjudicator"] = {filter = "searchBowMods", types = {"Bow"}},
	["bow_basilisk"] = {filter = "searchBowMods", types = {"Bow"}},
	["bow_crusader"] = {filter = "searchBowMods", types = {"Bow"}},
	["bow_elder"] = {filter = "searchBowMods", types = {"Bow"}},
	["bow_eyrie"] = {filter = "searchBowMods", types = {"Bow"}},
	["bow_shaper"] = {filter = "searchBowMods", types = {"Bow"}},
	["claw_adjudicator"] = {filter = "searchClawMods", types = {"Claw"}},
	["claw_basilisk"] = {filter = "searchClawMods", types = {"Claw"}},
	["claw_crusader"] = {filter = "searchClawMods", types = {"Claw"}},
	["claw_elder"] = {filter = "searchClawMods", types = {"Claw"}},
	["claw_eyrie"] = {filter = "searchClawMods", types = {"Claw"}},
	["claw_shaper"] = {filter = "searchClawMods", types = {"Claw"}},
	["dagger_adjudicator"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["dagger_basilisk"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["dagger_crusader"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["dagger_elder"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["dagger_eyrie"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["dagger_shaper"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["rune_dagger_adjudicator"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["rune_dagger_basilisk"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["rune_dagger_crusader"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["rune_dagger_elder"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["rune_dagger_eyrie"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["rune_dagger_shaper"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["mace_adjudicator"] = {filter = "searchMaceMods", types = {"Mace (1H)"}},
	["mace_basilisk"] = {filter = "searchMaceMods", types = {"Mace (1H)"}},
	["mace_crusader"] = {filter = "searchMaceMods", types = {"Mace (1H)"}},
	["mace_elder"] = {filter = "searchMaceMods", types = {"Mace (1H)"}},
	["mace_eyrie"] = {filter = "searchMaceMods", types = {"Mace (1H)"}},
	["mace_shaper"] = {filter = "searchMaceMods", types = {"Mace (1H)"}},
	["2h_mace_adjudicator"] = {filter = "searchMaceMods", types = {"Mace (2H)"}},
	["2h_mace_basilisk"] = {filter = "searchMaceMods", types = {"Mace (2H)"}},
	["2h_mace_crusader"] = {filter = "searchMaceMods", types = {"Mace (2H)"}},
	["2h_mace_elder"] = {filter = "searchMaceMods", types = {"Mace (2H)"}},
	["2h_mace_eyrie"] = {filter = "searchMaceMods", types = {"Mace (2H)"}},
	["2h_mace_shaper"] = {filter = "searchMaceMods", types = {"Mace (2H)"}},
	["sceptre_adjudicator"] = {filter = "searchSwordMods", types = {"Sceptre"}},
	["sceptre_basilisk"] = {filter = "searchSwordMods", types = {"Sceptre"}},
	["sceptre_crusader"] = {filter = "searchSwordMods", types = {"Sceptre"}},
	["sceptre_elder"] = {filter = "searchSwordMods", types = {"Sceptre"}},
	["sceptre_eyrie"] = {filter = "searchSwordMods", types = {"Sceptre"}},
	["sceptre_shaper"] = {filter = "searchSwordMods", types = {"Sceptre"}},
	["staff_adjudicator"] = {filter = "searchStaffMods", types = {"Staff"}},
	["staff_basilisk"] = {filter = "searchStaffMods", types = {"Staff"}},
	["staff_crusader"] = {filter = "searchStaffMods", types = {"Staff"}},
	["staff_elder"] = {filter = "searchStaffMods", types = {"Staff"}},
	["staff_eyrie"] = {filter = "searchStaffMods", types = {"Staff"}},
	["staff_shaper"] = {filter = "searchStaffMods", types = {"Staff"}},
	["sword_adjudicator"] = {filter = "searchSwordMods", types = {"Sword (1H)"}},
	["sword_basilisk"] = {filter = "searchSwordMods", types = {"Sword (1H)"}},
	["sword_crusader"] = {filter = "searchSwordMods", types = {"Sword (1H)"}},
	["sword_elder"] = {filter = "searchSwordMods", types = {"Sword (1H)"}},
	["sword_eyrie"] = {filter = "searchSwordMods", types = {"Sword (1H)"}},
	["sword_shaper"] = {filter = "searchSwordMods", types = {"Sword (1H)"}},
	["2h_sword_adjudicator"] = {filter = "searchSwordMods", types = {"Sword (2H)"}},
	["2h_sword_basilisk"] = {filter = "searchSwordMods", types = {"Sword (2H)"}},
	["2h_sword_crusader"] = {filter = "searchSwordMods", types = {"Sword (2H)"}},
	["2h_sword_elder"] = {filter = "searchSwordMods", types = {"Sword (2H)"}},
	["2h_sword_eyrie"] = {filter = "searchSwordMods", types = {"Sword (2H)"}},
	["2h_sword_shaper"] = {filter = "searchSwordMods", types = {"Sword (2H)"}},
	["warstaff_adjudicator"] = {filter = "searchStaffMods", types = {"Staff"}},
	["warstaff_basilisk"] = {filter = "searchStaffMods", types = {"Staff"}},
	["warstaff_crusader"] = {filter = "searchStaffMods", types = {"Staff"}},
	["warstaff_elder"] = {filter = "searchStaffMods", types = {"Staff"}},
	["warstaff_eyrie"] = {filter = "searchStaffMods", types = {"Staff"}},
	["warstaff_shaper"] = {filter = "searchStaffMods", types = {"Staff"}},
	["wand_adjudicator"] = {filter = "searchWandMods", types = {"Wand"}},
	["wand_basilisk"] = {filter = "searchWandMods", types = {"Wand"}},
	["wand_crusader"] = {filter = "searchWandMods", types = {"Wand"}},
	["wand_elder"] = {filter = "searchWandMods", types = {"Wand"}},
	["wand_eyrie"] = {filter = "searchWandMods", types = {"Wand"}},
	["wand_shaper"] = {filter = "searchWandMods", types = {"Wand"}},
	-- Generic weapon keys
	["one_hand_weapon"] = {filter = "searchSwordMods", types = {"Sword (1H)", "Axe (1H)", "Mace (1H)", "Wand", "Sceptre", "Claw", "Dagger", "Rapier"}},
	["two_hand_weapon"] = {filter = "searchSwordMods", types = {"Sword (2H)", "Axe (2H)", "Mace (2H)", "Staff", "Bow"}},
	["weapon"] = {filter = "searchSwordMods", types = {"Sword (1H)", "Sword (2H)", "Axe (1H)", "Axe (2H)", "Mace (1H)", "Mace (2H)", "Wand", "Sceptre", "Claw", "Dagger", "Rapier", "Staff", "Bow"}},
	-- Other
	["fishing_rod"] = {filter = "searchFishingMods", types = {"Fishing Rod"}},
	["flask"] = {filter = "searchFlaskMods", types = {"Flask"}},
	["jewel"] = {filter = "searchJewelMods", types = {"Jewel"}},
	["quiver"] = {filter = "searchQuiverMods", types = {"Quiver"}},
	["shield"] = {filter = "searchShieldMods", types = {"Shield"}},
	-- Item variant keys (these add a tag, not a separate item type)
	["attack_dagger"] = {filter = "searchDaggerMods", types = {"Dagger"}},
	["warstaff"] = {filter = "searchStaffMods", types = {"Staff"}},
	["weapon_can_roll_minion_modifiers"] = {filter = "searchWandMods", types = {"Wand"}},
	["wand_can_roll_caster_modifiers"] = {filter = "searchWandMods", types = {"Wand"}},
}

-- Item type variant tags: weightKey -> display tag name
-- These are shown as tags on tiers when the mod has variant-specific behavior
local WEIGHT_KEY_VARIANT_TAGS = {
	["attack_dagger"] = "Dagger",
	["dagger"] = "Runic Dagger",
	["warstaff"] = "Warstaff",
	["weapon_can_roll_minion_modifiers"] = "Minion Wand",
	["weapon_can_roll_caster_modifiers"] = "Cast Wand",
}

-- Item type hierarchy structure.
-- Defines the tree: Items -> (Armour, Weapons, Accessories, Other) -> leaf types.
-- Each leaf has a "display" name and a list of "keys" (display names from WEIGHT_KEY_INFO.types).
local ITEM_TYPE_HIERARCHY = {
	{
		name = "Items",
		expandedByDefault = true,
		children = {
			{
				name = "Armour",
				expandedByDefault = true,
				children = {
					{name = "Body Armour", keys = {"Body Armour"}},
					{name = "Helmet", keys = {"Helmet"}},
					{name = "Gloves", keys = {"Gloves"}},
					{name = "Boots", keys = {"Boots"}},
				},
			},
			{
				name = "Weapons",
				expandedByDefault = true,
				children = {
					{name = "Sword (1H)", keys = {"Sword (1H)"}},
					{name = "Sword (2H)", keys = {"Sword (2H)"}},
					{name = "Axe (1H)", keys = {"Axe (1H)"}},
					{name = "Axe (2H)", keys = {"Axe (2H)"}},
					{name = "Mace (1H)", keys = {"Mace (1H)"}},
					{name = "Mace (2H)", keys = {"Mace (2H)"}},
					{name = "Wand", keys = {"Wand"}},
					{name = "Sceptre", keys = {"Sceptre"}},
					{name = "Claw", keys = {"Claw"}},
					{name = "Dagger", keys = {"Dagger"}},
					{name = "Rapier", keys = {"Rapier"}},
					{name = "Staff", keys = {"Staff"}},
					{name = "Bow", keys = {"Bow"}},
				},
			},
			{
				name = "Accessories",
				expandedByDefault = true,
				children = {
					{name = "Ring", keys = {"Ring"}},
					{name = "Amulet", keys = {"Amulet"}},
					{name = "Belt", keys = {"Belt"}},
				},
			},
			{
				name = "Other",
				expandedByDefault = true,
				children = {
					{name = "Shield", keys = {"Shield"}},
					{name = "Quiver", keys = {"Quiver"}},
					{name = "Jewel", keys = {"Jewel"}},
					{name = "Flask", keys = {"Flask"}},
					{name = "Fishing Rod", keys = {"Fishing Rod"}},
				},
			},
		},
	},
}

-- Declarative data for all filter sections
-- Each section data contains:
--                             title, width, items array with label, property name, and default state
--                             width items array with label, property name, and default state
--                             select/deselect button width (optional)items array with label, property name, and default state
--                             items array with: label, property name, and default state (true/false for checkbox)
local FILTER_SECTIONS = {
	{
		title = "Mod Types",
		width = 185,
		items = {
			{label = "^7Flat value mods:", property = "searchFlat", default = true},
			{label = "^7Increase mods:", property = "searchInc", default = true},
			{label = "^7More mods:", property = "searchMore", default = true},
		}
	},
	{
		title = "Mod Sources",
		width = 185,
		items = {
			{label = "^7Base:", property = "searchBase", default = true},
			{label = "^7Corrupted:", property = "searchCorrupted", default = true},
			{label = "^7Crafted:", property = "searchCrafted", default = true},
			{label = "^7Delve:", property = "searchDelve", default = true},
			{label = "^7Eldritch:", property = "searchEldritch", default = true},
			{label = "^7Essence:", property = "searchEssence", default = true},
			{label = "^7Incursion:", property = "searchIncursion", default = true},
			{label = "^7Veiled:", property = "searchVeiled", default = true},
		}
	},
	{
		title = "Other Stat Sources",
		width = 185,
		items = {
			{label = "^7Bandits:", property = "searchBandits", default = true},
			{label = "^7Cluster jewel notables:", property = "searchClusterJewelNotables", default = true},
			{label = "^7Foulborn:", property = "searchFoulborn", default = true},
			{label = "^7Pantheon:", property = "searchPantheon", default = true},
			{label = "^7Tattoos:", property = "searchTattoos", default = true},
			{label = "^7Tree:", property = "searchTree", default = true},
			{label = "^7Uniques:", property = "searchUniques", default = true},
		}
	},
	{
		title = "Items",
		width = 175,
		buttonWidth = 75,
		items = {
			{label = "^7Amulet:", property = "searchAmuletMods", default = true},
			{label = "^7Axe:", property = "searchAxeMods", default = true},
			{label = "^7Belt:", property = "searchBeltMods", default = true},
			{label = "^7Body Armour:", property = "searchBodyArmourMods", default = true},
			{label = "^7Boots:", property = "searchBootsMods", default = true},
			{label = "^7Bow:", property = "searchBowMods", default = true},
			{label = "^7Claw:", property = "searchClawMods", default = true},
			{label = "^7Dagger:", property = "searchDaggerMods", default = true},
			{label = "^7Fishing:", property = "searchFishingMods", default = true},
			{label = "^7Flask:", property = "searchFlaskMods", default = true},
			{label = "^7Gloves:", property = "searchGlovesMods", default = true},
			{label = "^7Graft:", property = "searchGraftMods", default = false},
			{label = "^7Helmet:", property = "searchHelmetMods", default = true},
			{label = "^7Jewel:", property = "searchJewelMods", default = true},
			{label = "^7Mace:", property = "searchMaceMods", default = true},
			{label = "^7Quiver:", property = "searchQuiverMods", default = true},
			{label = "^7Ring:", property = "searchRingMods", default = true},
			{label = "^7Shield:", property = "searchShieldMods", default = true},
			{label = "^7Staff:", property = "searchStaffMods", default = true},
			{label = "^7Sword:", property = "searchSwordMods", default = true},
			{label = "^7Tincture:", property = "searchTinctureMods", default = true},
			{label = "^7Wand:", property = "searchWandMods", default = true},
		}
	},
}

-- Build a reverse lookup: display item type name -> hierarchy path (e.g., "Ring" -> {"Items", "Accessories", "Ring"})
local ITEM_TYPE_TO_PATH = {}
-- Also build: display item type name -> filter property name (e.g., "Ring" -> "searchRingMods")
local ITEM_TYPE_TO_FILTER = {}
local function buildItemTypePaths(node, pathPrefix)
	local path = {}
	for _, p in ipairs(pathPrefix) do table.insert(path, p) end
	table.insert(path, node.name)

	if node.keys then
		-- Leaf node: map display type names to hierarchy path and filter property
		for _, key in ipairs(node.keys) do
			ITEM_TYPE_TO_PATH[key] = path
			-- Derive filter property from display name: "Sword (1H)" -> "searchSwordMods"
			-- Strip " (1H)" / " (2H)" suffixes, then map to filter property
			local baseName = key:gsub(" %(%dH%)", "")
			-- Map common display names to filter properties
			local filterMap = {
				["Ring"] = "searchRingMods",
				["Amulet"] = "searchAmuletMods",
				["Belt"] = "searchBeltMods",
				["Body Armour"] = "searchBodyArmourMods",
				["Helmet"] = "searchHelmetMods",
				["Gloves"] = "searchGlovesMods",
				["Boots"] = "searchBootsMods",
				["Shield"] = "searchShieldMods",
				["Quiver"] = "searchQuiverMods",
				["Jewel"] = "searchJewelMods",
				["Flask"] = "searchFlaskMods",
				["Fishing Rod"] = "searchFishingMods",
				["Sword"] = "searchSwordMods",
				["Axe"] = "searchAxeMods",
				["Mace"] = "searchMaceMods",
				["Wand"] = "searchWandMods",
				["Sceptre"] = "searchSwordMods",
				["Claw"] = "searchClawMods",
				["Dagger"] = "searchDaggerMods",
				["Rapier"] = "searchSwordMods",
				["Staff"] = "searchStaffMods",
				["Bow"] = "searchBowMods",
			}
			ITEM_TYPE_TO_FILTER[key] = filterMap[baseName] or "searchSwordMods"
		end
	elseif node.children then
		for _, child in ipairs(node.children) do
			buildItemTypePaths(child, path)
		end
	end
end
for _, root in ipairs(ITEM_TYPE_HIERARCHY) do
	buildItemTypePaths(root, {})
end

-- Filter related functions  ============================================================================================================================================================================================

-- Check if a display item type is currently enabled by the item filter checkboxes
local function isItemTypeEnabled(itemType, self)
	local filterProp = ITEM_TYPE_TO_FILTER[itemType]
	if not filterProp then
		return true -- unknown type, show by default
	end
	return self[filterProp] ~= false
end

-- Check if any item filter is enabled
local function anyItemFilterEnabled(self)
	return self.searchRingMods or self.searchAmuletMods or self.searchBeltMods or
		self.searchBodyArmourMods or self.searchBootsMods or self.searchGlovesMods or
		self.searchHelmetMods or self.searchQuiverMods or self.searchShieldMods or
		self.searchFishingMods or self.searchSwordMods or self.searchAxeMods or
		self.searchMaceMods or self.searchWandMods or self.searchStaffMods or
		self.searchBowMods or self.searchDaggerMods or self.searchClawMods or
		self.searchJewelMods or self.searchFlaskMods
end

-- Check if a mod's weightKey matches any enabled item filter
local function modMatchesItemFilters(mod, self)
	if not mod.weightKey then
		return anyItemFilterEnabled(self)
	end
	for _, key in ipairs(mod.weightKey) do
		if key == "default" then
			goto continue
		end
 	-- Look up the filter property(s) for this weightKey
		local info = WEIGHT_KEY_INFO[key]
		if info and info.filter then
			local filterProp = info.filter
			-- filterProp can be a single string or an array of strings (for attribute armor keys)
			if type(filterProp) == "table" then
				-- Array of filter properties (e.g., attribute armor keys)
				for _, prop in ipairs(filterProp) do
					if self[prop] then
						return true
					end
				end
			else
				-- Single filter property (e.g., "ring", "body_armour_crusader")
				if self[filterProp] then
					return true
				end
			end
		end
		::continue::
	end
	return false
end

-- Mod search related functions  ========================================================================================================================================================================================

-- Check if a mod can spawn naturally
local function isNaturalMod(mod)
	if not mod.weightKey or not mod.weightVal then
		return true
	end
	-- Check if any weightKey has a non-zero weight (excluding "default")
	for i, key in ipairs(mod.weightKey) do
		if key ~= "default" and mod.weightVal[i] and mod.weightVal[i] > 0 then
			return true
		end
	end
	return false
end

-- Get the influence type from weightKey
local function getInfluenceType(mod)
	if not mod.weightKey then
		return nil
	end
	for _, key in ipairs(mod.weightKey) do
		if key:match("_shaper$") then return "Shaper" end
		if key:match("_elder$") then return "Elder" end
		if key:match("_crusader$") then return "Crusader" end
		if key:match("_eyrie$") then return "Redeemer" end
		if key:match("_adjudicator$") then return "Warlord" end
		if key:match("_basilisk$") then return "Hunter" end
	end
	return nil
end


local function isElevated(mod)
	if not mod.affix then
		return false
	end
	if mod.affix:match("^Elevated") then return true end
	if mod.affix:match("^of the Elevated") then return true end
	if mod.affix:match("^of Elevated") then return true end
	return false
end

-- Search ModExplicit for mods matching the given group names and filters
local function searchModsInExplicit(groupNames, self)
	-- In ModExplicit.lua, the table structure is:
	-- ["Intelligence1"] = { type = "Suffix", affix = "of the Pupil", "+(8-12) to Intelligence", statOrder = { 1206 }, level = 1, group = "Intelligence", weightKey = { "ring", "amulet", ..., "default", }, weightVal = { 1000, 1000, ..., 0 }, modTags = { "attribute" }, tradeHashes = { [328541901] = { "+(8-12) to Intelligence" }, } },
	local modData = require("Data.ModExplicit")
	local results = {}
	
	-- Build a set of group names for fast lookup
	local groupSet = {}
	for _, g in ipairs(groupNames) do
		groupSet[g] = true
	end
	
	for modId, mod in pairs(modData) do
		-- Check group match
		if not mod.group or not groupSet[mod.group] then
			goto continue
		end
		
		-- Apply item type filters
		if not modMatchesItemFilters(mod, self) then
			goto continue
		end
		
		-- Apply mod source filters
		local natural = isNaturalMod(mod)
		local essence = false -- todo: when searching through the essence lua 
		-- TODO: if we want to add influence filter, or/and elevated filter
		local influenceType = getInfluenceType(mod)
		local elevated = isElevated(mod)
		
		-- A mod passes if:
		-- - It's a natural mod AND searchBase is enabled
		-- - OR it's an essence-only mod AND searchEssence is enabled
		local passesSourceFilter = false
		if natural and self.searchBase then
			passesSourceFilter = true
		end
		if essence and self.searchEssence then
			passesSourceFilter = true
		end
		if elevated then
			passesSourceFilter = true
		end
		if not passesSourceFilter then
			goto continue
		end
		
		-- Store mod info
		local statText = mod[1] or ""
		table.insert(results, {
			id = modId,
			type = mod.type or "N/A",
			affix = mod.affix or "",
			statText = statText,
			group = mod.group,
			level = mod.level or 0,
			weightKey = mod.weightKey,
			weightVal = mod.weightVal,
			modTags = mod.modTags,
			natural = natural,
			influenceType = influenceType,
			isElevated = elevated,
			tradeHashes = mod.tradeHashes,
		})
		
		::continue::
	end
	
	return results
end

-- Collect group names based on selected stat and active filters
local function collectGroupNames(statIndex, self)
	if statIndex <= 1 then
		return {}
	end
	local statEntry = supportedStatsList[statIndex]
	if not statEntry then
		return {}
	end
	local groupNames = {}
	for _, group in ipairs(statEntry.groups) do
		-- Respect Flat/Inc/More filters
		if group.property == "searchFlat" and not self.searchFlat then
			goto continue
		end
		if group.property == "searchInc" and not self.searchInc then
			goto continue
		end
		if group.property == "searchMore" and not self.searchMore then
			goto continue
		end
		for _, name in ipairs(group.names) do
			table.insert(groupNames, name)
		end
		::continue::
	end
	return groupNames
end


-- Displaying results related functions  ================================================================================================================================================================================

-- Derive a merge key from a mod ID by stripping trailing underscores and digits
-- Examples: "Intelligence10" -> "Intelligence", "MaximumLifeUber2" -> "MaximumLifeUber",
--           "PercentageIntelligenceInfluence1_" -> "PercentageIntelligenceInfluence",
--           "IntelligenceEssence7" -> "IntelligenceEssence"
local function getMergeKey(modId)
	-- Strip trailing underscores and digits
	return modId:gsub("[_%d]+_$", ""):gsub("[_%d]+$", "")
end

-- Merge search results by merge key (mod ID with trailing digits/underscores stripped)
-- Groups tiers of the same mod (e.g., Intelligence1-10) into collapsible entries
local function mergeResults(results)
	-- First pass: group by merge key
	local groups = {} -- mergeKey -> { mergedEntry }
	local order = {}  -- preserve insertion order of merge keys
	
	for _, result in ipairs(results) do
		local mergeKey = getMergeKey(result.id)
		
		if not groups[mergeKey] then
			-- Create new merged entry from the first result
			local merged = {
				mergeKey = mergeKey,
				type = result.type,
				group = result.group,
				influenceType = result.influenceType,
				isElevated = result.isElevated,
				natural = result.natural,
				tiers = {},
			}
			groups[mergeKey] = merged
			table.insert(order, mergeKey)
		end
		
		-- Add this result as a tier
		local tier = {
			id = result.id,
			affix = result.affix,
			statText = result.statText,
			level = result.level,
			weightKey = result.weightKey,
			weightVal = result.weightVal,
			modTags = result.modTags,
			natural = result.natural,
			influenceType = result.influenceType,
			isElevated = result.isElevated,
			tradeHashes = result.tradeHashes,
		}
		table.insert(groups[mergeKey].tiers, tier)
	end
	
	-- Sort tiers within each group by level requirement
	for _, merged in ipairs(order) do
		local entry = groups[merged]
		table.sort(entry.tiers, function(a, b)
			return a.level < b.level
		end)
	end
	
	-- Build final ordered list
	local mergedList = {}
	for _, mergeKey in ipairs(order) do
		table.insert(mergedList, groups[mergeKey])
	end
	
	return mergedList
end

-- Class related code ===================================================================================================================================================================================================

---@class StatFinderTab: ControlHost, Control
local StatFinderTabClass = newClass("StatFinderTab", "ControlHost", "Control")

---@param build Build
function StatFinderTabClass:StatFinderTab(build)
	self:ControlHost()
	self:Control()
	
	-- todo: perhaps remove this, currently not using this
	-- Total content height for scroll clamping (populated at end of each Draw* pass)
	self.summaryTotalContentHeight = 0
	self.itemsTotalContentHeight = 0
	self.skillsTotalContentHeight = 0

	-- Selected stat category index (1 = "Select a stat...")
	self.selectedStatIndex = 1
	self.searchResults = {}
	self.mergedResults = {}
	self.groupedResults = {} -- grouped by item type hierarchy
	self.expandedGroups = {} -- mergeKey -> boolean (expanded/collapsed state)
	self.expandedSections = {} -- section path (e.g., "Items|Armour") -> boolean
	
	-- What mod type do we want to match / search for
	self.searchFlat = true
	self.searchInc = true
	self.searchMore = true
	
	-- Searched mod source
	self.searchBase = true
	self.searchCrafted = true
	self.searchCorrupted = true
	self.searchDelve = true
	self.searchEldritch = true
	self.searchEssence = true
	self.searchIncursion = true
	self.searchVeiled = true
	
	-- Item filters
	self.searchItems = true
	self.searchAmuletMods = true
	self.searchAxeMods = true
	self.searchBeltMods = true
	self.searchBodyArmourMods = true
	self.searchBootsMods = true
	self.searchBowMods = true
	self.searchClawMods = true
	self.searchDaggerMods = true
	self.searchFishingMods = true
	self.searchFlaskMods = true
	self.searchGlovesMods = true
	self.searchGraftMods = false
	self.searchHelmetMods = true
	self.searchJewelMods = true
	self.searchMaceMods = true
	self.searchQuiverMods = true
	self.searchRingMods = true
	self.searchShieldMods = true
	self.searchStaffMods = true
	self.searchSwordMods = true
	self.searchTinctureMods = true
	self.searchWandMods = true
	
	-- Other sources
	self.searchBandits = true
	self.searchClusterJewelNotables = true -- TODO: notables only, or do we care about the per node mods as well?
	self.searchFoulborn = true -- TODO: do we want to move this next to the unique - that it can be enabled only when uniques are enabled?
	self.searchPantheon = true
	self.searchTattoos = true
	self.searchTree = true
	self.searchUniques = true
	-- merc? probably very niche stats
	-- necropolis?
	-- scourge?
	-- synthesis?
	-- timeless jewels?
	-- bases flag?

	-- todo: do we want to move some of the logic into a module?
	--[[-- Pre-load static module data
	self.configOptions = require("Modules.ConfigOptions")
	self.calcSections = LoadModule("Modules/CalcSections")
	self.calcs = require("Modules.Calcs")]]

	-- Controls for the stat finder screen
	self:InitControls()
	return self
end

-- UI related functions =================================================================================================================================================================================================

-- Calculates the height for a filter section based on the number of checkboxes
-- Derived from original hardcoded heights: 46 + (numItems * 28)
local function CalculateSectionHeight(numItems)
	return 46 + (numItems * 28)
end

-- Sets the checked state of a CheckBoxControl programmatically
local function SetCheckBoxState(checkbox, state)
	checkbox.state = state
	if checkbox.changeFunc then
		checkbox.changeFunc(state)
	end
end

-- Creates a custom Draw override for a SectionControl with a unique z-layer to prevent border overlap
---@param section SectionControl The section control to modify
---@param subLayer number The z sub-layer for the border draw
---@param borderColor? number[] Optional [r, g, b] for the outer border (default: 0.66, 0.66, 0.66)
---@param insetColor? number[] Optional [r, g, b] for the inner inset (default: 0.1, 0.1, 0.1)
local function SetSectionDrawLayer(section, subLayer, borderColor, insetColor)
	borderColor = borderColor or {0.66, 0.66, 0.66}
	insetColor = insetColor or {0.1, 0.1, 0.1}
	section.Draw = function(inst)
		local x, y = inst:GetPos()
		local width, height = inst:GetSize()
		SetDrawLayer(nil, subLayer)
		SetDrawColor(borderColor[1], borderColor[2], borderColor[3])
		DrawImage(nil, x, y, width, height)
		SetDrawColor(insetColor[1], insetColor[2], insetColor[3])
		DrawImage(nil, x + 2, y + 2, width - 4, height - 4)
		SetDrawLayer(nil, 0)
		local label = inst:GetProperty("label")
		local labelWidth = DrawStringWidth(14, "VAR", label)
		SetDrawColor(borderColor[1], borderColor[2], borderColor[3])
		DrawImage(nil, x + 6, y - 8, labelWidth + 6, 18)
		SetDrawColor(0, 0, 0)
		DrawImage(nil, x + 7, y - 7, labelWidth + 4, 16)
		SetDrawColor(1, 1, 1)
		DrawString(x + 9, y - 6, "LEFT", 14, "VAR", label)
	end
end

-- Creates a filter section with checkboxes and select/deselect buttons from data
---@param host StatFinderTab The parent host (self)
---@param anchorTarget Control The control to anchor this section to
---@param anchorPoint string Anchor point on the section (e.g., "TOPLEFT")
---@param targetAnchorPoint string Anchor point on the target (e.g., "TOPLEFT")
---@param xOffset number X offset from anchor
---@param yOffset number Y offset from anchor
---@param sectionData table Section data from FILTER_SECTIONS
---@param zLayer number Z sub-layer for border drawing
---@return Control section The created SectionControl
---@return table checkboxes Table of created CheckBoxControl instances
local function CreateFilterSection(host, anchorTarget, anchorPoint, targetAnchorPoint, xOffset, yOffset, sectionData, zLayer)
	local numItems = #sectionData.items
	local height = CalculateSectionHeight(numItems)
	local buttonWidth = sectionData.buttonWidth or 80

	-- Create the section control
	local section = new("SectionControl"):SectionControl(
		{anchorPoint, anchorTarget, targetAnchorPoint},
		{xOffset, yOffset, sectionData.width, height},
		sectionData.title
	)
	SetSectionDrawLayer(section, zLayer)

	-- Create checkboxes
	local checkboxes = {}
	local prevControl = section
	for i, item in ipairs(sectionData.items) do
		local isFirst = (i == 1)
		local checkbox = new("CheckBoxControl"):CheckBoxControl(
			{"TOPRIGHT", prevControl, isFirst and "TOPRIGHT" or "BOTTOMRIGHT"},
			{
				isFirst and LAYOUT.topCheckboxHorizontalOffset or 0,
				isFirst and LAYOUT.topCheckboxVerticalOffset or LAYOUT.subCheckboxVerticalOffset,
				LAYOUT.checkboxSize,
				10
			},
			item.label,
			function(state)
				host[item.property] = state
				-- Re-run search if a stat is selected
				if host.selectedStatIndex and host.selectedStatIndex > 1 then
					host:runSearch()
				end
			end,
			nil,
			item.default
		)
		-- Store checkbox in controls with a predictable name
		local controlName = sectionData.title:gsub("%s+", "") .. item.property
		host.controls[controlName] = checkbox
		table.insert(checkboxes, checkbox)
		prevControl = checkbox
	end

	-- Create deselect button anchored to the last checkbox
	local lastCheckbox = checkboxes[#checkboxes]
	local deselectButton = new("ButtonControl"):ButtonControl(
		{"TOPRIGHT", lastCheckbox, "BOTTOMRIGHT"},
		{0, LAYOUT.subCheckboxVerticalOffset, buttonWidth, 20},
		"deselect",
		function()
			for _, checkbox in ipairs(checkboxes) do
				SetCheckBoxState(checkbox, false)
			end
			-- Also update the host properties
			for _, item in ipairs(sectionData.items) do
				host[item.property] = false
			end
			-- Re-run search if a stat is selected
			if host.selectedStatIndex and host.selectedStatIndex > 1 then
				host:runSearch()
			end
		end
	)
	host.controls[sectionData.title:gsub("%s+", "") .. "Deselect"] = deselectButton

	-- Create select button anchored to the deselect button
	local selectButton = new("ButtonControl"):ButtonControl(
		{"TOPRIGHT", deselectButton, "TOPLEFT"},
		{-6, 0, buttonWidth, 20},
		"select",
		function()
			for _, checkbox in ipairs(checkboxes) do
				SetCheckBoxState(checkbox, true)
			end
			-- Also update the host properties
			for _, item in ipairs(sectionData.items) do
				host[item.property] = true
			end
			-- Re-run search if a stat is selected
			if host.selectedStatIndex and host.selectedStatIndex > 1 then
				host:runSearch()
			end
		end
	)
	host.controls[sectionData.title:gsub("%s+", "") .. "Select"] = selectButton

	return section, checkboxes
end

-- Expand a mod's weightKey list to a set of display item type names
local function expandWeightKeysToItemTypes(mod)
	local itemTypeSet = {}
	if not mod.weightKey then
		return itemTypeSet
	end
	-- Check if this is a Maven/Elevated mod (weightVal is all zeros but still has meaningful weightKeys)
	-- These mods can't spawn naturally but should still show their item type
	local isMavenMod = mod.isElevated or false
	for i, key in ipairs(mod.weightKey) do
		if key == "default" then
			goto continue
		end
		-- Skip if weightVal is 0 for this key (mod cannot spawn on this item type)
		-- Exception: Maven/Elevated mods have weightVal = {0} but still have valid item types
		if not isMavenMod and mod.weightVal and mod.weightVal[i] and mod.weightVal[i] == 0 then
			goto continue
		end
		local info = WEIGHT_KEY_INFO[key]
		if info and info.types then
			for _, t in ipairs(info.types) do
				itemTypeSet[t] = true
			end
		end
		::continue::
	end
	return itemTypeSet
end

-- Get variant tags for a mod based on weightKey
local function getVariantTags(mod)
	local tags = {}
	if not mod.weightKey then
		return tags
	end
	for _, key in ipairs(mod.weightKey) do
		local tag = WEIGHT_KEY_VARIANT_TAGS[key]
		if tag then
			table.insert(tags, tag)
		end
	end
	return tags
end

-- todo: now obsolete?
-- Check if a tier can spawn on a specific item type
--local function tierMatchesItemType(tier, itemType)
--	local types = expandWeightKeysToItemTypes(tier)
--	return types[itemType] ~= nil
--end

-- Group merged results by item type hierarchy
-- Returns a table: hierarchyPath -> { mergedEntry, ... }
local function groupResultsByItemType(mergedResults, self)
	-- For each merged result, determine which item types it can appear on
	-- and distribute it into the hierarchy, filtering tiers per item type
	local grouped = {} -- "Items|Armour|Body Armour" -> { mergedEntry, ... }
	
	for _, merged in ipairs(mergedResults) do
		-- Build a map: itemType -> { tiers that can spawn on this item type }
		local itemTypeToTiers = {} -- itemType -> { tier, ... }
		for _, tier in ipairs(merged.tiers) do
			local types = expandWeightKeysToItemTypes(tier)
			for t in pairs(types) do
				if not itemTypeToTiers[t] then
					itemTypeToTiers[t] = {}
				end
				-- Check if this tier is already in the list for this item type
				local alreadyInList = false
				for _, existingTier in ipairs(itemTypeToTiers[t]) do
					if existingTier.id == tier.id then
						alreadyInList = true
						break
					end
				end
				if not alreadyInList then
					table.insert(itemTypeToTiers[t], tier)
				end
			end
		end
		
		-- For each item type, find the hierarchy path and add the merged entry with filtered tiers
		for itemType, tiers in pairs(itemTypeToTiers) do
			if #tiers == 0 then
				goto continue
			end
			-- Skip item types that are disabled by filter checkboxes
			if not isItemTypeEnabled(itemType, self) then
				goto continue
			end
			local path = ITEM_TYPE_TO_PATH[itemType]
			if path then
				-- Find the parent category path (e.g., "Items|Armour" for "Items|Armour|Body Armour")
				local parentPath = ""
				for i = 1, #path - 1 do
					if i > 1 then parentPath = parentPath .. "|" end
					parentPath = parentPath .. path[i]
				end
				
				if not grouped[parentPath] then
					grouped[parentPath] = {}
				end
				
				-- Check if this merged entry is already in this group
				local alreadyAdded = false
				for _, existing in ipairs(grouped[parentPath]) do
					if existing.mergeKey == merged.mergeKey then
						alreadyAdded = true
						break
					end
				end
				if not alreadyAdded then
					-- Create a copy with item-specific tiers (only those that can spawn on this item type)
					local entry = {
						mergeKey = merged.mergeKey,
						type = merged.type,
						group = merged.group,
						influenceType = merged.influenceType,
						isElevated = merged.isElevated,
						natural = merged.natural,
						itemType = itemType,
						tiers = tiers,
					}
					table.insert(grouped[parentPath], entry)
				end
				
				-- Also add to the leaf node
				local leafPath = parentPath
				if parentPath ~= "" then leafPath = parentPath .. "|" end
				leafPath = leafPath .. path[#path]
				
				if not grouped[leafPath] then
					grouped[leafPath] = {}
				end
				
				local alreadyAdded = false
				for _, existing in ipairs(grouped[leafPath]) do
					if existing.mergeKey == merged.mergeKey then
						alreadyAdded = true
						break
					end
				end
				if not alreadyAdded then
					local entry = {
						mergeKey = merged.mergeKey,
						type = merged.type,
						group = merged.group,
						influenceType = merged.influenceType,
						isElevated = merged.isElevated,
						natural = merged.natural,
						itemType = itemType,
						tiers = tiers,
					}
					table.insert(grouped[leafPath], entry)
				end
			end
			::continue::
		end
	end
	
	return grouped
end

-- Run the search with current filters (defined as a method on the class)
function StatFinderTabClass:runSearch()
	if self.selectedStatIndex <= 1 then
		self.searchResults = {}
		self.mergedResults = {}
		self.groupedResults = {}
		self.expandedGroups = {}
		self.expandedSections = {}
		return
	end
	local groupNames = collectGroupNames(self.selectedStatIndex, self)
	if #groupNames == 0 then
		self.searchResults = {}
		self.mergedResults = {}
		self.groupedResults = {}
		self.expandedGroups = {}
		self.expandedSections = {}
		return
	end
	self.searchResults = searchModsInExplicit(groupNames, self)
	self.mergedResults = mergeResults(self.searchResults)
	self.groupedResults = groupResultsByItemType(self.mergedResults, self)
	-- Reset expanded state on new search
	self.expandedGroups = {}
	-- Initialize expanded sections based on hierarchy defaults
	self.expandedSections = {}
	local function initExpandedSections(node, pathPrefix)
		local path = ""
		for i, p in ipairs(pathPrefix) do
			if i > 1 then path = path .. "|" end
			path = path .. p
		end
		if node.expandedByDefault ~= false then
			self.expandedSections[path] = true
		end
		if node.children then
			local fullPath = {}
			for _, p in ipairs(pathPrefix) do table.insert(fullPath, p) end
			table.insert(fullPath, node.name)
			for _, child in ipairs(node.children) do
				initExpandedSections(child, fullPath)
			end
		end
	end
	for _, root in ipairs(ITEM_TYPE_HIERARCHY) do
		initExpandedSections(root, {})
	end
end

function StatFinderTabClass:InitControls()
	-- Title label
	self.controls.titleLabel = new("LabelControl"):LabelControl({"TOPLEFT", self, "TOPLEFT"}, {10, 10, 300, 24}, "^7Select a stat category from the dropdown below to find sources for that stat.")

	-- Stat category dropdown
	self.controls.categoryDropdown = new("DropDownControl"):DropDownControl(
		{"TOPLEFT", self.controls.titleLabel, "BOTTOMLEFT"},
		{0, 10, 200, 20},
		supportedStatsList,
		function(index, value)
			-- Callback when a category is selected
			self.selectedStatIndex = index
			self:runSearch()
		end
	)
	
	-- search settings section
	self.controls.searchSettingsSection = new("SectionControl"):SectionControl({ "TOPLEFT", self.controls.categoryDropdown, "BOTTOMLEFT" }, { 0, 20, LAYOUT.searchSettingsSectionWidth, LAYOUT.searchSettingsSectionHeight }, "^7Search Settings")
	SetSectionDrawLayer(self.controls.searchSettingsSection, -10)
	
	-- Collect all checkbox controls for global select/deselect buttons
	local allCheckboxes = {}
	
	-- TODO: do we want to filter based on implicit/suffix/prefix
	-- mod type filter section (anchored inside search settings section)
	local modTypeSection, modTypeCheckboxes = CreateFilterSection(
		self, self.controls.searchSettingsSection, "TOPLEFT", "TOPLEFT",
		LAYOUT.subSectionHorizontalOffset, LAYOUT.subSectionVerticalOffset,
		FILTER_SECTIONS[1], -9
	)
	self.controls.modTypeFilterSection = modTypeSection
	for _, cb in ipairs(modTypeCheckboxes) do table.insert(allCheckboxes, cb) end
	
	-- mod source filter section (anchored below mod types)
	local modSourceSection, modSourceCheckboxes = CreateFilterSection(
		self, modTypeSection, "TOPLEFT", "BOTTOMLEFT",
		0, LAYOUT.subSectionVerticalOffset,
		FILTER_SECTIONS[2], -9
	)
	self.controls.modSourceFilterSection = modSourceSection
	for _, cb in ipairs(modSourceCheckboxes) do table.insert(allCheckboxes, cb) end
	
	-- other stat source filter section (anchored below mod sources)
	local otherStatSourceSection, otherStatSourceCheckboxes = CreateFilterSection(
		self, modSourceSection, "TOPLEFT", "BOTTOMLEFT",
		0, LAYOUT.subSectionVerticalOffset,
		FILTER_SECTIONS[3], -9
	)
	self.controls.otherStatSourceFilterSection = otherStatSourceSection
	for _, cb in ipairs(otherStatSourceCheckboxes) do table.insert(allCheckboxes, cb) end
	
	-- item filter section (anchored to the right of the left column, inside search settings section)
	local itemSection, itemCheckboxes = CreateFilterSection(
		self, modTypeSection, "TOPLEFT", "TOPRIGHT",
		LAYOUT.subSectionHorizontalOffset, 0,
		FILTER_SECTIONS[4], -9
	)
	self.controls.itemFilterSection = itemSection
	for _, cb in ipairs(itemCheckboxes) do table.insert(allCheckboxes, cb) end
	
	-- Global deselect button (anchored below item filter section)
	self.controls.deselectAllButton = new("ButtonControl"):ButtonControl(
		{"TOPRIGHT", itemSection, "BOTTOMRIGHT"},
		{0, LAYOUT.subCheckboxVerticalOffset, 85, 20},
		"deselect",
		function()
			for _, checkbox in ipairs(allCheckboxes) do
				SetCheckBoxState(checkbox, false)
			end
			-- Re-run search if a stat is selected
			if self.selectedStatIndex and self.selectedStatIndex > 1 then
				self:runSearch()
			end
		end
	)
	
	-- Global select button (anchored to the left of deselect)
	self.controls.selectAllButton = new("ButtonControl"):ButtonControl(
		{"TOPRIGHT", self.controls.deselectAllButton, "TOPLEFT"},
		{-6, 0, 85, 20},
		"select",
		function()
			for _, checkbox in ipairs(allCheckboxes) do
				SetCheckBoxState(checkbox, true)
			end
			-- Re-run search if a stat is selected
			if self.selectedStatIndex and self.selectedStatIndex > 1 then
				self:runSearch()
			end
		end
	)
	
	
	-- Results panel (anchored to the right of the settings section)
	self.controls.resultsPanel = new("SectionControl"):SectionControl(
		{"TOPLEFT", self.controls.searchSettingsSection, "TOPRIGHT"},
		{20, 0, 800, LAYOUT.searchSettingsSectionHeight},
		"^7Search Results"
	)
	SetSectionDrawLayer(self.controls.resultsPanel, -8)

	-- Results area label inside the results panel (placeholder — text updated dynamically)
	self.controls.resultsLabel = new("LabelControl"):LabelControl(
		{"TOPLEFT", self.controls.resultsPanel, "TOPLEFT"},
		{10, 10, 780, 20},
		"^7No stat selected. Choose a category above to begin searching."
	)
end

-- DRAW - Main render method =============================================================================================================================
function StatFinderTabClass:Draw(viewPort, inputEvents)
	self.x = viewPort.x
	self.y = viewPort.y
	self.width = viewPort.width
	self.height = viewPort.height

	self:ProcessControlsInput(inputEvents, viewPort)

	main:DrawBackground(viewPort)
	
	-- Update results display
	local resultsPanel = self.controls.resultsPanel
	local resultsLabel = self.controls.resultsLabel

	if self.selectedStatIndex and self.selectedStatIndex > 1 then
		-- A stat is selected — show results
		local statEntry = supportedStatsList[self.selectedStatIndex]
		local statName = statEntry and statEntry.label or "Unknown"
		local mergedCount = #self.mergedResults
		
		if mergedCount == 0 then
			-- No results found for the selected stat
			resultsLabel.label = "^7Found 0 mods for ^2" .. statName .. "^7."
		else
			-- Results found — show merged count and total tier count
			local totalTiers = 0
			for _, merged in ipairs(self.mergedResults) do
				totalTiers = totalTiers + #merged.tiers
			end
			resultsLabel.label = "^7Found ^2" .. mergedCount .. "^7 mod group(s) (^2" .. totalTiers .. "^7 tiers) for ^2" .. statName .. "^7."
			
			-- Draw hierarchical results tree
			local panelX, panelY = resultsPanel:GetPos()
			local labelX, labelY = resultsLabel:GetPos()
			local xPos = panelX + 10
			local yPos = labelY + 25
			
			-- Track y positions for click handling
			local clickTargets = {} -- {yStart, yEnd, type, data}
			
			-- Helper: draw a mod entry (single or multi-tier)
			local function drawModEntry(merged, indent)
				local indentStr = string.rep("  ", indent)
				local yStart = yPos
				
				-- Build composite key for expand/collapse state (independent per item type)
				local expandKey = (merged.itemType or "") .. "|" .. merged.mergeKey
				
				if #merged.tiers == 1 then
					-- Single-tier mod: display directly
					local tier = merged.tiers[1]
					local modLine = string.format(
						"%s^6%s^7 | ^3%s^7 | ^1%s^7 | ilvl %d^7 | %s",
						indentStr,
						tier.id,
						merged.type or "N/A",
						tier.affix or "",
						tier.level or 0,
						tier.statText or ""
					)
					if merged.influenceType then
						modLine = modLine .. string.format(" ^9[%s Influence]^7", merged.influenceType)
						if merged.isElevated then
							modLine = modLine .. " ^9[Elevated]^7"
						end
					elseif not merged.natural then
						modLine = modLine .. " ^9[Essence-only]^7"
					end
					DrawString(xPos, yPos, "LEFT", 13, "VAR", modLine)
					yPos = yPos + 18
				else
					-- Multi-tier mod: collapsible header
					local isExpanded = self.expandedGroups[expandKey]
					local expandIcon = isExpanded and "[-]" or "[+]"
					
					local headerLine = string.format(
						"%s^2%s^7 ^6%s^7 | ^3%s^7 | %d tier(s)",
						indentStr,
						expandIcon,
						merged.mergeKey,
						merged.type or "N/A",
						#merged.tiers
					)
					if merged.influenceType then
						headerLine = headerLine .. string.format(" ^9[%s Influence]^7", merged.influenceType)
						if merged.isElevated then
							headerLine = headerLine .. " ^9[Elevated]^7"
						end
					elseif not merged.natural then
						headerLine = headerLine .. " ^9[Essence-only]^7"
					end
					--if merged.tiers[1] and merged.tiers[1].statText then
					--	headerLine = headerLine .. " | ^7" .. merged.tiers[1].statText
					--end
					
					DrawString(xPos, yPos, "LEFT", 13, "VAR", headerLine)
					table.insert(clickTargets, {yStart = yPos, yEnd = yPos + 18, type = "mod", data = merged})
					yPos = yPos + 18
					
					if isExpanded then
						for j, tier in ipairs(merged.tiers) do
							if yPos > viewPort.y + viewPort.height then
								break
							end
							local tierLine = string.format(
								"%s    ^5%s^7 | ilvl %d^7 | %s",
								indentStr,
								tier.id,
								tier.level or 0,
								tier.statText or ""
							)
							-- Add variant tags
							local variantTags = getVariantTags(tier)
							for _, tag in ipairs(variantTags) do
								tierLine = tierLine .. string.format(" ^9[%s]^7", tag)
							end
							DrawString(xPos, yPos, "LEFT", 12, "VAR", tierLine)
							yPos = yPos + 16
						end
					end
				end
				
				return yPos - yStart
			end
			
			-- Helper: recursively draw hierarchy nodes
			local function drawHierarchyNode(node, pathPrefix, indent)
				local path = ""
				for i, p in ipairs(pathPrefix) do
					if i > 1 then path = path .. "|" end
					path = path .. p
				end
				if path ~= "" then path = path .. "|" end
				path = path .. node.name
				
				local indentStr = string.rep("  ", indent)
				
				if node.keys then
					-- Leaf node: draw mods for this item type
					local entries = self.groupedResults[path]
					if entries and #entries > 0 then
						-- Draw leaf header
						local yStart = yPos
						local isExpanded = self.expandedSections[path]
						local expandIcon = isExpanded and "[-]" or "[+]"
						local leafLine = string.format(
							"%s^2%s^7 ^4%s^7 (%d mod(s))",
							indentStr,
							expandIcon,
							node.name,
							#entries
						)
						DrawString(xPos, yPos, "LEFT", 13, "VAR", leafLine)
						table.insert(clickTargets, {yStart = yPos, yEnd = yPos + 18, type = "section", data = path})
						yPos = yPos + 18
						
						if isExpanded then
							for _, entry in ipairs(entries) do
								if yPos > viewPort.y + viewPort.height then
									break
								end
								drawModEntry(entry, indent + 1)
							end
						end
					end
				elseif node.children then
					-- Category node: draw header and recurse
					local hasContent = false
					local contentCount = 0
					local function countContent(childNode, childPathPrefix)
						local childPath = ""
						for i, p in ipairs(childPathPrefix) do
							if i > 1 then childPath = childPath .. "|" end
							childPath = childPath .. p
						end
						if childPath ~= "" then childPath = childPath .. "|" end
						childPath = childPath .. childNode.name
						
						if childNode.keys then
							local entries = self.groupedResults[childPath]
							if entries and #entries > 0 then
								hasContent = true
								contentCount = contentCount + #entries
							end
						elseif childNode.children then
							local fullPath = {}
							for _, p in ipairs(childPathPrefix) do table.insert(fullPath, p) end
							table.insert(fullPath, childNode.name)
							for _, grandchild in ipairs(childNode.children) do
								countContent(grandchild, fullPath)
							end
						end
					end
					
					local fullPath = {}
					for _, p in ipairs(pathPrefix) do table.insert(fullPath, p) end
					table.insert(fullPath, node.name)
					for _, child in ipairs(node.children) do
						countContent(child, fullPath)
					end
					
					if hasContent then
						local yStart = yPos
						local isExpanded = self.expandedSections[path]
						local expandIcon = isExpanded and "[-]" or "[+]"
						local catLine = string.format(
							"%s^2%s^7 ^1%s^7 (%d mod(s))",
							indentStr,
							expandIcon,
							node.name,
							contentCount
						)
						DrawString(xPos, yPos, "LEFT", 13, "VAR", catLine)
						table.insert(clickTargets, {yStart = yPos, yEnd = yPos + 18, type = "section", data = path})
						yPos = yPos + 18
						
						if isExpanded then
							for _, child in ipairs(node.children) do
								if yPos > viewPort.y + viewPort.height then
									break
								end
								drawHierarchyNode(child, fullPath, indent + 1)
							end
						end
					end
				end
			end
			
			-- Draw the hierarchy tree
			for _, root in ipairs(ITEM_TYPE_HIERARCHY) do
				if yPos > viewPort.y + viewPort.height then
					break
				end
				drawHierarchyNode(root, {}, 0)
			end
			
			-- Handle click events for expand/collapse toggles
			if inputEvents then
				for id, event in ipairs(inputEvents) do
					if event.type == "KeyDown" and event.key == "LEFTBUTTON" then
						local cursorX, cursorY = GetCursorPos()
						if cursorX >= xPos and cursorX <= xPos + 780 then
							for _, target in ipairs(clickTargets) do
								if cursorY >= target.yStart and cursorY <= target.yEnd then
									if target.type == "section" then
										self.expandedSections[target.data] = not self.expandedSections[target.data]
									elseif target.type == "mod" then
										local expandKey = (target.data.itemType or "") .. "|" .. target.data.mergeKey
										self.expandedGroups[expandKey] = not self.expandedGroups[expandKey]
									end
									inputEvents[id] = nil
									break
								end
							end
						end
					end
				end
			end
		end
	else
		-- Default "Select a stat..." — no results to show
		resultsLabel.label = "^7No stat selected. Choose a category above to begin searching."
	end

	self:DrawControls(viewPort)
end

return StatFinderTabClass
