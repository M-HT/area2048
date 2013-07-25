/*
	area2048 source 'GAME CTRL'

		'gctrl.d'

	2004/04/08 jumpei isshiki
*/

private	import	util_snd;
private	import	util_pad;
private	import	define;
private	import	task;
private	import	luminous;
private	import	main;
private	import	init;
private	import	bg;
private	import	system;
private	import	effect;
private	import	title;
private	import	stg;
private	import	ship;
private	import	enemy01;

enum{
	GSTEP_NONE = 0,
	GSTEP_TITLE,
	GSTEP_OPTION,
	GSTEP_GAME,
	GSTEP_DEMO,
	GSTEP_GAMEOVER,
	GSTEP_CLEAR,
	GSTEP_EXIT,

	GLEVEL_EASY = 0,
	GLEVEL_NORMAL,
	GLEVEL_HARD,
	GLEVEL_MAX,

	BOMB_ONE = 1200,
	BOMB_MAX = 4,
	BOMB_ADD_MAX = 4,
	BOMB_ADD_MIN = 2,
	BOMB_SUB = 20,

	BOMB_SCORE_ADD = 10,
	BOMB_SCORE_MAX = 1000,
	BOMB_REMAIN_ADD = 10,
	BOMB_REMAIN_MAX = ONE_MIN,
}

int game_level;
int	score;
int	left;
int	bomb;
int	bomb_lv;
int	bomb_bonus;
int	bomb_remain;
int	time_left;
int	time_clear;
int	time_total;
int	time_flag;
int	time_bonus;
int	opt_bonus;
int	g_step;

int	high_easy;
int	high_normal;
int	high_hard;

private	float rank;
private	float rank_max;
private	float rank_min;

