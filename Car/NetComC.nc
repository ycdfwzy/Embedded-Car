// network-communication configuration
#include "../configs.h"
#include <Timer.h>

configuration NetComC {
}

implementation {
	components MainC, LedsC, ActiveMessageC;
	components new AMReceiverC(INSMsgID) as INSMsgReceiver;
	components new AMReceiverC(INIMsgID) as INIMsgReceiver;
	components new TimerMilliC() as Timer;
	components CarSerialC;
	components NetCom;

	NetCom.Boot -> MainC.Boot;
	NetCom.Leds -> LedsC.Leds;
	NetCom.Timer -> Timer;
	NetCom.AMControl -> ActiveMessageC.SplitControl;
    // NetCom.AMPacket -> ActiveMessageC.Packet;
    NetCom.INSMsgReceiver -> INSMsgReceiver.Receive;
    NetCom.INIMsgReceiver -> INIMsgReceiver.Receive;

    NetCom.CarSerial -> CarSerialC.CarSerial;
}