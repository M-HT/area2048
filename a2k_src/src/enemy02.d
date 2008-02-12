/*
	area2048 source 'ENEMY-02'

		'enemy02.d'

	2004/04/11 jumpei isshiki
*/

private	import	std.math;
private	import	std.random;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	util_pad;
private	import	util_snd;
private	import	bulletcommand;
private	import	define;
private	import	task;
private	import	gctrl;
private	import	effect;
private	import	stg;
private	import	bg;
private	import	ship;
private	import	enemy;

private	const float	ENEMY_AREAMAX = (1024.0f - 22.0f);
private	const float	MAX_SPEED = (12.0f);
private	const float	SPEED_RATE = (30.0f);

private	float[]	enemy_poly = [
								/* BODY */
								 -4.0f, +4.0f,
								 -4.0f, -4.0f,
								 +4.0f, -4.0f,
								 +4.0f, +4.0f,
								/* NODE-1 */
								 -9.0f, +1.0f,
								 -2.0f,+10.0f,
								 -1.0f,+10.0f,
								 -1.0f, +1.0f,
								/* NODE-2 */
								 +9.0f, +1.0f,
								 +2.0f,+10.0f,
								 +1.0f,+10.0f,
								 +1.0f, +1.0f,
								/* WING-1 */
								 -8.0f, -9.0f,
								 -5.0f, -1.0f,
								 -1.0f, -1.0f,
								 -1.0f, -4.0f,
								/* WING-2 */
								 +8.0f, -9.0f,
								 +5.0f, -1.0f,
								 +1.0f, -1.0f,
								 +1.0f, -4.0f,
							];

void	TSKenemy02(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;
	double[XY]		tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_ZAKO;
			TskBuf[id].px = (rand() % 1536) - 768.0f;
			TskBuf[id].py = (rand() % 1536) - 768.0f;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKenemy02Draw;
			TskBuf[id].fp_exit = &TSKenemy02Exit;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].vx = 0.0f;
			TskBuf[id].vy = 0.0f;
			TskBuf[id].cx = 16.0f;
			TskBuf[id].cy = 16.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].body_list.length = enemy_poly.length / 2;
			TskBuf[id].body_ang.length  = enemy_poly.length / 2;
			for(int i = 0; i < TskBuf[id].body_list.length; i++){
				tpos[X] = enemy_poly[i*2+0];
				tpos[Y] = enemy_poly[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].energy = 2;
			TskBuf[id].bullet_length = 128;
			TskBuf[id].mov_cnt = 0;
			TskBuf[id].wait = 120;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].wait--;
			TskBuf[id].alpha += 1.0f / 120.0f;
			if(!TskBuf[id].wait){
				TskBuf[id].fp_int = &TSKenemy02Int;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].step++;
			}
		case	2:
			/* 移動モード更新 */
			if(!TskBuf[id].mov_cnt){
				TskBuf[id].mov_mode = (rand() % 100) & 0x01;
				TskBuf[id].mov_cnt = (rand() % 60) + 60;
			}else{
				TskBuf[id].mov_cnt--;
			}
			/* 座標更新 */
			switch(TskBuf[id].mov_mode){
				case	0:
					if(TskBuf[id].px < ship_px){
						TskBuf[id].vx += 1.0f / SPEED_RATE * 2.0f;
						if(TskBuf[id].vx > +MAX_SPEED) TskBuf[id].vx = +MAX_SPEED;
					}else{
						TskBuf[id].vx -= 1.0f / SPEED_RATE * 2.0f;
						if(TskBuf[id].vx < -MAX_SPEED) TskBuf[id].vx = -MAX_SPEED;
					}
					TskBuf[id].vy = 0;
					break;
				case	1:
					if(TskBuf[id].py < ship_py){
						TskBuf[id].vy += 1.0f / SPEED_RATE * 2.0f;
						if(TskBuf[id].vy > +MAX_SPEED) TskBuf[id].vy = +MAX_SPEED;
					}else{
						TskBuf[id].vy -= 1.0f / SPEED_RATE * 2.0f;
						if(TskBuf[id].vy < -MAX_SPEED) TskBuf[id].vy = -MAX_SPEED;
					}
					TskBuf[id].vx = 0;
					break;
				default:
					break;
			}
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			if(TskBuf[id].px < -ENEMY_AREAMAX){
				TskBuf[id].px = -ENEMY_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
			}
			if(TskBuf[id].px > +ENEMY_AREAMAX){
				TskBuf[id].px = +ENEMY_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
			}
			if(TskBuf[id].py < -ENEMY_AREAMAX){
				TskBuf[id].py = -ENEMY_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
			}
			if(TskBuf[id].py > +ENEMY_AREAMAX){
				TskBuf[id].py = +ENEMY_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
			}
			TskBuf[id].rot = atan2(-TskBuf[id].vx, -TskBuf[id].vy);
			break;
		default:
			if(cmd){
				cmd.vanish();
				delete cmd;
				TskBuf[id].bullet_command = null;
			}
			clrTSK(id);
			break;

	}
	return;
}


void	TSKenemy02Int(int id)
{
	if(TskBuf[id].energy > 0){
		playSNDse(SND_SE_EDMG);
		TskBuf[id].energy -= TskBuf[TskBuf[id].trg_id].energy;
	}
	if(TskBuf[id].energy <= 0 && TskBuf[id].step != -1){
		shipLockOff(id);
		TSKenemyDest(id,20);
		effSetBrokenBody(id, enemy_poly,  0, 4,+0.0f,+0.0f);
		effSetBrokenBody(id, enemy_poly,  4, 4,+0.0f,+0.0f);
		effSetBrokenBody(id, enemy_poly,  8, 4,+0.0f,+0.0f);
		effSetBrokenBody(id, enemy_poly, 12, 4,+0.0f,+0.0f);
		effSetBrokenBody(id, enemy_poly, 16, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly,  0, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly,  4, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly,  8, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly, 12, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly, 16, 4,+0.0f,+0.0f);
	}else{
		effSetParticle01(id, 0.0f, 0.0f, 4);
	}

	return;
}


void	TSKenemy02Draw(int id)
{
	float[XYZ]	pos;

	/* BODY */
	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glBegin(GL_QUADS);
	for(int i = 0; i < 4; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < 4; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	/* NODE */
	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glBegin(GL_QUADS);
	for(int i = 4; i < 8; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 4; i < 8; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glBegin(GL_QUADS);
	for(int i = 8; i < 12; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 8; i < 12; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	/* WING */
	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glBegin(GL_QUADS);
	for(int i = 12; i < 16; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 12; i < 16; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glBegin(GL_QUADS);
	for(int i = 16; i < 20; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 16; i < 20; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}


void	TSKenemy02Exit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	if(TskBuf[id].bullet_command) delete TskBuf[id].bullet_command;
}
