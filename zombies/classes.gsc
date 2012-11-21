/*
    File:           classes.gsc
    Author:         Cheese
    Last update:    11/14/2012
*/


init()
{
    setCvar( "g_TeamColor_Allies", "1 0 0" );
    setCvar( "g_TeamName_Allies", "Zombies" );
    setCvar( "g_TeamColor_Axis", "1 0 1" );
    setCvar( "g_TeamName_Axis", "Hunters" );
    
    level.classes = [];
    level.classes[ "hunters" ] = [];
    level.classes[ "zombies" ] = [];
    
    [[ level.register ]]( "classes_main", ::selectClass );
    [[ level.register ]]( "classes_loadout", ::loadout );
    [[ level.register ]]( "classes_hunter_default", ::hunterClass_default );
    [[ level.register ]]( "classes_hunter_default_loadout", ::hunterClass_default_loadout );
    [[ level.register ]]( "be_poisoned", ::be_poisoned, level.iFLAG_THREAD );
    [[ level.register ]]( "be_shocked", ::be_shocked, level.iFLAG_THREAD );
    [[ level.register ]]( "get_class_information", ::get_class_information, level.iFLAG_RETURN );
    
    [[ level.call ]]( "precache", &"Select A Class", "string" );
    [[ level.call ]]( "precache", &"You are a", "string" );
    [[ level.call ]]( "precache", &"Hunter", "string" );
    [[ level.call ]]( "precache", &"Zombie", "string" );
    [[ level.call ]]( "precache", &"Timeout in: ", "string" );
    [[ level.call ]]( "precache", &"Hold [{+activate}] to get ammo", "string" );
    [[ level.call ]]( "precache", &"Ammo left until depleted: ", "string" );
    [[ level.call ]]( "precache", &"Press [{+attack}] to change selection", "string" );
    [[ level.call ]]( "precache", &"Press [{+activate}] to spawn", "string" );
    [[ level.call ]]( "precache", &"Ammo remaining: ", "string" );
    [[ level.call ]]( "precache", &"Reloading... time remaining: ", "string" );
    [[ level.call ]]( "precache", &"Sentry status: ", "string" );
    [[ level.call ]]( "precache", &"Sentry health: ", "string" );
    [[ level.call ]]( "precache", &"Idle", "string" );
    [[ level.call ]]( "precache", &"Firing", "string" );
    [[ level.call ]]( "precache", &"Reloading", "string" );
    [[ level.call ]]( "precache", "gfx/hud/hud@health_bar.dds", "shader" );
    [[ level.call ]]( "precache", "gfx/hud/hud@health_back.dds", "shader" );
    
    [[ level.call ]]( "precache", "xmodel/crate_misc1", "model" );
    [[ level.call ]]( "precache", "xmodel/crate_misc_red1", "model" );
    [[ level.call ]]( "precache", "xmodel/crate_misc_green1", "model" );
    [[ level.call ]]( "precache", "xmodel/crate_champagne3", "model" );
    [[ level.call ]]( "precache", "xmodel/barrel_black1", "model" );
    [[ level.call ]]( "precache", "xmodel/mg42_bipod", "model" );
    
    //        <team>        <localized>     <string>     <description>                                                   line break|
    addClass( "hunters",    &"Default",     "default",   &"The basic hunter class. You can select any weapon you want.", &"" );
    addClass( "hunters",    &"Scout",       "scout",     &"A recon class, the scout is equipped with a shotgun and a pistol.", &"Health: 125\nMove Speed: 1.3x" );
    addClass( "hunters",    &"Soldier",     "soldier",   &"Panzerfaust and MP40 in hand, this is one class you don't want to mess\nwith.", &"Health: 200\nMove Speed: 1x" );
    addClass( "hunters",    &"Sniper",      "sniper",    &"Sniper stuff.", &"" );
    addClass( "hunters",    &"Support",     "support",   &"", &"" );
    addClass( "hunters",    &"Medic",       "medic",     &"", &"" );
    addClass( "hunters",    &"Engineer",    "engineer",  &"", &"" );
    addClass( "hunters",    &"Heavy",       "heavy",     &"", &"" );
    addClass( "hunters",    &"Random",      "random",   &"Let the game decide a class for you.", &"Will be determined once spawned." );
    
    //        <team>        <localized>     <string>    <description>                                                   line break|
    addClass( "zombies",    &"Default",     "default",  &"The basic zombie class. No perks, just pure death.", &"" );
	addClass( "zombies",    &"Fast",        "fast",     &"Faster than any hunter, this zombie can easily catch up to any one\nwithin reach!", &"Health: 150\nMove Speed: 1.5x" );
	addClass( "zombies",    &"Inferno",     "inferno",  &"A fiery zombie from the depths of hell! This zombie will catch other\nzombies and hunters on fire in a close proximity.", &"Health: 200\nMove Speed: 1.0x" );
	addClass( "zombies",    &"Jumper",      "jumper",   &"Agile to the core, the jumper zombie can get almost anywhere, ready to\npounce unsuspecting prey!", &"Health: 200\nMove Speed: 1.0x" );
	addClass( "zombies",    &"Poison",      "poison",   &"A toxic spill waiting to happen, the poison zombie will infect hunters\nwith a deadly smack.", &"Health: 300\nMove Speed: 0.9x" );
	addClass( "zombies",    &"Shocker",     "shocker",  &"Electrified by lightning, the shocker can easily put a damper on your\nday!", &"Health: 200\nMove Speed: 1.0x" );
	addClass( "zombies",    &"Random",      "random",   &"Let the game decide a class for you.", &"Will be determined once spawned." );
}

addClass( team, lName, sName, lDescription, lPerks ) 
{
	if ( !isDefined( level.classes[ team ] ) )
		return;
		
	[[ level.call ]]( "precache", lName, "string" );
	[[ level.call ]]( "precache", lDescription, "string" );
	[[ level.call ]]( "precache", lPerks, "string" );
		
	this = spawnstruct();
	this.team = team;
	this.lName = lName;
	this.lDescription = lDescription;
	this.lPerks = lPerks;
	this.sName = sName;
	
	size = level.classes[ team ].size;
	level.classes[ team ][ size ] = this;
}

get_class_information( sName, sTeam, o3, o4, o5, o6, o7, o8, o9 )
{
    thisclass = undefined;
    for ( i = 0; i < level.classes[ sTeam ].size; i++ )
    {
        if ( level.classes[ sTeam ][ i ].sName == sName )
        {
            thisclass = level.classes[ sTeam ][ i ];
            break;
        }
    }
    
    return thisclass;
}

