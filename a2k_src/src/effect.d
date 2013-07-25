/*
	area2048 'EFFCTE'

		'effect.d'

	2004/03/31 jumpei isshiki
*/

private	import	std.math;
private	import	main;
private	import	std.string;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	task;
private	import	bg;

float	fade_r = 0.0f;
float	fade_g = 0.0f;
float	fade_b = 0.0f;
float	fade_a = 0.0f;

int	fade_id;

void	effSetParticle01(int id, float ofs_x, float ofs_y, int cnt)
{
	int	eid;

	for(int i = 0; i < cnt; i++){
		eid = setTSK(GROUP_07,&TSKparticle01);
		if(eid != -1){
			TskBuf[eid].px = TskBuf[TskBuf[id].trg_id].px + ofs_x;
			TskBuf[eid].py = TskBuf[TskBuf[id].trg_id].py + ofs_y;
		}
	}
}


void	TSKparticle01(int id)
{
	double[XY]	tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKparticle01Draw;
			TskBuf[id].fp_exit = &TSKparticle01Exit;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].alpha = 0.625f;
			TskBuf[id].body_list.length = 3;
			TskBuf[id].body_ang.length  = 3;
			for(int i = 0; i < 3; i++){
				switch(i){
					case	0:
							tpos[X] = -((Rand() % 4096) / 1024.0f + 1.0f);
							tpos[Y] = +((Rand() % 4096) / 1024.0f + 1.0f);
							break;
					case	1:
							tpos[X] =  ((Rand() % 2048) / 1024.0f - 1.0f);
							tpos[Y] = -((Rand() % 4096) / 1024.0f + 1.0f);
							break;
					case	2:
							tpos[X] = +((Rand() % 4096) / 1024.0f + 1.0f);
							tpos[Y] = +((Rand() % 4096) / 1024.0f + 1.0f);
							break;
					default:
							break;
				}
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].tx = (Rand() % 256000) / 1000.0f - 128.0f;
			TskBuf[id].ty = (Rand() % 256000) / 1000.0f - 128.0f;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 15.0f;
			TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 15.0f;
			TskBuf[id].rot += PI / 30;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait) TskBuf[id].step = -1;
			TskBuf[id].alpha -= (0.625f / 60.0f);
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}


void	TSKparticle01Draw(int id)
{
	float[XYZ]	pos;

	glColor4f(0.25f,0.0f,0.0f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < 3; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < 3; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}


void	TSKparticle01Exit(int id)
{
	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
}


void	effSetParticle02(int id, float ofs_x, float ofs_y, int cnt)
{
	int	eid;

	for(int i = 0; i < cnt; i++){
		eid = setTSK(GROUP_07,&TSKparticle02);
		if(eid != -1){
			TskBuf[eid].px = TskBuf[TskBuf[id].trg_id].px + ofs_x;
			TskBuf[eid].py = TskBuf[TskBuf[id].trg_id].py + ofs_y;
		}
	}
}


void	TSKparticle02(int id)
{
	double[XY]	tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKparticle02Draw;
			TskBuf[id].fp_exit = &TSKparticle02Exit;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].alpha = 0.625f;
			TskBuf[id].body_list.length = 3;
			TskBuf[id].body_ang.length  = 3;
			for(int i = 0; i < 3; i++){
				switch(i){
					case	0:
							tpos[X] = -((Rand() % 12288) / 1024.0f + 3.0f);
							tpos[Y] = +((Rand() % 12288) / 1024.0f + 3.0f);
							break;
					case	1:
							tpos[X] =  ((Rand() %  6144) / 1024.0f - 3.0f);
							tpos[Y] = -((Rand() % 12288) / 1024.0f + 3.0f);
							break;
					case	2:
							tpos[X] = +((Rand() % 12288) / 1024.0f + 3.0f);
							tpos[Y] = +((Rand() % 12288) / 1024.0f + 3.0f);
							break;
					default:
							break;
				}
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].tx = (Rand() % 512000) / 1000.0f - 256.0f;
			TskBuf[id].ty = (Rand() % 512000) / 1000.0f - 256.0f;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 15.0f;
			TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 15.0f;
			TskBuf[id].rot += PI / 30;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait) TskBuf[id].step = -1;
			TskBuf[id].alpha -= (0.625f / 60.0f);
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}


