local internalNpcName = "Wounded Wolf"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = "a wounded wolf"
npcConfig.health = 25
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 1

npcConfig.outfit = {
	lookType = 27,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 12000,
	chance = 45,
	{ text = "*whimper*" },
	{ text = "The wounded wolf lowers its head." },
	{ text = "The wolf watches you with tired eyes." },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

local storages = Storage.SwordOfFury
local foodItems = {
	3577, -- meat
	3582, -- ham
}

local function getValue(player, storage)
	return math.max(0, player:getStorageValue(storage))
end

local function addValue(player, storage, amount)
	player:setStorageValue(storage, getValue(player, storage) + amount)
end

local function removeFood(player)
	for _, itemId in ipairs(foodItems) do
		if player:removeItem(itemId, 1) then
			return true
		end
	end
	return false
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local msg = message:lower()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if getValue(player, storages.Questline) < 1 then
		npcHandler:say("The wolf does not trust you yet.", npc, player)
		return true
	end

	if getValue(player, storages.Creature) >= 1 then
		npcHandler:say("The wolf has already accepted your kindness. It nudges your hand gently.", npc, player)
		return true
	end

	if table.contains({ "help", "food", "meat", "ham", "wolf", "ajudar", "comida", "carne" }, msg) then
		if not removeFood(player) then
			npcHandler:say("The wolf sniffs the air weakly. Bring meat or ham.", npc, player)
			return true
		end

		player:setStorageValue(storages.Creature, 1)
		addValue(player, storages.Humility, 1)
		player:getPosition():sendMagicEffect(CONST_ME_SOUND_GREEN)
		npcHandler:say("The wounded wolf eats from your hand and slowly stands. One flame grows quiet.", npc, player)
		return true
	end

	npcHandler:say("The wounded wolf whimpers. It seems hungry. Say {food} if you wish to help.", npc, player)
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "The wounded wolf looks at you. Its breathing is shallow.")
npcHandler:setMessage(MESSAGE_FAREWELL, "*whimper*")
npcHandler:setMessage(MESSAGE_WALKAWAY, "The wolf lowers its head again.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
