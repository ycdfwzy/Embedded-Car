// Car Serial configuration

configuration CarSerialC {
	provides interface CarSerial;
}

implementation {
	// components MainC;
	components CarSerialM;
	components HplMsp430Usart0C;
	components new Msp430Uart0C();

	CarSerial = CarSerialM.CarSerial;
	CarSerialM.Resource -> Msp430Uart0C.Resource;
	CarSerialM.HplMsp430Usart -> HplMsp430Usart0C.HplMsp430Usart;
	// CarSerialM.Boot -> MainC.Boot;
}