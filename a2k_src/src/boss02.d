/*
	area2048 source 'BOSS-02'

		'boss02.d'

	2004/04/16 jumpei isshiki
*/

private	import	std.math;
private	import	std.random;
private	import	std.string;
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

private	float[]	boss_poly = [
								/* BODY */
								-48.0f,+32.0f,
								 +0.0f,+48.0f,
								+48.0f,+32.0f,
								+16.0f,-32.0f,
								 +0.0f,-48.0f,
								-16.0f,-32.0f,
							];

private	float[]	option_poly = [
								/* BODY */
								-16.0f,+16.0f,
								 +0.0f,+32.0f,
								+16.0f,+16.0f,
								 +0.0f,-32.0f,
							];

private	int	option_cnt;

void	TSKboss02(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;
	int				eid;
	double[XY]		tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_BOSS;
			TskBuf[id].px = 0.0f;
			TskBuf[id].py = 0.0f;
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKboss02Draw;
			TskBuf[id].fp_exit = &TSKboss02Exit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].cx = 64.0f;
			TskBuf[id].cy = 64.0f;
			TskBuf[id].cen_x = +0.0f;
			TskBuf[id].cen_y = +0.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].body_list.length = boss_poly.length / 2;
			TskBuf[id].body_ang.length  = boss_poly.length / 2;
			for(int i = 0; i < TskBuf[id]. body_list.length; i++){
				tpos[X] = boss_poly[i*2+0];
				tpos[Y] = boss_poly[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			option_cnt = 0;
			eid = setTSK(GROUP_02, &TSKOption02);
			TskBuf[eid].parent = id;
			TskBuf[eid].tx = -48.0f * 3.0f;
			TskBuf[eid].ty = -16.0f * 3.0f;
			eid = setTSK(GROUP_02, &TSKOption02);
			TskBuf[eid].parent = id;
			TskBuf[eid].tx = +48.0f * 3.0f;
			TskBuf[eid].ty = -16.0f * 3.0f;
			TskBuf[id].bullet_wait = 60;
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].alpha += 1.0f / 120.0f;
			if(boss_flag){
				TskBuf[id].fp_int = &TSKboss02Int;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].energy = 500;
				eid = setTSK(GROUP_08, &TSKgauge);
				TskBuf[eid].parent = id;
				TskBuf[eid].vx = +384.0f;
				TskBuf[eid].vy = +12.0f;
				TskBuf[eid].tx = -(SCREEN_S / 2) + 8;
				TskBuf[eid].ty = +(SCREEN_S / 2) - 8 * 6;
				TskBuf[eid].cnt = TskBuf[id].energy;
				TskBuf[eid].mov_mode = 0;
				TskBuf[eid].mov_cnt = 0;
				TskBuf[id].step++;
			}
			TskBuf[id].px = +0.0f;
			TskBuf[id].py = -640.0f;
			TskBuf[id].rot = atan2(TskBuf[id].cen_x-TskBuf[id].px, TskBuf[id].cen_y-TskBuf[id].py);
			break;
		case	2:
			if(option_cnt <= 0){
				if(TskBuf[id].bullet_wait){
					if(cmd.isEnd()) TskBuf[id].bullet_wait--;
				}else{
					TskBuf[id].bullet_wait = 30;
					cmd.set(id, BULLET_BOSS0201);
				}
				if(!cmd.isEnd()) cmd.run();
			}
			break;
		case	7:
			if(TskBuf[id].wait){
				TskBuf[id].alpha -= 1.0f / 180.0f;
				if(!(TskBuf[id].wait % 10)){
					playSNDse(SND_SE_EEXP01);
					effSetBrokenBody(id, boss_poly,  0, 6,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0, 6,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0, 6,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0, 6,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0, 6,+0.0f,+0.0f);
				}
				if(!(TskBuf[id].wait % 30)) setQuake(30, 64.0f);
				TskBuf[id].wait--;
			}else{
				effSetBrokenBody(id, boss_poly,  0, 6,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0, 6,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0, 6,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0, 6,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0, 6,+0.0f,+0.0f);
				setQuake(30, 64.0f);
				addScore(300);
				addScoreBomb();
				playSNDse(SND_SE_EEXP02);
				enemy_cnt--;
				enemy_stg--;
				boss_flag = 0;
				TskBuf[id].step = -1;
			}
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