selectClassHud( player, x, y, alignx, aligny, sort, alpha, fontscale ) 
{
	if ( !isDefined( player ) )				return;
	if ( !isDefined( x ) ) 					x = 320;
	if ( !isDefined( y ) )					y = 240;
	if ( !isDefined( alignx ) )				alignx = "left";
	if ( !isDefined( aligny ) )				aligny = "top";
	if ( !isDefined( sort ) )				sort = 1;
	if ( !isDefined( alpha ) ) 				alpha = 1;
	if ( !isDefined( fontscale ) )			fontscale = 1;

	temp = newClientHudElem( player );
	temp.x = x;
	temp.y = y;
	temp.alignx = alignx;
	temp.aligny = aligny;
	temp.sort = sort;
	temp.alpha = alpha;
	temp.fontscale = fontscale;
	
	return temp;
}	

selectClassFadeOut( time ) 
{
	self fadeOverTime( time );
	self.alpha = 0;
	
	wait ( time + 0.05 );
	
	self destroy();
}

selectClass()
{
    self endon( "disconnect" );
    self endon( "select class notify stop" );
    
    self.atclassmenu = true;
    
	if ( isDefined( self.chud ) )
		self selectClass_destroy();
    
    self.chud = [];
    
    // left side selector for classes
    self.chud[ "left side select bg" ] = selectClassHud( self, 8, 8, "left", "top", 9000, 1, undefined );
    self.chud[ "left side select bg" ] setShader( "black", 196, 464 );
    self.chud[ "left side select line left" ] = selectClassHud( self, 10, 10, "left", "top", 9001, 0.3, undefined );
    self.chud[ "left side select line left" ] setShader( "white", 2, 460 );
    self.chud[ "left side select line up" ] = selectClassHud( self, 12, 10, "left", "top", 9001, 0.3, undefined );
    self.chud[ "left side select line up" ] setShader( "white", 188, 2 );
    self.chud[ "left side select line right" ] = selectClassHud( self, 200, 10, "left", "top", 9001, 0.3, undefined );
    self.chud[ "left side select line right" ] setShader( "white", 2, 460 );
    self.chud[ "left side select line bot" ] = selectClassHud( self, 12, 468, "left", "top", 9001, 0.3, undefined );
    self.chud[ "left side select line bot" ] setShader( "white", 188, 2 );
    self.chud[ "left side select line divider" ] = selectClassHud( self, 12, 68, "left", "top", 9001, 0.3, undefined );
    self.chud[ "left side select line divider" ] setShader( "white", 188, 2 );
    self.chud[ "left side select text" ] = selectClassHud( self, 104, 24, "center", "top", 9001, 1, 2 );
    self.chud[ "left side select text" ] setText( &"Select A Class" );
    self.chud[ "left side select line divider2" ] = selectClassHud( self, 12, 432, "left", "top", 9001, 0.3, undefined );
    self.chud[ "left side select line divider2" ] setShader( "white", 188, 2 );
    self.chud[ "left side select autoselect" ] = selectClassHud( self, 104, 450, "center", "middle", 9001, 1, 1 );
    self.chud[ "left side select autoselect" ].label = &"Timeout in: ";
    
    // right side info for classes
    self.chud[ "right side info bg" ] = selectClassHud( self, 632, 472, "right", "bottom", 9000, 1, undefined );
    self.chud[ "right side info bg" ] setShader( "black", 424, 220 );
    self.chud[ "right side info line right" ] = selectClassHud( self, 630, 470, "right", "bottom", 9001, 0.3, undefined );
    self.chud[ "right side info line right" ] setShader( "white", 2, 216 );
    self.chud[ "right side info line bot" ] = selectClassHud( self, 628, 470, "right", "bottom", 9001, 0.3, undefined );
    self.chud[ "right side info line bot" ] setShader( "white", 416, 2 );
    self.chud[ "right side info line left" ] = selectClassHud( self, 212, 470, "right", "bottom", 9001, 0.3, undefined );
    self.chud[ "right side info line left" ] setShader( "white", 2, 216 );
    self.chud[ "right side info line up" ] = selectClassHud( self, 628, 256, "right", "bottom", 9001, 0.3, undefined );
    self.chud[ "right side info line up" ] setShader( "white", 416, 2 );
    
    // you are a ...
    self.chud[ "team notify you" ] = selectClassHud( self, 422, 108, "center", "top", 9001, 1, 1 );
    self.chud[ "team notify you" ] setText( &"You are a" );
    self.chud[ "team notify team" ] = selectClassHud( self, 424, 112, "center", "top", 9001, 1, 4 );
    
    // for those who don't know what to do :p
	self.chud[ "attack" ] = selectClassHud( self, 412, 424, "center", "middle", 9003, 1, 1.25 );
	self.chud[ "attack" ].color = ( 1, 0, 0 );
	self.chud[ "attack" ] setText( &"Press [{+attack}] to change selection" );
	
	self.chud[ "use" ] = selectClassHud( self, 412, 448, "center", "middle", 9003, 1, 1.4 );
	self.chud[ "use" ].color = ( 0, 1, 0 );
	self.chud[ "use" ] setText( &"Press [{+activate}] to spawn" );
    
    if ( self.pers[ "team" ] == "allies" )
    {
        self.chud[ "team notify team" ] setText( &"Zombie" );
        self.chud[ "team notify team" ].color = ( 1, 0, 0 );
    }
    else
    {
        self.chud[ "team notify team" ] setText( &"Hunter" );
        self.chud[ "team notify team" ].color = ( 1, 0, 1 );
    }
    
    if ( self.pers[ "team" ] == "allies" )
        myclasses = level.classes[ "zombies" ];
    else
        myclasses = level.classes[ "hunters" ];
	self.chud[ "classes" ] = [];
    
    startx = 106;
	starty = 90;
	
    // fill out class list
	for ( i = 0; i < myclasses.size; i++ ) {
		m = myclasses[ i ];
		s = self.chud[ "classes" ].size;
		self.chud[ "classes" ][ s ] = selectClassHud( self, startx, starty, "center", "middle", 9002, 1, 1.4 );
		self.chud[ "classes" ][ s ] setText( m.lName );
		
		if ( !self.isRegistered && s != 0 )
			self.chud[ "classes" ][ s ].color = ( 0.1, 0.1, 0.1 );
		
		starty += 32;
	}
	
	// class selector
	self.chud[ "selector" ] = selectClassHud( self, startx, 90, "center", "middle", 9003, 0.3, undefined );
	self.chud[ "selector" ].color = ( 0, 1, 0 );
	self.chud[ "selector" ] setShader( "white", 188, 32 );
    
    // class description
	self.chud[ "desc" ] = selectClassHud( self, 216, 264, undefined, "middle", 9003, 1, 1 );
	self.chud[ "desc" ].label = &"Description:\n    ";
	
	// perk description
	//self.chud[ "perks" ] = selectClassHud( self, 236, 160, undefined, "middle", 9003, 1, 1.3 );
	//self.chud[ "perks" ].label = &"Perks:\n";
    
    self thread selectClass_menuStopper();
    self thread selectClass_notifyStop();
    self thread selectClass_timeout();
    
    index = 0;
    self.chudselectedclass = myclasses[ index ];
    
	self.chud[ "desc" ] setText( myclasses[ index ].lDescription );
	//self.chud[ "perks" ] setText( myclasses[ index ].lPerks );
    
    wait 0.5;
	
	while ( 1 ) 
    {
		wait 0.05;
		
		// go to next class, update info
		if ( self attackbuttonpressed() && self.isRegistered ) {
			if ( !hasattacked ) {
				hasattacked = true;
				//self.chud[ "auto" ] fadeOverTime( 0.5 );
				//self.chud[ "auto" ].alpha = 1;
			}
			
			pausedtime = 0;
			index++;
			
			if ( index > myclasses.size - 1 )
				index = 0;
				
			self.chud[ "selector" ] moveOverTime( 0.1 );
			self.chud[ "selector" ].y = self.chud[ "classes" ][ index ].y + 2; // safe?
            self.chudselectedclass = myclasses[ index ];
            
            self.chud[ "desc" ] fadeOverTime( 0.05 );
			self.chud[ "desc" ].alpha = 0;
			//self.chud[ "perks" ] fadeOverTime( 0.05 );
			//self.chud[ "perks" ].alpha = 0;
			
			wait 0.05;
			
			self.chud[ "desc" ] setText( myclasses[ index ].lDescription );
			self.chud[ "desc" ] fadeOverTime( 0.05 );
			self.chud[ "desc" ].alpha = 1;
			//self.chud[ "perks" ] setText( myclasses[ index ].lPerks );
			//self.chud[ "perks" ] fadeOverTime( 0.05 );
			//self.chud[ "perks" ].alpha = 1;
            
            wait 0.05;
		}
		
		// SPAWN TIME!
		if ( self usebuttonpressed() ) {
			self.class = self.chudselectedclass.sName;
			break;
		}
	}
    
	self.atclassmenu = undefined;
	self notify( "select class notify stop" );
}

