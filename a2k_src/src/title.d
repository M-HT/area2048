/*
	area2048 'TITLE'

		'title.d'

	2004/04/08 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	std.string;
private	import	std.conv;
private	import	SDL;
version (USE_GLES) {
	private	import	opengles;
} else {
	private	import opengl;
}
private	import	util_sdl;
private	import	util_pad;
private	import	util_snd;
private	import	util_ascii;
private	import	define;
private	import	init;
private	import	task;
private	import	main;
private	import	gctrl;

private	char[]	str_buf;
private	int		menu_max = 4;
private	int		menu_now;
private	int		option_max = 3;
private	int		option_now;
version (PANDORA) {
	private	int		option_min = 1;
} else {
	private	int		option_min = 0;
}

bool ignorekeys = false;
uint ignoretime;

void	TSKtitle(int id)
{
	if (ignorekeys) {
		if (SDL_GetTicks() - ignoretime > 100) {
			ignorekeys = false;
		}
	}

	switch(TskBuf[id].step){
		case	0:
			str_buf.length = 256;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKtitleDraw;
			TskBuf[id].fp_exit = null;
			TskBuf[id].cnt = 0;
			TskBuf[id].wait = 30*60;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].cnt++;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait){
				TskBuf[id].step = 5;
			}
			if((trgs & PAD_BUTTON1)){
				playSNDse(SND_SE_CORRECT);
				TskBuf[id].wait = 60;
				TskBuf[id].step++;
			}
			break;
		case	2:
			TskBuf[id].cnt++;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait){
				TskBuf[id].step++;
				menu_now = 0;
			}
			break;
		case	3:
			if((trgs & PAD_BUTTON2)){
				playSNDse(SND_SE_CANCEL);
				TskBuf[id].cnt = 0;
				TskBuf[id].step = 0;
			}
			if((trgs & PAD_BUTTON1)){
				playSNDse(SND_SE_CORRECT);
				MENUmodeSet(id);
			}
			if((reps & PAD_UP) && !ignorekeys){
				playSNDse(SND_SE_CURSOLE);
				menu_now--;
				ignorekeys = true;
				ignoretime = SDL_GetTicks();
			}
			if((reps & PAD_DOWN) && !ignorekeys){
				playSNDse(SND_SE_CURSOLE);
				menu_now++;
				ignorekeys = true;
				ignoretime = SDL_GetTicks();
			}
			if(menu_now < 0) menu_now = menu_max;
			if(menu_now > menu_max) menu_now = 0;
			break;
		case	4:
			if((trgs & PAD_BUTTON2)){
				playSNDse(SND_SE_CANCEL);
				TskBuf[id].step--;
				configSAVE();
			}
			MENUoptionSet(id);
			if((reps & PAD_UP) && !ignorekeys){
				playSNDse(SND_SE_CURSOLE);
				option_now--;
				ignorekeys = true;
				ignoretime = SDL_GetTicks();
			}
			if((reps & PAD_DOWN) && !ignorekeys){
				playSNDse(SND_SE_CURSOLE);
				option_now++;
				ignorekeys = true;
				ignoretime = SDL_GetTicks();
			}
			if(option_now < option_min) option_now = option_max;
			if(option_now > option_max) option_now = option_min;
			break;
		case	5:
			g_step = GSTEP_DEMO;
			TskBuf[id].step = -1;
			break;
		default:
			str_buf.length = 0;
			clrTSK(id);
			break;
	}

	return;
}


void	TSKtitleDraw(int id)
{
	float	z;
	float[XY]	pos;

	z = BASE_Z - cam_pos;
	glEnable(GL_TEXTURE_2D);
	bindSDLtexture(GRP_TITLE);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	{
		static	const	int	titleNumVertices = 4;
		GLfloat[XYZ*titleNumVertices]	titleVertices;
		static	const	GLfloat[XY*titleNumVertices]	titleTexCoords = [
			0, 0,
			1, 0,
			1, 1,
			0, 1
		];

		pos[X] = -(SCREEN_Y / 2 - 128) + (-128.0f);
		pos[Y] = +(SCREEN_Y / 2 - 128) + (+128.0f);
		titleVertices[0*XYZ + X] = getPointX(pos[X], z);
		titleVertices[0*XYZ + Y] = getPointY(pos[Y], z);
		titleVertices[0*XYZ + Z] = 0.0f;

		pos[X] = -(SCREEN_Y / 2 - 128) + (+128.0f);
		pos[Y] = +(SCREEN_Y / 2 - 128) + (+128.0f);
		titleVertices[1*XYZ + X] = getPointX(pos[X], z);
		titleVertices[1*XYZ + Y] = getPointY(pos[Y], z);
		titleVertices[1*XYZ + Z] = 0.0f;

		pos[X] = -(SCREEN_Y / 2 - 128) + (+128.0f);
		pos[Y] = +(SCREEN_Y / 2 - 128) + (-128.0f);
		titleVertices[2*XYZ + X] = getPointX(pos[X], z);
		titleVertices[2*XYZ + Y] = getPointY(pos[Y], z);
		titleVertices[2*XYZ + Z] = 0.0f;

		pos[X] = -(SCREEN_Y / 2 - 128) + (-128.0f);
		pos[Y] = +(SCREEN_Y / 2 - 128) + (-128.0f);
		titleVertices[3*XYZ + X] = getPointX(pos[X], z);
		titleVertices[3*XYZ + Y] = getPointY(pos[Y], z);
		titleVertices[3*XYZ + Z] = 0.0f;

		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);

		glVertexPointer(3, GL_FLOAT, 0, cast(void *)(titleVertices.ptr));
		glTexCoordPointer(2, GL_FLOAT, 0, cast(void *)(titleTexCoords.ptr));
		glDrawArrays(GL_TRIANGLE_FAN, 0, titleNumVertices);

		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
	}
	glDisable(GL_TEXTURE_2D);
	// begin text drawing
	glColor4f(0.75f, 0.75f, 0.75f, 1.0f);
	str_buf = "HELLO WORLD PROJECT 2004".dup;
	pos[X] = +(SCREEN_Y / 2) - 16.0f - getWidthASCII(str_buf, 0.5f);
	pos[Y] = -(SCREEN_Y / 2) + 24.0f;
	pos[X]  = ceil(pos[X]);
	pos[Y]  = ceil(pos[Y]);
	drawASCII(str_buf, pos[X], pos[Y], 0.5f);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);

	switch(TskBuf[id].step){
		case	1:
			if(!(TskBuf[id].cnt & 0x20)){
				str_buf = "PRESS SHOT BUTTON".dup;
				pos[X]  = -getWidthASCII(str_buf, 0.5f);
				pos[X] /= 2.0f;
				pos[Y]  = -64.0f;
				pos[X]  = ceil(pos[X]);
				pos[Y]  = ceil(pos[Y]);
				drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			}
			break;
		case	2:
			if(!(TskBuf[id].cnt & 0x01)){
				str_buf = "PRESS SHOT BUTTON".dup;
				pos[X]  = -getWidthASCII(str_buf, 0.5f);
				pos[X] /= 2.0f;
				pos[Y]  = -64.0f;
				pos[X]  = ceil(pos[X]);
				pos[Y]  = ceil(pos[Y]);
				drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			}
			break;
		case	3:
			str_buf = "           ".dup;
			pos[X]  = -getWidthASCII(str_buf, 0.5f);
			pos[X] /= 2.0f;
			pos[X]  = ceil(pos[X]);
			DrawMenuColor(0);
			str_buf = "EASY GAME  ".dup;
			pos[Y]  = -48.0f - 12.0f * 0;
			drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			DrawMenuColor(1);
			str_buf = "NORMAL GAME".dup;
			pos[Y]  = -48.0f - 12.0f * 1;
			drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			DrawMenuColor(2);
			str_buf = "HARD GAME  ".dup;
			pos[Y]  = -48.0f - 12.0f * 2;
			drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			DrawMenuColor(3);
			str_buf = "OPTION     ".dup;
			pos[Y]  = -48.0f - 12.0f * 3;
			drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			DrawMenuColor(4);
			str_buf = "EXIT       ".dup;
			pos[Y]  = -48.0f - 12.0f * 4;
			drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			str_buf = "HIGH 00000000".dup;
			pos[X]  = -getWidthASCII(str_buf, 0.5f);
			pos[X] /= 2.0f;
			pos[X]  = ceil(pos[X]);
			pos[Y]  = -48.0f - 12.0f * 6;
			str_buf = "HIGH ".dup;
			switch(menu_now){
				case	0:
					if(high_easy < 10000000) str_buf ~= "0";
					if(high_easy < 1000000 ) str_buf ~= "0";
					if(high_easy < 100000  ) str_buf ~= "0";
					if(high_easy < 10000   ) str_buf ~= "0";
					if(high_easy < 1000    ) str_buf ~= "0";
					if(high_easy < 100     ) str_buf ~= "0";
					if(high_easy < 10      ) str_buf ~= "0";
					str_buf ~= to!string(high_easy);
					drawASCII(str_buf, pos[X], pos[Y], 0.5f);
					break;
				case	1:
					if(high_normal < 10000000) str_buf ~= "0";
					if(high_normal < 1000000 ) str_buf ~= "0";
					if(high_normal < 100000  ) str_buf ~= "0";
					if(high_normal < 10000   ) str_buf ~= "0";
					if(high_normal < 1000    ) str_buf ~= "0";
					if(high_normal < 100     ) str_buf ~= "0";
					if(high_normal < 10      ) str_buf ~= "0";
					str_buf ~= to!string(high_normal);
					drawASCII(str_buf, pos[X], pos[Y], 0.5f);
					break;
				case	2:
					if(high_hard < 10000000) str_buf ~= "0";
					if(high_hard < 1000000 ) str_buf ~= "0";
					if(high_hard < 100000  ) str_buf ~= "0";
					if(high_hard < 10000   ) str_buf ~= "0";
					if(high_hard < 1000    ) str_buf ~= "0";
					if(high_hard < 100     ) str_buf ~= "0";
					if(high_hard < 10      ) str_buf ~= "0";
					str_buf ~= to!string(high_hard);
					drawASCII(str_buf, pos[X], pos[Y], 0.5f);
					break;
				default:
					break;
			}
			break;
		case	4:
			glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
			str_buf = "- OPTION -".dup;
			pos[X]  = -getWidthASCII(str_buf, 0.5f);
			pos[X] /= 2.0f;
			pos[Y]  = -32.0f - 12.0f * 0;
			pos[X]  = ceil(pos[X]);
			pos[Y]  = ceil(pos[Y]);
			drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			str_buf = "             ".dup;
			pos[X]  = -getWidthASCII(str_buf, 0.5f);
			pos[X] /= 2.0f;
			pos[X]  = ceil(pos[X]);
			version (PANDORA) {
			} else {
				DrawOptionColor(0);
				str_buf = "KEY TYPE TYPE-".dup ~ to!string(pad_type+1);
				pos[Y]  = -40.0f - 12.0f * 1;
				drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			}
			DrawOptionColor(1);
			str_buf = "BGM VOLUME ".dup ~ to!string(vol_music);
			pos[Y]  = -40.0f - 12.0f * 2;
			drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			DrawOptionColor(2);
			str_buf = "SE  VOLUME ".dup ~ to!string(vol_se);
			pos[Y]  = -40.0f - 12.0f * 3;
			drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			DrawOptionColor(3);
			str_buf = "EXIT          ".dup;
			pos[Y]  = -40.0f - 12.0f * 4;
			drawASCII(str_buf, pos[X], pos[Y], 0.5f);
			if(option_now == 0){
				switch(pad_type){
					case 0:
						glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
						str_buf = "- KEY TYPE 1 -".dup;
						pos[X]  = -getWidthASCII(str_buf, 0.5f);
						pos[X] /= 2.0f;
						pos[Y]  = -40.0f - 12.0f * 7;
						pos[X]  = ceil(pos[X]);
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "                              ".dup;
						pos[X]  = -getWidthASCII(str_buf, 0.5f);
						pos[X] /= 2.0f;
						pos[X]  = ceil(pos[X]);
						str_buf = "   MOVE : TENKEY'8426' CURSOLE".dup;
						pos[Y]  = -40.0f - 12.0f * 8;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "   SHOT : 'Z'".dup;
						pos[Y]  = -40.0f - 12.0f * 9;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "SPECIAL : 'C'".dup;
						pos[Y]  = -40.0f - 12.0f * 10;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						break;
					case 1:
						glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
						str_buf = "- KEY TYPE 2 -".dup;
						pos[X]  = -getWidthASCII(str_buf, 0.5f);
						pos[X] /= 2.0f;
						pos[Y]  = -40.0f - 12.0f * 7;
						pos[X]  = ceil(pos[X]);
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "                              ".dup;
						pos[X]  = -getWidthASCII(str_buf, 0.5f);
						pos[X] /= 2.0f;
						pos[X]  = ceil(pos[X]);
						str_buf = "   MOVE : TENKEY'8426' 'WASD'".dup;
						pos[Y]  = -40.0f - 12.0f * 8;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "   SHOT : BACKSLASH".dup;
						pos[Y]  = -40.0f - 12.0f * 9;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "SPECIAL : RIGHT-SHIFT".dup;
						pos[Y]  = -40.0f - 12.0f * 10;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						break;
					case 2:
						glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
						str_buf = "- KEY TYPE 3 -".dup;
						pos[X]  = -getWidthASCII(str_buf, 0.5f);
						pos[X] /= 2.0f;
						pos[Y]  = -40.0f - 12.0f * 7;
						pos[X]  = ceil(pos[X]);
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "                              ".dup;
						pos[X]  = -getWidthASCII(str_buf, 0.5f);
						pos[X] /= 2.0f;
						pos[X]  = ceil(pos[X]);
						str_buf = "   MOVE : TENKEY'8426' CURSOLE".dup;
						pos[Y]  = -40.0f - 12.0f * 8;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "   SHOT : LEFT-SHIFT".dup;
						pos[Y]  = -40.0f - 12.0f * 9;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "SPECIAL : LEFT-CTRL".dup;
						pos[Y]  = -40.0f - 12.0f * 10;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						break;
					case 3:
						glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
						str_buf = "- KEY TYPE 4 -".dup;
						pos[X]  = -getWidthASCII(str_buf, 0.5f);
						pos[X] /= 2.0f;
						pos[Y]  = -40.0f - 12.0f * 7;
						pos[X]  = ceil(pos[X]);
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "                              ".dup;
						pos[X]  = -getWidthASCII(str_buf, 0.5f);
						pos[X] /= 2.0f;
						pos[X]  = ceil(pos[X]);
						str_buf = "   MOVE : TENKEY'8426' CURSOLE".dup;
						pos[Y]  = -40.0f - 12.0f * 8;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "   SHOT : SPACE".dup;
						pos[Y]  = -40.0f - 12.0f * 9;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						str_buf = "SPECIAL : LEFT-ALT".dup;
						pos[Y]  = -40.0f - 12.0f * 10;
						pos[Y]  = ceil(pos[Y]);
						drawASCII(str_buf, pos[X], pos[Y], 0.5f);
						break;
					default:
						break;
				}
			}
			break;
		default:
			break;
	}
	// end text drawing

}

void	DrawMenuColor(int menu)
{
	if(menu_now != menu){
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	}else{
		glColor4f(1.0f, 1.0f, 0.0f, 1.0f);
	}
}

void	DrawOptionColor(int option)
{
	if(option_now != option){
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	}else{
		glColor4f(1.0f, 1.0f, 0.0f, 1.0f);
	}
}

void	MENUmodeSet(int id)
{
	switch(menu_now){
		case	0:
			g_step = GSTEP_GAME;
			game_level = GLEVEL_EASY;
			TskBuf[id].step = -1;
			break;
		case	1:
			g_step = GSTEP_GAME;
			game_level = GLEVEL_NORMAL;
			TskBuf[id].step = -1;
			break;
		case	2:
			g_step = GSTEP_GAME;
			game_level = GLEVEL_HARD;
			TskBuf[id].step = -1;
			break;
		case	3:
			option_now = option_min;
			TskBuf[id].step++;
			break;
		case	4:
			game_exec = 0;
			TskBuf[id].step = -1;
			break;
		default:
			break;
	}

	return;
}

void	MENUoptionSet(int id)
{
	int bak;

	switch(option_now){
		case	0:
			if((trgs & PAD_LEFT)) pad_type--;
			if((trgs & PAD_RIGHT)) pad_type++;
			if(pad_type < 0) pad_type = 3;
			if(pad_type > 3) pad_type = 0;
			break;
		case	1:
			bak = vol_music;
			if((reps & PAD_LEFT)) vol_music--;
			if((reps & PAD_RIGHT)) vol_music++;
			if(vol_music < 0) vol_music = 100;
			if(vol_music > 100) vol_music = 0;
			if(bak != vol_music) volumeSNDmusic(vol_music);
			break;
		case	2:
			bak = vol_se;
			if((reps & PAD_LEFT)) vol_se--;
			if((reps & PAD_RIGHT)) vol_se++;
			if(vol_se < 0) vol_se = 100;
			if(vol_se > 100) vol_se = 0;
			if(bak != vol_se) volumeSNDse(vol_se);
			break;
		case	3:
			if((trgs & PAD_BUTTON1)){
				playSNDse(SND_SE_CORRECT);
				configSAVE();
				TskBuf[id].step = 3;
			}
			break;
		default:
			break;
	}

	return;
}
