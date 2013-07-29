/*
	area2048 'SYSTEM DISPLAY'

		'system.d'

	2004/03/24 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	std.random;
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
private	import	task;
private	import	gctrl;
private	import	stg;
private	import	bg;
private	import	ship;

private	char[]	str_buf;
private	int		wrk1_time;
private	int		wrk2_time;
private	int		wrk1_bonus;
private	int		wrk2_bonus;
private	int		wrk1_option;
private	int		wrk2_option;
private	int		wrk1_total;
private	int		wrk2_total;
private	int		extend_score;

void	TSKsystem(int id)
{
	switch(TskBuf[id].step){
		case	0:
			str_buf.length = 256;
			TskBuf[id].fp_draw = &TSKsystemDraw;
			TskBuf[id].fp_exit = &TSKsystemExit;
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

void	TSKsystemDraw(int id)
{
	int	tmin,tsec,tmsec;
	float z;
	float[XY] base;
	float gauge;

	/* 文字情報描画 */
	glColor4f(1.0f,1.0f,1.0f,1.0f);
	str_buf  = "SCORE ".dup;
	str_buf ~= to!string(score);
	drawASCII(str_buf, -(SCREEN_S / 2) + 8, +(SCREEN_S / 2) - 8 - 12 * 0, 0.50f);
	str_buf  = "L:".dup;
	str_buf ~= to!string(left);
	drawASCII(str_buf, -(SCREEN_S / 2) + 8, +(SCREEN_S / 2) - 8 - 12 * 1, 0.50f);
	if(BombTST()) glColor4f(1.0f,1.0f,1.0f,1.0f);
	else		  glColor4f(0.5f,0.5f,0.5f,1.0f);
	str_buf  = "W:".dup;
	str_buf ~= to!string(bomb_lv);
	drawASCII(str_buf, -(SCREEN_S / 2) + 8 + (getWidthASCII("     ",0.5f)), +(SCREEN_S / 2) - 8 - 12 * 1, 0.50f);
	glColor4f(1.0f,1.0f,1.0f,1.0f);
	str_buf  = "BONUS ".dup;
	str_buf ~= to!string(bomb_bonus);
	drawASCII(str_buf, -(SCREEN_S / 2) + 8, +(SCREEN_S / 2) - 8 - 12 * 2, 0.50f);
