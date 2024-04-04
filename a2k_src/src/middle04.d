/*
	area2048 source 'MIDDLE-04'

		'middle04.d'

	2004/07/05 jumpei isshiki
*/

private	import	std.math;
private	import	std.random;
private	import	std.string;
private	import	bindbc.sdl;
private	import	opengl;
private	import	util_sdl;
private	import	util_pad;
private	import	util_snd;
private	import	util_ascii;
private	import	bulletcommand;
private	import	define;
private	import	task;
private	import	gctrl;
private	import	system;
private	import	effect;
private	import	stg;
private	import	bg;
private	import	ship;
private	import	enemy;

private	const float	ENEMY_AREAMAX = (1024.0f - 22.0f);
private	const float	MAX_SPEED = (8.0f);
private	const float	SPEED_RATE = (60.0f);

private	char[]	str_buf;

private	float[]	middle_poly = [
								/* BODY */
								-16.0f,+16.0f,
								-16.0f,-16.0f,
								+16.0f,-16.0f,
								+16.0f,+16.0f,

								 -8.0f, -8.0f,
								-32.0f, -8.0f,
								 -8.0f,-32.0f,

								 +8.0f, -8.0f,
								+32.0f, -8.0f,
								 +8.0f,-32.0f,

								 -8.0f, +8.0f,
								-32.0f, +8.0f,
								 -8.0f,+32.0f,

								 +8.0f, +8.0f,
								+32.0f, +8.0f,
								 +8.0f,+32.0f,
							];

void	TSKmiddle04(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;
	int				eid;
	double[XY]		tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_BOSS;
			switch(TskBuf[id].chr_id){
				case	0:
					TskBuf[id].px = +512.0f;
					TskBuf[id].py = -512.0f;
					break;
				case	1:
					TskBuf[id].px = -512.0f;
					TskBuf[id].py = -512.0f;
					break;
				case	2:
					TskBuf[id].px = +512.0f;
					TskBuf[id].py = +512.0f;
					break;
				case	3:
					TskBuf[id].px = -512.0f;
					TskBuf[id].py = +512.0f;
					break;
				default:
					TskBuf[id].px = 0.0f;
					TskBuf[id].py = 0.0f;
					break;
			}
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKmiddle04Draw;
			TskBuf[id].fp_exit = &TSKmiddle04Exit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].cx = 64.0f;
			TskBuf[id].cy = 64.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].energy = 150;
			TskBuf[id].body_list.length = middle_poly.length / 2;
			TskBuf[id].body_ang.length  = middle_poly.length / 2;
			for(int i = 0; i < TskBuf[id]. body_list.length; i++){
				tpos[X] = middle_poly[i*2+0];
				tpos[Y] = middle_poly[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].wait = 120;
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].alpha += 1.0f / 120.0f;
			if(!TskBuf[id].wait){
				TskBuf[id].fp_int = &TSKmiddle04Int;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].step++;
			}else{
				TskBuf[id].wait--;
			}
			break;
		case	2:
			if(TskBuf[id].bullet_wait){
				if(cmd.isEnd()) TskBuf[id].bullet_wait--;
			}else{
				TskBuf[id].bullet_wait = 30;
				cmd.set(id, BULLET_MIDDLE04);
			}
			if(!cmd.isEnd()){
				int flag = 0;
				switch(game_level){
					case	GLEVEL_EASY:
						if(getShipLength(TskBuf[id].px, TskBuf[id].py) < eshot_easy) flag = 1;
						break;
					case	GLEVEL_NORMAL:
						if(getShipLength(TskBuf[id].px, TskBuf[id].py) < eshot_normal) flag = 1;
						break;
					case	GLEVEL_HARD:
						if(getShipLength(TskBuf[id].px, TskBuf[id].py) < eshot_hard) flag = 1;
						break;
					default:
						flag = 1;
						break;
				}
				if(flag) cmd.run();
			}
			break;
		case	3:
			setQuake(60, 32.0f);
			effSetBrokenBody(id, middle_poly,  0, 4,+0.0f,+0.0f);
			for(int i = 0; i < 4; i++){
				effSetBrokenBody(id, middle_poly, (4 + i * 3), 3,+0.0f,+0.0f);
				effSetBrokenLine(id, middle_poly, (4 + i * 3), 3,+0.0f,+0.0f);
			}
			TskBuf[id].step = -1;
			break;
		default:
			if(cmd){
				cmd.vanish();
				destroy(cmd);
				TskBuf[id].bullet_command = null;
			}
			clrTSK(id);
			break;

	}
	return;
}


void	TSKmiddle04Int(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	if(TskBuf[id].energy > 0){
		playSNDse(SND_SE_EDMG);
		TskBuf[id].energy -= TskBuf[TskBuf[id].trg_id].energy;
	}
	if(TskBuf[id].energy <= 0){
		TskBuf[id].fp_int = null;
		if(cmd){
			cmd.vanish();
			destroy(cmd);
			TskBuf[id].bullet_command = null;
		}
		addScore(50);
		playSNDse(SND_SE_EEXP01);
		enemy_cnt--;
		enemy_stg--;
		TskBuf[id].step = 3;
	}else{
		effSetParticle02(id, 0.0f, 0.0f, 4);
	}

	return;
}


void	TSKmiddle04Draw(int id)
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

	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 4+3*0; i < 4+3*1; i++){
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
	for(int i = 4+3*0; i < 4+3*1; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();

	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 4+3*1; i < 4+3*2; i++){
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
	for(int i = 4+3*1; i < 4+3*2; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();

	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 4+3*2; i < 4+3*3; i++){
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
	for(int i = 4+3*2; i < 4+3*3; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();

	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 4+3*3; i < 4+3*4; i++){
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
	for(int i = 4+3*3; i < 4+3*4; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}


void	TSKmiddle04Exit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	TskBuf[id].line_list.length = 0;
	TskBuf[id].line_ang.length  = 0;
	if(cmd){
		destroy(cmd);
		TskBuf[id].bullet_command = null;
	}
}
