/*
	area2048 'MAIN'

		'main.d'

	2003/11/28 jumpei isshiki
*/

version (Windows) {
	private	import	std.c.windows.windows;
}
private	import	std.random;
private	import	core.stdc.stdio;
private	import	bindbc.sdl;
private	import	opengl;
private	import	util_sdl;
private	import	util_pad;
private	import	util_snd;
private	import	util_ascii;
private	import	bulletcommand;
private	import	init;
private	import	define;
private	import	task;
private	import	gctrl;
private	import	ship;

version(Windows) {
	extern (C) void	gc_init();
	extern (C) void	gc_term();
	extern (C) void	_minit();
	extern (C) void	_moduleCtor();
	extern (C) void	_moduleUnitTests();
}

int		turn = 0;
int		game_exec = 0;
int		pause = 0;
int		pause_flag = 0;
int		skip = 0;

static Random rndgen;

version(Windows) {
	extern (Windows)
	int		WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
	{
		int		result;

		gc_init();
		_minit();

		try{
			_moduleCtor();
			_moduleUnitTests();
			result = boot();
		}catch (Object o){
			MessageBoxA(null, cast(char*)o.toString(), "Error", MB_OK | MB_ICONEXCLAMATION);
			result = 0;
		}
		gc_term();

		return result;
	}
} else {
	int main(string[] argv)
	{
		return boot();
	}
}


int		boot()
{
	const int INTERVAL_BASE = 16;

	int			id;
	SDL_Event	event;
	int			interval = INTERVAL_BASE;
	int			accframe = 0;
	int			maxSkipFrame = 5;
	long		prvTickCount = 0;
	long		nowTick;
	int			frame;
	int			i;

	rndgen = Random(unpredictableSeed);

	// NaN Exception
	debug{
		version (X86) {
			short cw;
			asm { fnstcw cw; }
			cw &= ~1;
			asm { fldcw cw; }
		}
	}

	if(!initSDL()){
		printf("SDL initialize failed.\n");
		return	0;
	}
	if(!initPAD()){
		printf("PAD initialize failed.\n");
		closeSDL();
		return	0;
	}
	if(!initSND(7,32)){
		printf("SOUND initialize failed.\n");
		closePAD();
		closeSDL();
		return	0;
	}
	grpINIT();
	sndINIT();
	initTSK();
	initASCII();
	bulletINIT();
	configINIT();

	game_exec = 1;

	setTSK(GROUP_00,&TSKgctrl);

	while(game_exec){
		SDL_PollEvent(&event);
		getPAD();
		if(util_pad.keys[SDL_SCANCODE_ESCAPE] == SDL_PRESSED || event.type == SDL_QUIT){
			game_exec = 0;
		}
		nowTick = SDL_GetTicks();
		frame = cast(int)((nowTick - prvTickCount) / interval);
		if(frame <= 0){
			frame = 1;
			SDL_Delay(cast(uint)(prvTickCount + interval - nowTick));
			if(accframe){
			  prvTickCount = SDL_GetTicks();
			}else{
			  prvTickCount += interval;
			}
		}else if(frame > maxSkipFrame){
			frame = maxSkipFrame;
			prvTickCount = nowTick;
		} else {
			prvTickCount += frame * interval;
		}

		if(pause_flag == 1 && (trgs & PAD_BUTTON3)){
			if(!pause) pause = 1;
			else	   pause = 0;
		}

		debug{
			if(pause && (reps & PAD_BUTTON8)){
				frame = 1;
				skip = 1;
			}else{
				skip = 0;
			}
		}

		for(i = 0; i < frame; i++){
			execTSK();
			collision();
			turn++;
		}

		clearSDL();
		drawTSK();
		flipSDL();
	}

	releaseBulletcommandParser();

	clrTSKall();
	closeSND();
	closePAD();
	closeSDL();

	return	1;
}


void	collision()
{
	int	prev;
	int	group;

	/* 自機弾 */
	group = GROUP_04;
	for(int i = TskIndex[group]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].fp_int){
			collision_sub1(i, GROUP_02);
		}
	}
	/* 自機 */
	if(TskBuf[ship_id].tskid != 0 && TskBuf[ship_id].fp_int) collision_sub2(ship_id, GROUP_02);
	if(TskBuf[ship_id].tskid != 0 && TskBuf[ship_id].fp_int) collision_sub3(ship_id, GROUP_06);

	return;
}


