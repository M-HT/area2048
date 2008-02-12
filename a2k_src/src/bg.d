/*
	area2048 'BG'

		'bg.d'

	2004/02/05 jumpei isshiki
*/

private	import	std.math;
private	import	std.random;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	util_snd;
private	import	define;
private	import	task;
private	import	stg;
private	import	effect;
private	import	ship;

struct BG_OBJ {
	float[XY]		pos;
	float[XYZW][]	body_list;
	float[XYZW][]	line_list;
}

float[XY]	scr_pos;
float[XY]	scr_base;
float[XY]	scr_ofs;

int	bg_disp;
int	bg_id;

private	BG_OBJ[]	bg_obj;
private	int			bg_mode;

void	TSKbg00(int id)
{
	int	eid;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKbg00Draw;
			TskBuf[id].fp_exit = &TSKbg00Exit;
			scr_base[X] = 0.0f;
			scr_base[Y] = 0.0f;
			scr_ofs[X] = 0.0f;
			scr_ofs[Y] = 0.0f;
			cam_pos = BASE_Z + cam_scr;
			bg_obj.length = 512;
			for(int i = 0; i < bg_obj.length; i++){
				if((rand() % 100) & 0x01){
					bg_obj[i].pos[X] = cast(float)(rand() % 4096) - 2048.0f;
					bg_obj[i].pos[Y] = 0.0f;
					bg_obj[i].line_list.length = 2;
					bg_obj[i].line_list[0][X] = +0.0f;
					bg_obj[i].line_list[0][Y] = -2048.0f;
					bg_obj[i].line_list[1][X] = +0.0f;
					bg_obj[i].line_list[1][Y] = +2048.0f;
				}else{
					bg_obj[i].pos[X] = 0.0f;
					bg_obj[i].pos[Y] = cast(float)(rand() % 4096) - 2048.0f;
					bg_obj[i].line_list.length = 2;
					bg_obj[i].line_list[0][X] = -2048.0f;
					bg_obj[i].line_list[0][Y] = +0.0f;
					bg_obj[i].line_list[1][X] = +2048.0f;
					bg_obj[i].line_list[1][Y] = +0.0f;
				}
				bg_obj[i].line_list[0][Z] = 
				bg_obj[i].line_list[1][Z] = -(cast(float)(rand() % 75)) / 100.0f + 0.25f;
			}
			TskBuf[id].step++;
			break;
		case	1:
			fade_r = 0.0f;
			fade_g = 0.0f;
			fade_b = 0.0f;
			fade_a = 0.0f;
			TskBuf[fade_id].tx = 1.0f;
			TskBuf[fade_id].wait = 60;
			TskBuf[fade_id].step = 2;
			TskBuf[id].px = cast(float)(rand() % 1536 - 768.0f);
			TskBuf[id].py = cast(float)(rand() % 1536 - 768.0f);
			if((rand() % 100) & 0x01){
				if(TskBuf[id].px < 0.0f){
					TskBuf[id].tx = +(cast(float)(rand() % 768));
				}else{
					TskBuf[id].tx = -(cast(float)(rand() % 768));
				}
				TskBuf[id].ty = TskBuf[id].py;
			}else{
				if(TskBuf[id].py < 0.0f){
					TskBuf[id].ty = +(cast(float)(rand() % 768));
				}else{
					TskBuf[id].ty = -(cast(float)(rand() % 768));
				}
				TskBuf[id].tx = TskBuf[id].px;
			}
			TskBuf[id].vx = (TskBuf[id].tx - TskBuf[id].px) / 600.0f;
			TskBuf[id].vy = (TskBuf[id].ty - TskBuf[id].py) / 600.0f;
			scr_pos[X] = scr_base[X] + scr_ofs[X] + TskBuf[id].px;
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y] + TskBuf[id].py;
			TskBuf[id].wait = 540;
			cam_pos = BASE_Z + cam_scr;
			eid = setTSK(GROUP_08,&TSKbgZoom);
			TskBuf[eid].wait = 600;
			TskBuf[eid].tx = BASE_Z - (cast(float)((rand() % 5000) - 2500 + 10000) / 10000.0f);
			TskBuf[id].step++;
			break;
		case	2:
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			ship_px = TskBuf[id].px;
			ship_py = TskBuf[id].py;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				fade_r = 0.0f;
				fade_g = 0.0f;
				fade_b = 0.0f;
				fade_a = 1.0f;
				TskBuf[fade_id].tx = 0.01f;
				TskBuf[fade_id].wait = 60;
				TskBuf[fade_id].step = 2;
				TskBuf[id].wait = 60;
				TskBuf[id].step++;
			}
			scr_pos[X] = scr_base[X] + scr_ofs[X] + TskBuf[id].px;
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y] + TskBuf[id].py;
			break;
		case	3:
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			ship_px = TskBuf[id].px;
			ship_py = TskBuf[id].py;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].step = 1;
			}
			scr_pos[X] = scr_base[X] + scr_ofs[X] + TskBuf[id].px;
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y] + TskBuf[id].py;
			break;

		default:
			clrTSK(id);
			break;
	}

	return;
}


