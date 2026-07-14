function onUpdateDatabase()
	logger.info("Updating database to version 1 (sample players)")
	-- Rook Sample
	db.query("UPDATE `players` SET `level` = 1, `vocation` = 0, `health` = 150, `healthmax` = 150, `experience` = 0, `soul` = 100, `lookbody` = 113, `lookfeet` = 115, `lookhead` = 95, `looklegs` = 39, `looktype` = 129, `mana` = 0, `manamax` = 0, `town_id` = 1, `cap` = 400 WHERE `id` = 1;")
	-- Sorcerer Sample
	db.query("UPDATE `players` SET `level` = 8, `vocation` = 1, `health` = 185, `healthmax` = 185, `experience` = 4200, `soul` = 100, `lookbody` = 113, `lookfeet` = 115, `lookhead` = 95, `looklegs` = 39, `looktype` = 129, `mana` = 90, `manamax` = 90, `town_id` = 8, `cap` = 470 WHERE `id` = 2;")
	-- Druid Sample
	db.query("UPDATE `players` SET `level` = 8, `vocation` = 2, `health` = 185, `healthmax` = 185, `experience` = 4200, `soul` = 100, `lookbody` = 113, `lookfeet` = 115, `lookhead` = 95, `looklegs` = 39, `looktype` = 129, `mana` = 90, `manamax` = 90, `town_id` = 8, `cap` = 470 WHERE `id` = 3;")
	-- Paladin Sample
	db.query("UPDATE `players` SET `level` = 8, `vocation` = 3, `health` = 185, `healthmax` = 185, `experience` = 4200, `soul` = 100, `lookbody` = 113, `lookfeet` = 115, `lookhead` = 95, `looklegs` = 39, `looktype` = 129, `mana` = 90, `manamax` = 90, `town_id` = 8, `cap` = 470 WHERE `id` = 4;")
	-- Knight Sample
	db.query("UPDATE `players` SET `level` = 8, `vocation` = 4, `health` = 185, `healthmax` = 185, `experience` = 4200, `soul` = 100, `lookbody` = 113, `lookfeet` = 115, `lookhead` = 95, `looklegs` = 39, `looktype` = 129, `mana` = 90, `manamax` = 90, `town_id` = 8, `cap` = 470 WHERE `id` = 5;")
end