/*
	str_buf  = "TASK ".dup;
	str_buf ~= to!string(TskCnt);
	drawASCII(str_buf, -(SCREEN_S / 2) + 8, +(SCREEN_S / 2) - 8 - 12 * 3, 0.50f);
*/
	str_buf  = "ENEMY ".dup;
	if(enemy_stg < 10) str_buf ~= "0";
	str_buf ~= to!string(enemy_stg);
	drawASCII(str_buf, -(SCREEN_S / 2) + 8, -(SCREEN_S / 2) + 20, 0.50f);
	tmin  = time_left / ONE_MIN;
	tsec  = time_left / ONE_SEC % ONE_SEC;
	tmsec = ((time_left % ONE_SEC) * 100 / ONE_SEC);
	str_buf  = "TIME ".dup;
	if(tmin < 10) str_buf ~= " ";
	str_buf ~= to!string(tmin);
	str_buf ~= ":";
	if(tsec < 10) str_buf ~= "0";
	str_buf ~= to!string(tsec);
	str_buf ~= ":";
	if(tmsec < 10) str_buf ~= "0";
	str_buf ~= to!string(tmsec);
	drawASCII(str_buf, -(SCREEN_S / 2) + 8 + (getWidthASCII("         ",0.5f)), -(SCREEN_S / 2) + 20, 0.50f);

	/* ボムゲージ描画 */
	z = BASE_Z - cam_pos;

	base[X] = -(SCREEN_S / 2) + 4 + getWidthASCII("         ",0.5f);
	base[Y] = +(SCREEN_S / 2) - 8 - 12 * 1;

	GLfloat[4*XYZ]	quadVertices;

	quadVertices[0*XYZ + X] = getPointX(base[X]+  0.0f, z);
	quadVertices[0*XYZ + Y] = getPointY(base[Y]-  8.0f, z);
	quadVertices[0*XYZ + Z] = 0.0f;

	quadVertices[1*XYZ + X] = getPointX(base[X]+  0.0f, z);
	quadVertices[1*XYZ + Y] = getPointY(base[Y]+  0.0f, z);
	quadVertices[1*XYZ + Z] = 0.0f;

	quadVertices[2*XYZ + X] = getPointX(base[X]+248.0f, z);
	quadVertices[2*XYZ + Y] = getPointY(base[Y]+  0.0f, z);
	quadVertices[2*XYZ + Z] = 0.0f;

	quadVertices[3*XYZ + X] = getPointX(base[X]+248.0f, z);
	quadVertices[3*XYZ + Y] = getPointY(base[Y]-  8.0f, z);
	quadVertices[3*XYZ + Z] = 0.0f;

	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.25f,0.25f,0.25f,0.25f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

	if(bomb != (BOMB_ONE * BOMB_MAX)){
		gauge  = 248.0f * (bomb % BOMB_ONE);
		gauge /= BOMB_ONE;
	}else{
		gauge = 248.0f;
	}

	quadVertices[2*XYZ + X] = getPointX(base[X]+ gauge, z);
	quadVertices[3*XYZ + X] = getPointX(base[X]+ gauge, z);

	glColor4f(0.75f,0.75f,0.25f,0.50f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

	quadVertices[2*XYZ + X] = getPointX(base[X]+248.0f, z);
	quadVertices[3*XYZ + X] = getPointX(base[X]+248.0f, z);

	glColor4f(1.0f,1.0f,1.0f,0.75f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
	glDrawArrays(GL_LINE_LOOP, 0, 4);

	glDisableClientState(GL_VERTEX_ARRAY);
}

void	TSKsystemExit(int id)
{
	str_buf.length = 0;
}

void	TSKradar(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = +(SCREEN_S / 2)-64.0f-8.0f;
			TskBuf[id].py = +(SCREEN_S / 2)-64.0f-8.0f;
			TskBuf[id].fp_draw = &TSKradarDraw;
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

void	TSKradarDraw(int id)
{
	float z;
	float[XY] pos;
	float[XY] col;
	int	prev;
	GLfloat[4*XYZ]	quadVertices;

	z = BASE_Z - cam_pos;

	glEnableClientState(GL_VERTEX_ARRAY);

	/* レーダーBG表示 */
	quadVertices[0*XYZ + X] = getPointX(TskBuf[id].px-64.0f, z);
	quadVertices[0*XYZ + Y] = getPointY(TskBuf[id].py-64.0f, z);
	quadVertices[0*XYZ + Z] = 0.0f;

	quadVertices[1*XYZ + X] = getPointX(TskBuf[id].px-64.0f, z);
	quadVertices[1*XYZ + Y] = getPointY(TskBuf[id].py+64.0f, z);
	quadVertices[1*XYZ + Z] = 0.0f;

	quadVertices[2*XYZ + X] = getPointX(TskBuf[id].px+64.0f, z);
	quadVertices[2*XYZ + Y] = getPointY(TskBuf[id].py+64.0f, z);
	quadVertices[2*XYZ + Z] = 0.0f;

	quadVertices[3*XYZ + X] = getPointX(TskBuf[id].px+64.0f, z);
	quadVertices[3*XYZ + Y] = getPointY(TskBuf[id].py-64.0f, z);
	quadVertices[3*XYZ + Z] = 0.0f;

	glColor4f(0.05f,0.50f,0.05f,0.25f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

	glColor4f(1.0f,1.0f,1.0f,0.5f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
	glDrawArrays(GL_LINE_LOOP, 0, 4);


	/* 敵表示 */
	for(int i = TskIndex[GROUP_02]; i != -1; i = prev){
		glColor4f(1.0f,0.0f,0.0f,TskBuf[i].alpha);
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0){
			col[X] = TskBuf[i].cx / 16.0f;
			col[Y] = TskBuf[i].cy / 16.0f;
			pos[X] = TskBuf[id].px - TskBuf[i].px / 16.0f;
			pos[Y] = TskBuf[id].py - TskBuf[i].py / 16.0f;

			quadVertices[0*XYZ + X] = getPointX(pos[X]-col[X], z);
			quadVertices[0*XYZ + Y] = getPointY(pos[Y]+col[Y], z);

			quadVertices[1*XYZ + X] = getPointX(pos[X]-col[X], z);
			quadVertices[1*XYZ + Y] = getPointY(pos[Y]-col[Y], z);

			quadVertices[2*XYZ + X] = getPointX(pos[X]+col[X], z);
			quadVertices[2*XYZ + Y] = getPointY(pos[Y]-col[Y], z);

			quadVertices[3*XYZ + X] = getPointX(pos[X]+col[X], z);
			quadVertices[3*XYZ + Y] = getPointY(pos[Y]+col[Y], z);

			glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
			glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		}
	}
	/* 自機表示 */
	glColor4f(1.0f,1.0f,1.0f,1.0f);
	if(TskBuf[ship_id].tskid != 0){
		pos[X] = TskBuf[id].px - TskBuf[ship_id].px / 16.0f;
		pos[Y] = TskBuf[id].py - TskBuf[ship_id].py / 16.0f;

		quadVertices[0*XYZ + X] = getPointX(pos[X]-1.0f, z);
		quadVertices[0*XYZ + Y] = getPointY(pos[Y]+1.0f, z);

		quadVertices[1*XYZ + X] = getPointX(pos[X]-1.0f, z);
		quadVertices[1*XYZ + Y] = getPointY(pos[Y]-1.0f, z);

		quadVertices[2*XYZ + X] = getPointX(pos[X]+1.0f, z);
		quadVertices[2*XYZ + Y] = getPointY(pos[Y]-1.0f, z);

		quadVertices[3*XYZ + X] = getPointX(pos[X]+1.0f, z);
		quadVertices[3*XYZ + Y] = getPointY(pos[Y]+1.0f, z);

		glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	}
	glDisableClientState(GL_VERTEX_ARRAY);
}

void	TSKstgStartMsg(int id)
{
	int	eid;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKstgStartMsgDraw;
			TskBuf[id].wait = 60;
			TskBuf[id].nx = 0.0f;
			TskBuf[id].ny = 1.0f / (TskBuf[id].wait * 1.5f);
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait > 30 && TskBuf[id].wait & 0x02){
				eid = setTSK(GROUP_08,&TSKstgStartMsgEffect);
				TskBuf[eid].sx = 3.0f;
				TskBuf[eid].tx = 1.0f;
			}
			if(TskBuf[id].wait){
				TskBuf[id].nx += TskBuf[id].ny;
				TskBuf[id].wait--;
			}else{
				TskBuf[id].wait = 60;
				TskBuf[id].step++;
			}
			break;
		case	2:
			if(TskBuf[id].wait){
				TskBuf[id].nx += TskBuf[id].ny;
				TskBuf[id].wait--;
			}else{
				TskBuf[id].nx = 1.0f;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void	TSKstgStartMsgDraw(int id)
{
	float px;

	if(g_step != GSTEP_DEMO){
		glColor4f(1.0f,1.0f,1.0f,TskBuf[id].nx);
		str_buf  = "AREA ".dup;
		str_buf ~= to!string(area_num + 1);
		px = getWidthASCII(str_buf, 0.5f);
		px /= 2.0f;
		px *= -1.0f;
		px  = ceil(px);
		drawASCII(str_buf, px, +10.0f, 0.5f);
		str_buf  = "SCENE ".dup;
		str_buf ~= to!string(scene_num + 1);
		px = getWidthASCII(str_buf, 0.5f);
		px /= 2.0f;
		px *= -1.0f;
		px  = ceil(px);
		drawASCII(str_buf, px,  +0.0f, 0.5f);
		if(scene_num != SCENE_10){
			str_buf  = to!string(enemy_stg).dup;
			str_buf ~= " ENEMIES";
			px = getWidthASCII(str_buf, 0.5f);
			px /= 2.0f;
			px *= -1.0f;
			px  = ceil(px);
			drawASCII(str_buf, px, -10.0f, 0.5f);
		}
	}else{
		glColor4f(1.0f,1.0f,1.0f,1.0f);
		str_buf = "DEMO PLAY".dup;
		px = getWidthASCII(str_buf, 0.5f);
		px /= 2.0f;
		px *= -1.0f;
		px  = ceil(px);
		drawASCII(str_buf, px, +32.0f, 0.5f);
	}
}

void	TSKstgStartMsgEffect(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKstgStartMsgEffectDraw;
			TskBuf[id].wait = 15;
			TskBuf[id].vx = (TskBuf[id].tx - TskBuf[id].sx) / TskBuf[id].wait;
			TskBuf[id].nx = 1.0f;
			TskBuf[id].ny = 1.0f / TskBuf[id].wait;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].nx -= TskBuf[id].ny;
				TskBuf[id].sx += TskBuf[id].vx;
				TskBuf[id].wait--;
			}else{
				TskBuf[id].nx = 0.0f;
				TskBuf[id].sx = TskBuf[id].tx;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void	TSKstgStartMsgEffectDraw(int id)
{
	float[XY] pos;

	if(g_step != GSTEP_DEMO){
		glColor4f(1.0f,1.0f,1.0f,TskBuf[id].ny);
		str_buf  = "AREA ".dup;
		str_buf ~= to!string(area_num + 1);
		pos[X] = getWidthASCII(str_buf, TskBuf[id].sx);
		pos[X] /= 2.0f;
		pos[X] *= -1.0f;
		pos[X]  = ceil(pos[X]);
		pos[Y]  = 10.0f + ASC_SIZE * (TskBuf[id].wait / 15.0f);
		drawASCII(str_buf, pos[X], pos[Y], TskBuf[id].sx);
		str_buf  = "SCENE ".dup;
		str_buf ~= to!string(scene_num + 1);
		pos[X] = getWidthASCII(str_buf, TskBuf[id].sx);
		pos[X] /= 2.0f;
		pos[X] *= -1.0f;
		pos[X]  = ceil(pos[X]);
		pos[Y]  = 0.0f + ASC_SIZE * (TskBuf[id].wait / 15.0f);
		drawASCII(str_buf, pos[X], pos[Y], TskBuf[id].sx);
		if(scene_num != SCENE_10){
			str_buf  = to!string(enemy_stg).dup;
			str_buf ~= " ENEMIES";
			pos[X] = getWidthASCII(str_buf, TskBuf[id].sx);
			pos[X] /= 2.0f;
			pos[X] *= -1.0f;
			pos[X]  = ceil(pos[X]);
			pos[Y]  = -10.0f + ASC_SIZE * (TskBuf[id].wait / 15.0f);
			drawASCII(str_buf, pos[X], pos[Y], TskBuf[id].sx);
		}
	}
}

void	TSKstgClearMsg(int id)
{
	int	eid;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKstgClearMsgDraw;
			TskBuf[id].wait = 15;
			TskBuf[id].nx = 0.0f;
			TskBuf[id].ny = 1.0f / (TskBuf[id].wait * 1.5f);
			TskBuf[id].cnt = 0;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].nx += TskBuf[id].ny;
				TskBuf[id].wait--;
			}else{
				TskBuf[id].wait = 60;
				wrk1_time = 0;
				wrk2_time = time_clear / TskBuf[id].wait;
				wrk1_bonus = 0;
				wrk2_bonus = time_bonus - time_clear;
				if(wrk2_bonus < 0) wrk2_bonus = 0;
				wrk2_bonus *= 10;
				wrk2_bonus /= TskBuf[id].wait;
				wrk1_option = 0;
				wrk2_option = opt_bonus;
				wrk2_option /= TskBuf[id].wait;
				wrk1_total = 0;
				wrk2_total = time_total / TskBuf[id].wait;
				TskBuf[id].step++;
			}
			break;
		case	2:
			if(TskBuf[id].wait){
				wrk1_time += wrk2_time;
				wrk1_bonus += wrk2_bonus;
				wrk1_option += wrk2_option;
				wrk1_total += wrk2_total;
				TskBuf[id].nx += TskBuf[id].ny;
				TskBuf[id].wait--;
			}else{
				wrk2_bonus = time_bonus - time_clear;
				if(wrk2_bonus < 0) wrk2_bonus = 0;
				wrk2_bonus *= 10;
				wrk2_option = opt_bonus;
				wrk1_time = time_clear;
				wrk1_bonus = wrk2_bonus;
				wrk1_option = wrk2_option;
				wrk1_total = time_total;
				addScore(wrk1_bonus);
				addScore(wrk2_option);
				TskBuf[id].wait = 90;
				TskBuf[id].step++;
			}
			break;
		case	3:
			if(TskBuf[id].wait) TskBuf[id].wait--;
			else				TskBuf[id].step = -1;
			break;
		default:
			clrTSK(id);
			break;
	}
}

void	TSKstgClearMsgDraw(int id)
{
	float px,py;
	int	tmin,tsec,tmsec;

	if(g_step == GSTEP_DEMO) return;

	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].nx);
	if(area_num != 5 && scene_num != SCENE_10) str_buf  = "SCENE CLEAR".dup;
	else									   str_buf  = "MISSION COMPLETE".dup;
	px = getWidthASCII(str_buf, 0.5f);
	px /= 2.0f;
	px *= -1.0f;
	px  = ceil(px);
	py = +10.0f;
	drawASCII(str_buf, px, py, 0.5f);
	tmin  = wrk1_time / ONE_MIN;
	tsec  = wrk1_time / ONE_SEC % ONE_SEC;
	tmsec = ((wrk1_time % ONE_SEC) * 100 / ONE_SEC);
	str_buf  = "CLEAR TIME ".dup;
	if(tmin < 10) str_buf ~= " ";
	str_buf ~= to!string(tmin);
	str_buf ~= ":";
	if(tsec < 10) str_buf ~= "0";
	str_buf ~= to!string(tsec);
	str_buf ~= ":";
	if(tmsec < 10) str_buf ~= "0";
	str_buf ~= to!string(tmsec);
	px = getWidthASCII(str_buf, 0.5f);
	px /= 2.0f;
	px *= -1.0f;
	px  = ceil(px);
	py -= +10.0f;
	drawASCII(str_buf, px, py, 0.5f);
	if(scene_num == SCENE_10){
		tmin  = wrk1_total / ONE_MIN;
		tsec  = wrk1_total / ONE_SEC % ONE_SEC;
		tmsec = ((wrk1_total % ONE_SEC) * 100 / ONE_SEC);
		str_buf  = "TOTAL TIME ".dup;
		if(tmin < 10) str_buf ~= " ";
		str_buf ~= to!string(tmin);
		str_buf ~= ":";
		if(tsec < 10) str_buf ~= "0";
		str_buf ~= to!string(tsec);
		str_buf ~= ":";
		if(tmsec < 10) str_buf ~= "0";
		str_buf ~= to!string(tmsec);
		px = getWidthASCII(str_buf, 0.5f);
		px /= 2.0f;
		px *= -1.0f;
		px  = ceil(px);
		py -= +10.0f;
		drawASCII(str_buf, px, py, 0.5f);
	}
	str_buf  = "TIME BONUS ".dup;
	if(wrk1_bonus < 10000) str_buf ~= " ";
	if(wrk1_bonus < 1000)  str_buf ~= " ";
	if(wrk1_bonus < 100)   str_buf ~= " ";
	if(wrk1_bonus < 10)    str_buf ~= " ";
	str_buf ~= to!string(wrk1_bonus);
	px = getWidthASCII(str_buf, 0.5f);
	px /= 2.0f;
	px *= -1.0f;
	px  = ceil(px);
	py -= +10.0f;
	drawASCII(str_buf, px, py, 0.5f);
	if(scene_num == SCENE_10){
		str_buf  = "DESTROY BONUS ".dup;
		if(wrk1_option < 10000) str_buf ~= " ";
		if(wrk1_option < 1000)  str_buf ~= " ";
		if(wrk1_option < 100)   str_buf ~= " ";
		if(wrk1_option < 10)    str_buf ~= " ";
		str_buf ~= to!string(wrk1_option);
		px = getWidthASCII(str_buf, 0.5f);
		px /= 2.0f;
		px *= -1.0f;
		px  = ceil(px);
		py -= +10.0f;
		drawASCII(str_buf, px, py, 0.5f);
	}
}

