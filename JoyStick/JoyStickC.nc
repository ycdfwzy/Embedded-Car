// joystick configuration

#include <Msp430Adc12.h>

configuration JoyStickC {
	provides interface Read<uint16_t> as ReadX;
	provides interface Read<uint16_t> as ReadY;
}

implementation {
	components JoyStickM;
	components new AdcReadClientC() as JoyStickX;
    components new AdcReadClientC() as JoyStickY;

    ReadX = JoyStickX.Read;
    ReadY = JoyStickY.Read;
    JoyStickX.AdcConfigure -> JoyStickM.AdcConfigureX;
    JoyStickY.AdcConfigure -> JoyStickM.AdcConfigureY;
}