selectClass_destroy()
{
    self.chud[ "left side select bg" ]              thread selectClassFadeOut( 0.5 );
    self.chud[ "left side select line left" ]       thread selectClassFadeOut( 0.5 );
    self.chud[ "left side select line up" ]         thread selectClassFadeOut( 0.5 );
    self.chud[ "left side select line right" ]      thread selectClassFadeOut( 0.5 );
    self.chud[ "left side select line bot" ]        thread selectClassFadeOut( 0.5 );
    self.chud[ "left side select line divider" ]    thread selectClassFadeOut( 0.5 );
    self.chud[ "left side select text" ]            thread selectClassFadeOut( 0.5 );
    self.chud[ "left side select line divider2" ]   thread selectClassFadeOut( 0.5 );
    self.chud[ "left side select autoselect" ]      thread selectClassFadeOut( 0.5 );
    self.chud[ "right side info bg" ]               thread selectClassFadeOut( 0.5 );
    self.chud[ "right side info line right" ]       thread selectClassFadeOut( 0.5 );
    self.chud[ "right side info line bot" ]         thread selectClassFadeOut( 0.5 );
    self.chud[ "right side info line left" ]        thread selectClassFadeOut( 0.5 );
    self.chud[ "right side info line up" ]          thread selectClassFadeOut( 0.5 );
    self.chud[ "team notify you" ]                  thread selectClassFadeOut( 0.5 );
    self.chud[ "team notify team" ]                 thread selectClassFadeOut( 0.5 );
    self.chud[ "attack" ]                           thread selectClassFadeOut( 0.5 );
    self.chud[ "use" ]                              thread selectClassFadeOut( 0.5 );
    
	for ( i = 0; i < self.chud[ "classes" ].size; i++ )         
        self.chud[ "classes" ][ i ] thread selectClassFadeOut( 0.5 );

	self.chud[ "selector" ]                         thread selectClassFadeOut( 0.5 );
    self.chud[ "desc" ]                             thread selectClassFadeOut( 0.5 );
    //self.chud[ "perks" ]                            thread selectClassFadeOut( 0.5 );
    
    wait 0.6;
    self.chud = undefined;
    self.atclassmenu = undefined;
}


selectClass_menuStopper() 
{
	self endon( "select class notify stop" );
	
	while ( 1 ) {
		self waittill( "menuresponse", menu, response );
		break;
	}
	
	self.pers[ "team" ] = "spectator";
	self.pers[ "weapon" ] = undefined;
	self.pers[ "savedmodel" ] = undefined;
	self.team = "spectator";
	self.sessionteam = "spectator";
	self.sessionstate = "spectator";
	self notify( "select class notify stop" );
    self [[ level.call ]]( "spawn_spectator" );
}

selectClass_notifyStop() 
{
	self waittill( "select class notify stop" );
	self thread selectClass_destroy();
}

selectClass_timeout() 
{	
    self endon( "select class notify stop" );
	
	self.chud[ "left side select autoselect" ] setTimer( 60 );
	time = 0;
	while ( 1 ) {
		wait 0.05;
		
		if ( self attackButtonPressed() ) {
			time = 0;
			self.chud[ "left side select autoselect" ] setTimer( 60 );
		}
			
		if ( time > 60 )
			break;
			
		time += 0.05;
	}
	
	self notify( "select class notify stop" );
    
    self [[ level.call ]]( "print", "Moved to spectator for AFK", true );
    self [[ level.call ]]( "spawn_spectator" );
}

zombieClasses() 
{
	// base class values
	self.health = 500;
	self.maxhealth = 500;
	
	if ( !isDefined( self.class ) )
		return;
		
	if ( self.class == "random" ) 
    {
		r = randomInt( level.classes[ "zombies" ].size - 1 );	// minus the random one
		self.class = level.classes[ "zombies" ][ r ].sName;
	}
		
	weapon = "enfield_mp";
		
	switch ( self.class ) 
    {
		case "jumper": self thread zombieClass_jumper(); break;
		case "inferno": self thread zombieClass_fire(); break;
		case "shocker": self thread zombieClass_shocker(); break;
		case "poison": weapon = "bren_mp"; self thread zombieClass_poison(); break;
		case "fast": weapon = "sten_mp"; self thread zombieClass_fast(); break;
			break;
		default:
			// unknown class:o
			break;
	}
    
    self.pers[ "weapon" ] = weapon;
	
	self giveWeapon( weapon );
	self setWeaponSlotAmmo( "primary", 0 );
	self setWeaponSlotClipAmmo( "primary", 0 );
	self setSpawnWeapon( weapon );
}

