// Car Serial module
#include <msp430usart.h>

module CarSerialM {
	// uses interface Boot;
	provides interface CarSerial;
	uses interface HplMsp430Usart;
	uses interface Resource;
}

implementation {
	bool busy = FALSE;
	enum {
		header0 = 0x01,
		header1 = 0x02,
		footer0 = 0xFF,
		footer1 = 0xFF,
		footer2 = 0x00,
		lenMsg = 0x08
	};
	// const uint8_t header0 = 0x01;
	// const uint8_t header1 = 0x02;
	// const uint8_t footer0 = 0xFF;
	// const uint8_t footer1 = 0xFF;
	// const uint8_t footer2 = 0x00;
	// const uint8_t lenMsg = 0x08;
	uint8_t msg[lenMsg];

	msp430_uart_union_config_t config = {
        {	utxe:   1,
            urxe:   1,
            ubr:    UBR_1MHZ_115200,
            umctl:  UMCTL_1MHZ_115200,
            ssel:   0x02,
            pena:   0,
            pev:    0,
            spb:    0,
            clen:   1,
            listen: 0,
            mm:     0,
            ckpl:   0,
            urxse:  0,
            urxeie: 0,
            urxwie: 0,
            utxe:   1,
            urxe:   1
        }
    };

    // event void Boot.booted(){

    // }

    // send one byte message
    void sendMsgB(uint8_t index) {
    	while (!(call HplMsp430Usart.isTxEmpty()));
    	call HplMsp430Usart.tx(msg[index]);
    	while (!(call HplMsp430Usart.isTxEmpty()));
    }
    // send all message
    void sendMsg() {
    	uint8_t i;
    	for (i = 0; i < lenMsg; i = i+1)
    		sendMsgB(i);
    }

    event void Resource.granted() {
    	call HplMsp430Usart.setModeUart(&config);
    	call HplMsp430Usart.enableUart();
    	U0CTL &= (~SYNC);

    	sendMsg();
    	call Resource.release();
    	atomic busy = FALSE;

    }

    void setHeaderFooter() {
    	msg[0] = header0;
    	msg[1] = header1;
    	msg[5] = footer0;
    	msg[6] = footer1;
    	msg[7] = footer2;
    }

    error_t doSendMsg(uint8_t typeByte, uint8_t lowByte, uint8_t highByte) {
    	if (busy)
    		return EBUSY;

    	atomic busy = TRUE; 
    	setHeaderFooter();
    	// set type
    	msg[2] = typeByte;
    	// set data
    	msg[3] = highByte;
    	msg[4] = lowByte;

    	return call Resource.request();
    }

    command error_t CarSerial.Forward(uint16_t value) {
    	uint8_t lowByte = (value & 0xFF);
    	uint8_t highByte = (value >> 8);
    	return doSendMsg(0x02, lowByte, highByte);
    }

    command error_t CarSerial.Back(uint16_t value) {
    	uint8_t lowByte = (value & 0xFF);
    	uint8_t highByte = (value >> 8);
    	return doSendMsg(0x03, lowByte, highByte);
    }

    command error_t CarSerial.Left(uint16_t value) {
    	uint8_t lowByte = (value & 0xFF);
    	uint8_t highByte = (value >> 8);
    	return doSendMsg(0x04, lowByte, highByte);
    }

    command error_t CarSerial.Right(uint16_t value) {
    	uint8_t lowByte = (value & 0xFF);
    	uint8_t highByte = (value >> 8);
    	return doSendMsg(0x05, lowByte, highByte);
    }

    command error_t CarSerial.Pause() {
    	return doSendMsg(0x06, 0x00, 0x00);
    }

    command error_t CarSerial.Angle(uint16_t value, uint8_t id) {
    	uint8_t lowByte = (value & 0xFF);
    	uint8_t highByte = (value >> 8);
    	uint8_t ret = FAIL;
    	switch (id):
    		case 0:
    			ret = doSendMsg(0x01, lowByte, highByte);
    			break;
    		case 1:
    			ret = doSendMsg(0x07, lowByte, highByte)
    			break;
    		case 2:
    			ret = doSendMsg(0x08, lowByte, highByte)
    			break;
    	return ret;
    }

    // command error_t CarSerial.Angle_First(uint16_t value) {
    // 	uint8_t lowByte = (value & 0xFF);
    // 	uint8_t highByte = (value >> 8);
    // 	return doSendMsg(0x01, lowByte, highByte);
    // }

    // command error_t CarSerial.Angle_Secon(uint16_t value) {
    // 	uint8_t lowByte = (value & 0xFF);
    // 	uint8_t highByte = (value >> 8);
    // 	return doSendMsg(0x07, lowByte, highByte);
    // }

    // command error_t CarSerial.Angle_Third(uint16_t value) {
    // 	uint8_t lowByte = (value & 0xFF);
    // 	uint8_t highByte = (value >> 8);
    // 	return doSendMsg(0x08, lowByte, highByte);
    // }
}