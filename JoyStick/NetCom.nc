// network-communication configuration
#include <Timer.h>
#include "../configs.h"

module NetCom {
	uses interface Boot;
	uses interface Leds;
	uses interface AMPacket;
	uses interface Timer<TMilli> as Timer;
	uses interface SplitControl as AMControl;
	uses interface AMSend as INSMsgSender;
    uses interface AMSend as INIMsgSender;
    uses interface Packet as INSPacket;
    uses interface Packet as INIPacket;

    uses interface Button;
    uses interface Read<uint16_t> as ReadX;
	uses interface Read<uint16_t> as ReadY;
}

implementation {
	bool busy = FALSE;
	bool initialAngle = FALSE;
	// uint16_t autotestcnt = 0;
	uint8_t preMove = MOVE_NOP;
	
	uint16_t valX;
	uint16_t valY;
	uint16_t PortA;
	uint16_t PortB;
	uint16_t PortC;
	uint16_t PortD;
	uint16_t PortE;
	uint16_t PortF;


	task void initializeAngle() {
		message_t pkt;
		angleMsg* msg;
		do {
            msg = (angleMsg*)(call INIPacket.getPayload(&pkt, sizeof(angleMsg)));
        } while (msg == NULL);
        msg->angle_first = ANGLE_DEFAULT;
        msg->angle_secon = ANGLE_DEFAULT;
        msg->angle_third = ANGLE_DEFAULT;
        if (call INIMsgSender.send(AM_BROADCAST_ADDR, &pkt, sizeof(angleMsg)) == SUCCESS) {
            atomic busy = TRUE;
        }
	}

	void sendMsg() {

		message_t pkt;
		insMsg* msg;
		msg = (insMsg*)(call INSPacket.getPayload(&pkt, sizeof(insMsg)));
		if (msg == NULL) {	// no message
			return;
		}

		if (PortA == 0 && PortB == 0) { // reset
			post initializeAngle();
			return;
		}

		// angle_first
		if (PortA == 0 && PortB != 0) {
			msg->angle_first = ANGLE_UP;
			// msg->angle_third = ANGLE_UP;
		} else
		if (PortA != 0 && PortB == 0) {
			msg->angle_first = ANGLE_DOWN;
			// msg->angle_third = ANGLE_DOWN;
		} else
		{
			msg->angle_first = ANGLE_NOP;
			// msg->angle_third = ANGLE_NOP;
		}
		// msg->angle_first = ANGLE_NOP;
		// msg->angle_secon = ANGLE_NOP;
		// angle_secon
		if (PortC == 0 && PortD != 0) {
			msg->angle_secon = ANGLE_UP;
		} else
		if (PortC != 0 && PortD == 0) {
			msg->angle_secon = ANGLE_DOWN;
		} else
		{
			msg->angle_secon = ANGLE_NOP;
		}
		// angle_third
		if (PortE == 0 && PortF != 0) {
			msg->angle_third = ANGLE_UP;
		} else
		if (PortE != 0 && PortF == 0) {
			msg->angle_third = ANGLE_DOWN;
		} else
		{
			msg->angle_third = ANGLE_NOP;
		}
		// move
		if (valX > valY) {
            if (valX <= 0xB00 && valY >= 0x500) {
                msg->move = MOVE_PAUSE;
            } else
            if (valX + valY >= 0x1000) {
                msg->move = MOVE_RIGHT; // MOVE_BACK;
            } else
            {
                msg->move = MOVE_FORWARD; // MOVE_LEFT;
            }
        } else
        {
            if (valX >= 0x500 && valY <= 0xB00) {
                msg->move = MOVE_PAUSE;
            } else
            if (valX + valY >= 0x1000) {
                msg->move = MOVE_BACK; //MOVE_RIGHT;
            } else
            {
                msg->move = MOVE_LEFT; // MOVE_FORWARD;
            }
        }

        if (preMove == MOVE_PAUSE && msg->move == MOVE_PAUSE) {
        	msg->move = MOVE_NOP;
        } else
        {
        	preMove = msg->move;
        }

        // msg->angle_first = ANGLE_NOP;
        // msg->angle_secon = ANGLE_UP;
        // msg->angle_third = ANGLE_NOP;
        // msg->move = MOVE_NOP;

        if (call INSMsgSender.send(AM_BROADCAST_ADDR, &pkt, sizeof(insMsg)) == SUCCESS) {
            atomic busy = TRUE;
        }
	}

	task void beforeSendMsg() {
		call ReadX.read();
		call ReadY.read();
		call Button.pinvalueA();
		call Button.pinvalueB();
		call Button.pinvalueC();
		call Button.pinvalueD();
		call Button.pinvalueE();
		call Button.pinvalueF();
		sendMsg();
	}

	// task void autotest() {
	// 	message_t pkt;
	// 	insMsg* msg;
	// 	msg = (insMsg*)(call INSPacket.getPayload(&pkt, sizeof(insMsg)));
	// 	if (msg == NULL) {	// no message
	// 		return;
	// 	}

	// 	msg->move = MOVE_NOP;
	// 	msg->angle_first = ANGLE_NOP;
	// 	msg->angle_secon = ANGLE_NOP;
	// 	msg->angle_third = ANGLE_NOP;

	// 	switch (autotestcnt/5){
	// 		case 0:
	// 			msg->move = MOVE_FORWARD;
	// 			break;
	// 		case 1:
	// 			msg->move = MOVE_BACK;
	// 			break;
	// 		case 2:
	// 			msg->move = MOVE_LEFT;
	// 			break;
	// 		case 3:
	// 			msg->move = MOVE_RIGHT;
	// 			break;
	// 		case 4:
	// 			msg->move = MOVE_PAUSE;
	// 			break;
	// 		case 5:
	// 			msg->angle_first = ANGLE_UP;
	// 			break;
	// 		case 6:
	// 			msg->angle_first = ANGLE_DOWN;
	// 			break;
	// 		case 7:
	// 			msg->angle_secon = ANGLE_UP;
	// 			break;
	// 		case 8:
	// 			msg->angle_secon = ANGLE_DOWN;
	// 			break;
	// 		case 9:
	// 			msg->angle_third = ANGLE_UP;
	// 			break;
	// 		case 10:
	// 			msg->angle_third = ANGLE_DOWN;
	// 			break;
	// 	}

	// 	if (call INSMsgSender.send(AM_BROADCAST_ADDR, &pkt, sizeof(insMsg)) == SUCCESS) {
 //            atomic busy = TRUE;
 //        }
	// }

	event void ReadX.readDone(error_t error, uint16_t val) {
		if (error == SUCCESS) {
			valX = val;
		} else
		{
			call ReadX.read();
		}
	}

	event void ReadY.readDone(error_t error, uint16_t val) {
		if (error == SUCCESS) {
			valY = val;
		} else
		{
			call ReadY.read();
		}
	}

	event void Button.pinvalueADone(error_t error) {
		PortA = error;
	}
	event void Button.pinvalueBDone(error_t error) {
		PortB = error;
	}
	event void Button.pinvalueCDone(error_t error) {
		PortC = error;
	}
	event void Button.pinvalueDDone(error_t error) {
		PortD = error;
	}
	event void Button.pinvalueEDone(error_t error) {
		PortE = error;
	}
	event void Button.pinvalueFDone(error_t error) {
		PortF = error;
	}


	event void Timer.fired() {
		if (!busy) {
			// if (autotestcnt < 50) {
			// 	post autotest();
			// } else
			if (!initialAngle) {
				post initializeAngle();
			} else
			{
				post beforeSendMsg();
				// sendMsg();
			}
		}
		call Leds.led0On();
	}

	event void INSMsgSender.sendDone(message_t* msg, error_t error) {
		if (error == SUCCESS) {
			// if (autotestcnt < )
			atomic busy = FALSE;
		}
	}

	event void INIMsgSender.sendDone(message_t* msg, error_t error) {
		if (error == SUCCESS) {
			atomic busy = FALSE;
			initialAngle = TRUE;
		}
	}

	event void Button.startDone(error_t error) {

		if (error == SUCCESS) {
			call Timer.startPeriodic(LED_Periodic);
		} else
		{
			call Button.start();
		}
	}

	event void Button.stopDone(error_t error) {}

	event void AMControl.startDone(error_t error) {
		if (error == SUCCESS) {
			call Button.start();
		} else
		{
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t error) {}

	event void Boot.booted() {
		call AMControl.start();
	}
}