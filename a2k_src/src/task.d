/*
	D-System 'TASK CTRL'

		'task.d'

	2003/11/27 jumpei isshiki
*/

private	import	SDL;
private	import	util_sdl;
private	import	bulletml;
private	import	bulletcommand;
private	import	main;

struct TSK {
	/* システムメンバ */
	int		tskid;
	int		group;
	int		entry;
	int		next;
	int		prev;
	void	function(int) fp;
	void	function(int) fp_int;
	void	function(int) fp_draw;
	void	function(int) fp_exit;
	/* アプリ依存メンバ */
	int				step;
	int				wait;
	int				cnt;
	SDL_Surface*	image;
	int				parent;
	int				child;
	int				wrk1;
	int				wrk2;
	float			fwrk1;
	float			fwrk2;
	/* ゲーム依存メンバ */
	int				flag;
	int				energy;
	int				chr_id;
	int				trg_id;
	int				opt_id;
	int				mov_mode;
	int				mov_cnt;
	int				bullet_attack;
	int				bullet_wait;
	int				bullet_time;
	int				bullet_cnt;
	float			px;
	float			py;
	float			pz;
	float			vx;
	float			vy;
	float			ax;
	float			ay;
	float			nx;
	float			ny;
	float			tx;
	float			ty;
	float			sx;
	float			sy;
	float			cx;
	float			cy;
	float			cen_x;
	float			cen_y;
	float			rad_x;
	float			rad_y;
	float			ang_x;
	float			ang_y;
	float			rot;
	float			rot_add;
	float[XYZW][]	body_list;
	float[XYZW][]	line_list;
	float[XYZW][]	body_ang;
	float[XYZW][]	line_ang;
	float[XYZW][]	offset_ang;
	float			alpha;
	/* BulletMLメンバ */
	BulletCommand	bullet_command;
	BulletMLState*	bullet_state;
	int				tid;
	float			bullet_speed;
	float			bullet_velx;
	float			bullet_vely;
	float			bullet_accx;
	float			bullet_accy;
	float			bullet_direction;
	float			bullet_length;
	void	function(int) simple;
	void	function(int) active;
	float	function(int) target;
}

enum{
	TSK_MAX = 1500,

	GROUP_00 = 0,
	GROUP_01,
	GROUP_02,
	GROUP_03,
	GROUP_04,
	GROUP_05,
	GROUP_06,
	GROUP_07,
	GROUP_08,
	GROUP_MAX,

}

enum{
	TSKID_NONE   = 0x00000000,
	TSKID_EXIST  = 0x00000001,
	TSKID_NPAUSE = 0x00000002,

	TSKID_ZAKO   = 0x00100000,
	TSKID_BOSS   = 0x00200000,

	TSKID_MUTEKI = 0x10000000,
}

TSK[]	TskBuf;
int		TskEntry;
int[]	TskIndex;
int		TskCnt;

void	initTSK()
{
	/*
	//	ワークの確保
	*/
	TskBuf.length = TSK_MAX;
	TskIndex.length = GROUP_MAX;

	for(int i = 0; i < GROUP_MAX; i++){
		TskIndex[i] = -1;
	}

	TskEntry = 0;

	/*
	//	空きリストの作成
	*/
	{
		int	i;
		for(i = 0; i < TSK_MAX - 1; i++){
			TskBuf[i].tskid = TSKID_NONE;
			TskBuf[i].entry = i + 1;
			TskBuf[i].next = -1;
			TskBuf[i].prev = -1;
			TskBuf[i].fp = null;
			TskBuf[i].fp_int = null;
			TskBuf[i].fp_draw = null;
			TskBuf[i].fp_exit = null;
			TskBuf[i].image = null;
			TskBuf[i].bullet_command = null;
			TskBuf[i].bullet_state = null;
		}
		TskBuf[i].tskid = TSKID_NONE;
		TskBuf[i].entry = -1;
		TskBuf[i].next = -1;
		TskBuf[i].prev = -1;
		TskBuf[i].fp = null;
		TskBuf[i].fp_int = null;
		TskBuf[i].fp_draw = null;
		TskBuf[i].fp_exit = null;
		TskBuf[i].bullet_command = null;
		TskBuf[i].bullet_state = null;
		TskBuf[i].image = null;
	}

	return;
}


int		setTSK(int group,void function(int) func)
{
	int		id = TskEntry;

	if(id != -1){
		TskBuf[id].tskid = TSKID_EXIST;
		TskBuf[id].group = group;
		TskBuf[id].step = 0;
		TskBuf[id].fp = func;
		TskBuf[id].fp_int = null;
		TskBuf[id].fp_draw = null;
		TskBuf[id].fp_exit = null;
		TskBuf[id].image = null;
		TskBuf[id].bullet_command = null;
		TskBuf[id].bullet_state = null;
		if(TskIndex[group] != -1){
			int i = TskIndex[group];
			TskBuf[id].prev = i;
			TskBuf[i].next = id;
		}
		member_init(id);
		TskIndex[group] = id;
		TskEntry = TskBuf[id].entry;
	}

	return	id;
}


