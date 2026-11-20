-- Path of Building
--
-- Module: Stat Finder Tab
-- Allows user to search stat mod sources
--

---@enum (key) ItemBaseType
local ItemBaseType = {
	AMULET = 1,
	AXE = 2,
	BELT = 3,
	BODY_ARMOUR= 4,
	BOOTS = 5,
	BOW = 6,
	CLAW = 7,
	DAGGER = 8,
	FISHING_ROD = 9,
	GLOVES = 10,
	HELMET = 11,
	MACE = 12,
	QUIVER = 13,
	RING = 14,
	SCEPTRE = 15,
	SHIELD = 16,
	STAFF = 17,
	SWORD = 18,
	WAND = 19,
}

---@enum (key) TierTags
local TierTags = {
	DEX_BASE = 1,
	INT_BASE = 2,
	STR_BASE = 3,
	STR_INT_BASE = 4,
	STR_DEX_BASE = 5,
	STR_DEX_INT_BASE = 6,
	DEX_INT_BASE = 7,
	WARD_BASE = 8,
	ELEVATED = 9,
	ESSENCE = 10,
	ESSENCE_ONLY = 11,
	DELVE = 12,
	CRUSADER = 13,
	ELDER = 14,
	HUNTER = 15,
	REDEEMER = 16,
	SHAPER = 17,
	WARLORD = 18,
	RUNE_DAGGER = 19,
	NON_RUNE_DAGGER = 20,
	WARSTAFF = 21,
	NON_WARSTAFF = 22,
	RAPIER = 23,
	MINION_RING = 24,
	MINION_WAND = 25,
	MINION_SHIELD = 26,
	ATTACK_WAND = 27, -- todo not using this now
	ONE_HANDED = 28,
	TWO_HANDED = 29,
	FOCUS = 30,
	NON_FOCUS = 31,
	UNSET_RING = 32,
	DEX_SHIELD = 33,
	STR_SHIELD = 34,
	STR_DEX_SHIELD = 35,
	DEX_INT_SHIELD = 36,
	STR_INT_SHIELD = 37
}
local function sharedTagLogic(_, _, possibleTags, tags)
	if possibleTags[TierTags.ELEVATED] and possibleTags[TierTags.ELEVATED] == true then
		table.insert(tags, TierTags.ELEVATED)
	end
	if possibleTags[TierTags.ESSENCE_ONLY] and possibleTags[TierTags.ESSENCE_ONLY] == true then
		table.insert(tags, TierTags.ESSENCE_ONLY)
	end
	if possibleTags[TierTags.CRUSADER] and possibleTags[TierTags.CRUSADER] == true then
		table.insert(tags, TierTags.CRUSADER)
	elseif possibleTags[TierTags.ELDER] and possibleTags[TierTags.ELDER] == true then
		table.insert(tags, TierTags.ELDER)
	elseif possibleTags[TierTags.HUNTER] and possibleTags[TierTags.HUNTER] == true then
		table.insert(tags, TierTags.HUNTER)
	elseif possibleTags[TierTags.REDEEMER] and possibleTags[TierTags.REDEEMER] == true then
		table.insert(tags, TierTags.REDEEMER)
	elseif possibleTags[TierTags.SHAPER] and possibleTags[TierTags.SHAPER] == true then
		table.insert(tags, TierTags.SHAPER)
	elseif possibleTags[TierTags.WARLORD] and possibleTags[TierTags.WARLORD] == true then
		table.insert(tags, TierTags.WARLORD)
	end
end

local function armourTags(weightKeys, weightVals, possibleTags, tags, currentWeightKey)
	sharedTagLogic(weightKeys, weightVals, possibleTags, tags)
	
	for i, weightKey in weightKeys do
		if weightKey == currentWeightKey and weightVals[i] == 0 then
			return -- means that the armour item type has weight val = 0, was removed from the dex/int/str base set
		end
	end
	
	if possibleTags[TierTags.DEX_BASE] and possibleTags[TierTags.DEX_BASE] == true then
		table.insert(tags, TierTags.DEX_BASE)
	end
	if possibleTags[TierTags.INT_BASE] and possibleTags[TierTags.INT_BASE] == true then
		table.insert(tags, TierTags.INT_BASE)
	end
	if possibleTags[TierTags.STR_BASE] and possibleTags[TierTags.STR_BASE] == true then
		table.insert(tags, TierTags.STR_BASE)
	end
	if possibleTags[TierTags.DEX_INT_BASE] and possibleTags[TierTags.DEX_INT_BASE] == true then
		table.insert(tags, TierTags.DEX_INT_BASE)
	end
	if possibleTags[TierTags.STR_DEX_BASE] and possibleTags[TierTags.STR_DEX_BASE] == true then
		table.insert(tags, TierTags.STR_DEX_BASE)
	end
	if possibleTags[TierTags.STR_INT_BASE] and possibleTags[TierTags.STR_INT_BASE] == true then
		table.insert(tags, TierTags.STR_INT_BASE)
	end
	if possibleTags[TierTags.STR_DEX_INT_BASE] and possibleTags[TierTags.STR_DEX_INT_BASE] == true then
		table.insert(tags, TierTags.STR_DEX_INT_BASE)
	end
	if possibleTags[TierTags.WARD_BASE] and possibleTags[TierTags.WARD_BASE] == true then
		table.insert(tags, TierTags.WARD_BASE)
	end
end

local function twoOrOneHandResolver(weightKeys, weightVals, possibleTags, tags, oneHandPattern, twoHandPattern)
	-- first we check, if the item is influenced
	if (possibleTags.INFLUENCED and possibleTags.INFLUENCED == true) then
		local one_hand_index
		local two_hand_index
		for i, weightKey in ipairs(weightKeys) do
			if weightKey:match(oneHandPattern) then one_hand_index = i
			elseif weightKey:match(twoHandPattern) then two_hand_index = i end
		end
		-- for elevated mods, the weightVals are always zero, so they are perceived in a way, that it means it can spawn on that variant
		if(possibleTags.ELEVATED or possibleTags.ELEVATED == true) then
			if one_hand_index and two_hand_index then
				return	-- means that the mod can spawn on all weapon variants
			end
			if one_hand_index then table.insert(tags, TierTags.ONE_HANDED)
			elseif two_hand_index then table.insert(tags,TierTags.ONE_HANDED) end
		else -- for non-elevated mods, we check the vals, here val = 0 is perceived in the same way as "the weightKeys is missing completely"
			local one_hand_weight
			local two_hand_weight
			if one_hand_index then one_hand_weight = weightVals[one_hand_index] end
			if two_hand_index then two_hand_weight = weightVals[two_hand_index] end
			if two_hand_weight and two_hand_weight > 0 then
				if one_hand_weight and one_hand_weight > 0 then
					return
				else
					table.insert(tags, TierTags.TWO_HANDED)
				end
			end
			if one_hand_weight and one_hand_weight > 0 then
				table.insert(tags, TierTags.ONE_HANDED)
			end
		end
		return
	end
	-- other than influence only the one_hand_weapon and two_hand_weapon weightKeys can result in the ONE/TWO_HANDED possibleTags, in negative or positive way, but should not get both at the same time
	if (possibleTags.ONE_HANDED and possibleTags.ONE_HANDED == true) then table.insert(tags, TierTags.ONE_HANDED)
	elseif (possibleTags.TWO_HANDED and possibleTags.TWO_HANDED == true) then table.insert(tags, TierTags.TWO_HANDED) end