// original code from brax's 1.5 zombie mod
// heavily modified by Cheese :)
zombieClass_jumper() 
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_respawn" );

	wait 1;
    
    doublejumped = false;
    self.jumpblocked = false;
    airjumps = 0;
	while ( 1 ) {
		if ( self useButtonPressed() && !self.jumpblocked ) 
        {
            if ( !self isOnGround() )
                airjumps++;
                
            if ( airjumps == 2 ) {
                airjumps = 0;
                self thread blockjump();
            }

			for ( i = 0; i < 2; i++ ) 
            {
				self.health += 2000;
				self finishPlayerDamage(self, self, 2000, 0, "MOD_PROJECTILE", "panzerfaust_mp", (self.origin + (0,0,-1)), vectornormalize(self.origin - (self.origin + (0,0,-1))), "none");
			}
			wait 1;
		}
		wait 0.05;
	}
}

blockjump() 
{
    self.jumpblocked = true;
    
    while ( !self isOnGround() )
        wait 0.05;
        
    self.jumpblocked = false;
}

zombieClass_poison() 
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_respawn" );
	
	self.maxhealth = 750;
	self.health = 750;
}

be_poisoned( dude )
{	
    //self endon( "death" );
    self endon( "disconnect" );
    self endon( "end_respawn" );
    
    self.ispoisoned = true;
    
	self.poisonhud = newClientHudElem( self );
	self.poisonhud.x = 0;
	self.poisonhud.y = 0;
	self.poisonhud setShader( "white", 640, 480 );
	self.poisonhud.color = ( 0, 1, 0 );
	self.poisonhud.alpha = 0.1;
	self.poisonhud.sort = 1;
	
	self iPrintLnBold( "You have been ^2poisoned^7!" );
	
	while ( isAlive( self ) && isDefined( self.ispoisoned ) )
	{
		oldhealth = self.health;
		
		dmg = 5;
		
		self finishPlayerDamage( dude, dude, dmg, 0, "MOD_MELEE", "bren_mp", self.origin, ( 0, 0, 0 ), "none" );
		
		wait 2;
		
		if ( self.health > oldhealth )
			break;
	}
	
	self.poisonhud destroy();
	self.ispoisoned = undefined;
}

zombieClass_fire() 
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_respawn" );
    
    self thread firemonitor( self );
}

firemonitor( dude )
{	
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_respawn" );
	self endon( "stopfire" );
	
	self.onfire = true;
	
	if ( self.pers[ "team" ] == "axis" )
		self thread firedeath( dude );
	
	while ( 1 )
	{
		playFx( level._effect[ "zombies_fire" ], self.origin + ( 0, 0, 32 ) );
		
		players = [[ level.call ]]( "get_good_players" );
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[ i ] != self && ( distance( self.origin, players[ i ].origin ) < 36 && !isDefined( players[ i ].onfire ) ) )
				players[ i ] thread firemonitor( dude );
		}
		
		wait 0.1;
	}
}

firedeath( dude )
{
	self iPrintLnBold( "You are on ^1fire^7!" );
	
	while ( isAlive( self ) && isDefined( self.onfire ) )
	{
		oldhealth = self.health;
		
		self finishPlayerDamage( dude, dude, 3, 0, "MOD_MELEE", "enfield_mp", self.origin, ( 0, 0, 0 ), "none" );
		
		wait 0.75;
		
		if ( self.health > oldhealth )
			break;
	}
	
	self notify( "stopfire" );
	self.onfire = undefined;
}

zombieClass_fast() 
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_respawn" );
	
	self.maxhealth = 250;
	self.health = 250;
}

zombieClass_shocker() 
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_respawn" );
}

be_shocked( dude )
{
    self shellshock( "groggy", 2 );
}

hunterClasses() {
	// base class values
	self.health = 100;
	self.maxhealth = 100;
	
	if ( !isDefined( self.class ) )
		return;
		
	if ( self.class == "random" ) {
		r = randomInt( level.classes[ "hunters" ].size - 1 );	// minus the random one
		self.class = level.classes[ "hunters" ][ r ].sName;
	}
	
	weapon = "";
		
	switch ( self.class ) {
		default:
            case "scout":               weapon = "ppsh_mp";             self hunterClass_scout();               break;
            case "soldier":             weapon = "panzerfaust_mp";      self hunterClass_soldier();             break;
            case "sniper":              weapon = "kar98k_sniper_mp";    self hunterClass_sniper();              break;
            case "support":             weapon = "mp44_mp";             self hunterClass_support();             break;
            case "medic":               weapon = "thompson_mp";         self hunterClass_medic();               break;
            case "engineer":            weapon = "m1garand_mp";         self hunterClass_engineer();            break;
            case "heavy":               weapon = "fg42_mp";             self hunterClass_heavy();               break;
			// unknown class:o
			break;
	}
	
    self.pers[ "weapon" ] = weapon;
	self giveWeapon( weapon );
	self giveMaxAmmo( weapon );
	self setSpawnWeapon( weapon );
    
    if ( self.class != "soldier" )
        self setWeaponSlotClipAmmo( "primary", 0 );
	
	self hunterClass_updateAmmo();	
	
	self.health = self.maxhealth;
}

hunterClass_default_loadout()
{
    self giveWeapon( "luger_mp" );
    self giveWeapon( "stielhandgranate_mp" );   
    self setWeaponSlotAmmo( "grenade", 1 );
}

hunterClass_default() {
	self endon( "death" );
	
	self openMenu( "weapon_americangerman" );
	
	weapon = "";
	
	while ( 1 )
	{
		self waittill( "menuresponse", menu, response );
		
        // don't allow 'default' players to exit out of a weapon choice
		if ( response == "open" )
			continue;
		
		if ( response == "close" )
		{
			self openMenu( "weapon_americangerman" );
			continue;
		}
			
		if ( menu == "weapon_americangerman" )
		{
			if ( response == "team" || response == "viewmap" || response == "callvote" )
			{
				self closeMenu();
				wait 0.05;
				self openMenu( "weapon_americangerman" );
				continue;
			}
			
			self.pers[ "weapon" ] = response;
			break;
		}
	}
	
	wait 0.05;
	
	self.maxhealth = 100;
	self.health = self.maxhealth;
}

hunterClass_scout() {
    self.maxhealth = 125;
    
    self giveWeapon( "colt_mp" );
}

hunterClass_soldier() {
    self.maxhealth = 200;
    
    self setWeaponSlotWeapon( "primaryb", "mp40_mp" );
    self giveMaxAmmo( "mp40_mp" );
}

hunterClass_heavy() {
	self.maxhealth = 300;
    
    self setWeaponSlotWeapon( "primaryb", "bar_mp" );
    self giveMaxAmmo( "bar_mp" );
}

hunterClass_engineer() {
    self.maxhealth = 125;
    self setWeaponSlotWeapon( "grenade", "mk1britishfrag_mp" );
    self setWeaponSlotAmmo( "grenade", 0 );
    
    self thread sentry();
}

