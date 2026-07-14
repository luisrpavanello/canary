local internalNpcName = "Arlan the Ashkeeper"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName
npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 95,
	lookBody = 114,
	lookLegs = 78,
	lookFeet = 115,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 40,
	{ text = "The sword was never hidden from the strong. It was hidden from the proud." },
	{ text = "Seven flames, three deeds, one quiet heart." },
	{ text = "Only the humble may touch the Sword of Fury." },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local talkState = {}

local storages = Storage.SwordOfFury
local medicinePouchId = 12517
local lostAmuletId = 3054

local function getValue(player, storage)
	return math.max(0, player:getStorageValue(storage))
end

local function addValue(player, storage, amount)
	player:setStorageValue(storage, getValue(player, storage) + amount)
end

local function hasStarted(player)
	return getValue(player, storages.Questline) >= 1
end

local function startQuest(npc, player)
	if not hasStarted(player) then
		player:setStorageValue(storages.Questline, 1)
		player:setStorageValue(storages.Humility, 0)
		player:setStorageValue(storages.Greed, 0)
		player:setStorageValue(storages.Medicine, 0)
		player:setStorageValue(storages.LostItem, 0)
		player:setStorageValue(storages.Creature, 0)
		player:setStorageValue(storages.Flames, 0)
		player:setStorageValue(storages.Claimed, 0)
	end

	npcHandler:say({
		"You have seen it, then. A blade surrounded by fire, waiting longer than any of us.",
		"The sword does not ask for strength. It asks what you demand when nobody can repay you.",
		"Bring medicine to a poor sick man, recover a lost amulet, and help a weak creature. Speak to me about {medicine}, {amulet}, or {creature}.",
	}, npc, player)
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
	local playerId = player:getId()
	local msg = message:lower()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "sword", "fury", "mission", "quest", "legend", "lenda" }, msg) then
		startQuest(npc, player)
		talkState[playerId] = 0
		return true
	end

	if not hasStarted(player) then
		npcHandler:say("If your eyes are still fixed on the burning island, ask me about the {sword}.", npc, player)
		return true
	end

	if msg == "status" or msg == "flames" or msg == "chamas" then
		npcHandler:say(string.format("Your quiet deeds: %d. Prices accepted: %d. Three quiet deeds and no accepted price are required.", getValue(player, storages.Humility), getValue(player, storages.Greed)), npc, player)
		return true
	end

	if msg == "medicine" or msg == "remedio" or msg == "remédio" then
		if getValue(player, storages.Medicine) >= 2 then
			npcHandler:say("The sick man sleeps without pain tonight. That flame has already heard you.", npc, player)
		elseif player:getItemCount(medicinePouchId) > 0 or getValue(player, storages.Medicine) == 1 then
			npcHandler:say("You found the medicine. Will you give it {free}, or will you {charge} 100 gold?", npc, player)
			talkState[playerId] = 1
		else
			npcHandler:say("A medicine pouch was lost near the old roots. Find it, then return to me. If you help for free, the first flame will remember.", npc, player)
		end
		return true
	end

	if msg == "free" or msg == "gratis" or msg == "grátis" then
		if talkState[playerId] ~= 1 or getValue(player, storages.Medicine) >= 2 then
			npcHandler:say("Kindness is only counted when someone is waiting for it.", npc, player)
			return true
		end

		if not player:removeItem(medicinePouchId, 1) then
			npcHandler:say("You do not carry the medicine pouch.", npc, player)
			return true
		end

		player:setStorageValue(storages.Medicine, 2)
		addValue(player, storages.Humility, 1)
		npcHandler:say("Then your hands are warmer than gold. One flame grows quiet.", npc, player)
		talkState[playerId] = 0
		return true
	end

	if msg == "charge" or msg == "cobrar" or msg == "100" or msg == "100 gold" then
		if talkState[playerId] ~= 1 or getValue(player, storages.Medicine) >= 2 then
			npcHandler:say("Gold has many uses, but it cannot buy this moment twice.", npc, player)
			return true
		end

		if not player:removeItem(medicinePouchId, 1) then
			npcHandler:say("You do not carry the medicine pouch.", npc, player)
			return true
		end

		player:addItem(ITEM_GOLD_COIN, 100)
		player:setStorageValue(storages.Medicine, 2)
		addValue(player, storages.Greed, 1)
		npcHandler:say("He will pay, if he must. But the fire will remember the price.", npc, player)
		talkState[playerId] = 0
		return true
	end

	if msg == "amulet" or msg == "medallion" or msg == "medalhao" or msg == "medalhão" then
		if getValue(player, storages.LostItem) >= 2 then
			npcHandler:say("The amulet is back with the one who mourned it. That flame has already heard you.", npc, player)
		elseif player:getItemCount(lostAmuletId) > 0 or getValue(player, storages.LostItem) == 1 then
			npcHandler:say("You recovered the amulet. Its owner offers 100 gold in thanks. Will you {accept} or {refuse} the reward?", npc, player)
			talkState[playerId] = 2
		else
			npcHandler:say("A small silver amulet was lost in the dark. It is worth little to merchants, but everything to its owner.", npc, player)
		end
		return true
	end

	if msg == "refuse" or msg == "recusar" or msg == "no reward" then
		if talkState[playerId] ~= 2 or getValue(player, storages.LostItem) >= 2 then
			npcHandler:say("Refusal means little without temptation.", npc, player)
			return true
		end

		if not player:removeItem(lostAmuletId, 1) then
			npcHandler:say("You do not carry the lost amulet.", npc, player)
			return true
		end

		player:setStorageValue(storages.LostItem, 2)
		addValue(player, storages.Humility, 1)
		npcHandler:say("You return memory without weighing it in coins. One flame grows quiet.", npc, player)
		talkState[playerId] = 0
		return true
	end

	if msg == "accept" or msg == "aceitar" or msg == "reward" or msg == "recompensa" then
		if talkState[playerId] ~= 2 or getValue(player, storages.LostItem) >= 2 then
			npcHandler:say("Rewards are easy to accept. The sword asks what you do before taking them.", npc, player)
			return true
		end

		if not player:removeItem(lostAmuletId, 1) then
			npcHandler:say("You do not carry the lost amulet.", npc, player)
			return true
		end

		player:addItem(ITEM_GOLD_COIN, 100)
		player:setStorageValue(storages.LostItem, 2)
		addValue(player, storages.Greed, 1)
		npcHandler:say("A fair reward, perhaps. Yet the fire weighs even fair prices.", npc, player)
		talkState[playerId] = 0
		return true
	end

	if msg == "creature" or msg == "wolf" or msg == "criatura" then
		if getValue(player, storages.Creature) >= 1 then
			npcHandler:say("The weak creature still breathes because of you. That flame has already heard you.", npc, player)
		else
			npcHandler:say("A wounded creature hides near the old paths. Bring meat or ham, and use it gently. A blade would teach the flames a different truth.", npc, player)
		end
		return true
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "Come closer, |PLAYERNAME|. Are you here because of the {sword}?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Walk quietly.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "The flames are patient.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)
npcType:register(npcConfig)
