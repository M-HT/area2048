/*
	area2048 'Bulletml'

		'bulletcommand.d'

	2004/02/19 jumpei isshiki
*/

private	import	std.math;
private	import	std.string;
private	import	bulletml;
private	import	main;
private	import	task;
private	import	gctrl;
private	import	ship;

private	const float	ROTVAL = (180.0f / PI);
private	const float	VEL_SDM_SS_RATIO = 1.0f;
private	const float	VEL_SS_SDM_RATIO = 1.0f;

private const int SHOT_DIST = 20;

private	BulletMLParserTinyXML*[]	parser;

void	initBulletcommandParser(int bank)
{
	parser.length = bank;
	for(int i = 0; i < parser.length; i++){
		parser[i] = null;
	}
}

void	readBulletcommandParser(int bank, const char[] fname)
{
	parser[bank] = BulletMLParserTinyXML_new(std.string.toStringz(fname));
	if(parser[bank]) BulletMLParserTinyXML_parse(parser[bank]);
}

void	releaseBulletcommandParser()
{
	for(int i = 0; i < parser.length; i++){
		if(parser[i]) BulletMLParserTinyXML_delete(parser[i]);
		parser[i] = null;
	}
}

class BulletCommand {
	public:
		static	BulletCommand	now;
		int	id;

	private:
		void	setBulletmlRunner(int task_id, int bank){
			runner = BulletMLRunner_new_parser(parser[bank]);
			if(runner){
				registFunctions(runner);
				id = task_id;
			}
		}

		void	setBulletmlRunner(int task_id, BulletMLState* state){
			runner = BulletMLRunner_new_state(state);
			if(runner){
				registFunctions(runner);
				id = task_id;
			}
		}

		void	delBulletmlRunner(BulletMLRunner* runner){
			BulletMLRunner_delete(runner);
		}

		void	registFunctions(BulletMLRunner* runner){
			BulletMLRunner_set_getBulletDirection(runner, &getBulletDirection_);
			BulletMLRunner_set_getAimDirection(runner, &getAimDirection_);
			BulletMLRunner_set_getBulletSpeed(runner, &getBulletSpeed_);
			BulletMLRunner_set_getDefaultSpeed(runner, &getDefaultSpeed_);
			BulletMLRunner_set_getRank(runner, &getRank_);
			BulletMLRunner_set_createSimpleBullet(runner, &createSimpleBullet_);
			BulletMLRunner_set_createBullet(runner, &createBullet_);
			BulletMLRunner_set_getTurn(runner, &getTurn_);
			BulletMLRunner_set_doVanish(runner, &doVanish_);

			BulletMLRunner_set_doChangeDirection(runner, &doChangeDirection_);
			BulletMLRunner_set_doChangeSpeed(runner, &doChangeSpeed_);
			BulletMLRunner_set_doAccelX(runner, &doAccelX_);
			BulletMLRunner_set_doAccelY(runner, &doAccelY_);
			BulletMLRunner_set_getBulletSpeedX(runner, &getBulletSpeedX_);
			BulletMLRunner_set_getBulletSpeedY(runner, &getBulletSpeedY_);
			BulletMLRunner_set_getRand(runner, &getRand_);
		}

	public:
		~this(){
		}

		void	set(int task_id, int bank){
			setBulletmlRunner(task_id, bank);
		}

		void	set(int task_id, BulletMLState* state){
			setBulletmlRunner(task_id, state);
		}

		bool	isEnd(){
		    if(runner) return BulletMLRunner_isEnd(runner);
			else	   return true;
		}

		void	run(){
			now = this;
		    if(runner) BulletMLRunner_run(runner);
		}

		void	vanish(){
		    if(runner) delBulletmlRunner(runner);
			runner = null;
		}

	private:
		BulletMLRunner*	runner;
}

/*
//	BulletML Functions
*/