sentry()
{   
    barrel = spawn( "script_model", self getOrigin() );
    barrel setModel( "xmodel/barrel_black1" );
    
    while ( isAlive( self ) )
    {  
        wait 0.05;
        
        barrel hide();
        
        if ( self getCurrentWeapon() != "mk1britishfrag_mp" )
            continue;

        barrel show();
        traceDir = anglesToForward( self.angles );
        traceEnd = self.origin;
        traceEnd += [[ level.call ]]( "vector_scale", traceDir, 80 );
        trace = bulletTrace( self.origin, traceEnd, false, barrel );

        pos = trace[ "position" ];
        barrel moveto( pos, 0.05 );
        barrel.angles = self.angles;
            
        // stoled from lev
        if ( self useButtonPressed() )
        {
            catch_next = false;
            lol = false;

			for ( i = 0; i <= 0.30; i += 0.01 )
			{
				if ( catch_next && self useButtonPressed() )
				{
					lol = true;
					break;
				}
				else if ( !( self useButtonPressed() ) )
					catch_next = true;

				wait 0.01;
			}
            
            if ( lol )
                break;
        }
        
        wait 0.05;
    }
    
    if ( !isAlive( self ) )
    {
        barrel delete();
        return;
    }
    
    trace = bullettrace( barrel.origin, barrel.origin + ( 0, 0, -1024 ), false, undefined );
    barrel moveto( trace[ "position" ], 0.1 );
    
    self iprintln( "sentry placed!" );
    
    self switchToWeapon( self getWeaponSlotWeapon( "primary" ) );
    self setWeaponSlotWeapon( "grenade", "none" );
    
    wait 0.15;
    
    self thread sentry_remove();
    self thread sentry_think( barrel );
    
    self waittill( "remove sentry" );
    barrel delete();
}

sentry_remove()
{
    self waittill( "death" );
    self notify( "remove sentry" );
}

mg_remove( mg )
{
    self waittill( "remove sentry" );
    self.mg delete();
    self.mg = undefined;
}

sentry_think( barrel )
{     
    self.mg = spawn( "script_model", barrel getOrigin() + ( 0, 0, 42 ) );
    self.mg setModel( "xmodel/mg42_bipod" );
    
    self thread mg_remove( self.mg );
    self thread sentry_hud( self.mg );
       
    self.mg.ammo = 50;
    self.mg.health = 100;
    
    while ( isAlive( self ) && isDefined( self.mg ) )
    {
        wait 0.02;
        
        self sentry_aim();
        self sentry_damage_detect();
    }
}

sentry_aim()
{
    // do stuff here
    players = [[ level.call ]]( "get_good_players" );
    bestplayer = undefined;
    bestdist = level.fogdist - 250;
    for ( i = 0; i < players.size; i++ )
    {               
        if ( distance( self.mg.origin, players[ i ].origin ) < bestdist && players[ i ].pers[ "team" ] == "allies" )
        {
            trace = bullettrace( self.mg.origin, players[ i ].origin + ( 0, 0, 60 ), true, players[ i ] );
            if ( trace[ "fraction" ] != 1 )
                continue;
                
            bestplayer = players[ i ];
            bestdist = distance( self.mg.origin, players[ i ].origin );
        }
    }
    
    if ( isDefined( bestplayer ) )
    {
        x = bestplayer [[ level.call ]]( "get_stance", true );
        trace = bullettrace( self.mg.origin, bestplayer.origin + ( 0, 0, x - 8 ), true, bestplayer );
        if ( trace[ "fraction" ] != 1 )
            return;
            
        self.mg.angles = vectorToAngles( vectorNormalize( ( bestplayer.origin + ( 0, 0, x - 20 ) ) - self.mg.origin ) );
        
        if ( !isDefined( self.mg.isfiring ) )
            self.mg thread sentry_fire( bestplayer, self, x );
    }
}

sentry_damage_detect()
{
    doHit = false;
    players = [[ level.call ]]( "get_good_players" );
    for ( i = 0; i < players.size; i++ )
    {
        if ( distance( self.mg.origin, players[ i ].origin ) < 52 )
        {
            if ( players[ i ].pers[ "team" ] == "allies" && players[ i ].class == "shocker" && players[ i ] meleeButtonPressed() )
            {
                players[ i ] playSound( "melee_hit" );
                doHit = true;
                break;
            }
            
            if ( players[ i ] == self )
            {
                self.mg.health += 1;
                if ( self.mg.health > 100 )
                    self.mg.health = 100;
            }
        }
    }
    
    if ( doHit )
    {
        self.mg.health -= [[ level.call ]]( "rand_range", 15, 45 );
        if ( self.mg.health <= 0 )
            self sentry_explode();
            
        // melee time from lee enfield
        wait 0.8;
    }
}

sentry_explode()
{
    playFx( level._effect[ "sentry_explode" ], self.mg.origin );
    wait 0.05;
    
    self notify( "remove sentry" );
}

sentry_fire( target, owner, x )
{
    if ( self.ammo == 0 )
    {
        if ( !isDefined( self.reloading ) )
            self thread sentry_reload( owner );
            
        return;
    }
        
    self.isfiring = true;
    
    // hurt with mg42_bipod_stand_mp :)
    stance = target [[ level.call ]]( "get_stance" );

    self playSound( "weap_bren_fire" );
    playFxOnTag( level._effect[ "sentry_fire" ], self, "tag_flash" );
    
    trace = bullettrace( origin, target.origin + ( 0, 0, 16 ), false, undefined );
    trace2 = bullettrace( origin, target.origin + ( 0, 0, 40 ), false, undefined );
    trace3 = bullettrace( origin, target.origin + ( 0, 0, 60 ), false, undefined );

    hitloc = "torso_upper";
    if ( trace3[ "fraction" ] != 1 && trace2[ "fraction" ] == 1 )
        hitloc = "torso_lower";
    if ( trace3[ "fraction" ] != 1 && trace2[ "fraction" ] != 1 && trace[ "fraction" ] == 1 )
    {
        s = "left";
        if ( [[ level.call ]]( "rand", 100 ) > 50 )
            s = "right";
            
        hitloc = s + "_leg_upper";
    }
    
    dist = distance( target.origin, self.origin );
    maxdist = 1024;
    distanceModifier = ( (maxdist/2) - dist ) / maxdist + 1;
    if ( dist > maxdist )
        distanceModifier = 0.5;

    target [[ level.call ]]( "player_damage", owner, owner, 5 * distanceModifier, 0, "MOD_RIFLE_BULLET", "mg42_bipod_stand_mp", target.origin + ( 0, 0, x - 20 ), vectornormalize( target.origin - self.origin ), hitloc );

    wait 0.2;
    
    self.ammo--;
    
    // every 10th shot has a chance of lowering the health by 1-3 points
    if ( self.ammo % 10 == 0 && [[ level.call ]]( "rand", 100 ) > 50 )
        self.health -= [[ level.call ]]( "rand_range", 1, 5 );
        
    self.isfiring = undefined;
}