void	addScore(int add_score)
{
	score += add_score;
	if(score > 999999990) score = 999999990;
}

void	addScoreBomb()
{
	addScore(bomb_bonus);
}

void	TSKgauge(int id)
{
	int	tid;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKgaugeDraw;
			TskBuf[id].step++;
			break;
		case	1:
			tid = TskBuf[id].parent;
			TskBuf[id].pz = TskBuf[tid].pz;
			TskBuf[id].energy = TskBuf[tid].energy;
			if(TskBuf[tid].energy <= 0){
				TskBuf[id].step = -1;
				TskBuf[id].energy = 0;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void	TSKgaugeDraw(int id)
{
	float z;
	float[XY] base;
	float energy;

	/* ボムゲージ描画 */
	z = BASE_Z - cam_pos;

	base[X] = TskBuf[id].tx;
	base[Y] = TskBuf[id].ty;

	GLfloat[4*XYZ]	quadVertices;

	quadVertices[0*XYZ + X] = getPointX(base[X]+         0.0f, z);
	quadVertices[0*XYZ + Y] = getPointY(base[Y]-TskBuf[id].vy, z);
	quadVertices[0*XYZ + Z] = 0.0f;

	quadVertices[1*XYZ + X] = getPointX(base[X]+         0.0f, z);
	quadVertices[1*XYZ + Y] = getPointY(base[Y]+         0.0f, z);
	quadVertices[1*XYZ + Z] = 0.0f;

	quadVertices[2*XYZ + X] = getPointX(base[X]+TskBuf[id].vx, z);
	quadVertices[2*XYZ + Y] = getPointY(base[Y]+         0.0f, z);
	quadVertices[2*XYZ + Z] = 0.0f;

	quadVertices[3*XYZ + X] = getPointX(base[X]+TskBuf[id].vx, z);
	quadVertices[3*XYZ + Y] = getPointY(base[Y]-TskBuf[id].vy, z);
	quadVertices[3*XYZ + Z] = 0.0f;

	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.25f,0.25f,0.25f,0.25f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

	energy  = TskBuf[id].energy;
	energy /= TskBuf[id].cnt;
	energy *= TskBuf[id].vx;

	quadVertices[2*XYZ + X] = getPointX(base[X]+       energy, z);
	quadVertices[3*XYZ + X] = getPointX(base[X]+       energy, z);

	glColor4f(0.25f,0.25f,0.75f,0.50f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

	quadVertices[2*XYZ + X] = getPointX(base[X]+TskBuf[id].vx, z);
	quadVertices[3*XYZ + X] = getPointX(base[X]+TskBuf[id].vx, z);

	glColor4f(1.0f,1.0f,1.0f,0.50f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
	glDrawArrays(GL_LINE_LOOP, 0, 4);

	glDisableClientState(GL_VERTEX_ARRAY);

}

void	TSKgameover(int id)
{
	int	eid;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].fp_draw = &TSKgameoverDraw;
				TskBuf[id].wait = 300;
				TskBuf[id].step++;
			}
			break;
		case	2:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				if(TskBuf[id].wait < 180 && (trgs & PAD_BUTTON1)){
					TskBuf[id].step = -1;
				}
			}else{
				TskBuf[id].step = -1;
			}
			break;
		default:
			stg_ctrl = STG_INIT;
			clrTSK(id);
			break;
	}
}