void	TSKbg00Draw(int id)
{
	float[XYZ]	pos;

	glBegin(GL_QUADS);
	glColor3f(0.015f,0.015f,0.075f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(-1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(+1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(+1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(-1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glEnd();
	for(int i = 0; i < bg_obj.length; i++){
		glBegin(GL_LINES);
		glColor3f(0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
				  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
				  0.25f*(1.0f+bg_obj[i].line_list[0][Z]));
		for(int j = 0; j < bg_obj[i].line_list.length; j++){
			pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[j][X], bg_obj[i].line_list[j][Z]);
			pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[j][Y], bg_obj[i].line_list[j][Z]);
			pos[Z] = bg_obj[i].line_list[j][Z];
			glVertex3f(pos[X], pos[Y], pos[Z]);
		}
		glEnd();
	}
}


void	TSKbg00Exit(int id)
{
	bg_obj.length = 0;
}


void	TSKbg01(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKbg01Draw;
			TskBuf[id].fp_exit = &TSKbg01Exit;
			scr_base[X] = START_X;
			scr_base[Y] = START_Y;
			scr_ofs[X] = 0.0f;
			scr_ofs[Y] = 0.0f;
			cam_pos = BASE_Z + cam_scr;
			switch(area_num){
				case	AREA_01:
					bg_mode = 0;
					break;
				case	AREA_02:
					bg_mode = 1;
					break;
				case	AREA_03:
					bg_mode = 2;
					break;
				case	AREA_04:
					bg_mode = 3;
					break;
				case	AREA_05:
					bg_mode = 4;
					break;
				default:
					break;
			}
			bg_disp = 0;
			switch(bg_mode){
				case	0:
					bg_obj.length = 512;
					for(int i = 0; i < bg_obj.length; i++){
						if((rand() % 100) & 0x01){
							bg_obj[i].pos[X] = cast(float)(rand() % 4096) - 2048.0f;
							bg_obj[i].pos[Y] = 0.0f;
							bg_obj[i].line_list.length = 2;
							bg_obj[i].line_list[0][X] = +0.0f;
							bg_obj[i].line_list[0][Y] = -2048.0f;
							bg_obj[i].line_list[1][X] = +0.0f;
							bg_obj[i].line_list[1][Y] = +2048.0f;
						}else{
							bg_obj[i].pos[X] = 0.0f;
							bg_obj[i].pos[Y] = cast(float)(rand() % 4096) - 2048.0f;
							bg_obj[i].line_list.length = 4;
							bg_obj[i].line_list[0][X] = -2048.0f;
							bg_obj[i].line_list[0][Y] = +0.0f;
							bg_obj[i].line_list[1][X] = +2048.0f;
							bg_obj[i].line_list[1][Y] = +0.0f;
						}
						bg_obj[i].line_list[0][Z] = 
						bg_obj[i].line_list[1][Z] = -(cast(float)(rand() % 75)) / 100.0f + 0.25f;
					}
					break;
				case	1:
					bg_obj.length = 1024;
					for(int i = 0; i < bg_obj.length; i++){
						bg_obj[i].pos[X] = cast(float)(rand() % 2048) - 1024.0f;
						bg_obj[i].pos[Y] = cast(float)(rand() % 2048) - 1024.0f;
						bg_obj[i].line_list.length = 4;
						bg_obj[i].line_list[0][X] = -64.0f;
						bg_obj[i].line_list[0][Y] = -64.0f;
						bg_obj[i].line_list[1][X] = -64.0f;
						bg_obj[i].line_list[1][Y] = +64.0f;
						bg_obj[i].line_list[2][X] = +64.0f;
						bg_obj[i].line_list[2][Y] = +64.0f;
						bg_obj[i].line_list[3][X] = +64.0f;
						bg_obj[i].line_list[3][Y] = -64.0f;
						bg_obj[i].line_list[0][Z] = 
						bg_obj[i].line_list[1][Z] = 
						bg_obj[i].line_list[2][Z] = 
						bg_obj[i].line_list[3][Z] = -(cast(float)(rand() % 75)) / 100.0f + 0.25f;
					}
					break;
				case	2:
					bg_obj.length = 768;
					for(int i = 0; i < bg_obj.length; i++){
						bg_obj[i].pos[X] = cast(float)(rand() % 2048) - 1024.0f;
						bg_obj[i].pos[Y] = cast(float)(rand() % 2048) - 1024.0f;
						bg_obj[i].line_list.length = 4;
						bg_obj[i].line_list[0][X] = -48.0f;
						bg_obj[i].line_list[0][Y] = -48.0f;
						bg_obj[i].line_list[1][X] = -48.0f;
						bg_obj[i].line_list[1][Y] = +48.0f;
						bg_obj[i].line_list[2][X] = +48.0f;
						bg_obj[i].line_list[2][Y] = +48.0f;
						bg_obj[i].line_list[3][X] = +48.0f;
						bg_obj[i].line_list[3][Y] = -48.0f;
						bg_obj[i].line_list[0][Z] = 
						bg_obj[i].line_list[1][Z] = 
						bg_obj[i].line_list[2][Z] = 
						bg_obj[i].line_list[3][Z] = -(cast(float)(rand() % 75)) / 100.0f + 0.25f;
					}
					break;
				case	3:
					bg_obj.length = 8192;
					for(int i = 0; i < bg_obj.length; i++){
						bg_obj[i].pos[X] = cast(float)(rand() % 3072) - 1536.0f;
						bg_obj[i].pos[Y] = cast(float)(rand() % 3072) - 1536.0f;
						bg_obj[i].line_list.length = 1;
						bg_obj[i].line_list[0][X] = +0.0f;
						bg_obj[i].line_list[0][Y] = +0.0f;
						bg_obj[i].line_list[0][Z] = -(cast(float)(rand() % 75)) / 100.0f + 0.25f;
					}
					break;
				case	4:
					bg_obj.length = 1024 * 3;
					for(int i = 0; i < bg_obj.length; i++){
						bg_obj[i].pos[X] = cast(float)(rand() % 2048) - 1024.0f;
						bg_obj[i].pos[Y] = cast(float)(rand() % 2048) - 1024.0f;
						bg_obj[i].line_list.length = 2;
						bg_obj[i].line_list[0][X] = +0.0f;
						bg_obj[i].line_list[0][Y] = +0.0f;
						bg_obj[i].line_list[1][X] = +0.0f;
						bg_obj[i].line_list[1][Y] = +0.0f;
						bg_obj[i].line_list[0][Z] = +0.0f;
						bg_obj[i].line_list[1][Z] = +4096.0f;
					}
					break;
				default:
					break;
			}
			TskBuf[id].step++;
			break;
		case	1:
			scr_base[X] -= (scr_base[X] - ship_px) / 8.0f;
			scr_base[Y] -= (scr_base[Y] - ship_py) / 8.0f;
			scr_pos[X] = scr_base[X] + scr_ofs[X];
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y];
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}


void	TSKbg01Draw(int id)
{
	float[XYZ]	pos;

	if(!bg_disp) return;

	glBegin(GL_QUADS);
	glColor3f(0.015f,0.015f,0.075f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(-1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(+1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(+1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(-1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glEnd();
	switch(bg_mode){
		case	0:
			for(int i = 0; i < bg_obj.length; i++){
				glBegin(GL_LINES);
				glColor3f(0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]));
				for(int j = 0; j < bg_obj[i].line_list.length; j++){
					pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[j][X], bg_obj[i].line_list[j][Z]);
					pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[j][Y], bg_obj[i].line_list[j][Z]);
					pos[Z] = bg_obj[i].line_list[j][Z];
					glVertex3f(pos[X], pos[Y], pos[Z]);
				}
				glEnd();
			}
			break;
		case	1:
			for(int i = 0; i < bg_obj.length; i++){
				glBegin(GL_LINE_LOOP);
				glColor3f(0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]));
				for(int j = 0; j < bg_obj[i].line_list[i].length; j++){
					pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[j][X], bg_obj[i].line_list[j][Z]);
					pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[j][Y], bg_obj[i].line_list[j][Z]);
					pos[Z] = bg_obj[i].line_list[j][Z];
					glVertex3f(pos[X], pos[Y], pos[Z]);
				}
				glEnd();
			}
			break;
		case	2:
			for(int i = 0; i < bg_obj.length; i++){
				glBegin(GL_QUADS);
				glColor3f(0.05f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.05f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.05f*(1.0f+bg_obj[i].line_list[0][Z]));
				for(int j = 0; j < bg_obj[i].line_list[i].length; j++){
					pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[j][X], bg_obj[i].line_list[j][Z]);
					pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[j][Y], bg_obj[i].line_list[j][Z]);
					pos[Z] = bg_obj[i].line_list[j][Z];
					glVertex3f(pos[X], pos[Y], pos[Z]);
				}
				glEnd();
			}
			break;
		case	3:
			glBegin(GL_POINTS);
			for(int i = 0; i < bg_obj.length; i++){
				pos[Z] = bg_obj[i].line_list[0][Z];
				glColor3f(1.0f+pos[Z],
						  1.0f+pos[Z],
						  1.0f+pos[Z]);
				pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[0][X], pos[Z]);
				pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[0][Y], pos[Z]);
				glVertex3f(pos[X], pos[Y], pos[Z]);
			}
			glEnd();
			break;
		case	4:
			for(int i = 0; i < bg_obj.length; i++){
				glBegin(GL_LINES);
				glColor3f(0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]));
				pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[0][X], bg_obj[i].line_list[0][Z]);
				pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[0][Y], bg_obj[i].line_list[0][Z]);
				pos[Z] = bg_obj[i].line_list[0][Z];
				glVertex3f(pos[X], pos[Y], pos[Z]);
				glColor3f(0.25f*(1.0f+bg_obj[i].line_list[1][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[1][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[1][Z]));
				pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[1][X], bg_obj[i].line_list[1][Z]);
				pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[1][Y], bg_obj[i].line_list[1][Z]);
				pos[Z] = bg_obj[i].line_list[1][Z];
				glVertex3f(pos[X], pos[Y], pos[Z]);
				glEnd();
			}
			break;
		default:
			break;
	}
}


