local config = {
	actionIds = {
		medicinePouch = 59001,
		lostAmulet = 59002,
		woundedCreature = 59003,
		secretEntrance = 59004,
		swordOfFury = 59005,
		secretExit = 59006,
	},
	items = {
		medicinePouch = 12517,
		lostAmulet = 3054,
		rewardSword = 3271,
		food = { 3577, 3582 }, -- meat, ham
	},
	limits = {
		maxLevel = 8,
		requiredHumility = 3,
	},
	teleports = {
		secretEntrance = Position(32099, 32085, 7),
		secretExit = Position(32094, 32084, 7),
	},
}

local storages = Storage.SwordOfFury

local function getValue(player, storage)
	return math.max(0, player:getStorageValue(storage))
end

local function addValue(player, storage, amount)
	player:setStorageValue(storage, getValue(player, storage) + amount)
end

local function hasStarted(player)
	return getValue(player, storages.Questline) >= 1
end

local function isPure(player)
	return getValue(player, storages.Humility) >= config.limits.requiredHumility and getValue(player, storages.Greed) == 0
end

local function canAccessSecret(player)
	if not hasStarted(player) then
		return false, "The flames do not know your name."
	end

	if player:getVocation():getId() ~= VOCATION.ID.NONE then
		return false, "The sword rejects those who have already chosen a vocation."
	end

	if player:getLevel() > config.limits.maxLevel then
		return false, "The sword was left for rookies, not seasoned adventurers."
	end

	if getValue(player, storages.Medicine) < 2 or getValue(player, storages.LostItem) < 2 or getValue(player, storages.Creature) < 1 then
		return false, "Three flames still await three humble deeds."
	end

	if getValue(player, storages.Greed) > 0 then
		return false, "The flames rise. The sword remembers every price you accepted."
	end

	if not isPure(player) then
		return false, "The flames bend toward you, but do not bow."
	end

	return true
end

local function canClaimSword(player)
	local ok, reason = canAccessSecret(player)
	if not ok then
		return false, reason
	end

	if getValue(player, storages.Claimed) > 0 then
		return false, "The sword remains, yet its flame already follows you."
	end

	return true
end

local medicinePouch = Action()
function medicinePouch.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not hasStarted(player) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You do not know who needs this medicine yet.")
		return true
	end

	if getValue(player, storages.Medicine) >= 2 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The sick man has already received medicine.")
		return true
	end

	if player:getItemCount(config.items.medicinePouch) > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You already carry a medicine pouch.")
		return true
	end

	player:addItem(config.items.medicinePouch, 1)
	player:setStorageValue(storages.Medicine, 1)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You found a medicine pouch. Return it to Arlan and choose what to ask in return.")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	return true
end

medicinePouch:aid(config.actionIds.medicinePouch)
medicinePouch:register()

local lostAmulet = Action()
function lostAmulet.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not hasStarted(player) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "This amulet means nothing to you yet.")
		return true
	end

	if getValue(player, storages.LostItem) >= 2 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The lost amulet has already been returned.")
		return true
	end

	if player:getItemCount(config.items.lostAmulet) > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You already carry the lost amulet.")
		return true
	end

	player:addItem(config.items.lostAmulet, 1)
	player:setStorageValue(storages.LostItem, 1)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You recovered the lost amulet. Return it to Arlan and decide whether thanks are enough.")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

lostAmulet:aid(config.actionIds.lostAmulet)
lostAmulet:register()

local woundedCreature = Action()
function woundedCreature.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not hasStarted(player) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The frightened creature backs away from you.")
		return true
	end

	if getValue(player, storages.Creature) >= 1 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The weak creature has already been helped.")
		return true
	end

	local removedFood = false
	for _, itemId in ipairs(config.items.food) do
		if player:removeItem(itemId, 1) then
			removedFood = true
			break
		end
	end

	if not removedFood then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The weak creature needs food. Bring meat or ham.")
		return true
	end

	player:setStorageValue(storages.Creature, 1)
	addValue(player, storages.Humility, 1)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The weak creature eats from your hand and limps away. One flame grows quiet.")
	player:getPosition():sendMagicEffect(CONST_ME_SOUND_GREEN)
	return true
end

woundedCreature:aid(config.actionIds.woundedCreature)
woundedCreature:register()

local secretEntrance = Action()
function secretEntrance.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local ok, reason = canAccessSecret(player)
	if not ok then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, reason)
		return true
	end

	player:teleportTo(config.teleports.secretEntrance)
	config.teleports.secretEntrance:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

secretEntrance:aid(config.actionIds.secretEntrance)
secretEntrance:register()

local secretExit = Action()
function secretExit.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local ok, reason = canAccessSecret(player)
	if not ok then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, reason)
		return true
	end

	player:teleportTo(config.teleports.secretExit)
	config.teleports.secretExit:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

secretExit:aid(config.actionIds.secretExit)
secretExit:register()

local swordOfFury = Action()
function swordOfFury.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local ok, reason = canClaimSword(player)
	if not ok then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, reason)
		fromPosition:sendMagicEffect(CONST_ME_HITBYFIRE)
		return true
	end

	player:setStorageValue(storages.Flames, 7)
	player:setStorageValue(storages.Claimed, 1)

	local sword = player:addItem(config.items.rewardSword, 1)
	if sword then
		sword:setAttribute(ITEM_ATTRIBUTE_NAME, "Humbled Sword of Fury")
		sword:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Only the humble may touch it. Its flame grows quiet in the hands of the worthy.")
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The seven flames bow. You place your hand upon the hilt. It is warm, but it does not burn.")
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have received the Humbled Sword of Fury.")
	fromPosition:sendMagicEffect(CONST_ME_FIREWORK_RED)
	return true
end

swordOfFury:aid(config.actionIds.swordOfFury)
swordOfFury:register()