void	TSKparticle02Draw(int id)
{
	float[XYZ]	pos;

	glColor4f(0.25f,0.25f,0.00f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < 3; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < 3; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}


void	TSKparticle02Exit(int id)
{
	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
}


void	effSetBrokenBody(int id, float[] poly_tbl,int start, int cnt, float ofs_x, float ofs_y)
{
	double[XY]	tpos;
	int			eid;

	eid = setTSK(GROUP_01,&TSKBrokenBody);
	TskBuf[eid].px = TskBuf[id].px + ofs_x;
	TskBuf[eid].py = TskBuf[id].py + ofs_y;
	TskBuf[eid].pz = TskBuf[id].pz;
	TskBuf[eid].rot = TskBuf[id].rot;
	TskBuf[eid].body_list.length = cnt;
	TskBuf[eid].body_ang.length  = cnt;
	for(int i = 0; i < cnt; i++){
		tpos[X] = poly_tbl[(start+i)*2+0] + ofs_x;
		tpos[Y] = poly_tbl[(start+i)*2+1] + ofs_y;
		TskBuf[eid].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
		TskBuf[eid].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
		TskBuf[eid].body_ang[i][Z] = 0.0f;
		tpos[X] = fabs(tpos[X]);
		tpos[Y] = fabs(tpos[Y]);
		TskBuf[eid].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
	}
}


void	TSKBrokenBody(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKBrokenBodyDraw;
			TskBuf[id].fp_exit = &TSKBrokenBodyExit;
			TskBuf[id].alpha = 1.0f;
			TskBuf[id].tx = (Rand() % 256000) / 1000.0f - 128.0f;
			TskBuf[id].ty = (Rand() % 256000) / 1000.0f - 128.0f;
			TskBuf[id].tx *= 2.0f;
			TskBuf[id].ty *= 2.0f;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].rot_add = (Rand() % 30) - 15;
			if(!(TskBuf[id].rot_add - 15))		TskBuf[id].rot_add = -1;
			else if(!(TskBuf[id].rot_add + 15)) TskBuf[id].rot_add = +1;
			if(TskBuf[id].rot_add < 0) TskBuf[id].rot_add = PI / (TskBuf[id].rot_add - 15);
			else					   TskBuf[id].rot_add = PI / (TskBuf[id].rot_add + 15);
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 15.0f;
			TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 15.0f;
			TskBuf[id].rot += TskBuf[id].rot_add;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait) TskBuf[id].step = -1;
			TskBuf[id].alpha -= (1.0f / 60.0f);
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}


void	TSKBrokenBodyDraw(int id)
{
	float[XYZ]	pos;

	glColor4f(0.5f,0.5f,0.5f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < TskBuf[id].body_list.length; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}


void	TSKBrokenBodyExit(int id)
{
	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
}


void	effSetBrokenLine(int id, float[] poly_tbl,int start, int cnt, float ofs_x, float ofs_y)
{
	double[XY]	tpos1;
	double[XY]	tpos2;
	int			eid;

	tpos1[X] = poly_tbl[start*2+0] + ofs_x;
	tpos1[Y] = poly_tbl[start*2+1] + ofs_y;
	for(int i = 1; i < cnt; i++){
		eid = setTSK(GROUP_01,&TSKBrokenLine);
		TskBuf[eid].px = TskBuf[id].px + ofs_x;
		TskBuf[eid].py = TskBuf[id].py + ofs_y;
		TskBuf[eid].pz = TskBuf[id].pz;
		TskBuf[eid].rot = TskBuf[id].rot;
		TskBuf[eid].body_list.length = 2;
		TskBuf[eid].body_ang.length  = 2;

		TskBuf[eid].body_ang[0][X] = atan2(tpos1[X], tpos1[Y]);
		TskBuf[eid].body_ang[0][Y] = atan2(tpos1[X], tpos1[Y]);
		TskBuf[eid].body_ang[0][Z] = 0.0f;
		tpos2[X] = fabs(tpos1[X]);
		tpos2[Y] = fabs(tpos1[Y]);
		TskBuf[eid].body_ang[0][W] = sqrt(pow(tpos2[X],2.0) + pow(tpos2[Y],2.0));

		tpos2[X] = poly_tbl[(start+i)*2+0] + ofs_x;
		tpos2[Y] = poly_tbl[(start+i)*2+1] + ofs_y;
		TskBuf[eid].body_ang[1][X] = atan2(tpos2[X], tpos2[Y]);
		TskBuf[eid].body_ang[1][Y] = atan2(tpos2[X], tpos2[Y]);
		TskBuf[eid].body_ang[1][Z] = 0.0f;

		tpos1[X] = tpos2[X];
		tpos1[Y] = tpos2[Y];

		tpos2[X] = fabs(tpos2[X]);
		tpos2[Y] = fabs(tpos2[Y]);
		TskBuf[eid].body_ang[1][W] = sqrt(pow(tpos2[X],2.0) + pow(tpos2[Y],2.0));
	}

	eid = setTSK(GROUP_01,&TSKBrokenLine);
	TskBuf[eid].px = TskBuf[id].px + ofs_x;
	TskBuf[eid].py = TskBuf[id].py + ofs_y;
	TskBuf[eid].pz = TskBuf[id].pz;
	TskBuf[eid].rot = TskBuf[id].rot;
	TskBuf[eid].body_list.length = 2;
	TskBuf[eid].body_ang.length  = 2;

	TskBuf[eid].body_ang[0][X] = atan2(tpos1[X], tpos1[Y]);
	TskBuf[eid].body_ang[0][Y] = atan2(tpos1[X], tpos1[Y]);
	TskBuf[eid].body_ang[0][Z] = 0.0f;
	tpos2[X] = fabs(tpos1[X]);
	tpos2[Y] = fabs(tpos1[Y]);
	TskBuf[eid].body_ang[0][W] = sqrt(pow(tpos2[X],2.0) + pow(tpos2[Y],2.0));

	tpos2[X] = poly_tbl[start*2+0] + ofs_x;
	tpos2[Y] = poly_tbl[start*2+1] + ofs_y;
	TskBuf[eid].body_ang[1][X] = atan2(tpos2[X], tpos2[Y]);
	TskBuf[eid].body_ang[1][Y] = atan2(tpos2[X], tpos2[Y]);
	TskBuf[eid].body_ang[1][Z] = 0.0f;

	tpos2[X] = fabs(tpos2[X]);
	tpos2[Y] = fabs(tpos2[Y]);
	TskBuf[eid].body_ang[1][W] = sqrt(pow(tpos2[X],2.0) + pow(tpos2[Y],2.0));

	return;
}


void	TSKBrokenLine(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKBrokenLineDraw;
			TskBuf[id].fp_exit = &TSKBrokenLineExit;
			TskBuf[id].alpha = 1.0f;
			TskBuf[id].tx = (Rand() % 256000) / 1000.0f - 128.0f;
			TskBuf[id].ty = (Rand() % 256000) / 1000.0f - 128.0f;
			TskBuf[id].tx *= 2.0f;
			TskBuf[id].ty *= 2.0f;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].rot_add = (Rand() % 30) - 15;
			if(!(TskBuf[id].rot_add - 15))		TskBuf[id].rot_add = -1;
			else if(!(TskBuf[id].rot_add + 15)) TskBuf[id].rot_add = +1;
			if(TskBuf[id].rot_add < 0) TskBuf[id].rot_add = PI / (TskBuf[id].rot_add - 15);
			else					   TskBuf[id].rot_add = PI / (TskBuf[id].rot_add + 15);
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 15.0f;
			TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 15.0f;
			TskBuf[id].rot += TskBuf[id].rot_add;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait) TskBuf[id].step = -1;
			TskBuf[id].alpha -= (1.0f / 60.0f);
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}