sentry_reload( owner )
{
    self.reloading = true;
    
    self.time = 11;
    self.timeup = 0;
    
    while ( self.time > 0 )
    {
        wait 0.1;
        self.time -= 0.1;
        self.timeup += 0.1;
    }

    self.time = undefined;
    self.timeup = undefined;
    self.reloading = undefined;
    
    self.ammo = 50;
}

sentry_hud( mg )
{
    self endon( "disconnect" );
    
    self.sentry_hud_back = newClientHudElem( self );
	self.sentry_hud_back.x = 630;
	self.sentry_hud_back.y = 400;
	self.sentry_hud_back.alignx = "right";
	self.sentry_hud_back.aligny = "middle";
	self.sentry_hud_back.alpha = 0.7;
	self.sentry_hud_back setShader( "gfx/hud/hud@health_back.dds", 116, 10 );
	self.sentry_hud_back.sort = 10;
	
	self.sentry_hud_front = newClientHudElem( self );
	self.sentry_hud_front.x = 628;
	self.sentry_hud_front.y = 400;
	self.sentry_hud_front.alignx = "right";
	self.sentry_hud_front.aligny = "middle";
	self.sentry_hud_front.alpha = 0.8;
	self.sentry_hud_front setShader( "gfx/hud/hud@health_bar.dds", 112, 8 );
	self.sentry_hud_front.sort = 20;
	
	self.sentry_hud_notice = newClientHudElem( self );
	self.sentry_hud_notice.x = 572;
	self.sentry_hud_notice.y = 400;
	self.sentry_hud_notice.alignx = "center";
	self.sentry_hud_notice.aligny = "middle";
	self.sentry_hud_notice.alpha = 1;
	self.sentry_hud_notice.sort = 25;
    self.sentry_hud_notice.fontscale = 0.7;
    self.sentry_hud_notice.label = &"Sentry status: ";
    
    self.sentry_hud_health_back = newClientHudElem( self );
	self.sentry_hud_health_back.x = 630;
	self.sentry_hud_health_back.y = 388;
	self.sentry_hud_health_back.alignx = "right";
	self.sentry_hud_health_back.aligny = "middle";
	self.sentry_hud_health_back.alpha = 0.7;
	self.sentry_hud_health_back setShader( "gfx/hud/hud@health_back.dds", 116, 10 );
	self.sentry_hud_health_back.sort = 10;
	
	self.sentry_hud_health_front = newClientHudElem( self );
	self.sentry_hud_health_front.x = 628;
	self.sentry_hud_health_front.y = 388;
	self.sentry_hud_health_front.alignx = "right";
	self.sentry_hud_health_front.aligny = "middle";
	self.sentry_hud_health_front.alpha = 0.8;
    self.sentry_hud_health_front.color = ( 0, 0, 1 );
	self.sentry_hud_health_front setShader( "gfx/hud/hud@health_bar.dds", 112, 8 );
	self.sentry_hud_health_front.sort = 20;
    
    self.sentry_hud_health = newClientHudElem( self );
	self.sentry_hud_health.x = 572;
	self.sentry_hud_health.y = 388;
	self.sentry_hud_health.alignx = "center";
	self.sentry_hud_health.aligny = "middle";
	self.sentry_hud_health.alpha = 1;
	self.sentry_hud_health.sort = 25;
    self.sentry_hud_health.fontscale = 0.7;
    self.sentry_hud_health.label = &"Sentry health: ";
    
    while ( isAlive( self ) && isDefined( self.mg ) )
    {       
        if ( isDefined( mg.isfiring ) )
        {
            self.sentry_hud_front.alpha = 0;
            self.sentry_hud_notice.color = ( 0, 1, 0 );
            self.sentry_hud_notice setText( &"Firing" );
        }        
        else if ( isDefined( mg.reloading ) )
        {
            self.sentry_hud_front.alpha = 1;
            self.sentry_hud_front.color = ( 1, 0, 0 );
            self.sentry_hud_front setShader( "white", mg.timeup * 11.2, 8 );
            self.sentry_hud_notice.color = ( 1, 1, 1 );
            self.sentry_hud_notice setText( &"Reloading" );
        }        
//        else if ( isDefined( mg.timeup ) )
        else
        {
            self.sentry_hud_front.alpha = 0;
            self.sentry_hud_notice.color = ( 1, 1, 1 );
            self.sentry_hud_notice setText( &"Idle" );
        }            
        
        self.sentry_hud_health setValue( self.mg.health );
        self.sentry_hud_health_front setShader( "white", self.mg.health * 1.12, 8 );
        wait 0.1;
    }
    
    if ( isDefined( self.sentry_hud_back ) )            self.sentry_hud_back destroy();
    if ( isDefined( self.sentry_hud_front ) )           self.sentry_hud_front destroy();
    if ( isDefined( self.sentry_hud_notice ) )          self.sentry_hud_notice destroy();
    if ( isDefined( self.sentry_hud_health_back ) )     self.sentry_hud_health_back destroy();
    if ( isDefined( self.sentry_hud_health_front ) )    self.sentry_hud_health_front destroy();
    if ( isDefined( self.sentry_hud_health ) )          self.sentry_hud_health destroy();
}

hunterClass_medic() {
    self.maxhealth = 150;
    
    self setWeaponSlotWeapon( "grenade", "mk1britishfrag_mp" );
    self setWeaponSlotAmmo( "grenade", 0 );
    
    self thread heal();
    self thread regen_health();
}

regen_health()
{
    self endon( "death" );
    self endon( "disconnect" );
    
    while ( isAlive( self ) )
    {
        // got hurt somehow
        if ( self.health < self.maxhealth && self.lasthittime + 3000 < gettime() )
            self.health++;
            
        wait 0.5;
    }
}

heal()
{
    mypack = spawn( "script_model", self getOrigin() );
    mypack setModel( "xmodel/health_large" );
    
    self thread dohealing( mypack );
    
    while ( isAlive( self ) )
    {  
        wait 0.05;
        
        mypack hide();
        
        if ( self getCurrentWeapon() != "mk1britishfrag_mp" )
            continue;

        mypack show();
        traceDir = anglesToForward( self.angles );
        traceEnd = self.origin + ( 0, 0, 36 );
        traceEnd += [[ level.call ]]( "vector_scale", traceDir, 16 );
        trace = bulletTrace( self.origin + ( 0, 0, 36 ), traceEnd, false, mypack );

        pos = trace[ "position" ];
        mypack moveto( pos, 0.05 );
        mypack.angles = self.angles;
    }

    mypack delete();
}