void	TSKgameoverDraw(int id)
{
	float px;

	glColor4f(1.0f,1.0f,1.0f,1.0f);
	str_buf = "GAME OVER".dup;
	px = getWidthASCII(str_buf, 0.5f);
	px /= 2.0f;
	px *= -1.0f;
	px  = ceil(px);
	drawASCII(str_buf, px, +5.0f, 0.5f);
}

void	TSKextend(int id)
{
	int	flag = 0;

	switch(TskBuf[id].step){
		case	0:
			extend_score = 10000;
			TskBuf[id].step++;
		case	1:
			if(score >= extend_score){
				flag++;
				extend_score = 50000;
				TskBuf[id].step++;
			}else{
				break;
			}
		case	2:
			if(score > extend_score){
				flag++;
				extend_score = 100000;
				TskBuf[id].step++;
			}else{
				break;
			}
		case	3:
			if(score > extend_score){
				flag++;
				extend_score += 100000;
			}
			break;
		default:
			clrTSK(id);
			break;
	}

	if(flag){
		if(game_level == GLEVEL_EASY){
			if(left < 99){
				playSNDse(SND_VOICE_EXTEND);
				left += flag;
			}
		}else{
			if(left < 4){
				playSNDse(SND_VOICE_EXTEND);
				left += flag;
			}
		}
	}
}