end

local ITEM_TYPE_TAG_HANDLERS = {
	[ItemBaseType.AMULET] = sharedTagLogic,
	[ItemBaseType.AXE] = function(weightKeys, weightVals, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, possibleTags, tags)
		twoOrOneHandResolver(weightKeys, weightVals, possibleTags, tags, "^axe_", "^2h_axe_")
	end,
	[ItemBaseType.BODY_ARMOUR] = function(weightKeys, weightVals, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, possibleTags, tags)
		armourTags(weightKeys, weightVals, possibleTags, tags, "body_armour")
	end,
	[ItemBaseType.BOOTS] = function(weightKeys, weightVals, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, possibleTags, tags)
		armourTags(weightKeys, weightVals, possibleTags, tags, "boots")
	end,
	[ItemBaseType.GLOVES] = function(weightKeys, weightVals, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, possibleTags, tags)
		armourTags(weightKeys, weightVals, possibleTags, tags, "gloves")
	end,
	[ItemBaseType.HELMET] = function(weightKeys, weightVals, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, possibleTags, tags)
		armourTags(weightKeys, weightVals, possibleTags, tags, "helmet")
	end,
	[ItemBaseType.BELT] = sharedTagLogic,
	[ItemBaseType.BOW] = sharedTagLogic,
	[ItemBaseType.CLAW] = sharedTagLogic,
	[ItemBaseType.DAGGER] = function(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		-- for DAGGER we check dagger / rune dagger / non rune dagger
		if (possibleTags.INFLUENCED and possibleTags.INFLUENCED == true) then
			local dagger_index
			local rune_dagger_index
			for i, weightKey in ipairs(weightKeys) do
				if weightKey:match("^dagger_") then dagger_index = i
				elseif weightKey:match("^rune_dagger_") then rune_dagger_index = i end
			end
			if(possibleTags.ELEVATED or possibleTags.ELEVATED == true) then
				if dagger_index and rune_dagger_index then
					return	-- means, that the mod can spawn on all daggers
				end
				if dagger_index then table.insert(tags, TierTags.NON_RUNE_DAGGER)
				elseif rune_dagger_index then table.insert(tags,TierTags.RUNE_DAGGER) end
			else
				local dagger_weight
				local rune_dagger_weight
				if dagger_index then dagger_weight = weightVals[dagger_index] end
				if rune_dagger_index then rune_dagger_weight = weightVals[rune_dagger_index] end
				if rune_dagger_weight and rune_dagger_weight > 0 then
					if dagger_weight and dagger_weight > 0 then
						return -- means, that the mod can spawn on all daggers
					else
						table.insert(tags, TierTags.RUNE_DAGGER)
					end
				end
				if dagger_weight and dagger_weight > 0 then
					table.insert(tags, TierTags.NON_RUNE_DAGGER)
				end
			end
			return
		end
		-- other than influence we work with attack_dagger and dagger_weight key
		local dagger_index
		for i, weightKey in ipairs(weightKeys) do
			if weightKey:match("^dagger") then dagger_index = i end
		end
		local dagger_weight
		if dagger_index then dagger_weight = weightVals[dagger_index] end
		if dagger_weight and dagger_weight > 0 then	-- weightKeys contain dagger with positive weight
			if possibleTags.RUNE_DAGGER and possibleTags.RUNE_DAGGER == true then table.insert(tags, TierTags.RUNE_DAGGER) end -- weightKeys contain attack_dagger with weight == 0
			-- otherwise weightKeys either contain attack_dagger with non zero value or don't contain it at all, in both cases mod can spawn on all daggers
		else -- weightKeys either don't contain dagger weightKey or its value is zero
			if possibleTags.NON_RUNE_DAGGER and possibleTags.NON_RUNE_DAGGER == true then table.insert(tags, TierTags.NON_RUNE_DAGGER) end -- weightKeys contain attack_dagger with weight > 1
			-- otherwise neither attack_dagger or dagger weightKeys are present, in which case there was something like one_hand_weapon or weapon weight key and mod can spawn on all daggers
			-- the use-case when both attack_dagger and dagger weightKeys are present but have 0 values, would result in mod cannot be on dagger at all -> we would not get here in the first place
		end
	end, 
	[ItemBaseType.FISHING_ROD] = sharedTagLogic,
	[ItemBaseType.MACE] = function(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		twoOrOneHandResolver(weightKeys, weightVals, possibleTags, tags, "^mace_", "^2h_mace_")
	end,
	[ItemBaseType.QUIVER] = sharedTagLogic,
	[ItemBaseType.RING] = function(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		-- both variants only on mods, which cannot otherwise spawn on ring -> currently no checking regarding that, could change in the future, but I doubt it
		if possibleTags.UNSET_RING and possibleTags.UNSET_RING == true then table.insert(tags, TierTags.UNSET_RING) end
		if possibleTags.MINION_RING and possibleTags.MINION_RING == true then table.insert(tags, TierTags.MINION_RING) end
	end,
	[ItemBaseType.SCEPTRE] = sharedTagLogic,
	[ItemBaseType.SHIELD] = function(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		
		local shieldRemoved = false
		for i, weightKey in weightKeys do
			if weightKey == "shield" and weightVals[i] == 0 then
				shieldRemoved = true
			end
		end
		
		if (possibleTags[TierTags.DEX_BASE] and possibleTags[TierTags.DEX_BASE] == true and not shieldRemoved) or
			(possibleTags[TierTags.DEX_SHIELD] and possibleTags[TierTags.DEX_SHIELD] == true) then
			table.insert(tags, TierTags.DEX_BASE)
		end
		if (possibleTags[TierTags.INT_BASE] and possibleTags[TierTags.INT_BASE] == true and not shieldRemoved) or
			(possibleTags[TierTags.FOCUS] and possibleTags[TierTags.FOCUS] == true) then
			table.insert(tags, TierTags.INT_BASE)
		end
		if (possibleTags[TierTags.STR_BASE] and possibleTags[TierTags.STR_BASE] == true and not shieldRemoved) or
			(possibleTags[TierTags.STR_SHIELD] and possibleTags[TierTags.STR_SHIELD] == true) then
			table.insert(tags, TierTags.STR_BASE)
		end
		if (possibleTags[TierTags.DEX_INT_BASE] and possibleTags[TierTags.DEX_INT_BASE] == true and not shieldRemoved) or
			(possibleTags[TierTags.DEX_INT_SHIELD] and possibleTags[TierTags.DEX_INT_SHIELD] == true) then
			table.insert(tags, TierTags.DEX_INT_BASE)
		end
		if (possibleTags[TierTags.STR_DEX_BASE] and possibleTags[TierTags.STR_DEX_BASE] == true and not shieldRemoved) or
			(possibleTags[TierTags.STR_DEX_SHIELD] and possibleTags[TierTags.STR_DEX_SHIELD] == true) then
			table.insert(tags, TierTags.STR_DEX_BASE)
		end
		if (possibleTags[TierTags.STR_INT_BASE] and possibleTags[TierTags.STR_INT_BASE] == true and not shieldRemoved) or
			(possibleTags[TierTags.STR_INT_SHIELD] and possibleTags[TierTags.STR_INT_SHIELD] == true) then
			table.insert(tags, TierTags.STR_INT_BASE)
		end
		if possibleTags[TierTags.NON_FOCUS] and possibleTags[TierTags.NON_FOCUS] == true then
			table.insert(tags, TierTags.DEX_BASE)
			table.insert(tags, TierTags.STR_BASE)
			table.insert(tags, TierTags.STR_DEX_BASE)
			table.insert(tags, TierTags.DEX_INT_BASE)
			table.insert(tags, TierTags.STR_INT_BASE)
		end
		if possibleTags[TierTags.MINION_SHIELD] and possibleTags[TierTags.MINION_SHIELD] == true then
			table.insert(tags, TierTags.MINION_SHIELD)
		end
	end,
	[ItemBaseType.STAFF] = function(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		-- for STAVES we check warstaff / staff
		if (possibleTags.INFLUENCED and possibleTags.INFLUENCED == true) then
			local staff_index
			local warstaff_index
			local attack_staff_index
			for i, weightKey in ipairs(weightKeys) do
				if weightKey:match("^staff_") then staff_index = i
				elseif weightKey:match("^warstaff_") then warstaff_index = i
				elseif weightKey:match("^attack_staff") then attack_staff_index = i end
			end
			if(possibleTags.ELEVATED or possibleTags.ELEVATED == true) then
				if staff_index and warstaff_index then
					return	-- means, that the mod can spawn on all staves
				end
				if staff_index then table.insert(tags, TierTags.NON_WARSTAFF)
				elseif warstaff_index then table.insert(tags,TierTags.WARSTAFF) end
			else
				local staff_weight
				local warstaff_weight
				local attack_staff_weight
				if staff_index then staff_weight = weightVals[staff_index] end
				if warstaff_index then warstaff_weight = weightVals[warstaff_index] end
				if attack_staff_index then warstaff_weight = weightVals[warstaff_index] end
				if warstaff_weight and warstaff_weight > 0 then
					if staff_weight and staff_weight > 0 then
						if attack_staff_weight and attack_staff_weight == 0 then
							table.insert(tags, TierTags.NON_WARSTAFF)
						end
						-- else mod can spawn on all staves
					end
					table.insert(tags, TierTags.WARSTAFF)
				else
					if staff_weight and staff_weight > 0 then
						table.insert(tags, TierTags.NON_WARSTAFF)
					end
				end
			end
			return
		end
		-- other than influence we work with attack_dagger and dagger_weight key
		local staff_index
		for i, weightKey in ipairs(weightKeys) do
			if weightKey:match("^staff") then staff_index = i end
		end
		local staff_weight
		if staff_index then staff_weight = weightVals[staff_index] end
		if staff_weight and staff_weight > 0 then	-- weightKeys contain staff with positive weight
			if possibleTags.NON_WARSTAFF and possibleTags.NON_WARSTAFF == true then table.insert(tags, TierTags.NON_WARSTAFF) end -- weightKeys contain warstaff or attack_staff with weight == 0
			-- otherwise weightKeys either contain warstaff or attack_staff with non zero value or don't contain them at all, in both cases mod can spawn on all staves
		else -- weightKeys either don't contain staff weightKey or its value is zero
			if possibleTags.WARSTAFF and possibleTags.WARSTAFF == true then table.insert(tags, TierTags.WARSTAFF) end -- weightKeys contain warstaff or attack_staff with weight > 1
			-- otherwise neither warstaff, attack_staff or staff weightKeys are present, in which case there was something like one_hand_weapon or weapon weight key and mod can spawn on all staves
			-- currently not caring about the situation when there is both attack_staff and warstaff in the weightKeys (especially if one val > 0, second == 0), as the situation is not present in the data
		end
	end,
	[ItemBaseType.SWORD] = function(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		-- rapier weightKey is currently only in 31 mods, always positive weightVal, always sword has also positive val and two_hand_weapon has 0 value, the weightKey has no influence versions
		-- will view as subset of 1h sword
		twoOrOneHandResolver(weightKeys, weightVals, possibleTags, tags, "^sword_", "^2h_sword_")
		
	end,
	[ItemBaseType.WAND] = function(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		sharedTagLogic(weightKeys, weightVals, itemBaseType, possibleTags, tags)
		-- only on mods, which cannot otherwise spawn on wand -> currently no checking regarding that, could change in the future, but I doubt it
		if possibleTags.MINION_WAND and possibleTags.MINION_WAND == true then table.insert(tags, TierTags.MINION_WAND) end
	end,
}

-- we have: TierTags -> boolean
-- we want: ItemBaseType -> {TierTags} for each tier...
-- ItemBaseType -> boolean
function ModClass.processPossibleTags(weightKeys, weightVals, itemBaseTypes, possibleTags)
	local typeTagMap = {}
	for i, key in ipairs(itemBaseTypes) do
		local tags = {}
		if key == true then
			local handler = ITEM_TYPE_TAG_HANDLERS[i]
			if handler then
				handler(weightKeys, weightVals, i, possibleTags, tags)
			end
		end
		
		typeTagMap[i] = tags
	end
	return typeTagMap
end


local WEIGHT_KEY_INFO = {
	-- SETS
	["default"] = {priority = 1,
				   adds = {ItemBaseType.AMULET, ItemBaseType.AXE, ItemBaseType.BELT, ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.BOW, ItemBaseType.CLAW,
						   ItemBaseType.DAGGER, ItemBaseType.FISHING_ROD, ItemBaseType.FLASK, ItemBaseType.GLOVES, ItemBaseType.HELMET, ItemBaseType.JEWEL, ItemBaseType.MACE,
						   ItemBaseType.QUIVER, ItemBaseType.RING, ItemBaseType.SCEPTRE, ItemBaseType.SHIELD, ItemBaseType.STAFF, ItemBaseType.SWORD, ItemBaseType.WAND},
				   removes = {}, tagsPositive = {}, tagsNegative = {}},
	["armour"] = {priority = 2,
				  adds = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET, ItemBaseType.SHIELD},
				  removes = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET, ItemBaseType.SHIELD},
				  tagsPositive = {}, tagsNegative = {}},
	["weapon"] = {priority = 2,
				  adds = {ItemBaseType.AXE, ItemBaseType.BOW, ItemBaseType.CLAW, ItemBaseType.DAGGER, ItemBaseType.MACE, ItemBaseType.SCEPTRE, ItemBaseType.STAFF, ItemBaseType.SWORD, ItemBaseType.WAND},
				  removes = {ItemBaseType.AXE, ItemBaseType.BOW, ItemBaseType.CLAW, ItemBaseType.DAGGER, ItemBaseType.MACE, ItemBaseType.SCEPTRE, ItemBaseType.STAFF, ItemBaseType.SWORD, ItemBaseType.WAND},
				  tagsPositive = {}, tagsNegative = {}},
	["one_hand_weapon"] = {priority = 3,
						   adds = {ItemBaseType.AXE, ItemBaseType.CLAW, ItemBaseType.DAGGER, ItemBaseType.MACE, ItemBaseType.SCEPTRE, ItemBaseType.SWORD, ItemBaseType.WAND},
						   removes = {ItemBaseType.CLAW, ItemBaseType.DAGGER, ItemBaseType.SCEPTRE, ItemBaseType.WAND},
						   tagsPositive = {TierTags.ONE_HANDED}, tagsNegative = {TierTags.TWO_HANDED}},
	["two_hand_weapon"] = {priority = 3,
						   adds = {ItemBaseType.AXE, ItemBaseType.BOW, ItemBaseType.MACE, ItemBaseType.STAFF, ItemBaseType.SWORD},
						   removes = {ItemBaseType.BOW, ItemBaseType.STAFF},
						   tagsPositive = {TierTags.TWO_HANDED}, tagsNegative = {TierTags.ONE_HANDED}},
	["ranged"] = {priority = 4,
				  adds = {ItemBaseType.BOW, ItemBaseType.WAND},
				  removes = {ItemBaseType.BOW, ItemBaseType.WAND}, tagsPositive = {}, tagsNegative = {}},
	-- Accessories
	["amulet"] = {priority = 3,
				  adds = {ItemBaseType.AMULET},
				  removes = {ItemBaseType.AMULET}, tagsPositive = {}, tagsNegative = {}},
	["belt"] = {priority = 3,
				adds = {ItemBaseType.BELT},
				removes = {ItemBaseType.BELT}, tagsPositive = {}, tagsNegative = {}},
	["ring"] = {priority = 3, 
				adds = {ItemBaseType.RING},
				removes = {ItemBaseType.RING}, tagsPositive = {}, tagsNegative = {}},
	-- Armour slots
	["body_armour"] = {priority = 3,
					   adds = {ItemBaseType.BODY_ARMOUR},
					   removes = {ItemBaseType.BODY_ARMOUR}, tagsPositive = {}, tagsNegative = {}},
	["boots"] = {priority = 3,
				 adds = {ItemBaseType.BOOTS},
				 removes = {ItemBaseType.BOOTS}, tagsPositive = {}, tagsNegative = {}},
	["gloves"] = {priority = 3,
				  adds = {ItemBaseType.GLOVES},
				  removes = {ItemBaseType.GLOVES}, tagsPositive = {}, tagsNegative = {}},
	["helmet"] = {priority = 3, adds = {ItemBaseType.HELMET},
				  removes = {ItemBaseType.HELMET}, tagsPositive = {}, tagsNegative = {}},
	-- Attribute-based armour (applies to all 4 armor slots)
	["dex_armour"] = {priority = 4,
					  adds = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET, ItemBaseType.SHIELD},
					  removes = {}, tagsPositive = {TierTags.DEX_BASE}, tagsNegative = {}},
	["int_armour"] = {priority = 4,
					  adds = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET, ItemBaseType.SHIELD},
					  removes = {}, tagsPositive = {TierTags.INT_BASE}, tagsNegative = {}},
	["str_armour"] = {priority = 4,
					  adds = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET, ItemBaseType.SHIELD},
					  removes = {}, tagsPositive = {TierTags.STR_BASE}, tagsNegative = {}},
	["dex_int_armour"] = {priority = 4,
						  adds = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET, ItemBaseType.SHIELD},
						  removes = {}, tagsPositive = {TierTags.DEX_INT_BASE}, tagsNegative = {}},
	["str_dex_armour"] = {priority = 4,
						  adds = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET, ItemBaseType.SHIELD},
						  removes = {}, tagsPositive = {TierTags.STR_DEX_BASE}, tagsNegative = {}},
	["str_int_armour"] = {priority = 4,
						  adds = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET, ItemBaseType.SHIELD},
						  removes = {}, tagsPositive = {TierTags.STR_INT_BASE}, tagsNegative = {}},
	["str_dex_int_armour"] = {priority = 4,
							  adds = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET}, -- there is no str/dex/int shield base
							  removes = {}, tagsPositive = {TierTags.STR_DEX_INT_BASE}, tagsNegative = {}},
	["ward_armour"] = {priority = 4,
					   adds = {ItemBaseType.BODY_ARMOUR, ItemBaseType.BOOTS, ItemBaseType.GLOVES, ItemBaseType.HELMET},
					   removes = {}, tagsPositive = {TierTags.WARD_BASE}, tagsNegative = {}},
	["dex_shield"] = {priority = 6,	-- all shield attribute specific bases are subset of all shield bases, that is why we give priority = 6 = lower than shield
					  adds = {ItemBaseType.SHIELD},
					  removes = {}, tagsPositive = {TierTags.DEX_SHIELD}, tagsNegative = {}},
	["str_shield"] = {priority = 6,
					  adds = {ItemBaseType.SHIELD},
					  removes = {}, tagsPositive = {TierTags.STR_SHIELD}, tagsNegative = {}},
	["dex_int_shield"] = {priority = 6,
						  adds = {ItemBaseType.SHIELD},
						  removes = {}, tagsPositive = {TierTags.DEX_INT_BASE}, tagsNegative = {}},
	["str_dex_shield"] = {priority = 6,
						  adds = {ItemBaseType.SHIELD},
						  removes = {}, tagsPositive = {TierTags.STR_DEX_BASE}, tagsNegative = {}},
	["str_int_shield"] = {priority = 6,
						  adds = {ItemBaseType.SHIELD},
						  removes = {}, tagsPositive = {TierTags.STR_INT_BASE}, tagsNegative = {}},
	-- Weapons - with one and two handed variants
	["axe"] = {priority = 5, adds = {ItemBaseType.AXE}, removes = {ItemBaseType.AXE}, tagsPositive = {}, tagsNegative = {}},
	["mace"] = {priority = 5, adds = {ItemBaseType.MACE}, removes = {ItemBaseType.MACE}, tagsPositive = {}, tagsNegative = {}},
	["sword"] = {priority = 5, adds = {ItemBaseType.SWORD}, removes = {ItemBaseType.SWORD}, tagsPositive = {}, tagsNegative = {}},
	-- Weapons - one handed
	["claw"] = {priority = 5, adds = {ItemBaseType.CLAW}, removes = {ItemBaseType.CLAW}, tagsPositive = {}, tagsNegative = {}},
	["dagger"] = {priority = 5, adds = {ItemBaseType.DAGGER}, removes = {ItemBaseType.DAGGER}, tagsPositive = {}, tagsNegative = {}},
	["sceptre"] = {priority = 5, adds = {ItemBaseType.SCEPTRE}, removes = {ItemBaseType.SCEPTRE}, tagsPositive = {}, tagsNegative = {}},
	["wand"] = {priority = 5, adds = {ItemBaseType.WAND}, removes = {ItemBaseType.WAND}, tagsPositive = {}, tagsNegative = {}},
	-- Weapons - two handed
	["bow"] = {priority = 5, adds = {ItemBaseType.BOW}, removes = {ItemBaseType.BOW}, tagsPositive = {}, tagsNegative = {}},
	["staff"] = {priority = 5, adds = {ItemBaseType.STAFF}, removes = {ItemBaseType.STAFF}, tagsPositive = {}, tagsNegative = {}},
	-- Other
	["fishing_rod"] = {priority = 3, adds = {ItemBaseType.FISHING_ROD}, removes = {ItemBaseType.FISHING_ROD}, tagsPositive = {}, tagsNegative = {}},
	["quiver"] = {priority = 3, adds = {ItemBaseType.QUIVER}, removes = {ItemBaseType.QUIVER}, tagsPositive = {}, tagsNegative = {}},
	["shield"] = {priority = 3, adds = {ItemBaseType.SHIELD}, removes = {ItemBaseType.SHIELD}, tagsPositive = {}, tagsNegative = {}},
	-- Item variant keys
	["rapier"] = {priority = 6, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.RAPIER}, tagsNegative = {}},
	["attack_dagger"] = {priority = 6, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.NON_RUNE_DAGGER}, tagsNegative = {TierTags.RUNE_DAGGER}},
	["warstaff"] = {priority = 6, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.WARSTAFF}, tagsNegative = {TierTags.NON_WARSTAFF}},
	["attack_staff"] = {priority = 6, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.WARSTAFF}, tagsNegative = {TierTags.NON_WARSTAFF}},
	["focus"] = {priority = 6, adds = {ItemBaseType.SHIELD}, removes = {}, tagsPositive = {TierTags.FOCUS}, tagsNegative = {TierTags.NON_FOCUS}},
	["focus_can_roll_minion_modifiers"] = {priority = 7, adds = {ItemBaseType.SHIELD}, removes = {}, tagsPositive = {TierTags.MINION_SHIELD}, tagsNegative = {}},
	["weapon_can_roll_minion_modifiers"] = {priority = 7, adds = {ItemBaseType.WAND}, removes = {}, tagsPositive = {TierTags.MINION_WAND}, tagsNegative = {}},
	["ring_can_roll_minion_modifiers"] = {priority = 7, adds = {ItemBaseType.RING}, removes = {}, tagsPositive = {TierTags.MINION_RING}, tagsNegative = {}},
	["unset_ring"] = {priority = 7, adds = {ItemBaseType.RING}, removes = {}, tagsPositive = {TierTags.UNSET_RING}, tagsNegative = {}},
	-- Influence-specific armour
	["body_armour_adjudicator"] = {priority = 8, adds = {ItemBaseType.BODY_ARMOUR}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["body_armour_basilisk"] = {priority = 8, adds = {ItemBaseType.BODY_ARMOUR}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["body_armour_crusader"] = {priority = 8, adds = {ItemBaseType.BODY_ARMOUR}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["body_armour_elder"] = {priority = 8, adds = {ItemBaseType.BODY_ARMOUR}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["body_armour_eyrie"] = {priority = 8, adds = {ItemBaseType.BODY_ARMOUR}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["body_armour_shaper"] = {priority = 8, adds = {ItemBaseType.BODY_ARMOUR}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	["boots_adjudicator"] = {priority = 8, adds = {ItemBaseType.BOOTS}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["boots_basilisk"] = {priority = 8, adds = {ItemBaseType.BOOTS}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["boots_crusader"] = {priority = 8, adds = {ItemBaseType.BOOTS}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["boots_elder"] = {priority = 8, adds = {ItemBaseType.BOOTS}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["boots_eyrie"] = {priority = 8, adds = {ItemBaseType.BOOTS}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["boots_shaper"] = {priority = 8, adds = {ItemBaseType.BOOTS}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	["helmet_adjudicator"] = {priority = 8, adds = {ItemBaseType.HELMET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["helmet_basilisk"] = {priority = 8, adds = {ItemBaseType.HELMET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["helmet_crusader"] = {priority = 8, adds = {ItemBaseType.HELMET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["helmet_elder"] = {priority = 8, adds = {ItemBaseType.HELMET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["helmet_eyrie"] = {priority = 8, adds = {ItemBaseType.HELMET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["helmet_shaper"] = {priority = 8, adds = {ItemBaseType.HELMET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	["gloves_adjudicator"] = {priority = 8, adds = {ItemBaseType.GLOVES}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["gloves_basilisk"] = {priority = 8, adds = {ItemBaseType.GLOVES}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["gloves_crusader"] = {priority = 8, adds = {ItemBaseType.GLOVES}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["gloves_elder"] = {priority = 8, adds = {ItemBaseType.GLOVES}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["gloves_eyrie"] = {priority = 8, adds = {ItemBaseType.GLOVES}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["gloves_shaper"] = {priority = 8, adds = {ItemBaseType.GLOVES}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	-- Influence-specific jewellery
	["amulet_adjudicator"] = {priority = 8, adds = {ItemBaseType.AMULET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["amulet_basilisk"] = {priority = 8, adds = {ItemBaseType.AMULET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["amulet_crusader"] = {priority = 8, adds = {ItemBaseType.AMULET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["amulet_elder"] = {priority = 8, adds = {ItemBaseType.AMULET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["amulet_eyrie"] = {priority = 8, adds = {ItemBaseType.AMULET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["amulet_shaper"] = {priority = 8, adds = {ItemBaseType.AMULET}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	["belt_adjudicator"] = {priority = 8, adds = {ItemBaseType.BELT}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["belt_basilisk"] = {priority = 8, adds = {ItemBaseType.BELT}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["belt_crusader"] = {priority = 8, adds = {ItemBaseType.BELT}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["belt_elder"] = {priority = 8, adds = {ItemBaseType.BELT}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["belt_eyrie"] = {priority = 8, adds = {ItemBaseType.BELT}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["belt_shaper"] = {priority = 8, adds = {ItemBaseType.BELT}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	["ring_adjudicator"] = {priority = 8, adds = {ItemBaseType.RING}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["ring_basilisk"] = {priority = 8, adds = {ItemBaseType.RING}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["ring_crusader"] = {priority = 8, adds = {ItemBaseType.RING}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["ring_elder"] = {priority = 8, adds = {ItemBaseType.RING}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["ring_eyrie"] = {priority = 8, adds = {ItemBaseType.RING}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["ring_shaper"] = {priority = 8, adds = {ItemBaseType.RING}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	-- Influenced offhands
	["quiver_adjudicator"] = {priority = 8, adds = {ItemBaseType.QUIVER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["quiver_basilisk"] = {priority = 8, adds = {ItemBaseType.QUIVER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["quiver_crusader"] = {priority = 8, adds = {ItemBaseType.QUIVER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["quiver_elder"] = {priority = 8, adds = {ItemBaseType.QUIVER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["quiver_eyrie"] = {priority = 8, adds = {ItemBaseType.QUIVER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["quiver_shaper"] = {priority = 8, adds = {ItemBaseType.QUIVER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	["shield_adjudicator"] = {priority = 8, adds = {ItemBaseType.SHIELD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["shield_basilisk"] = {priority = 8, adds = {ItemBaseType.SHIELD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["shield_crusader"] = {priority = 8, adds = {ItemBaseType.SHIELD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["shield_elder"] = {priority = 8, adds = {ItemBaseType.SHIELD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["shield_eyrie"] = {priority = 8, adds = {ItemBaseType.SHIELD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["shield_shaper"] = {priority = 8, adds = {ItemBaseType.SHIELD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	-- Influenced weapons
	["axe_adjudicator"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.ONE_HANDED}, tagsNegative = {}},
	["axe_basilisk"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["axe_crusader"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["axe_elder"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["axe_eyrie"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["axe_shaper"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["2h_axe_adjudicator"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_axe_basilisk"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_axe_crusader"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_axe_elder"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_axe_eyrie"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_axe_shaper"] = {priority = 8, adds = {ItemBaseType.AXE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["bow_adjudicator"] = {priority = 8, adds = {ItemBaseType.BOW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["bow_basilisk"] = {priority = 8, adds = {ItemBaseType.BOW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["bow_crusader"] = {priority = 8, adds = {ItemBaseType.BOW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["bow_elder"] = {priority = 8, adds = {ItemBaseType.BOW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["bow_eyrie"] = {priority = 8, adds = {ItemBaseType.BOW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["bow_shaper"] = {priority = 8, adds = {ItemBaseType.BOW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	["claw_adjudicator"] = {priority = 8, adds = {ItemBaseType.CLAW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["claw_basilisk"] = {priority = 8, adds = {ItemBaseType.CLAW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["claw_crusader"] = {priority = 8, adds = {ItemBaseType.CLAW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["claw_elder"] = {priority = 8, adds = {ItemBaseType.CLAW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["claw_eyrie"] = {priority = 8, adds = {ItemBaseType.CLAW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["claw_shaper"] = {priority = 8, adds = {ItemBaseType.CLAW}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	["dagger_adjudicator"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.NON_RUNE_DAGGER}, tagsNegative = {}},
	["dagger_basilisk"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.NON_RUNE_DAGGER}, tagsNegative = {}},
	["dagger_crusader"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.NON_RUNE_DAGGER}, tagsNegative = {}},
	["dagger_elder"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.NON_RUNE_DAGGER}, tagsNegative = {}},
	["dagger_eyrie"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.NON_RUNE_DAGGER}, tagsNegative = {}},
	["dagger_shaper"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.NON_RUNE_DAGGER}, tagsNegative = {}},
	["rune_dagger_adjudicator"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.RUNE_DAGGER}, tagsNegative = {}},
	["rune_dagger_basilisk"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.RUNE_DAGGER}, tagsNegative = {}},
	["rune_dagger_crusader"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.RUNE_DAGGER}, tagsNegative = {}},
	["rune_dagger_elder"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.RUNE_DAGGER}, tagsNegative = {}},
	["rune_dagger_eyrie"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.RUNE_DAGGER}, tagsNegative = {}},
	["rune_dagger_shaper"] = {priority = 8, adds = {ItemBaseType.DAGGER}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.RUNE_DAGGER}, tagsNegative = {}},
	["mace_adjudicator"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.ONE_HANDED}, tagsNegative = {}},
	["mace_basilisk"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["mace_crusader"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["mace_elder"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["mace_eyrie"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["mace_shaper"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["2h_mace_adjudicator"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_mace_basilisk"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_mace_crusader"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_mace_elder"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_mace_eyrie"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_mace_shaper"] = {priority = 8, adds = {ItemBaseType.MACE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["sceptre_adjudicator"] = {priority = 8, adds = {ItemBaseType.SCEPTRE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["sceptre_basilisk"] = {priority = 8, adds = {ItemBaseType.SCEPTRE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["sceptre_crusader"] = {priority = 8, adds = {ItemBaseType.SCEPTRE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["sceptre_elder"] = {priority = 8, adds = {ItemBaseType.SCEPTRE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["sceptre_eyrie"] = {priority = 8, adds = {ItemBaseType.SCEPTRE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["sceptre_shaper"] = {priority = 8, adds = {ItemBaseType.SCEPTRE}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	["staff_adjudicator"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.NON_WARSTAFF}, tagsNegative = {}},
	["staff_basilisk"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.NON_WARSTAFF}, tagsNegative = {}},
	["staff_crusader"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.NON_WARSTAFF}, tagsNegative = {}},
	["staff_elder"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.NON_WARSTAFF}, tagsNegative = {}},
	["staff_eyrie"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.NON_WARSTAFF}, tagsNegative = {}},
	["staff_shaper"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.NON_WARSTAFF}, tagsNegative = {}},
	["sword_adjudicator"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.ONE_HANDED}, tagsNegative = {}},
	["sword_basilisk"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["sword_crusader"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["sword_elder"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["sword_eyrie"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["sword_shaper"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.ONE_HANDED}, tagsNegative = {}},
	["2h_sword_adjudicator"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_sword_basilisk"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_sword_crusader"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_sword_elder"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_sword_eyrie"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["2h_sword_shaper"] = {priority = 8, adds = {ItemBaseType.SWORD}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.TWO_HANDED}, tagsNegative = {}},
	["warstaff_adjudicator"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD, TierTags.WARSTAFF}, tagsNegative = {}},
	["warstaff_basilisk"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER, TierTags.WARSTAFF}, tagsNegative = {}},
	["warstaff_crusader"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER, TierTags.WARSTAFF}, tagsNegative = {}},
	["warstaff_elder"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER, TierTags.WARSTAFF}, tagsNegative = {}},
	["warstaff_eyrie"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER, TierTags.WARSTAFF}, tagsNegative = {}},
	["warstaff_shaper"] = {priority = 8, adds = {ItemBaseType.STAFF}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER, TierTags.WARSTAFF}, tagsNegative = {}},
	["wand_adjudicator"] = {priority = 8, adds = {ItemBaseType.WAND}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.WARLORD}, tagsNegative = {}},
	["wand_basilisk"] = {priority = 8, adds = {ItemBaseType.WAND}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.HUNTER}, tagsNegative = {}},
	["wand_crusader"] = {priority = 8, adds = {ItemBaseType.WAND}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.CRUSADER}, tagsNegative = {}},
	["wand_elder"] = {priority = 8, adds = {ItemBaseType.WAND}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.ELDER}, tagsNegative = {}},
	["wand_eyrie"] = {priority = 8, adds = {ItemBaseType.WAND}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.REDEEMER}, tagsNegative = {}},
	["wand_shaper"] = {priority = 8, adds = {ItemBaseType.WAND}, removes = {}, tagsPositive = {TierTags.INFLUENCED, TierTags.SHAPER}, tagsNegative = {}},
	-- unsupported weight tags
	["deepwater_sword"] = {priority = 999, adds = {}, removes = {}, tagsPositive = {}, tagsNegative = {}},
	["grants_2h_support"] = {priority = 999, adds = {}, removes = {}, tagsPositive = {}, tagsNegative = {}},
	["grants_crit_chance_support"] = {priority = 999, adds = {}, removes = {}, tagsPositive = {}, tagsNegative = {}}
}


-- LOGIC CLASSES ========================================================================================================================================================================================================
-- TIER class
local TierClass = newClass("Tier", "ParentClass")

-- Tier class constructor
function TierClass:Tier(tierId, affix, effect, levelReq, spawnsOnItems, tags)
	self.tierId = tierId				-- "LocalAddedColdDamage6"
	self.affix = affix					-- "Frozen"
	self.effect = effect				-- "Adds (31-42) to (62-71) Cold Damage"
	self.levelReq = levelReq			-- 43
	self.spawnsOnItems = spawnsOnItems	-- { ItemBaseType }
	self.tags = tags					-- [ItemBaseType] -> { TierTags }
end

-- MOD class
local ModClass = newClass("Mod", "ParentClass")

-- constructor
function ModClass:Mod(modKey, type, group, affectsItems, tiers)
	self.modKey = modKey				-- "LocalAddedColdDamage"
	self.type = type					-- "Prefix"/"Suffix"/"Implicit"
	self.group = group					-- "LocalColdDamage"
	self.affectsItems = affectsItems	-- {"Helmet", "Gloves", "Amulet"}
	self.tierCount = 1
	self.tiers = tiers
end

function ModClass.addTier(self, newTier)
	table.insert(self.tiers, newTier)
end

-- MOD/TIER construction ===========================================================================================

--[[Derive a merge key from a mod ID by stripping trailing underscores and digits, examples:
    "Intelligence10" -> "Intelligence", "MaximumLifeUber2" -> "MaximumLifeUber",
    "PercentageIntelligenceInfluence1_" -> "PercentageIntelligenceInfluence",
    "IntelligenceEssence7" -> "IntelligenceEssence"]]
function ModClass.getModKey(modId)
	-- Strip trailing underscores and digits
	return modId:gsub("[_%d]+_$", ""):gsub("[_%d]+$", "")
end

function ModClass.isElevated(mod)
	if not mod.affix then
		return false
	end
	if mod.affix:match("^Elevated") then return true end
	if mod.affix:match("^of the Essence") then return true end
	if mod.affix:match("^of Elevated") then return true end
	return false
end

function ModClass.isEssenceOnly(mod)
	if not mod.affix then
		return false
	end
	if mod.affix:match("^Essences") then return true end
	if mod.affix:match("^of the Elevated") then return true end
	if mod.affix:match("^of Elevated") then return true end
	return false
end

local function dropsOnSomeItem(spawnsOnItems)
	for _, dropBool in ipairs(spawnsOnItems) do
		if dropBool == true then
			return true
		end
	end
	return false
end

function ModClass.fromExplicitData(tierId, modKey, dataMod, existingMod)
	if ModClass.isElevated(dataMod) then
		local spawnsOnItems, possibleTags = ModClass.getTierItemsElevated(dataMod.weightKey, dataMod.weightVal)
		if dropsOnSomeItem(spawnsOnItems) then
			local itemTagMap = ModClass.processPossibleTags(dataMod.weightKey, dataMod.weightVal, spawnsOnItems, possibleTags)
			local parsedTier = new("Tier"):Mod(tierId, dataMod.affix or "", dataMod[1] or "", dataMod.level or 0, spawnsOnItems, itemTagMap)
			if existingMod then
				existingMod.addTier(parsedTier)
				return nil
			end
			return new("Mod"):Mod(modKey, dataMod.type or "N/A", dataMod.group or "", spawnsOnItems, {parsedTier})
		end
		return nil
	end
	if ModClass.isEssenceOnly() then
		-- todo: plan is, to get the items on which the mod can occur from Essence.lua file "here", then we will know, what are the item bases for the mod
	    -- todo: then later, we will have to go over the essence file (the essences with type value matching the one in supportedStatsList) and add the info, that the mod can be
		-- todo: also the tag thingies
	end

	local spawnsOnItems, possibleTags = ModClass.getTierItems(dataMod.weightKey, dataMod.weightVal)
	if dropsOnSomeItem(spawnsOnItems) then
		local itemTagMap = ModClass.processPossibleTags(dataMod.weightKey, dataMod.weightVal, spawnsOnItems, possibleTags)
		local parsedTier = new("Tier"):Mod(tierId, dataMod.affix or "", dataMod[1] or "", dataMod.level or 0, spawnsOnItems, itemTagMap)
		if existingMod then
			existingMod.addTier(parsedTier)
			return nil
		end
		return new("Mod"):Mod(modKey, dataMod.type or "N/A", dataMod.group or "", spawnsOnItems, {parsedTier})	
	end
	return nil
end

function ModClass.getTierItems(weightKeys, weightVals)
	local weightKeyValPairs = {}
	for i, key in ipairs(weightKeys) do
		table.insert(weightKeyValPairs, {key = key, val = weightVals[i]})
	end

	table.sort(weightKeyValPairs, function(a,b)
		local aPriority = WEIGHT_KEY_INFO[a.key].priority or 999
		local bPriority = WEIGHT_KEY_INFO[b.key].priority or 999
		return aPriority < bPriority
	end)

	local itemBaseTypes = {} -- ItemBaseType -> boolean
	local possibleTags = {} -- TierTags -> boolean
	for _, keyValPair in ipairs(weightKeyValPairs) do
		if keyValPair.val > 0 then
			for _, itemType in ipairs(WEIGHT_KEY_INFO[keyValPair.key].adds) do
				itemBaseTypes[itemType] = true
			end
			for _, tag in ipairs(WEIGHT_KEY_INFO[keyValPair.key].tagsPositive) do
				possibleTags[tag] = true
			end
		else
			for _, itemType in ipairs(WEIGHT_KEY_INFO[keyValPair.key].removes) do
				itemBaseTypes[itemType] = false
			end
			for _, tag in ipairs(WEIGHT_KEY_INFO[keyValPair.key].tagsNegative) do
				possibleTags[tag] = true
			end
		end
	end
	return itemBaseTypes, possibleTags
end

function ModClass.getTierItemsElevated(weightKeys, weightVals)
	local weightKeyValPairs = {}
	for i, key in ipairs(weightKeys) do
		table.insert(weightKeyValPairs, {key = key, val = weightVals[i]})
	end
	
	local itemBaseTypes = {} -- ItemBaseType -> boolean
	local possibleTags = {} -- TierTags -> boolean
	
	possibleTags[TierTags.ELEVATED] = true

	-- first we add all item types with false value
	for _, itemType in ipairs(WEIGHT_KEY_INFO["default"].adds) do
		itemBaseTypes[itemType] = false
	end
	
	for _, keyValPair in ipairs(weightKeyValPairs) do
		if keyValPair.key ~= "default" then
			for _, itemType in ipairs(WEIGHT_KEY_INFO[keyValPair.key].adds) do
				itemBaseTypes[itemType] = true
			end
			for _, tag in ipairs(WEIGHT_KEY_INFO[keyValPair.key].tagsPositive) do
				possibleTags[tag] = true
			end
		end
	end
	return itemBaseTypes, possibleTags
end



--[[
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
end]]

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
			-- ""AttackAndCastSpeedDuringFlaskEffect", "AttackCastSpeedPerNearbyEnemy" -- essence of desolation or legacy essence
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
			-- "AttackAndCastSpeedDuringFlaskEffect", "AttackCastSpeedPerNearbyEnemy" -- essence of desolation or legacy essence
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
			-- "MovementVelocitySpeed", "MovementVelocityDodge", "MovementVelocitySpellDodge" -- incursion mod
			-- "MovementSpeedOnBurningChilledShockedGround", "MovementSpeedPerNearbyEnemyEssence1" -- essence of desolation
			{property = "searchFlat", names = {}, essenceTypes = {}},
			{property = "searchInc", names = {"MovementVelocity", "MovementSpeedDuringFlaskEffect", "MovementSpeedIfHitRecently"}, essenceTypes = {21}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Intelligence",
		groups = {
			-- "DexterityAndIntelligence", "HybridStrInt", "HybridDexInt", "StrengthIntelligenceForJewel", "StrengthAndIntelligence" -- different files
			{property = "searchFlat", names = {"Intelligence", "AllAttributes"}, essenceTypes = {14}},
			{property = "searchInc", names = {"PercentageIntelligence", "PercentageIntelligenceMaven", "PercentageAllAttributes"}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Strength",
		groups = {
			{property = "searchFlat", names = {"Strength", "AllAttributes"}, essenceTypes = {9}},
			{property = "searchInc", names = {"PercentageStrength", "PercentageStrengthMaven", "PercentageAllAttributes"}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Dexterity",
		groups = {
			{property = "searchFlat", names = {"Dexterity", "AllAttributes"}, essenceTypes = {4}},
			{property = "searchInc", names = {"PercentageDexterity", "PercentageDexterityMaven", "PercentageAllAttributes"}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Reservation Efficiency",
		groups = {
			-- "IncreasedManaAndReservation" -- incursion mod
			-- "ReducedReservation", "WrathReservation", "DisciplineReservation", "PurityOfLightningReservation", "ZealotryReservation", "AngerReservation", -- probably legacy
			-- "PrideReservation", "DeterminationReservation", "PurityOfFireReservation", "HatredReservation", "GraceReservation", "PurityOfIceReservation", "MalevolenceReservation" -- probably legacy
			-- "ArcticArmourReservationCost", "ArcticArmourReservationEfficiency" -- tul body armour old and new: 
			-- "DeepwaterSwordAngerReservation" -- allflame did not go core, so currently legacy
			{property = "searchFlat", names = {}, essenceTypes = {}},
			{property = "searchInc", names = {"ManaReservationEfficiency", "DisplaySocketedGemsGetReducedReservation", "WrathReservationEfficiency",
											  "DisciplineReservationEfficiency", "PurityOfLightningReservationEfficiency", "ZealotryReservationEfficiency",
											  "AngerReservationEfficiency", "PrideReservationEfficiency", "DeterminationReservationEfficiency", "PurityOfFireReservationEfficiency",
											  "HatredReservationEfficiency", "GraceReservationEfficiency", "PurityOfIceReservationEfficiency", "MalevolenceReservationEfficiency", }, essenceTypes = {13}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Spell Suppression",
		groups = {
			-- "ChanceToSuppressSpellsOld", "ChanceToSuppressSpellsMavenOld" -- legacy
			{property = "searchFlat", names = {"ChanceToSuppressSpells", "SpellDamageSuppressed"}, essenceTypes = {}},
			{property = "searchInc", names = {}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Physical Damage Reduction",
		groups = {
			-- todo: can be used to test showing str/dex/int tags, because these need str on for example boots
			-- "ReducedPhysicalDamageTakenMaven" -- legacy
			-- "AdditionalPhysicalDamageReductionDuringFlaskEffect" -- essence of desolation or legacy essence
			{property = "searchFlat", names = {}, essenceTypes = {}},
			{property = "searchInc", names = {"ReducedPhysicalDamageTaken"}, essenceTypes = {}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Damage from Crits",
		groups = {
			-- ReducedCriticalStrikeDamageTaken -- influence legacy
			{property = "searchFlat", names = {}, essenceTypes = {}},
			{property = "searchInc", names = {"ReducedExtraDamageFromCrits", "ReducedDamageFromCriticalStrikesPerEnduranceCharge"}, essenceTypes = {22}},
			{property = "searchMore", names = {}, essenceTypes = {}},
		}
	},
	{
		label = "Taken as",
		groups = {
			-- "PhysicalDamageTakenAsFirePercent", "PhysicalDamageTakenAsCold", "PhysicalDamageTakenAsFirePercent" -- legacy
			-- "FireResistancePhysTakenAsFire", "ColdResistancePhysTakenAsCold", "LightningResistancePhysTakenAsLightning", -- incursion mod and perhaps also legacy
			{property = "searchFlat", names = {}, essenceTypes = {}},
			{property = "searchInc", names = {"PhysicalDamageTakenAsFireUber", "PhysicalDamageTakenAsColdUber", "PhysicalDamageTakenAsLightningUber", "PhysicalDamageTakenAsChaosUber",
											  "PhysicalDamageTakenAsFireUberMaven", "PhysicalDamageTakenAsColdUberMaven", "PhysicalDamageTakenAsLightningUberMaven", "PhysicalDamageTakenAsChaosUberMaven"}, essenceTypes = {}},
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
		
		-- todo: do we want to apply the filters before we process the mod? perhaps makes it faster, but there would be double logic no, like if it can spawn on the item
		-- TODO: if we want to add influence filter, or/and elevated filter
		-- Apply item type filters
		if not modMatchesItemFilters(mod, self) then
			goto continue
		end
		
		local modKey = ModClass.getModKey(modId)
		local existingMod = results[modKey]
		if existingMod then
			-- todo: we already parsed mod from this group ... do we want to count them?
			ModClass.fromExplicitData(modId, modKey, mod, existingMod)
		else
			local modParent = ModClass.fromExplicitData(modId, modKey, mod, existingMod)
			if modParent then
				results[modKey] = modParent
			end
		end
		-- todo: do we want some natural tag or something like that?
		-- todo: do we want to somehow sort the tiers
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
local function getVariantTags(mod, itemType)
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

-- Determine the attribute base restriction(s) for a mod on a specific armor item type
-- Returns a list of tag strings like {"Int Base"}, {"Str Base"}, {"Str/Dex Base"}, etc.
-- Helmet is excluded since it can spawn on any helmet base type, so no tag is needed.
-- The function checks the mod's weightKey for attribute armor keys (str_armour, dex_armour, int_armour
-- and their combinations) and respects weightVal = 0 exclusions.
local function getAttributeBaseTags(mod, itemType)
	local tags = {}
	if not mod.weightKey or not mod.weightVal then
		return tags
	end
	
	local armourTypeToWeightKeyMap = {
		["Body Armour"] = "body_armour",
		["Helmet"] = "helmet",
		["Gloves"] = "gloves",
		["Boots"] = "boots",
	}
	
	local weightKey = armourTypeToWeightKeyMap[itemType]
	-- str/dex/int bases apply only for armour
	if weightKey == nil then
		return tags
	end
	
	for i, key in ipairs(mod.weightKey) do
		local weight = mod.weightVal[i] or 0
		if weight > 0 then
			if weightKey:match(key) then
				return {}
			end
			-- Check if this key is an attribute-based armor key
			if key:match("^str_armour$") then
				table.insert(tags, "STR Base")
			elseif key:match("^dex_armour$") then
				table.insert(tags, "DEX Base")
			elseif key:match("^int_armour$") then
				table.insert(tags, "INT Base")
			elseif key:match("^ward_armour$") then
				table.insert(tags, "WARD Base")
			end
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
					-- Add variant tags
					local variantTags = getVariantTags(tier, merged.itemType)
					for _, tag in ipairs(variantTags) do
						modLine = modLine .. string.format(" ^9[%s]^7", tag)
					end
					-- Add attribute base restriction tags (e.g., "[Int Base]" for attribute-restricted armor)
					local attrTags = getAttributeBaseTags(tier, merged.itemType)
					for _, tag in ipairs(attrTags) do
						modLine = modLine .. string.format(" ^9[%s]^7", tag)
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
							-- Add attribute base restriction tags (e.g., "[Int Base]" for attribute-restricted armor)
							local attrTags = getAttributeBaseTags(tier, merged.itemType)
							for _, tag in ipairs(attrTags) do
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