dohealing( mypack )
{
    while ( isAlive( self ) )
    {
        wait 0.25;
        
        if ( self getCurrentWeapon() != "mk1britishfrag_mp" )
            continue;
            
        players = [[ level.call ]]( "get_good_players" );
        for ( i = 0; i < players.size; i++ )
        {
            if ( players[ i ].pers[ "team" ] == "axis" && distance( self.origin, players[ i ].origin ) < 56 )
            {
                if ( isDefined( players[ i ].ispoisoned ) )
                    players[ i ].ispoisoned = undefined;
                if ( isDefined( players[ i ].onfire ) )
                    players[ i ].onfire = undefined;
                    
                if ( players[ i ] != self && players[ i ].health < players[ i ].maxhealth )
                    players[ i ].health++;
            }
        } 
    }
}

hunterClass_sniper() {
    self.maxhealth = 150;
    
    self.claymores = 2;
    
    self setWeaponSlotWeapon( "grenade", "stielhandgranate_mp" );
    self setWeaponSlotAmmo( "grenade", 2 );
    
    self thread claymores();
}

claymores()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "spawn_spectator" );
	
	while ( isAlive( self ) && self.sessionstate == "playing" )
	{
		wait 0.05;
		
		if ( self meleeButtonPressed() && self getCurrentWeapon() == "stielhandgranate_mp" )
			self checkStickyPlacement();
	}
}

checkStickyPlacement()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "spawn_spectator" );

	if ( isdefined( self.checkstickyplacement ) ) return;
	self.checkstickyplacement = true;
	
	if( !isdefined( self ) || !isAlive( self ) || self.sessionstate != "playing" )
	{
		self.checkstickyplacement = undefined;
		return;
	}

	while( isdefined( self ) && isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() )
		wait( 0.1 );
	
	if ( self.claymores == 0 )
	{
		self iPrintLnBold( "You don't have any more Claymores." );
		wait 2;
		self.checkstickyplacement = undefined;
		return;
	}
	
	if ( level.claymores == 50 )
	{
		self iPrintLnBold( "Too many Claymores have been placed." );
		wait 2;
		self.checkstickyplacement = undefined;
		return;
	}

	model = "xmodel/weapon_nebelhandgrenate";
	slot = "grenade";
	aOffset = ( 0,0,0 );

	iAmmo = self getWeaponSlotClipAmmo( slot );
	if ( !iAmmo )
	{
		self.checkstickyplacement = undefined;
		return;
	}

	offset = ( 0,0,60 );
	roll = 0;
	voffset = -1;
	trace = bullettrace( self.origin + ( 0, 0, 8 ), self.origin + ( 0, 0, -64 ), false, self );

	if ( trace[ "fraction" ] == 1 )
	{
		self.checkstickyplacement = undefined;
		return;
	}

	iAmmo--;
	if ( iAmmo )
		self setWeaponSlotClipAmmo( slot, iAmmo );
	else
	{
		self setWeaponSlotClipAmmo( slot, iAmmo );
		self setWeaponSlotWeapon( slot, "none" );
		newWeapon = self getWeaponSlotWeapon( "primary" );
		if ( newWeapon == "none" ) newWeapon = self getWeaponSlotWeapon( "primaryb" );
		if ( newWeapon == "none" ) newWeapon = self getWeaponSlotWeapon( "pistol" );
		if ( newWeapon != "none" ) self switchToWeapon( newWeapon );
	}	

	self.claymores--;
	level.claymores++;

	stickybomb = spawn( "script_model", trace[ "position" ] + ( 0, 0, voffset ) );
	stickybomb.angles = ( 0, 0, 0 );
	stickybomb setModel( model );
	
	stickybomb thread monitorSticky( self );

	self.checkstickyplacement = undefined;
	wait 1;
}

monitorSticky( owner )
{
	wait 0.15;
	
	owner playsound( "weap_fraggrenade_pin" );
	
	explode = false;
	while ( !explode && isAlive( owner ) )
	{
        players = [[ level.call ]]( "get_good_players" );
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[ i ].pers[ "team" ] == "allies" && distance( players[ i ].origin, self.origin ) < 128 )
			{
				trace = bullettrace( self.origin + ( 0, 0, 1 ), players[ i ].origin + ( 0, 0, 1 ), false, undefined );
				if ( trace[ "fraction" ] == 1 )
					explode = true;
			}
		}
		
		wait 0.05;
	}
	
	if ( isAlive( owner ) )
	{
		self movez( 8, 0.05 );
		self setModel( "xmodel/weapon_nebelhandgrenate" );
		wait 0.05;
		self playSound( "minefield_click" );
		wait 0.30;
		self hide();
		
		if ( owner.pers[ "team" ] == "axis" )
		{
			self playsound( "grenade_explode_default" );
			playfx( level._effect[ "bomb_explosion" ], self.origin + ( 0, 0, 8 ) );
			[[ level.call ]]( "scripted_radius_damage", self.origin + ( 0, 0, 8 ), 192, 800, 20, owner, owner );
			earthquake( 0.5, 3, self.origin + ( 0, 0, 8 ), 192 );
			wait 3;
			owner.claymores++;
		}
	}
	
	level.claymores--;
	self delete();
}

hunterClass_support() {
	self.maxhealth = 175;
    
    self setWeaponSlotWeapon( "grenade", "mk1britishfrag_mp" );
    self setWeaponSlotAmmo( "grenade", 0 );
    
    self thread ammobox();
}

hunterClass_updateAmmo() {
}

// support class gets to place an ammobox :p
ammobox()
{  
    boxmodels = [];
    boxmodels[ 0 ] = "xmodel/crate_misc1";
    boxmodels[ 1 ] = "xmodel/crate_misc_red1";
    boxmodels[ 2 ] = "xmodel/crate_misc_green1";
    boxmodels[ 3 ] = "xmodel/crate_champagne3";
    modeli = 0;
    
    mybox = spawn( "script_model", self getOrigin() );
    mybox setModel( boxmodels[ modeli ] );
    
    self iPrintLnBold( "double tap [f] to place ammobox" );
    
    while ( isAlive( self ) )
    {  
        wait 0.05;
        
        mybox hide();
        
        if ( self getCurrentWeapon() != "mk1britishfrag_mp" )
            continue;

        mybox show();
        traceDir = anglesToForward( self.angles );
        traceEnd = self.origin;
        traceEnd += [[ level.call ]]( "vector_scale", traceDir, 80 );
        trace = bulletTrace( self.origin, traceEnd, false, mybox );

        pos = trace[ "position" ];
        mybox moveto( pos, 0.05 );
        mybox.angles = self.angles;
            
        // stoled from lev
        if ( self useButtonPressed() )
        {
            catch_next = false;
            lol = false;

			for ( i = 0; i <= 0.30; i += 0.01 )
			{
				if ( catch_next && self useButtonPressed() )
				{
					lol = true;
					break;
				}
				else if ( !( self useButtonPressed() ) )
					catch_next = true;

				wait 0.01;
			}
            
            if ( lol )
                break;
        }
        
        if ( self meleeButtonPressed() )
        {
            modeli++;
            
            if ( modeli >= boxmodels.size )
                modeli = 0;
                
            mybox setModel( boxmodels[ modeli ] );
            
            wait 0.5;
        }
        
        wait 0.05;
    }
    
    if ( !isAlive( self ) )
    {
        mybox delete();
        return;
    }
    
    trace = bullettrace( mybox.origin, mybox.origin + ( 0, 0, -1024 ), false, undefined );
    mybox moveto( trace[ "position" ], 0.1 );
    
    self iprintln( "ammobox placed!" );
    
    self switchToWeapon( self getWeaponSlotWeapon( "primary" ) );
    self setWeaponSlotWeapon( "grenade", "none" );
    
    self thread ammobox_remove();
    self thread ammobox_remove_count( mybox );
    self thread ammobox_think( mybox );
    
    self waittill( "remove ammobox" );
    mybox delete();
}