void	clrTSK(int id)
{
	if(id != -1){
		int	next,prev;
		int group = TskBuf[id].group;

		if(TskBuf[id].fp_exit) TskBuf[id].fp_exit(id);
		TskBuf[id].tskid = TSKID_NONE;
		TskBuf[id].group = 0;
		next = TskBuf[id].next;
		prev = TskBuf[id].prev;
		if(TskIndex[group] == id){
			TskIndex[group] = prev;
		}
		if(next != -1){
			TskBuf[next].prev = TskBuf[id].prev;
		}
		if(prev != -1){
			TskBuf[prev].next = TskBuf[id].next;
		}
		TskBuf[id].next = -1;
		TskBuf[id].prev = -1;
		TskBuf[id].entry = TskEntry;
		TskBuf[id].fp = null;
		TskBuf[id].fp_int = null;
		TskBuf[id].fp_draw = null;
		TskBuf[id].fp_exit = null;
		TskBuf[id].image = null;
		TskBuf[id].body_list.length = 0;
		TskBuf[id].body_ang.length  = 0;
		TskBuf[id].line_list.length = 0;
		TskBuf[id].line_ang.length  = 0;
		TskBuf[id].bullet_command = null;
		TskBuf[id].bullet_state = null;
		TskEntry = id;
	}

	return;
}


void	clrTSKall()
{
	int	prev;

	/*
	//	全消去
	*/
	for(int i = 0; i < GROUP_MAX; i++){
		for(int j = TskIndex[i]; j != -1; j = prev){
			prev = TskBuf[j].prev;
			if(TskBuf[j].tskid & TSKID_EXIST){
				clrTSK(j);
			}
		}
	}

	return;
}


void	clrTSKgroup(int group)
{
	int	prev;

	/*
	//	全消去
	*/
	for(int i = TskIndex[group]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0){
			clrTSK(i);
		}
	}

	return;
}


void	execTSK()
{
	int	prev;

	TskCnt = 0;

	/*
	//	実行
	*/
	for(int i = 0; i < GROUP_MAX; i++){
		for(int j = TskIndex[i]; j != -1; j = prev){
			prev = TskBuf[j].prev;
			if(TskBuf[j].tskid != 0 && TskBuf[j].fp){
				if(pause != 1){
					TskBuf[j].fp(j);
				}else if(skip || (TskBuf[j].tskid & TSKID_NPAUSE)){
					TskBuf[j].fp(j);
				}
				TskCnt++;
			}
		}
	}

	return;
}


void	drawTSK()
{
	int	prev;

	/*
	//	描画
	*/
	for(int i = 0; i < GROUP_MAX; i++){
		for(int j = TskIndex[i]; j != -1; j = prev){
			prev = TskBuf[j].prev;
			if(TskBuf[j].tskid != 0 && TskBuf[j].fp_draw){
				TskBuf[j].fp_draw(j);
			}
		}
	}

	return;
}


private void member_init(int id)
{
	TskBuf[id].px = 0.0f;
	TskBuf[id].py = 0.0f;
	TskBuf[id].pz = 0.0f;
	TskBuf[id].vx = 0.0f;
	TskBuf[id].vy = 0.0f;
	TskBuf[id].ax = 0.0f;
	TskBuf[id].ay = 0.0f;
	TskBuf[id].nx = 0.0f;
	TskBuf[id].ny = 0.0f;
	TskBuf[id].tx = 0.0f;
	TskBuf[id].ty = 0.0f;
	TskBuf[id].sx = 0.0f;
	TskBuf[id].sy = 0.0f;
	TskBuf[id].cx = 0.0f;
	TskBuf[id].cy = 0.0f;
	TskBuf[id].cen_x = 0.0f;
	TskBuf[id].cen_y = 0.0f;
	TskBuf[id].rad_x = 0.0f;
	TskBuf[id].rad_y = 0.0f;
	TskBuf[id].ang_x = 0.0f;
	TskBuf[id].ang_y = 0.0f;
	TskBuf[id].rot = 0.0f;
	TskBuf[id].rot_add = 0.0f;
	TskBuf[id].alpha = 0.0f;
	TskBuf[id].bullet_speed = 0.0f;
	TskBuf[id].bullet_velx = 0.0f;
	TskBuf[id].bullet_vely = 0.0f;
	TskBuf[id].bullet_accx = 0.0f;
	TskBuf[id].bullet_accy = 0.0f;
	TskBuf[id].bullet_direction = 0.0f;
	TskBuf[id].bullet_length = 0.0f;
}
