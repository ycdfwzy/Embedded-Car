// network-communication configuration
#include "../configs.h"

module NetCom {
	uses interface Boot;
	uses interface Leds;
	uses interface AMPacket;
	uses interface Receive as INSMsgReceiver;
	uses interface Receive as INIMsgReceiver;
	uses interface Timer<TMilli> as Timer;
	uses interface SplitControl as AMControl;
	uses interface CarSerial;
}

implementation {
	bool busy = FALSE;
	uint16_t angle_status[3];
	uint16_t autotestcnt = 0;
	uint16_t cmd = 0;
	uint16_t reset = 0;

	void handle_angle_operation(uint16_t op, uint8_t id) {
		// call Leds.led2On();
		if (op == ANGLE_UP) {
			cmd = 5+id;
			angle_status[id] += ANGLE_DELTA;
			if (angle_status[id] > ANGLE_MAX)
				angle_status[id] = ANGLE_MAX;
			call CarSerial.Angle(angle_status[id], id);
		} else
		if (op == ANGLE_DOWN) {
			cmd = 5+id;
			angle_status[id] -= ANGLE_DELTA;
			if (angle_status[id] < ANGLE_MIN)
				angle_status[id] = ANGLE_MIN;
			call CarSerial.Angle(angle_status[id], id);
		}
	}

	event message_t* INSMsgReceiver.receive(message_t* msg,
											void* payload,
											uint8_t len) {
		insMsg* rcvMsg;
		if (busy || len != sizeof(insMsg))
			return msg;
		// call Leds.led1On();
		
		rcvMsg = (insMsg*)payload;
		atomic busy = TRUE;

		switch (rcvMsg->move){
			case MOVE_FORWARD:
				call CarSerial.Forward(LINE_DEFAULT);
				cmd = 1;
				break;
			case MOVE_BACK:
				call CarSerial.Back(LINE_DEFAULT);
				cmd = 2;
				break;
			case MOVE_RIGHT:
				call CarSerial.Right(TURN_DEFAULT);
				cmd = 3;
				break;
			case MOVE_LEFT:
				call CarSerial.Left(TURN_DEFAULT);
				cmd = 4;
				break;
			case MOVE_PAUSE:
				call CarSerial.Pause();
				cmd = 0;
				break;
			default:
				// call CarSerial.Pause();
				cmd = 0;
		}

		handle_angle_operation(rcvMsg->angle_first, 0);
		handle_angle_operation(rcvMsg->angle_secon, 1);
		handle_angle_operation(rcvMsg->angle_third, 2);

		atomic busy = FALSE;
		return msg;
	}

	event message_t* INIMsgReceiver.receive(message_t* msg,
											void* payload,
											uint8_t len) {
		angleMsg* rcvMsg;
		if (len != sizeof(angleMsg))
			return msg;

		rcvMsg = (angleMsg*)payload;
		atomic {
			angle_status[0] = rcvMsg->angle_first;
			angle_status[1] = rcvMsg->angle_secon;
			angle_status[2] = rcvMsg->angle_third;
		}
		reset = 1;
		// call CarSerial.Angle(angle_status[0], 0);
		// call CarSerial.Angle(angle_status[1], 1);
		// call CarSerial.Angle(angle_status[2], 2);

		return msg;
	}

	task void autotest() {
		switch (autotestcnt/20) {
			case 0:
				call CarSerial.Forward(LINE_DEFAULT);
				break;
			case 1:
				call CarSerial.Back(LINE_DEFAULT);
				break;
			case 2:
				call CarSerial.Left(LINE_DEFAULT);
				break;
			case 3:
				call CarSerial.Right(LINE_DEFAULT);
				break;
			case 4:
				call CarSerial.Pause();
				break;
			case 5:
				call CarSerial.Angle(ANGLE_MAX, 0);
				break;
			case 6:
				call CarSerial.Angle(ANGLE_MIN, 0);
				break;
			case 7:
				call CarSerial.Angle(ANGLE_MAX, 1);
				break;
			case 8:
				call CarSerial.Angle(ANGLE_MIN, 1);
				break;
			case 9:
				call CarSerial.Angle(ANGLE_MAX, 2);
				break;
			case 10:
				call CarSerial.Angle(ANGLE_MIN, 2);
				break;
			case 11:
				if (autotestcnt < 226) {
					call CarSerial.Angle(ANGLE_DEFAULT, 0);
				} else
				if (autotestcnt < 234) {
					call CarSerial.Angle(ANGLE_DEFAULT, 1);
				} else
				{
					call CarSerial.Angle(ANGLE_DEFAULT, 2);
				}
				break;
		}
		autotestcnt++;
	}

	event void Timer.fired() {
		if (autotestcnt < 240) {
			post autotest();
			return;
		}

		if (reset > 15) {
			reset = 0;
		} else
		if (reset > 0) {
			switch ((reset-1)/5) {
				case 0:
					call CarSerial.Angle(ANGLE_DEFAULT, 0);
					break;
				case 1:
					call CarSerial.Angle(ANGLE_DEFAULT, 1);
					break;
				case 2:
					call CarSerial.Angle(ANGLE_DEFAULT, 2);
					break;
			}
			reset++;
		}

		if (cmd & 1) {
			call Leds.led0On();
		} else
		{
			call Leds.led0Off();
		}
		if (cmd & 2) {
			call Leds.led1On();
		} else
		{
			call Leds.led1Off();
		}
		if (cmd & 4) {
			call Leds.led2On();
		} else
		{
			call Leds.led2Off();
		}
		// call Leds.led0On();
	}

	event void AMControl.startDone(error_t error) {
		if (error == SUCCESS) {
			call Timer.startPeriodic(LED_Periodic);
		} else
		{
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t error) {

	}

	event void Boot.booted() {
		call AMControl.start();
	}
}