extern (C){

double	getBulletDirection_(BulletMLRunner* runner){
	//printf("getBulletDirection_(%d)\n",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].bullet_direction * ROTVAL;
}

double	getAimDirection_(BulletMLRunner* runner){
	//printf("getAimDirection_(%d)\n",BulletCommand.now.id);
	double	dir;
	dir = TskBuf[BulletCommand.now.id].target(BulletCommand.now.id);
	dir = dir * ROTVAL;
	return	dir;
}

double	getBulletSpeed_(BulletMLRunner* runner){
	//printf("getBulletSpeed_(%d)\n",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].bullet_speed * VEL_SS_SDM_RATIO;
}

double	getDefaultSpeed_(BulletMLRunner* runner){
	//printf("getDefaultSpeed_(%d)\n",BulletCommand.now.id);
	return	1.0;
}

double	getRank_(BulletMLRunner* runner){
	//printf("getRank_(%d)\n",BulletCommand.now.id);
	return	getRank();
}

void	createSimpleBullet_(BulletMLRunner* runner, double d, double s){
	//printf("createSimpleBullet_(%d)\n",BulletCommand.now.id);
	if(TskBuf[BulletCommand.now.id].simple){
		int	eid;
		if((TskBuf[BulletCommand.now.id].tskid & TSKID_BOSS+TSKID_ZAKO)) eid = setTSK(GROUP_06,TskBuf[BulletCommand.now.id].simple);
		else															 eid = setTSK(GROUP_04,TskBuf[BulletCommand.now.id].simple);
		if(eid != -1){
			TskBuf[eid].parent = BulletCommand.now.id;
			d = (d <= 180.0f ? d : -(360.0f - d));
			d = d / ROTVAL;
			TskBuf[eid].bullet_speed = s;
			TskBuf[eid].bullet_direction = d;
			TskBuf[eid].bullet_velx = (sin(d) * (-s * VEL_SDM_SS_RATIO));
			TskBuf[eid].bullet_vely = (cos(d) * (-s * VEL_SDM_SS_RATIO));
			TskBuf[eid].bullet_accx = TskBuf[BulletCommand.now.id].bullet_accx;
			TskBuf[eid].bullet_accy = TskBuf[BulletCommand.now.id].bullet_accy;
			TskBuf[eid].fp(eid);
		}
	}
}

void	createBullet_(BulletMLRunner* runner, BulletMLState *state, double d, double s){
	//printf("createBullet_(%d)\n",BulletCommand.now.id);
	if(TskBuf[BulletCommand.now.id].active){
		int	eid;
		if((TskBuf[BulletCommand.now.id].tskid & TSKID_BOSS+TSKID_ZAKO)) eid = setTSK(GROUP_06,TskBuf[BulletCommand.now.id].active);
		else															 eid = setTSK(GROUP_04,TskBuf[BulletCommand.now.id].active);
		if(eid != -1){
			TskBuf[eid].parent = BulletCommand.now.id;
			d = (d <= 180.0f ? d : -(360.0f - d));
			d = d / ROTVAL;
			TskBuf[eid].bullet_state = state;
			TskBuf[eid].bullet_speed = s;
			TskBuf[eid].bullet_direction = d;
			TskBuf[eid].bullet_velx = (sin(d) * (-s * VEL_SDM_SS_RATIO));
			TskBuf[eid].bullet_vely = (cos(d) * (-s * VEL_SDM_SS_RATIO));
			TskBuf[eid].bullet_accx = TskBuf[BulletCommand.now.id].bullet_accx;
			TskBuf[eid].bullet_accy = TskBuf[BulletCommand.now.id].bullet_accy;
			TskBuf[eid].fp(eid);
		}
	}
}

int		getTurn_(BulletMLRunner* runner){
	//printf("getTurn_(%d)\n",BulletCommand.now.id);
	return	turn;
}

void	doVanish_(BulletMLRunner* runner){
	//printf("doVanish_(%d)\n",BulletCommand.now.id);
}

void	doChangeDirection_(BulletMLRunner* runner, double d){
	//printf("doChangeDirection_(%d)\n",BulletCommand.now.id);
	d = (d <= 180.0f ? d : -(360.0f - d));
	d = d / ROTVAL;
	TskBuf[BulletCommand.now.id].bullet_direction = d;
}

void	doChangeSpeed_(BulletMLRunner* runner, double s){
	//printf("doChangeSpeed_(%d)\n",BulletCommand.now.id);
	TskBuf[BulletCommand.now.id].bullet_speed = s * VEL_SDM_SS_RATIO;
}

void	doAccelX_(BulletMLRunner* runner, double ax){
	//printf("doAccelX_(%d)\n",BulletCommand.now.id);
	TskBuf[BulletCommand.now.id].bullet_accx = ax * VEL_SDM_SS_RATIO;
}

void	doAccelY_(BulletMLRunner* runner, double ay){
	//printf("doAccelY_(%d)\n",BulletCommand.now.id);
	TskBuf[BulletCommand.now.id].bullet_accy = ay * VEL_SDM_SS_RATIO;
}

double	getBulletSpeedX_(BulletMLRunner* runner){
	//printf("getBulletSpeedX_(%d)\n",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].bullet_accx;
}

double	getBulletSpeedY_(BulletMLRunner* runner){
	//printf("getBulletSpeedY_(%d)\n",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].bullet_accy;
}

double	getRand_(BulletMLRunner* runner){
	double	rand_val;
	//printf("getRand_(%d)\n",BulletCommand.now.id);
	rand_val = Rand() % 10000;
	rand_val /= 10000;
	return	rand_val;
}

}

int	getBulletDistance(){
	int	dist;

	switch(bomb_lv){
		case	0:
		case	1:
			dist = 5;
			break;
		case	2:
			dist = 7;
			break;
		case	3:
			dist = 10;
			break;
		case	4:
			dist = 12;
			break;
		case	5:
			dist = 14;
			break;
		case	6:
			dist = 16;
			break;
		case	7:
			dist = 18;
			break;
		case	8:
			dist = 20;
			break;
		default:
			dist = 1;
			break;
	}

	return	dist;
}
