/*
 * ============================================================
 *  COD4X - Admin ESP Tool
 *  Version: 1.4
 *  Developer: Gery Kurucz (github.com/gerykurucz)
 * ============================================================
 */

adminesp( target )
{
    self endon("disconnect");
    self endon("end_wallhack");
    level endon("game_ended");

	if(isDefined(self.wallhack))
	{
		for(i=0; i < self.wallhack.size; i++)
		{
			if(isDefined(self.wallhack[i]))
				self.wallhack[i] destroy();
		}
	}

    self.wallhack = [];
    for(i=0; i<5; i++)
    {
        self.wallhack[i] = NewClientHudElem(self);
        self.wallhack[i] setShader("white", 1, 1);
        self.wallhack[i] setWaypoint(true, "white");
        self.wallhack[i].color = (1, 0, 0); 
        self.wallhack[i].alpha = 0; 
    }
    self setClientDvars("waypointIconHeight", 12, "waypointIconWidth", 7);

    if(isDefined(target) && isDefined(target.pers) && isDefined(target.pers["team"]) && (target.pers["team"] == "axis" || target.pers["team"] == "allies"))
        myTeam = target.pers["team"];
    else
        myTeam = self.pers["team"];

    if(myTeam == "axis") targetTeam = "allies";
    else if(myTeam == "allies") targetTeam = "axis";
    else targetTeam = "";

    while(1)
    {
        wait 0.05;

        filteredPlayers = getFilteredEnemies(targetTeam);
        hudIndex = 0;

        for(i=0; i<filteredPlayers.size; i++)
        {
            if(hudIndex >= 5) break;
            p = filteredPlayers[i];
            
            heightOffset = 40;
            if(isDefined(p GetStance() )) {
                stance = p GetStance();
                if (stance == "prone") heightOffset = 12;
                else if (stance == "crouch") heightOffset = 25;
            }

            dist = distance(target.origin, p.origin);
            
            zCompensation = int(dist / 15); 
            
            finalZ = (p.origin[2] + heightOffset) - zCompensation;

            self.wallhack[hudIndex].x = p.origin[0];
            self.wallhack[hudIndex].y = p.origin[1];
            self.wallhack[hudIndex].z = finalZ; 
            
            self.wallhack[hudIndex].alpha = 1;
            hudIndex++;
        }

        for(i=hudIndex; i<5; i++)
        {
            if(isDefined(self.wallhack[i]))
                self.wallhack[i].alpha = 0;
        }
    }
}

fakeSpectate( target )
{
    self endon("disconnect");
    self endon("end_wallhack");
    self endon("stop_fake_spectate");
    target endon("disconnect");

    self freezeControls( true ); 
    
    self setClientDvar("cg_fov", 80);
    self.pers["lastFov"] = 80;

    forwardDist = 60;
    heightOffset = 0;
    pitchOffset = 0;

    while( 1 )
    {
        self.spectatorclient = -1;
        self.killcamentity = -1;

        eyePos = target getEye();
        playerAngles = target getPlayerAngles(); 
        
        forward = anglesToForward( playerAngles );
        
        offsetX = forward[0] * forwardDist;
        offsetY = forward[1] * forwardDist;
        
        offsetZ = (forward[2] * forwardDist) + heightOffset; 
        
        camPos = ( eyePos[0] + offsetX, eyePos[1] + offsetY, eyePos[2] + offsetZ );
        
        newAngles = ( playerAngles[0], playerAngles[1] + pitchOffset, playerAngles[2] );
        
        self setOrigin( camPos );
        self setPlayerAngles( newAngles ); 

		self setClientDvar( "cg_enemyNameFadeOut", "900000" );

		self setClientDvar( "cg_enemyNameFadeIn", "0" );

		self setClientDvar( "cg_drawThroughWalls", "1" );

        ads = target playerADS();

        if( ads > 0 )
        {

            self setOrigin( target.origin + (0, 0, 60) );
            self setPlayerAngles( playerAngles ); 

            newFov = 65;
            if( self.pers["lastFov"] != newFov )
            {
				self.pers["lastFov"] = 65;
				forwardDist = -60;
				heightOffset = 20;
				pitchOffset = 5;
				eyePos = target getEye();
				playerAngles = target getPlayerAngles(); 
				
				forward = anglesToForward( playerAngles );
				
				offsetX = forward[0] * forwardDist;
				offsetY = forward[1] * forwardDist;
				
				offsetZ = (forward[2] * forwardDist) + heightOffset; 
				
				camPos = ( eyePos[0] + offsetX, eyePos[1] + offsetY, eyePos[2] + offsetZ );
				
				newAngles = ( playerAngles[0], playerAngles[1] + pitchOffset, playerAngles[2] );
				
				self setOrigin( camPos );
				self setPlayerAngles( newAngles + camPos + (-500, -500, -30));
            }
        }
        else
        {
			newFov = 80;
            self.pers["lastFov"] = 80;
			forwardDist = 60;
			heightOffset = 0;
			pitchOffset = 0;
			eyePos = target getEye();
			playerAngles = target getPlayerAngles(); 
			
			forward = anglesToForward( playerAngles );
			
			offsetX = forward[0] * forwardDist;
			offsetY = forward[1] * forwardDist;
			
			offsetZ = (forward[2] * forwardDist) + heightOffset; 
			
			camPos = ( eyePos[0] + offsetX, eyePos[1] + offsetY, eyePos[2] + offsetZ );
			
			newAngles = ( playerAngles[0], playerAngles[1] + pitchOffset, playerAngles[2] );
			
			self setOrigin( camPos );
			self setPlayerAngles( newAngles );
        }
        wait 0.05; 
    }
}

