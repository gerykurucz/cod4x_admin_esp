/*
 * ============================================================
 *  COD4X - Blitz
 *  Version: 3.2
 *  Developer: Gery Kurucz (github.com/gerykurucz)
 * ============================================================
 */

init()
{
	addscriptcommand( "esp", 1 );
	addscriptcommand( "espoff", 1);
}

commandHandler( cmd, arg )
{
	self endon( "disconnect" );
	level endon( "game_ended" );

	if( !isDefined( self.pers["AdminESP"] ) )
		self.pers["AdminESP"] = 0;

	switch( toLower( cmd ) )
	{		
		case "esp":
			if( isDefined(self.pers) && isDefined(self.pers["team"]) && self.pers["team"] == "spectator" && self.pers["AdminESP"] == 0 )
			{
				target = undefined;
				
				if( isDefined( arg ) && arg != "" )
				{
					targetId = int( arg );
					for( i = 0; i < level.players.size; i++ )
					{
						p = level.players[i];
						if( p getEntityNumber() == targetId )
						{
							target = p;
							break;
						}
					}
				}

				if( isDefined( target ) )
				{
					self iPrintlnBold("^2Nektum Shield: ^7Admin ESP | P: " + target.name);
					self thread gery\_esp::fakeSpectate( target );
					self thread gery\_esp::adminesp( target );
				}

				else
				{
					self iPrintlnBold("^1Nektum Shield: No Target Found!");
					break;
				}
				self.pers["AdminESP"] = 1;
				
				if (isDefined(self.r)) {
					for (k = 0; k < self.r.size; k++) {
						if (isDefined(self.r[k])) {
							self.r[k] destroy();
						}
					}
				}

				self.r = [];
				self.r[0] = newClientHudElem(self);
				self.r[0] setShader("white", 10, 2);
				self.r[0].x = 0; self.r[0].y = 0;
				self.r[0].alignX = "center"; self.r[0].alignY = "middle";
				self.r[0].horzAlign = "center"; self.r[0].vertAlign = "middle";
				self.r[0].alpha = 1; self.r[0].sort = 100;
				self.r[0].color = ( 1, 0, 0 );
				self.r[0].glowColor = ( 1, 0, 0 );
				self.r[0].hideWhenInMenu = true;

				waittillframeend;

				self.r[1] = newClientHudElem(self);
				self.r[1] setShader("white", 2, 10);
				self.r[1].x = 0; self.r[1].y = 0;
				self.r[1].alignX = "center"; self.r[1].alignY = "middle";
				self.r[1].horzAlign = "center"; self.r[1].vertAlign = "middle";
				self.r[1].alpha = 1; self.r[1].sort = 100;
				self.r[1].color = ( 1, 0, 0 );
				self.r[1].glowColor = ( 1, 0, 0 );
				self.r[1].hideWhenInMenu = true;
				
				waittillframeend;
				
				while(self.pers["team"] == "spectator" && self.pers["AdminESP"] == 1)
					wait 1;

				self.pers["AdminESP"] = 0;
				self iPrintlnBold("^1Nektum Shield: ^7Admin ESP ^1OFF");
				self notify("end_wallhack");
				self notify("stop_fake_spectate"); 
				self freezeControls( false ); 
				
				self setClientDvar( "cg_thirdperson", "0" );    
				self setClientDvar( "cg_fov", 80 );
				self setClientDvar( "cg_enemyNameFadeOut", "250" );
				self setClientDvar( "cg_enemyNameFadeIn", "0" );
				self setClientDvar( "cg_drawThroughWalls", "0" );

				if(isDefined(self.wallhack))
				{
					for(i=0; i < self.wallhack.size; i++)
					{
						if(isDefined(self.wallhack[i]))
							self.wallhack[i] destroy();
					}
				}

				if (isDefined(self.r)) {
					for (k = 0; k < self.r.size; k++) {
						if (isDefined(self.r[k])) {
							self.r[k] destroy();
						}
					}
				}
				target = undefined;
			}
			break;

		case "espoff":
			if( self.pers["team"] == "spectator" && self.pers["AdminESP"] == 1)
			{
				self.pers["AdminESP"] = 0;
			}
			else
			{
				iPrintlnBold("^1Nektum Shield: ^7Admin ESP is not active^1!");
			}
			break;
	}
	wait 0.05;
}

rconSupport()
{
	setDvar( "cmd", "" );

	for(;;)
	{
		if( getDvar( "cmd" ) != "" )
		{
			data = strTok( getDvar("cmd"), ":" );

			if( isDefined( data[ 0 ] ) && isDefined( data[ 1 ] ) )
			{
				thread processRcon( data );
				setDvar( "cmd", "" );
			}
		}

		wait .05;
	}
}

processRcon( data )
{
	cmd = data[ 0 ];

	if( data[ 1 ].size > 2 || !isInt( data[ 1 ] ) )
		return;

	player = getEntByNum( int( data[ 1 ] ) );

	if( !isPlayer( player ) )
		return;

	if( isDefined( data[ 2 ] ) )
		args = data[ 2 ];
	else
		args = "";

	player thread commandHandler( cmd, args );
}

isInt( s )
{
	for( i = 0; i < s.size; i++ )
	{
		if( s[ i ] != "0" && !int( s[ i ] ) )
		{
			return false;
		}
	}

	return true;
}