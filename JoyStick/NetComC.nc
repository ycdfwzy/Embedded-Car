// network-communication configuration
#include <Timer.h>
#include "../configs.h"

configuration NetComC {
}

implementation {
	components MainC, LedsC, ActiveMessageC;
	components new TimerMilliC() as Timer;
	components new AMSenderC(INSMsgID) as insSender;
    components new AMSenderC(INIMsgID) as iniSender;
    components new HamamatsuS10871TsrC() as LightSensor;
	components ButtonC;
	components JoyStickC;
	components NetCom;

	NetCom.Boot -> MainC.Boot;
	NetCom.Leds -> LedsC.Leds;
	NetCom.Timer -> Timer;
	NetCom.Button -> ButtonC.Button;
	NetCom.ReadX -> JoyStickC.ReadX;
	NetCom.ReadY -> JoyStickC.ReadY;
	NetCom.INSMsgSender -> insSender;
	NetCom.INIMsgSender -> iniSender;
	NetCom.INSPacket -> insSender;
	NetCom.INIPacket -> iniSender;
	NetCom.AMControl -> ActiveMessageC.SplitControl;
	NetCom.LightSensor -> LightSensor;
}