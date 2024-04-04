/*
	area2048 source 'ENEMY-06'

		'enemy06.d'

	2004/06/04 jumpei isshiki
*/

private	import	std.math;
private	import	main;
private	import	SDL;
version (USE_GLES) {
	private	import	opengles;
} else {
	private	import opengl;
}
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
private	const float	MAX_SPEED = (5.0f);
private	const float	SPEED_RATE = (30.0f);

private	float[]	enemy_poly = [
								/* BODY */
								 -4.0f, +4.0f,
								 -4.0f, -4.0f,
								 +4.0f, -4.0f,
								 +4.0f, +4.0f,

								/* WING1 */
								 -9.0f, -1.0f,
								 -7.0f, -7.0f,
								 -1.0f, -9.0f,
								 -1.0f, -1.0f,
								/* WING2 */
								 +1.0f, -1.0f,
								 +1.0f, -9.0f,
								 +7.0f, -7.0f,
								 +9.0f, -1.0f,
								/* WING3 */
								 -9.0f, +1.0f,
								 -7.0f, +7.0f,
								 -1.0f, +9.0f,
								 -1.0f, +1.0f,
								/* WING4 */
								 +1.0f, +1.0f,
								 +1.0f, +9.0f,
								 +7.0f, +7.0f,
								 +9.0f, +1.0f,
							];

void	TSKenemy06(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;
	double[XY]		tpos;
	int				idx,idy;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_ZAKO;
			TskBuf[id].px = (Rand() % 1536) - 768.0f;
			TskBuf[id].py = (Rand() % 1536) - 768.0f;
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKenemy06Draw;
			TskBuf[id].fp_exit = &TSKenemy06Exit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
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
			TskBuf[id].energy = 3;
			TskBuf[id].bullet_length = 128;
			TskBuf[id].wait = 120;
			TskBuf[id].mov_cnt =
			TskBuf[id].cnt = 180;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].wait--;
			TskBuf[id].alpha += 1.0f / 120.0f;
			if(!TskBuf[id].wait){
				cmd = new BulletCommand();
				TskBuf[id].bullet_command = cmd;
				TskBuf[id].bullet_wait = 0;
				TskBuf[id].fp_int = &TSKenemy06Int;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].step++;
			}
			goto case;
		case	2:
			/* 弾撃ち */
			if(cmd){
				if(TskBuf[id].bullet_wait){
					if(cmd.isEnd()) TskBuf[id].bullet_wait--;
				}else{
					TskBuf[id].bullet_wait = 180;
					cmd.set(id, BULLET_ZAKO06);
				}
				if(!cmd.isEnd()){
					if(getShipLength(TskBuf[id].px, TskBuf[id].py) > TskBuf[id].bullet_length){
						int flag = 0;
						switch(game_level){
							case	GLEVEL_EASY:
								if(getShipLength(TskBuf[id].px, TskBuf[id].py) < eshot_easy) flag = 1;
								break;
							case	GLEVEL_NORMAL:
								if(getShipLength(TskBuf[id].px, TskBuf[id].py) < eshot_normal) flag = 1;
								break;
							case	GLEVEL_HARD:
								flag = 1;
								break;
							default:
								flag = 1;
								break;
						}
						if(flag) cmd.run();
					}
				}
			}
			/* 座標更新 */
			TskBuf[id].vx = TskBuf[id].px;
			TskBuf[id].vy = TskBuf[id].py;
			if(TskBuf[id].cnt == TskBuf[id].mov_cnt){
				TskBuf[id].tx = (Rand() % 512) + 256.0f;
				TskBuf[id].ty = (Rand() % 512) + 256.0f;
				if(TskBuf[id].px < ship_px) TskBuf[id].tx = +TskBuf[id].tx;
				else						TskBuf[id].tx = -TskBuf[id].tx;
				if(TskBuf[id].py < ship_py) TskBuf[id].ty = +TskBuf[id].ty;
				else						TskBuf[id].ty = -TskBuf[id].ty;
				if((Rand() % 100) > 97) TskBuf[id].tx = -TskBuf[id].tx;
				if((Rand() % 100) > 97) TskBuf[id].ty = -TskBuf[id].ty;
				TskBuf[id].tx = TskBuf[id].px + TskBuf[id].tx;
				TskBuf[id].ty = TskBuf[id].py + TskBuf[id].ty;
				if(TskBuf[id].tx < -ENEMY_AREAMAX) TskBuf[id].tx = -ENEMY_AREAMAX + 1.0f;
				if(TskBuf[id].tx > +ENEMY_AREAMAX) TskBuf[id].tx = +ENEMY_AREAMAX - 1.0f;
				if(TskBuf[id].ty < -ENEMY_AREAMAX) TskBuf[id].ty = -ENEMY_AREAMAX + 1.0f;
				if(TskBuf[id].ty > +ENEMY_AREAMAX) TskBuf[id].ty = +ENEMY_AREAMAX - 1.0f;
				TskBuf[id].sx = TskBuf[id].px;
				TskBuf[id].sy = TskBuf[id].py;
				TskBuf[id].cnt = 0;
			}else{
				TskBuf[id].cnt++;
			}
			idx = TskBuf[id].cnt * TskBuf[id].cnt;
			idy = TskBuf[id].mov_cnt * TskBuf[id].mov_cnt;
			if(!idx) idx = 1;
			if(!idy) idy = 1;
			TskBuf[id].px = TskBuf[id].sx + (TskBuf[id].tx - TskBuf[id].sx) * idx / idy;
			TskBuf[id].py = TskBuf[id].sy + (TskBuf[id].ty - TskBuf[id].sy) * idx / idy;
			TskBuf[id].vx -= TskBuf[id].px;
			TskBuf[id].vy -= TskBuf[id].py;
			TskBuf[id].rot = atan2(-TskBuf[id].vx, -TskBuf[id].vy);
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


void	TSKenemy06Int(int id)
{
	if(TskBuf[id].energy > 0){
		playSNDse(SND_SE_EDMG);
		TskBuf[id].energy -= TskBuf[TskBuf[id].trg_id].energy;
	}
	if(TskBuf[id].energy <= 0 && TskBuf[id].step != -1){
		shipLockOff(id);
		TSKenemyDest(id,80);
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


void	TSKenemy06Draw(int id)
{
	float[XYZ]	pos;

	/* BODY */
	GLfloat[4*XYZ]	bodyVertices;

	glEnableClientState(GL_VERTEX_ARRAY);

	foreach(k; 0..5){
		int	bodyNumVertices = (k == 0)?4:4;
		int	startOffset = (k == 0)?0:(4+4*(k-1));

		foreach(j; 0..bodyNumVertices){
			int i = startOffset + j;
			pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Z] = TskBuf[id].body_ang[i][Z];
			bodyVertices[j*XYZ + X] = pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz);
			bodyVertices[j*XYZ + Y] = pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz);
			bodyVertices[j*XYZ + Z] = pos[Z];
		}

		glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
		glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
		glDrawArrays(GL_TRIANGLE_FAN, 0, bodyNumVertices);

		glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
		glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
		glDrawArrays(GL_LINE_LOOP, 0, bodyNumVertices);
	}

	glDisableClientState(GL_VERTEX_ARRAY);
}


void	TSKenemy06Exit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	if(cmd){
		destroy(cmd);
		TskBuf[id].bullet_command = null;
	}
}
