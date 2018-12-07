// network-component configuration
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

	NetCom.Boot -> MainC.Boot;
	BlinkToRadioC.Leds -> LedsC.Leds;
	NetCom.AMControl -> ActiveMessageC.SplitControl;
    NetCom.Packet -> ActiveMessageC.Packet;
    NetCom.INSMsgReceiver -> INSMsgReceiver.Receive;
    NetCom.INIMsgReceiver -> INIMsgReceiver.Receive;
    NetCom.Timer -> Timer;

    NetCom.CarSerial -> CarSerialC.CarSerial;
}