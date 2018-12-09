// define some constants and structures
#ifndef EMBEDDEDCAR_CONFIGS_H
#define EMBEDDEDCAR_CONFIGS_H

enum MoveConst {
	LINE_DEFAULT = 500,
	TURN_DEFAULT = 500
};

enum AngleConst {
	ANGLE_MIN = 1800,
	ANGLE_MAX = 5000,
	ANGLE_DELTA = 500,
	ANGLE_DEFAULT = 3000,
};

enum OPNumber {
	MOVE_FORWARD = 0,
	MOVE_BACK = 1,
	MOVE_LEFT = 2,
	MOVE_RIGHT = 3,
	MOVE_PAUSE = 4,

	ANGLE_NOP = 5,
	ANGLE_UP = 6,
	ANGLE_DOWN = 7
};

enum ReceiverID {
	INSMsgID = 10,
	INIMsgID = 20
};

enum TimerPeriodic {
	LED_Periodic = 50,
};

// instruct message
typedef nx_struct insMsg {
	nx_uint16_t move;
	nx_uint16_t angle_first;
	nx_uint16_t angle_secon;
	nx_uint16_t angle_third;
} insMsg;

// angle initail status message
typedef nx_struct angleMsg {
	nx_uint16_t angle_first;
	nx_uint16_t angle_secon;
	nx_uint16_t angle_third;
} angleMsg;

#endif