ammobox_remove()
{
    self waittill( "death" );
    self notify( "remove ammobox" );
}

// removes ammobox after it's depleted
ammobox_remove_count( box )
{
    self endon( "remove ammobox" );
   
    box.ammocount = randomInt( 20 ) + 10;
    
    while ( box.ammocount > 0 )
        wait 1;
        
    self notify( "remove ammobox" );
}

ammobox_think( box )
{
    self endon( "remove ammobox" );
    
	while ( 1 )
	{
		players = [[ level.call ]]( "get_good_players" );
		for ( i = 0; i < players.size; i++ )
		{
			if ( distance( box.origin, players[ i ].origin ) < 32 && players[ i ].pers[ "team" ] == "axis" && !isDefined( players[ i ].gettingammo ) )
				players[ i ] thread getammo( box );
		}
		
		wait 0.1;
	}
}

getammo( box )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self.gettingammo = true;
	
	while ( isDefined( box ) && distance( box.origin, self.origin ) < 32 && isAlive( self ) )
	{	
		if ( !isDefined( self.ammonotice ) || !isDefined( self.boxnotice ) )
		{
			self.ammonotice = newClientHudElem( self );
			self.ammonotice.alignX = "center";
			self.ammonotice.alignY = "middle";
			self.ammonotice.x = 320;
			self.ammonotice.y = 320;
			self.ammonotice.alpha = 1;
			self.ammonotice setText( &"Hold [{+activate}] to get ammo" );
            
            self.boxnotice = newClientHudElem( self );
			self.boxnotice.alignX = "center";
			self.boxnotice.alignY = "middle";
			self.boxnotice.x = 320;
			self.boxnotice.y = 330;
			self.boxnotice.alpha = 1;
			self.boxnotice.label = &"Ammo left until depleted: ";
		}
        
        self.boxnotice setValue( box.ammocount );
		
		while ( !isDefined( self.givenammo ) && self usebuttonpressed() && self isOnGround() && isAlive( self ) )
		{
			org = spawn( "script_origin", self.origin );
			if ( !isdefined( self.progressbackground ) )
			{
				self.progressbackground = newClientHudElem( self );				
				self.progressbackground.alignX = "center";
				self.progressbackground.alignY = "middle";
				self.progressbackground.x = 320;
				self.progressbackground.y = 385;
				self.progressbackground.alpha = 0.75;
			}
			self.progressbackground setShader( "black", ( 288 + 4 ), 12 );		

			if ( !isdefined( self.progressbar ) )
			{
				self.progressbar = newClientHudElem( self );				
				self.progressbar.alignX = "left";
				self.progressbar.alignY = "middle";
				self.progressbar.x = ( 320 - ( 288 / 2.0 ) );
				self.progressbar.y = 385;
				self.progressbar.alpha = 1;
			}
			self.progressbar setShader( "white", 0, 8 );
			self.progressbar scaleOverTime( 2, 288, 8 );
			
			self linkto( org );
			
			self.progresstime = 0;
			while( self useButtonPressed() && ( self.progresstime < 2 ) && isAlive( self ) )
			{
				self.progresstime += 0.05;
				wait 0.05;
			}
			
			org delete();
			
			if ( self.progresstime >= 2 )
			{			
				// ideally we'll decrement the amount of uses this ammobox has here
                box.ammocount--;
                
                // stolen from kill3r's mod
                // this way is better suited for this version of zombies, since we're not actually giving health anymore
                self playlocalsound( "weap_pickup" );

                oldamountpri = self getWeaponSlotAmmo( "primary" );
                oldamountprib = self getWeaponSlotAmmo( "primaryb" );
                oldamountpistol = self getWeaponSlotAmmo( "pistol" );
                oldamountgrenade = self getWeaponSlotAmmo( "grenade" );
                oldamountsmokegrenade = self getWeaponSlotAmmo( "smokegrenade" );

                self setWeaponSlotAmmo( "primary", ( oldamountpri + 90 ) );
                self setWeaponSlotAmmo( "primaryb", ( oldamountprib + 90 ) );
                self setWeaponSlotAmmo( "pistol", ( oldamountpistol + 30 ) );
				
				self.givenammo = true;
				
				self.progressbackground destroy();
				self.progressbar destroy();
				
				self playSound( "weap_ammo_pickup" );
				
				self thread waitammo();
				break;
			}
			else
			{
				self.progressbackground destroy();
				self.progressbar destroy();
			}
		}
		
		wait 0.05;
	}
	
	self.ammonotice destroy();
    self.boxnotice destroy();
	self.gettingammo = undefined;
}
/*
getammo( box )
{
    self endon( "death" );
    self endon( "disconnect" );
    
    self.gettingammo = true;
    
    self playlocalsound( "weap_pickup" );

    oldamountpri = self getWeaponSlotAmmo( "primary" );
    oldamountprib = self getWeaponSlotAmmo( "primaryb" );
    oldamountpistol = self getWeaponSlotAmmo( "pistol" );

    self setWeaponSlotAmmo( "primary", ( oldamountpri + 30 ) );
    self setWeaponSlotAmmo( "primaryb", ( oldamountprib + 30 ) );
    self setWeaponSlotAmmo( "pistol", ( oldamountpistol + 10 ) );
    
    wait 2;
    
    self.gettingammo = undefined;
}
*/
waitammo()
{
	wait 1;
	self.givenammo = undefined;
}

loadout()
{
    if ( self.pers[ "team" ] == "axis" )
    {
        if ( self.class != "default" )
            self hunterClasses();
    }
    else
        self zombieClasses();
}