getFilteredEnemies( targetTeam )
{
    filtered = [];
    players = level.players;
    
    for(i=0; i<players.size; i++)
    {
        p = players[i];
        if(!isDefined(p)) continue;
        if(p == self || !isDefined(p.sessionstate) || p.sessionstate != "playing") continue;
        if(!isDefined(p.origin) || !isDefined(p.pers) || !isDefined(p.pers["team"])) continue;
        
        if(targetTeam != "" && p.pers["team"] != targetTeam) continue;
        
        dist = distance(self.origin, p.origin);
        if (dist < 300) continue;
        
        if (isPlayerVisible(self, p)) continue;
        
        if (!isLookingAt(p.origin + (0, 0, 40), 0.85)) continue;
        
        filtered[filtered.size] = p;
    }
    

    for (k = 0; k < filtered.size; k++) 
    {
        for (j = k + 1; j < filtered.size; j++) 
        {
            if (distance(self.origin, filtered[k].origin) > distance(self.origin, filtered[j].origin)) 
            {
                temp = filtered[k];
                filtered[k] = filtered[j];
                filtered[j] = temp;
            }
        }
    }
    
    return filtered;
}

isPlayerVisible( eye, player ) 
{
    if(!isDefined(eye) || !isDefined(player))
        return false;

    eyePos = eye getEye(); 
    
    height = 55;
    if(isDefined(player GetStance() )) {
        pStance = player GetStance();
        if (pStance == "prone") height = 12;
        else if (pStance == "crouch") height = 30;
    }
    
    trace1 = bulletTrace(eyePos, player.origin + (0, 0, height), false, eye);
    if (trace1["fraction"] == 1) return true;
    
    trace2 = bulletTrace(eyePos, player.origin + (0, 0, 10), false, eye);
    if (trace2["fraction"] == 1) return true;
    
    trace3 = bulletTrace(eyePos, player.origin + (0, 0, height / 2), false, eye);
    if (trace3["fraction"] == 1) return true;
    
    return false; 
}

isLookingAt( targetPos, threshold )
{
    viewAngles = self getPlayerAngles();
    forward = anglesToForward(viewAngles);
    eyePos = self getEye();
    
    dirX = targetPos[0] - eyePos[0];
    dirY = targetPos[1] - eyePos[1];
    dirZ = targetPos[2] - eyePos[2];
    
    len = sqrt((dirX * dirX) + (dirY * dirY) + (dirZ * dirZ));
    if (len == 0) return false;
    
    dirNormX = dirX / len;
    dirNormY = dirY / len;
    dirNormZ = dirZ / len;
    
    dot = (forward[0] * dirNormX) + (forward[1] * dirNormY) + (forward[2] * dirNormZ);
    
    return (dot >= threshold);
}