/*
	D-System 'PAD UTILITY'

		'util_pad.d'

	2003/12/02 jumpei isshiki
*/

private	import	SDL;
private	import	std.conv;

enum{
	PAD_UP = 0x01,
	PAD_DOWN = 0x02,
	PAD_LEFT = 0x04,
	PAD_RIGHT = 0x08,
	PAD_BUTTON1 = 0x10,
	PAD_BUTTON2 = 0x20,
	PAD_BUTTON3 = 0x40,
	PAD_BUTTON4 = 0x80,
	PAD_BUTTON5 = 0x100,
	PAD_BUTTON6 = 0x200,
	PAD_BUTTON7 = 0x400,
	PAD_BUTTON8 = 0x800,

	PAD_DIR = PAD_UP | PAD_DOWN | PAD_LEFT | PAD_RIGHT,
	PAD_BUTTON = PAD_BUTTON1 | PAD_BUTTON2 | PAD_BUTTON3 | PAD_BUTTON4 | PAD_BUTTON5 | PAD_BUTTON6 | PAD_BUTTON7 | PAD_BUTTON8,
	PAD_ALL = PAD_DIR | PAD_BUTTON,

	JOYSTICK_AXIS = 16384,

	REP_MIN = 2,
	REP_MAX = 30,
}

int	pad_type;
int	pads;
int	trgs;
int	reps;

SDL_Joystick*	joys;
Uint8*			keys;

private	int	pads_old;
private	int	rep_cnt;

int		initPAD()
{
	if(SDL_InitSubSystem(SDL_INIT_JOYSTICK) < 0){
		return	0;
    }

	joys = null;
	version (PANDORA) {
		foreach (i; 0..SDL_NumJoysticks()) {
			if (to!string(SDL_JoystickName(i)) == "nub0") {
				joys = SDL_JoystickOpen(i);
			}
		}
	} else {
		if(SDL_NumJoysticks() > 0){
			joys = SDL_JoystickOpen(0);
		}
	}

	if (joys){
		SDL_JoystickEventState(SDL_ENABLE);
	}

	pad_type = 0;
	trgs = 0;
	reps = 0;

	rep_cnt = 0;

	return	1;
}


void	closePAD()
{
	if(SDL_JoystickOpened(0)){
		SDL_JoystickClose(joys);
	}

	return;
}


int		getPAD()
{
	int x = 0, y = 0;
	int pad = 0;

	keys = SDL_GetKeyState(null);

	/* 綷・*/
	if(joys){
		x = SDL_JoystickGetAxis(joys, 0);
		y = SDL_JoystickGetAxis(joys, 1);
	}
	if(pad_type == 0 || pad_type == 2 || pad_type == 3){
		if(keys[SDLK_RIGHT] == SDL_PRESSED || keys[SDLK_KP6] == SDL_PRESSED || x > JOYSTICK_AXIS){
			pad |= PAD_RIGHT;
		}
		if(keys[SDLK_LEFT] == SDL_PRESSED || keys[SDLK_KP4] == SDL_PRESSED || x < -JOYSTICK_AXIS){
			pad |= PAD_LEFT;
		}
		if(keys[SDLK_DOWN] == SDL_PRESSED || keys[SDLK_KP2] == SDL_PRESSED || y > JOYSTICK_AXIS){
			pad |= PAD_DOWN;
		}
		if(keys[SDLK_UP] == SDL_PRESSED || keys[SDLK_KP8] == SDL_PRESSED || y < -JOYSTICK_AXIS){
			pad |= PAD_UP;
		}
	}
	if(pad_type == 1){
		if(keys[SDLK_d] == SDL_PRESSED || keys[SDLK_KP6] == SDL_PRESSED || x > JOYSTICK_AXIS){
			pad |= PAD_RIGHT;
		}
		if(keys[SDLK_a] == SDL_PRESSED || keys[SDLK_KP4] == SDL_PRESSED || x < -JOYSTICK_AXIS){
			pad |= PAD_LEFT;
		}
		if(keys[SDLK_s] == SDL_PRESSED || keys[SDLK_KP2] == SDL_PRESSED || y > JOYSTICK_AXIS){
			pad |= PAD_DOWN;
		}
		if(keys[SDLK_w] == SDL_PRESSED || keys[SDLK_KP8] == SDL_PRESSED || y < -JOYSTICK_AXIS){
			pad |= PAD_UP;
		}
	}

	int	btn1 = 0, btn2 = 0, btn3 = 0, btn4 = 0, btn5 = 0, btn6 = 0, btn7 = 0, btn8 = 0;

	/* ボタン */
	if(joys){
		btn1 = SDL_JoystickGetButton(joys, 0);
		btn2 = SDL_JoystickGetButton(joys, 1);
		btn3 = SDL_JoystickGetButton(joys, 2);
		btn4 = SDL_JoystickGetButton(joys, 3);
		btn5 = SDL_JoystickGetButton(joys, 4);
		btn6 = SDL_JoystickGetButton(joys, 5);
		btn7 = SDL_JoystickGetButton(joys, 6);
		btn8 = SDL_JoystickGetButton(joys, 7);
	}
	if(pad_type == 0){
		version (PANDORA) {
			if(keys[SDLK_HOME] == SDL_PRESSED || keys[SDLK_PAGEUP] == SDL_PRESSED || btn1){
				pad |= PAD_BUTTON1;
			}
			if(keys[SDLK_PAGEDOWN] == SDL_PRESSED || keys[SDLK_END] == SDL_PRESSED || btn2){
				pad |= PAD_BUTTON2;
			}
		} else {
			if(keys[SDLK_z] == SDL_PRESSED || btn1){
				pad |= PAD_BUTTON1;
			}
			if(keys[SDLK_x] == SDL_PRESSED || btn2){
				pad |= PAD_BUTTON2;
			}
		}
	}
	if(pad_type == 1){
		if(keys[SDLK_BACKSLASH] == SDL_PRESSED || btn1){
			pad |= PAD_BUTTON1;
		}
		if(keys[SDLK_RSHIFT] == SDL_PRESSED || btn2){
			pad |= PAD_BUTTON2;
		}
	}
	if(pad_type == 2){
		if(keys[SDLK_LSHIFT] == SDL_PRESSED || btn1){
			pad |= PAD_BUTTON1;
		}
		if(keys[SDLK_LCTRL] == SDL_PRESSED || btn2){
			pad |= PAD_BUTTON2;
		}
	}
	if(pad_type == 3){
		if(keys[SDLK_SPACE] == SDL_PRESSED || btn1){
			pad |= PAD_BUTTON1;
		}
		if(keys[SDLK_LALT] == SDL_PRESSED || btn2){
			pad |= PAD_BUTTON2;
		}
	}
	if(keys[SDLK_p] == SDL_PRESSED || btn3){
		pad |= PAD_BUTTON3;
	}

	/* トリガ */
	pads_old = pads;
	pads = pad;
	trgs = pads & ~pads_old;

	/* リピート */
	reps = 0;
	if(pads){
		if(!trgs && !rep_cnt){
			reps = pads;
			rep_cnt = REP_MIN;
		}else if(!trgs && rep_cnt){
			rep_cnt--;
		}else if(trgs){
			rep_cnt = REP_MAX;
			reps = trgs;
		}
	}else{
		rep_cnt = 0;
	}

	return	pad;
}
