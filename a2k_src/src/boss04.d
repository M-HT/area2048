/*
	area2048 source 'BOSS-04'

		'boss04.d'

	2004/06/06 jumpei isshiki
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
								 +0.0f,+16.0f,
								+16.0f,+32.0f,
								+40.0f,+40.0f,
								+24.0f, +0.0f,
								+40.0f,-40.0f,
								+24.0f,-24.0f,
								+16.0f,-32.0f,
								 +0.0f,-16.0f,
								-16.0f,-32.0f,
								-24.0f,-24.0f,
								-40.0f,-40.0f,
								-24.0f, +0.0f,
								-40.0f,+40.0f,
								-16.0f,+32.0f,

							];

void	TSKboss04(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;
	int				eid;
	int				mov_bak;
	double[XY]		tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_BOSS;
			TskBuf[id].px = 0.0f;
			TskBuf[id].py = -640.0f;
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKboss04Draw;
			TskBuf[id].fp_exit = &TSKboss04Exit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].cx = 48.0f;
			TskBuf[id].cy = 48.0f;
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
			TskBuf[id].bullet_wait = 60;
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].alpha += 1.0f / 120.0f;
			if(boss_flag){
				TskBuf[id].fp_int = &TSKboss04Int;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].energy = 550;
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
			if(TskBuf[id].energy < 225){
				playSNDse(SND_SE_EEXP01);
				effSetBrokenLine(id, boss_poly,  0,14, +0.0f, +0.0f);
				effSetBrokenLine(id, boss_poly,  0,14, +0.0f, +0.0f);
				effSetBrokenLine(id, boss_poly,  0,14, +0.0f, +0.0f);
				effSetBrokenLine(id, boss_poly,  0,14, +0.0f, +0.0f);
				setQuake(30, 64.0f);
				cmd.vanish();
				TskBuf[id].wait = 60;
				TskBuf[id].step++;
			}
			if(TskBuf[id].bullet_wait){
				if(cmd.isEnd()) TskBuf[id].bullet_wait--;
			}else{
				TskBuf[id].bullet_wait = 60;
				if(TskBuf[id].bullet_cnt < 4) cmd.set(id, BULLET_BOSS0401);
				if(TskBuf[id].bullet_cnt > 3) cmd.set(id, BULLET_BOSS0402);
				TskBuf[id].bullet_cnt++;
				TskBuf[id].bullet_cnt %= 0x08;
			}
			if(!cmd.isEnd()) cmd.run();
			break;
		case	3:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].bullet_wait = 60;
				TskBuf[id].bullet_cnt = 0;
				TskBuf[id].step++;
			}
			break;
		case	4:
			if(TskBuf[id].bullet_wait){
				if(cmd.isEnd()) TskBuf[id].bullet_wait--;
			}else{
				TskBuf[id].bullet_wait = 60;
				if(TskBuf[id].bullet_cnt < 4) cmd.set(id, BULLET_BOSS0403);
				if(TskBuf[id].bullet_cnt > 3) cmd.set(id, BULLET_BOSS0404);
				TskBuf[id].bullet_cnt++;
				TskBuf[id].bullet_cnt %= 0x08;
			}
			if(!cmd.isEnd()) cmd.run();
			break;
		case	5:
			if(TskBuf[id].wait){
				TskBuf[id].alpha -= 1.0f / 180.0f;
				if(!(TskBuf[id].wait % 10)){
					playSNDse(SND_SE_EEXP01);
					effSetBrokenBody(id, boss_poly,  0,14,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0,14,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0,14,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0,14,+0.0f,+0.0f);
					effSetBrokenLine(id, boss_poly,  0,14,+0.0f,+0.0f);
				}
				if(!(TskBuf[id].wait % 30)) setQuake(30, 64.0f);
				TskBuf[id].wait--;
			}else{
				effSetBrokenBody(id, boss_poly,  0,14,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0,14,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0,14,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0,14,+0.0f,+0.0f);
				effSetBrokenLine(id, boss_poly,  0,14,+0.0f,+0.0f);
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


void	TSKboss04Int(int id)
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
		opt_bonus = 50000;
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


void	TSKboss04Draw(int id)
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


void	TSKboss04Exit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	if(cmd){
		delete cmd;
		TskBuf[id].bullet_command = null;
	}
}