void	TSKgctrl(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_NPAUSE;
			TskBuf[id].step++;
			break;
		case	1:
			setTSK(GROUP_01,&TSKbg00);
			setTSK(GROUP_01,&TSKdemoCtrl);
			setTSK(GROUP_01,&TSKluminous);
			setTSK(GROUP_07,&TSKfade);
			setTSK(GROUP_07,&TSKbgOutBg);
			setTSK(GROUP_08,&TSKbgFrame);
			setTSK(GROUP_08,&TSKtitle);
			g_step = GSTEP_TITLE;
			TskBuf[id].step++;
			break;
		case	2:
			if(g_step == GSTEP_GAME){
				TSKclrAll();
				TskBuf[id].wait = 60;
				TskBuf[id].step = 3;
			}
			if(g_step == GSTEP_DEMO){
				TSKclrAll();
				TskBuf[id].wait = 60;
				TskBuf[id].step = 6;
			}
			if(g_step == GSTEP_EXIT){
				TSKclrAll();
				TskBuf[id].wait = 60;
				TskBuf[id].step = -1;
			}
			break;
		/* game-main */
		case	3:
			if(TskBuf[id].wait) TskBuf[id].wait--;
			else				TskBuf[id].step++;
			break;
		case	4:
			bomb = BOMB_ONE;
			bomb_lv = bomb / BOMB_ONE;
			bomb_bonus = 0;
			bomb_remain = 0;
			score = 0;
			time_flag = 0;
			time_clear = 0;
			time_total = 0;
			bg_id = -1;
			fade_r = 1.0f;
			fade_g = 1.0f;
			fade_b = 1.0f;
			fade_a = 1.0f;
			switch(game_level){
				case	GLEVEL_EASY:
					time_left = ONE_MIN * 30;
					left = 3;
					initRank(0.0f, 0.5f);
					break;
				case	GLEVEL_NORMAL:
					time_left = ONE_MIN * 25;
					left = 2;
					initRank(0.0f, 1.0f);
					break;
				case	GLEVEL_HARD:
					time_left = ONE_MIN * 20;
					left = 2;
					initRank(0.5f, 1.0f);
					break;
				default:
					break;
			}
			setTSK(GROUP_01,&TSKluminous);
			setTSK(GROUP_01,&TSKstgCtrl);
			setTSK(GROUP_05,&TSKship);
			setTSK(GROUP_07,&TSKbarrier);
			setTSK(GROUP_07,&TSKfadeAlpha);
			setTSK(GROUP_07,&TSKbgOutBg);
			setTSK(GROUP_08,&TSKextend);
			setTSK(GROUP_08,&TSKsystem);
			setTSK(GROUP_08,&TSKradar);
			setTSK(GROUP_08,&TSKbgFrame);
			TskBuf[id].step++;
			break;
		case	5:
			if(pause == 0){
				if(time_flag && time_left) time_left--;
			}
			//if((pause == 1 && (pads & PAD_BUTTON4) && (trgs & PAD_BUTTON6)) || g_step == GSTEP_CLEAR){
			if(g_step == GSTEP_CLEAR){
				switch(game_level){
					case	GLEVEL_EASY:
						if(high_easy < score) high_easy = score;
						break;
					case	GLEVEL_NORMAL:
						if(high_normal < score) high_normal = score;
						break;
					case	GLEVEL_HARD:
						if(high_hard < score) high_hard = score;
						break;
					default:
						break;
				}
				configSAVE();
				stopSNDall();
				TSKclrAll();
				fade_r = 0.0f;
				fade_g = 0.0f;
				fade_b = 0.0f;
				fade_a = 0.0f;
				TskBuf[id].step = 1;
				pause_flag = 0;
				pause = 0;
				skip = 0;
			}
			break;
		/* demo-main */
		case	6:
			if(TskBuf[id].wait) TskBuf[id].wait--;
			else				TskBuf[id].step++;
			break;
		case	7:
			bomb = BOMB_ONE;
			bomb_lv = bomb / BOMB_ONE;
			bomb_bonus = 0;
			bomb_remain = 0;
			score = 0;
			time_flag = 0;
			time_clear = 0;
			time_total = 0;
			bg_id = -1;
			fade_r = 1.0f;
			fade_g = 1.0f;
			fade_b = 1.0f;
			fade_a = 1.0f;
			game_level = Rand() % GLEVEL_MAX;
			switch(game_level){
				case	GLEVEL_EASY:
					time_left = ONE_MIN * 30;
					left = 3;
					initRank(0.0f, 0.5f);
					break;
				case	GLEVEL_NORMAL:
					time_left = ONE_MIN * 25;
					left = 2;
					initRank(0.0f, 1.0f);
					break;
				case	GLEVEL_HARD:
					time_left = ONE_MIN * 20;
					left = 2;
					initRank(0.5f, 1.0f);
					break;
				default:
					break;
			}
			setTSK(GROUP_01,&TSKluminous);
			setTSK(GROUP_01,&TSKatrractCtrl);
			setTSK(GROUP_05,&TSKship);
			setTSK(GROUP_07,&TSKbarrier);
			setTSK(GROUP_07,&TSKfadeAlpha);
			setTSK(GROUP_07,&TSKbgOutBg);
			setTSK(GROUP_08,&TSKextend);
			setTSK(GROUP_08,&TSKsystem);
			setTSK(GROUP_08,&TSKradar);
			setTSK(GROUP_08,&TSKbgFrame);
			TskBuf[id].wait = 60 * 60;
			TskBuf[id].step++;
			break;
		case	8:
			if(pause == 0){
				if(time_flag && time_left) time_left--;
			}
			TskBuf[id].wait--;
			if(!TskBuf[id].wait || (pads & PAD_BUTTON1)){
				stopSNDall();
				TSKclrAll();
				fade_r = 0.0f;
				fade_g = 0.0f;
				fade_b = 0.0f;
				fade_a = 0.0f;
				TskBuf[id].step = 1;
				pause_flag = 0;
				pause = 0;
				skip = 0;
			}
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}

void	TSKclrAll()
{
	clrTSKgroup(GROUP_01);
	clrTSKgroup(GROUP_02);
	clrTSKgroup(GROUP_03);
	clrTSKgroup(GROUP_04);
	clrTSKgroup(GROUP_05);
	clrTSKgroup(GROUP_06);
	clrTSKgroup(GROUP_07);
	clrTSKgroup(GROUP_08);
}

void	initRank(float min, float max)
{
	rank_min = min;
	rank_max = max;
	setRank(0.0f);
}

float	getRank()
{
	return	rank;
}

void	addRank(float add)
{
	rank += add;
	if(rank > rank_max) rank = rank_max;
	if(rank < rank_min) rank = rank_min;
}

void	setRank(float val)
{
	rank = val;
	if(rank > rank_max) rank = rank_max;
	if(rank < rank_min) rank = rank_min;
}
