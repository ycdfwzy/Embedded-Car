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

		// todo: choose a reset operation

		message_t pkt;
		insMsg* msg;
		msg = (insMsg*)(call INSPacket.getPayload(&pkt, sizeof(insMsg)));
		if (msg == NULL) {	// no message
			return;
		}

		// angle_first
		if (PortA == 0 && PortB != 0) {
			msg->angle_first = ANGLE_UP;
		} else
		if (PortA != 0 && PortB == 0) {
			msg->angle_first = ANGLE_DOWN;
		} else
		{
			msg->angle_first = ANGLE_NOP;
		}
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
            if (valX <= 0xA00 && valY >= 0x600) {
                msg->move = MOVE_PAUSE;
            } else
            if (valX + valY >= 0x1000) {
                msg->move = MOVE_BACK;
            } else
            {
                msg->move = MOVE_LEFT;
            }
        } else
        {
            if (valX >= 0x600 && valY <= 0xA00) {
                msg->move = MOVE_PAUSE;
            } else
            if (valX + valY >= 0x1000) {
                msg->move = MOVE_RIGHT;
            } else
            {
                msg->move = MOVE_FORWARD;
            }
        }

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
			if (!initialAngle){
				post initializeAngle();
			} else
			{
				post beforeSendMsg();
			}
		}
	}

	event void INSMsgSender.sendDone(message_t* msg, error_t error) {
		if (error == SUCCESS) {
			atomic busy = FALSE;
		}
	}

	event void INIMsgSender.sendDone(message_t* msg, error_t error) {
		if (error == SUCCESS) {
			atomic busy = FALSE;
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