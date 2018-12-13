// network-component
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
	uint16_t cmd = 0;

	void handle_angle_operation(uint16_t op, uint8_t id) {
		call Leds.led2On();
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
		call Leds.led1On();
		
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
		call CarSerial.Angle(angle_status[0], 0);
		call CarSerial.Angle(angle_status[1], 1);
		call CarSerial.Angle(angle_status[2], 2);

		return msg;
	}

	event void Timer.fired() {
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
		call Leds.led0On();
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