void	TSKBrokenLineDraw(int id)
{
	float[XYZ]	pos;

	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINES);
	for(int i = 0; i < TskBuf[id].body_list.length; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}


void	TSKBrokenLineExit(int id)
{
	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
}


void	TSKfadeAlpha(int id)
{
	switch(TskBuf[id].step){
		case	0:
			fade_id = id;
			TskBuf[id].px = +0.0f;
			TskBuf[id].py = +0.0f;
			TskBuf[id].fp_draw = &TSKfadeAlphaDraw;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		case	2:
			if(TskBuf[id].wait) TskBuf[id].vx = (TskBuf[id].tx - fade_a) / cast(float)TskBuf[id].wait;
			TskBuf[id].step++;
		case	3:
			if(TskBuf[id].wait){
				fade_a += TskBuf[id].vx;
				TskBuf[id].wait--;
			}else{
				fade_a = TskBuf[id].tx;
				TskBuf[id].step = 1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKfadeAlphaDraw(int id)
{
	float	z;

	if(fade_a == 0.0f) return;

	z = BASE_Z - cam_pos;

	/* フェード表示 */
	glBegin(GL_QUADS);
	glColor4f(fade_r,fade_g,fade_b,fade_a);
	glVertex3f(getPointX(TskBuf[id].px-(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px-(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px+(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px+(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py-(SCREEN_Y / 2), z),
			   0.0f);
	glEnd();
}


void	TSKfade(int id)
{
	switch(TskBuf[id].step){
		case	0:
			fade_id = id;
			TskBuf[id].px = +0.0f;
			TskBuf[id].py = +0.0f;
			TskBuf[id].fp_draw = &TSKfadeDraw;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		case	2:
			if(TskBuf[id].wait) TskBuf[id].vx = (TskBuf[id].tx - fade_a) / cast(float)TskBuf[id].wait;
			TskBuf[id].step++;
		case	3:
			if(TskBuf[id].wait){
				fade_a += TskBuf[id].vx;
				TskBuf[id].wait--;
			}else{
				fade_a = TskBuf[id].tx;
				TskBuf[id].step = 1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKfadeDraw(int id)
{
	float	z;

	if(fade_a == 0.0f) return;

	z = BASE_Z - cam_pos;

	/* フェード表示 */
    glBlendFunc(GL_SRC_ALPHA, GL_SRC_ALPHA);
	glBegin(GL_QUADS);
	glColor4f(fade_r,fade_g,fade_b,fade_a);
	glVertex3f(getPointX(TskBuf[id].px-(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px-(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px+(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px+(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py-(SCREEN_Y / 2), z),
			   0.0f);
	glEnd();
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
}