void	TSKbg01Exit(int id)
{
	bg_obj.length = 0;
}


void	TSKbgOutBg(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKbgOutBgDraw;
			TskBuf[id].fp_exit = null;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKbgOutBgDraw(int id)
{
	glDisable(GL_BLEND);
	glColor4f(0.035f,0.035f,0.015f,1.0f);
	glBegin(GL_QUADS);
	glVertex3f(getPointX(-2048.0f+scr_pos[X], 0.0f),
			   getPointY(-2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(-2048.0f+scr_pos[X], 0.0f),
			   getPointY(+2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(+2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(-2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(-2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(+2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+2048.0f+scr_pos[X], 0.0f),
			   getPointY(+2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+2048.0f+scr_pos[X], 0.0f),
			   getPointY(-2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(-2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(-1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(-1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(-2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(+1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(-1024.0f+scr_pos[X], 0.0f),
			   getPointY(+2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(+2048.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glVertex3f(getPointX(+1024.0f+scr_pos[X], 0.0f),
			   getPointY(+1024.0f+scr_pos[Y], 0.0f),
			   0.0f);
	glEnd();
	glEnable(GL_BLEND);
}


void	TSKbgFrame(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKbgFrameDraw;
			TskBuf[id].fp_exit = null;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKbgFrameDraw(int id)
{
	float	z;

	z = BASE_Z - cam_pos;

	glDisable(GL_BLEND);
	glColor4f(0.0f,0.0f,0.0f,1.0f);
	glBegin(GL_QUADS);
	glVertex3f(getPointX(-(SCREEN_X / 2), z),
			   getPointY(-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_Y / 2), z),
			   getPointY(-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_Y / 2), z),
			   getPointY(+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_X / 2), z),
			   getPointY(+(SCREEN_Y / 2), z),
			   0.0f);

	glVertex3f(getPointX(+(SCREEN_Y / 2), z),
			   getPointY(-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_X / 2), z),
			   getPointY(-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_X / 2), z),
			   getPointY(+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_Y / 2), z),
			   getPointY(+(SCREEN_Y / 2), z),
			   0.0f);
	glEnd();
	glEnable(GL_BLEND);
}


void	setQuake(int frame, float quake)
{
	int	eid;

	eid = setTSK(GROUP_01,&TSKbgQuake);
	TskBuf[eid].wait = frame;
	TskBuf[eid].vx = quake;
	TskBuf[eid].vy = quake;
}


void	TSKbgQuake(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].cnt = TskBuf[id].wait / 2;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].px  = ((rand() % (256.0f * TskBuf[id].vx)) - ((256.0f * TskBuf[id].vx) / 2)) / 256.0f;
				TskBuf[id].py  = ((rand() % (256.0f * TskBuf[id].vy)) - ((256.0f * TskBuf[id].vy) / 2)) / 256.0f;
				TskBuf[id].vx += (0.0f - TskBuf[id].vx) / TskBuf[id].cnt;
				TskBuf[id].vy += (0.0f - TskBuf[id].vy) / TskBuf[id].cnt;
				scr_ofs[X] = TskBuf[id].px;
				scr_ofs[Y] = TskBuf[id].py;
				TskBuf[id].wait--;
			}else{
				scr_ofs[X] = 0.0f;
				scr_ofs[Y] = 0.0f;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKbgZoom(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].vx = (TskBuf[id].tx - cam_pos) / TskBuf[id].wait;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				cam_pos += TskBuf[id].vx;
			}else{
				cam_pos = TskBuf[id].tx;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}