void	TSKboss02Int(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	if(TskBuf[id].energy > 0){
		addScore(10);
		playSNDse(SND_SE_EDMG);
		TskBuf[id].energy -= TskBuf[TskBuf[id].trg_id].energy;
	}
	if(TskBuf[id].energy <= 0){
		shipLockOff(id);
		boss_flag = 2;
		TskBuf[id].fp_int = null;
		TskBuf[id].tskid &= ~TSKID_BOSS;
		switch(option_cnt){
			case	0:
				opt_bonus = 50000;
				break;
			case	1:
				opt_bonus = 10000;
				break;
			default:
				opt_bonus = 0;
				break;
		}
		TskBuf[id].step = 7;
		TskBuf[id].wait = 180;
		if(cmd){
			cmd.vanish();
			destroy(cmd);
			TskBuf[id].bullet_command = null;
		}
	}else{
		effSetParticle02(id, 0.0f, 0.0f, 4);
	}

	return;
}


void	TSKboss02Draw(int id)
{
	float[XYZ]	pos;

	/* BODY */
	int	bodyNumVertices = cast(int)(TskBuf[id].body_list.length);
	GLfloat[]	bodyVertices;

	bodyVertices.length = bodyNumVertices*XYZ;

	foreach(i; 0..bodyNumVertices){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		bodyVertices[i*XYZ + X] = pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz);
		bodyVertices[i*XYZ + Y] = pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz);
		bodyVertices[i*XYZ + Z] = pos[Z];
	}

	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, bodyNumVertices);

	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
	glDrawArrays(GL_LINE_LOOP, 0, bodyNumVertices);

	glDisableClientState(GL_VERTEX_ARRAY);

	bodyVertices.length = 0;
}


void	TSKboss02Exit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	if(cmd){
		destroy(cmd);
		TskBuf[id].bullet_command = null;
	}
}


