// button Configuration

configuration ButtonC {
	provides interface Button;
}

implementation {
	components ButtonM;
	components HplMsp430GeneralIOC;

	Button = ButtonM;
	ButtonM.PortA -> HplMsp430GeneralIOC.Port60;
	ButtonM.PortB -> HplMsp430GeneralIOC.Port21;
	ButtonM.PortC -> HplMsp430GeneralIOC.Port61;
	ButtonM.PortD -> HplMsp430GeneralIOC.Port23;
	ButtonM.PortE -> HplMsp430GeneralIOC.Port62;
	ButtonM.PortF -> HplMsp430GeneralIOC.Port26;
}