void	collision_sub1(int id, int group)
{
	int	coll_flag = 0;
	int	prev;
	int	ssx,ssy;
	int	sex,sey;
	int	dsx,dsy;
	int	dex,dey;

	ssx = cast(int)(TskBuf[id].px - TskBuf[id].cx);
	ssy = cast(int)(TskBuf[id].py - TskBuf[id].cy);
	sex = cast(int)(TskBuf[id].px + TskBuf[id].cx);
	sey = cast(int)(TskBuf[id].py + TskBuf[id].cy);

	/* 敵 */
	for(int i = TskIndex[group]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].fp_int){
			dsx = cast(int)(TskBuf[i].px - TskBuf[i].cx);
			dsy = cast(int)(TskBuf[i].py - TskBuf[i].cy);
			dex = cast(int)(TskBuf[i].px + TskBuf[i].cx);
			dey = cast(int)(TskBuf[i].py + TskBuf[i].cy);
			coll_flag = ((ssx - dex) & (dsx - sex) & (ssy - dey) & (dsy - sey)) >> 31;
			if(coll_flag){
				TskBuf[i].trg_id = id;
				TskBuf[i].fp_int(i);
				TskBuf[id].trg_id = i;
				TskBuf[id].fp_int(id);
				return;
			}
		}
	}

	return;
}


void	collision_sub2(int id, int group)
{
	int	coll_flag = 0;
	int	prev;
	int	ssx,ssy;
	int	sex,sey;
	int	dsx,dsy;
	int	dex,dey;

	if(TskBuf[id].tskid & TSKID_MUTEKI) return;

	ssx = cast(int)(TskBuf[id].px - TskBuf[id].cx);
	ssy = cast(int)(TskBuf[id].py - TskBuf[id].cy);
	sex = cast(int)(TskBuf[id].px + TskBuf[id].cx);
	sey = cast(int)(TskBuf[id].py + TskBuf[id].cy);

	/* 敵 */
	for(int i = TskIndex[group]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].fp_int){
			dsx = cast(int)(TskBuf[i].px - TskBuf[i].cx);
			dsy = cast(int)(TskBuf[i].py - TskBuf[i].cy);
			dex = cast(int)(TskBuf[i].px + TskBuf[i].cx);
			dey = cast(int)(TskBuf[i].py + TskBuf[i].cy);
			coll_flag = ((ssx - dex) & (dsx - sex) & (ssy - dey) & (dsy - sey)) >> 31;
			if(coll_flag){
				TskBuf[id].trg_id = i;
				TskBuf[id].fp_int(id);
				return;
			}
		}
	}

	return;
}


void	collision_sub3(int id, int group)
{
	int	coll_flag = 0;
	int	prev;
	int	ssx,ssy;
	int	sex,sey;
	int	dsx,dsy;
	int	dex,dey;

	if(TskBuf[id].tskid & TSKID_MUTEKI) return;

	ssx = cast(int)(TskBuf[id].px - TskBuf[id].cx);
	ssy = cast(int)(TskBuf[id].py - TskBuf[id].cy);
	sex = cast(int)(TskBuf[id].px + TskBuf[id].cx);
	sey = cast(int)(TskBuf[id].py + TskBuf[id].cy);

	/* 敵弾 */
	for(int i = TskIndex[group]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].fp_int){
			dsx = cast(int)(TskBuf[i].px - TskBuf[i].cx);
			dsy = cast(int)(TskBuf[i].py - TskBuf[i].cy);
			dex = cast(int)(TskBuf[i].px + TskBuf[i].cx);
			dey = cast(int)(TskBuf[i].py + TskBuf[i].cy);
			coll_flag = ((ssx - dex) & (dsx - sex) & (ssy - dey) & (dsy - sey)) >> 31;
			if(coll_flag){
				TskBuf[id].trg_id = i;
				TskBuf[id].fp_int(id);
				return;
			}
		}
	}

	return;
}

uint Rand()
{
	uint ret = rndgen.front();
	rndgen.popFront();

	debug{
		//writefln("rand %d", ret);
	}

	return ret;
}