void	TSKOption02(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;
	int				eid;
	double[XY]		tpos;

	switch(TskBuf[id].step){
		case	0:
			option_cnt++;
			TskBuf[id].opt_id = option_cnt;
			TskBuf[id].tskid |= TSKID_BOSS;
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKOption02Draw;
			TskBuf[id].fp_exit = &TSKOption02Exit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].cx = 64.0f;
			TskBuf[id].cy = 64.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].body_list.length = option_poly.length / 2;
			TskBuf[id].body_ang.length  = option_poly.length / 2;
			for(int i = 0; i < TskBuf[id]. body_list.length; i++){
				tpos[X] = option_poly[i*2+0];
				tpos[Y] = option_poly[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].offset_ang.length = 1;
			tpos[X] = TskBuf[id].tx;
			tpos[Y] = TskBuf[id].ty;
			TskBuf[id].offset_ang[0][X] = atan2(tpos[X], tpos[Y]);
			TskBuf[id].offset_ang[0][Y] = atan2(tpos[X], tpos[Y]);
			tpos[X] = fabs(TskBuf[id].tx);
			tpos[Y] = fabs(TskBuf[id].ty);
			TskBuf[id].offset_ang[0][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			TskBuf[id].bullet_wait = 60 * (TskBuf[id].opt_id + 1);
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].alpha += 1.0f / 120.0f;
			if(boss_flag){
				TskBuf[id].fp_int = &TSKOption02Int;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].energy = 250;
				eid = setTSK(GROUP_08, &TSKgauge);
				TskBuf[eid].parent = id;
				TskBuf[eid].vx = +256.0f;
				TskBuf[eid].vy = +8.0f;
				TskBuf[eid].tx = -(SCREEN_S / 2) + 8;
				TskBuf[eid].ty = +(SCREEN_S / 2) - 8 * 7 - 12 * TskBuf[id].opt_id;
				TskBuf[eid].cnt = TskBuf[id].energy;
				TskBuf[id].step++;
			}
			TskBuf[id].px = TskBuf[TskBuf[id].parent].px + TskBuf[id].tx;
			TskBuf[id].py = TskBuf[TskBuf[id].parent].py + TskBuf[id].ty;
			break;
		case	2:
			if(TskBuf[TskBuf[id].parent].energy <= 0){
				for(int i = 0; i < 2; i++){
					effSetBrokenBody(id, option_poly,  0, 4,+0.0f,+0.0f);
					effSetBrokenLine(id, option_poly,  0, 4,+0.0f,+0.0f);
				}
				TskBuf[id].energy = 0;
				TskBuf[id].step = -1;
				break;
			}
			if(TskBuf[id].bullet_wait){
				if(cmd.isEnd()) TskBuf[id].bullet_wait--;
			}else{
				TskBuf[id].bullet_wait = 60;
				cmd.set(id, BULLET_BOSS0202);
			}
			if(!cmd.isEnd()) cmd.run();
			else			 TskBuf[id].rot += (atan2(TskBuf[ship_id].px-TskBuf[id].px, TskBuf[ship_id].py-TskBuf[id].py) - TskBuf[id].rot) / 4.0f;
			break;
		case	10:
			if(TskBuf[id].wait) TskBuf[id].wait--;
			else				TskBuf[id].step = -1;
			break;
		default:
			clrTSK(id);
			break;

	}
	return;
}


void	TSKOption02Int(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	if(TskBuf[id].energy > 0){
		addScore(10);
		playSNDse(SND_SE_EDMG);
		TskBuf[id].energy -= TskBuf[TskBuf[id].trg_id].energy;
	}
	if(TskBuf[id].energy <= 0){
		shipLockOff(id);
		addScore(150);
		addScoreBomb();
		TskBuf[id].fp_int = null;
		TskBuf[id].tskid &= ~TSKID_BOSS;
		playSNDse(SND_SE_EEXP01);
		TskBuf[id].step = 10;
		TskBuf[id].wait = 2;
		option_cnt--;
		setQuake(60, 32.0f);
		for(int i = 0; i < 2; i++){
			effSetBrokenBody(id, option_poly,  0, 4,+0.0f,+0.0f);
			effSetBrokenLine(id, option_poly,  0, 4,+0.0f,+0.0f);
		}
		if(cmd){
			cmd.vanish();
			destroy(cmd);
			TskBuf[id].bullet_command = null;
		}
	}else{
		effSetParticle02(id, 0.0f, 0.0f, 4);
	}

	return;
}


void	TSKOption02Draw(int id)
{
	float[XYZ]	pos;

	/* BODY */
	int	bodyNumVertices = cast(int)(TskBuf[id].body_list.length);
	GLfloat[]	bodyVertices;

	bodyVertices.length = bodyNumVertices*XYZ;

	foreach(i; 0..bodyNumVertices){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		bodyVertices[i*XYZ + X] = pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz);
		bodyVertices[i*XYZ + Y] = pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz);
		bodyVertices[i*XYZ + Z] = pos[Z];
	}

	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, bodyNumVertices);

	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
	glDrawArrays(GL_LINE_LOOP, 0, bodyNumVertices);

	glDisableClientState(GL_VERTEX_ARRAY);

	bodyVertices.length = 0;
}


void	TSKOption02Exit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	TskBuf[id].line_list.length = 0;
	TskBuf[id].line_ang.length  = 0;
	TskBuf[id].offset_ang.length  = 0;
	if(cmd){
		destroy(cmd);
		TskBuf[id].bullet_command = null;
	}
}