void	TSKlock(int id)
{
	int	trg = TskBuf[ship_id].trg_id;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKlockDraw;
			TskBuf[id].step++;
			break;
		case	1:
			if(ship_lock == 1 && trg != -1){
				playSNDse(SND_SE_LOCK_ON);
				TskBuf[id].sx = 2.0f;
				TskBuf[id].wait = 10;
				TskBuf[id].step++;
			}
			break;
		case	2:
			if(ship_lock == 0 || trg == -1) TskBuf[id].step++;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				TskBuf[id].sx -= 1.0f / 10.0f;
			}else{
				TskBuf[id].sx = 1.0f;
			}
			break;
		case	3:
			if(ship_lock == 1 && trg != -1){
				playSNDse(SND_SE_LOCK_ON);
				TskBuf[id].step--;
				break;
			}
			playSNDse(SND_SE_LOCK_OFF);
			TskBuf[id].step = 1;
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}

void	TSKlockDraw(int id)
{
	int	trg = TskBuf[ship_id].trg_id;
	float[XY] base;
	float z;
	float size,lx,ly;
	GLfloat[4*XYZ]	quadVertices;
	GLfloat[20*XYZ]	lineVertices;

	if(ship_lock == 0) return;

	/* ターゲット描画 */
	z = BASE_Z - cam_pos;
	base[X] = scr_pos[X] - TskBuf[trg].px;
	base[Y] = scr_pos[Y] - TskBuf[trg].py;

	size = 40.0f * TskBuf[id].sx;

	quadVertices[0*XYZ + X] = getPointX(base[X]-size, 0.0f);
	quadVertices[0*XYZ + Y] = getPointY(base[Y]-size, 0.0f);
	quadVertices[0*XYZ + Z] = z;

	quadVertices[1*XYZ + X] = getPointX(base[X]-size, 0.0f);
	quadVertices[1*XYZ + Y] = getPointY(base[Y]+size, 0.0f);
	quadVertices[1*XYZ + Z] = z;

	quadVertices[2*XYZ + X] = getPointX(base[X]+size, 0.0f);
	quadVertices[2*XYZ + Y] = getPointY(base[Y]+size, 0.0f);
	quadVertices[2*XYZ + Z] = z;

	quadVertices[3*XYZ + X] = getPointX(base[X]+size, 0.0f);
	quadVertices[3*XYZ + Y] = getPointY(base[Y]-size, 0.0f);
	quadVertices[3*XYZ + Z] = z;

	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.50f,0.50f,0.50f,0.75f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);


	lx = 24.0f * TskBuf[id].sx;
	ly = 24.0f * TskBuf[id].sx;
	/* 左下 */
	lineVertices[0*XYZ + X] = getPointX(base[X]-size, 0.0f);
	lineVertices[0*XYZ + Y] = getPointY(base[Y]-size+ly, 0.0f);
	lineVertices[0*XYZ + Z] = z;

	lineVertices[1*XYZ + X] = getPointX(base[X]-size, 0.0f);
	lineVertices[1*XYZ + Y] = getPointY(base[Y]-size, 0.0f);
	lineVertices[1*XYZ + Z] = z;

	lineVertices[2*XYZ + X] = getPointX(base[X]-size, 0.0f);
	lineVertices[2*XYZ + Y] = getPointY(base[Y]-size, 0.0f);
	lineVertices[2*XYZ + Z] = z;

	lineVertices[3*XYZ + X] = getPointX(base[X]-size+lx, 0.0f);
	lineVertices[3*XYZ + Y] = getPointY(base[Y]-size, 0.0f);
	lineVertices[3*XYZ + Z] = z;
	/* 左上 */
	lineVertices[4*XYZ + X] = getPointX(base[X]-size, 0.0f);
	lineVertices[4*XYZ + Y] = getPointY(base[Y]+size-ly, 0.0f);
	lineVertices[4*XYZ + Z] = z;

	lineVertices[5*XYZ + X] = getPointX(base[X]-size, 0.0f);
	lineVertices[5*XYZ + Y] = getPointY(base[Y]+size, 0.0f);
	lineVertices[5*XYZ + Z] = z;

	lineVertices[6*XYZ + X] = getPointX(base[X]-size, 0.0f);
	lineVertices[6*XYZ + Y] = getPointY(base[Y]+size, 0.0f);
	lineVertices[6*XYZ + Z] = z;

	lineVertices[7*XYZ + X] = getPointX(base[X]-size+lx, 0.0f);
	lineVertices[7*XYZ + Y] = getPointY(base[Y]+size, 0.0f);
	lineVertices[7*XYZ + Z] = z;
	/* 右下 */
	lineVertices[8*XYZ + X] = getPointX(base[X]+size, 0.0f);
	lineVertices[8*XYZ + Y] = getPointY(base[Y]-size+ly, 0.0f);
	lineVertices[8*XYZ + Z] = z;

	lineVertices[9*XYZ + X] = getPointX(base[X]+size, 0.0f);
	lineVertices[9*XYZ + Y] = getPointY(base[Y]-size, 0.0f);
	lineVertices[9*XYZ + Z] = z;

	lineVertices[10*XYZ + X] = getPointX(base[X]+size, 0.0f);
	lineVertices[10*XYZ + Y] = getPointY(base[Y]-size, 0.0f);
	lineVertices[10*XYZ + Z] = z;

	lineVertices[11*XYZ + X] = getPointX(base[X]+size-lx, 0.0f);
	lineVertices[11*XYZ + Y] = getPointY(base[Y]-size, 0.0f);
	lineVertices[11*XYZ + Z] = z;
	/* 右上 */
	lineVertices[12*XYZ + X] = getPointX(base[X]+size, 0.0f);
	lineVertices[12*XYZ + Y] = getPointY(base[Y]+size-ly, 0.0f);
	lineVertices[12*XYZ + Z] = z;

	lineVertices[13*XYZ + X] = getPointX(base[X]+size, 0.0f);
	lineVertices[13*XYZ + Y] = getPointY(base[Y]+size, 0.0f);
	lineVertices[13*XYZ + Z] = z;

	lineVertices[14*XYZ + X] = getPointX(base[X]+size, 0.0f);
	lineVertices[14*XYZ + Y] = getPointY(base[Y]+size, 0.0f);
	lineVertices[14*XYZ + Z] = z;

	lineVertices[15*XYZ + X] = getPointX(base[X]+size-lx, 0.0f);
	lineVertices[15*XYZ + Y] = getPointY(base[Y]+size, 0.0f);
	lineVertices[15*XYZ + Z] = z;
	/* クロス */
	lineVertices[16*XYZ + X] = getPointX(base[X]-lx, 0.0f);
	lineVertices[16*XYZ + Y] = getPointY(base[Y], 0.0f);
	lineVertices[16*XYZ + Z] = z;

	lineVertices[17*XYZ + X] = getPointX(base[X]+lx, 0.0f);
	lineVertices[17*XYZ + Y] = getPointY(base[Y], 0.0f);
	lineVertices[17*XYZ + Z] = z;

	lineVertices[18*XYZ + X] = getPointX(base[X], 0.0f);
	lineVertices[18*XYZ + Y] = getPointY(base[Y]-ly, 0.0f);
	lineVertices[18*XYZ + Z] = z;

	lineVertices[19*XYZ + X] = getPointX(base[X], 0.0f);
	lineVertices[19*XYZ + Y] = getPointY(base[Y]+ly, 0.0f);
	lineVertices[19*XYZ + Z] = z;

	glColor4f(1.0f,1.0f,1.0f,1.50f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(lineVertices.ptr));
	glDrawArrays(GL_LINES, 0, 20);

	glDisableClientState(GL_VERTEX_ARRAY);
}
