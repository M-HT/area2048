/*
	area2048 source 'BOSS-03'

		'boss03.d'

	2004/06/08 jumpei isshiki
*/

private	import	std.math;
private	import	main;
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
								 +0.0f,+32.0f,
								+16.0f,+40.0f,
								+40.0f,+24.0f,
								+16.0f, +8.0f,
								 +0.0f,-40.0f,
								-16.0f, +8.0f,
								-40.0f,+24.0f,
								-16.0f,+40.0f,
							];

private	float[]	option_poly = [
								/* BODY */
								 +0.0f,-16.0f,
								+16.0f, +0.0f,
								 +0.0f,+16.0f,
								-16.0f, +0.0f,
							];

private	int	option_cnt = 0;

void	TSKboss03(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;
	int				eid;
	int				mov_bak;
	double[XY]		tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_BOSS;
			TskBuf[id].px = 0.0f;
			TskBuf[id].py = 0.0f;
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKboss03Draw;
			TskBuf[id].fp_exit = &TSKboss03Exit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].cx = 32.0f;
			TskBuf[id].cy = 64.0f;
			TskBuf[id].cen_x = 0.0f;
			TskBuf[id].cen_y = -384.0f;
			TskBuf[id].rad_x = 512.0f;
			TskBuf[id].rad_y = 256.0f;
			TskBuf[id].ang_x = 0.0f;
			TskBuf[id].ang_y = 0.0f;
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
			eid = setTSK(GROUP_02, &TSKOption03);
			TskBuf[eid].parent = id;
			TskBuf[eid].tx = -48.0f * 3.0f;
			TskBuf[eid].ty = -48.0f * 3.0f;
			eid = setTSK(GROUP_02, &TSKOption03);
			TskBuf[eid].parent = id;
			TskBuf[eid].tx = +48.0f * 3.0f;
			TskBuf[eid].ty = -48.0f * 3.0f;
			eid = setTSK(GROUP_02, &TSKOption03);
			TskBuf[eid].parent = id;
			TskBuf[eid].tx = -48.0f * 3.0f;
			TskBuf[eid].ty = +48.0f * 3.0f;
			eid = setTSK(GROUP_02, &TSKOption03);
			TskBuf[eid].parent = id;
			TskBuf[eid].tx = +48.0f * 3.0f;
			TskBuf[eid].ty = +48.0f * 3.0f;
			TskBuf[id].bullet_wait = 60;
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].alpha += 1.0f / 120.0f;
			if(boss_flag){
				TskBuf[id].fp_int = &TSKboss03Int;
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
			break;
		case	2:
			if(option_cnt <= 0){
				if(TskBuf[id].bullet_wait){
					if(cmd.isEnd()) TskBuf[id].bullet_wait--;
				}else{
					TskBuf[id].bullet_wait = 30;
					cmd.set(id, BULLET_BOSS0302);
				}
				if(!cmd.isEnd()) cmd.run();
			}else{
				if(TskBuf[id].bullet_wait){
					if(cmd.isEnd()) TskBuf[id].bullet_wait--;
				}else{
					TskBuf[id].bullet_wait = 45;
					cmd.set(id, BULLET_BOSS0301);
				}
				if(!cmd.isEnd()) cmd.run();
			}
			break;
		case	5:
			if(TskBuf[id].wait){
				TskBuf[id].alpha -= 1.0f / 180.0f;
				if(!(TskBuf[id].wait % 10)){
					playSNDse(SND_SE_EEXP01);
					effSetBrokenBody(id, boss_poly,  0, 8,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0, 8,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0, 8,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0, 8,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0, 8,+0.0f,+0.0f);
				}
				if(!(TskBuf[id].wait % 30)) setQuake(30, 64.0f);
				TskBuf[id].wait--;
			}else{
				effSetBrokenBody(id, boss_poly,  0, 8,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0, 8,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0, 8,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0, 8,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0, 8,+0.0f,+0.0f);
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
				delete cmd;
				TskBuf[id].bullet_command = null;
			}
			clrTSK(id);
			break;

	}
	return;
}


void	TSKboss03Int(int id)
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
		TskBuf[id].step = 5;
		TskBuf[id].wait = 180;
		if(cmd){
			cmd.vanish();
			delete cmd;
			TskBuf[id].bullet_command = null;
		}
	}else{
		effSetParticle02(id, 0.0f, 0.0f, 4);
	}

	return;
}


void	TSKboss03Draw(int id)
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


void	TSKboss03Exit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	if(cmd){
		delete cmd;
		TskBuf[id].bullet_command = null;
	}
}


void	TSKOption03(int id)
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
			TskBuf[id].px = TskBuf[TskBuf[id].parent].px + TskBuf[id].tx;
			TskBuf[id].py = TskBuf[TskBuf[id].parent].py + TskBuf[id].ty;
			TskBuf[id].cx = 16.0f;
			TskBuf[id].cy = 16.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKOption03Draw;
			TskBuf[id].fp_exit = &TSKOption03Exit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].pz = 0.0f;
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
			TskBuf[id].bullet_wait = 60;
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].alpha += 1.0f / 120.0f;
			if(boss_flag){
				TskBuf[id].fp_int = &TSKOption03Int;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].energy = 150;
				eid = setTSK(GROUP_08, &TSKgauge);
				TskBuf[eid].parent = id;
				TskBuf[eid].cnt = TskBuf[id].energy;
				TskBuf[eid].vx = +256.0f;
				TskBuf[eid].vy = +8.0f;
				TskBuf[eid].tx = -(SCREEN_S / 2) + 8;
				TskBuf[eid].ty = +(SCREEN_S / 2) - 8 * 7 - 12 * TskBuf[id].opt_id;
				TskBuf[eid].cnt = TskBuf[id].energy;
				TskBuf[id].step++;
			}
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
				TskBuf[id].bullet_wait = 30;
				cmd.set(id, BULLET_BOSS0301);
			}
			if(!cmd.isEnd()) cmd.run();
			break;
			TskBuf[id].ang_x  = Rand() % 65536;
			TskBuf[id].ang_x *= PI / 65536.0f;
			TskBuf[id].ax =
			TskBuf[id].ay = sin(TskBuf[id].ang_x) * 5.0f / PI;
			TskBuf[id].vx = cos(TskBuf[id].ang_x) * 5.0f / PI_2;
			TskBuf[id].vy = cos(TskBuf[id].ang_x) * 5.0f / PI_2;
			if(fabs(TskBuf[id].ax) < 0.5f){
				TskBuf[id].ax = 0.5f;
				TskBuf[id].ay = 0.5f;
			}
			if(fabs(TskBuf[id].ax) > 1.5f){
				TskBuf[id].ax = 1.5f;
				TskBuf[id].ay = 1.5f;
			}
			if(fabs(TskBuf[id].vx) < 0.5f){
				TskBuf[id].vx = 0.5f;
				TskBuf[id].vy = 0.5f;
			}
			if(fabs(TskBuf[id].vx) > 1.5f){
				TskBuf[id].vx = 1.5f;
				TskBuf[id].vy = 1.5f;
			}
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


void	TSKOption03Int(int id)
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
			delete cmd;
			TskBuf[id].bullet_command = null;
		}
	}else{
		effSetParticle02(id, 0.0f, 0.0f, 4);
	}

	return;
}


void	TSKOption03Draw(int id)
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


void	TSKOption03Exit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	TskBuf[id].line_list.length = 0;
	TskBuf[id].line_ang.length  = 0;
	if(cmd){
		delete cmd;
		TskBuf[id].bullet_command = null;
	}
}
