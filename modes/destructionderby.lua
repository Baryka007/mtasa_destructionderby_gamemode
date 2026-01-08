diff --git a/modes/destructionderby.lua b/modes/destructionderby.lua
index 3a6ba4e78a0a48803b9f404e86d01881cc137bea..f4895a17ba09b5612c541385ab45e84ee315af44 100644
--- a/modes/destructionderby.lua
+++ b/modes/destructionderby.lua
@@ -8,62 +8,68 @@ function DestructionDerby:isApplicable()
 end
 
 function DestructionDerby:getPlayerRank(player)
 	return #getActivePlayers()
 end
 
 -- Copy of old updateRank
 function DestructionDerby:updateRanks()
 	for i,player in ipairs(g_Players) do
 		if not isPlayerFinished(player) then
 			local rank = self:getPlayerRank(player)
 			if not rank or rank > 0 then
 				setElementData(player, 'race rank', rank)
 			end
 		end
 	end
 	-- Make text look good at the start
 	if not self.running then
 		for i,player in ipairs(g_Players) do
 			setElementData(player, 'race rank', '' )
 			setElementData(player, 'checkpoint', '' )
 		end
 	end
 end
 
-function DestructionDerby:onPlayerWasted(player)
-	if isActivePlayer(player) then
-		self:handleFinishActivePlayer(player)
-		if getActivePlayerCount() <= 1 then
-			RaceMode.endMap()
-		else
-			TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
-		end
-	end
-	RaceMode.setPlayerIsFinished(player)
-	showBlipsAttachedTo(player, false)
-end
+function DestructionDerby:onPlayerWasted(player)
+	if not isActivePlayer(player) then
+		return
+	end
+	if not self.checkpointBackups[player] then
+		return
+	end
+
+	local respawnTime = RaceMode.getMapOption('respawntime') or g_GameOptions.defaultrespawntime
+	if respawnTime and respawnTime > 0 then
+		Countdown.create(respawnTime / 1000, restorePlayer, 'You will respawn in:', 255, 255, 255, 0.25, 2.5, true, self.id, player):start(player)
+		if respawnTime >= 5000 then
+			TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
+		end
+	else
+		restorePlayer(self.id, player)
+	end
+end
 
 function DestructionDerby:onPlayerQuit(player)
 	if isActivePlayer(player) then
 		self:handleFinishActivePlayer(player)
 		if getActivePlayerCount() <= 1 then
 			RaceMode.endMap()
 		end
 	end
 end
 
 function DestructionDerby:handleFinishActivePlayer(player)
 	-- Update ranking board for player being removed
 	if not self.rankingBoard then
 		self.rankingBoard = RankingBoard:create()
 		self.rankingBoard:setDirection( 'up', getActivePlayerCount() )
 	end
 	local timePassed = self:getTimePassed()
 	self.rankingBoard:add(player, timePassed)
 	-- Do remove
 	local rank = self:getPlayerRank(player)
 	finishActivePlayer(player)
 	if rank and rank > 1 then
 		triggerEvent( "onPlayerFinishDD",player,tonumber( rank ) )
 	end
 	-- Update ranking board if one player left
