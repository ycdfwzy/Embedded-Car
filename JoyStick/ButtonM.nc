// button module

module ButtonM {
	uses interface HplMsp430GeneralIO as PortA;
	uses interface HplMsp430GeneralIO as PortB;
	uses interface HplMsp430GeneralIO as PortC;
	uses interface HplMsp430GeneralIO as PortD;
	uses interface HplMsp430GeneralIO as PortE;
	uses interface HplMsp430GeneralIO as PortF;

	provides interface Button;
}

implementation {
	command void Button.start() {
		call PortA.clr();
		call PortB.clr();
		call PortC.clr();
		call PortD.clr();
		call PortE.clr();
		call PortF.clr();

		call PortA.makeInput();
		call PortB.makeInput();
		call PortC.makeInput();
		call PortD.makeInput();
		call PortE.makeInput();
		call PortF.makeInput();

		signal Button.startDone(SUCCESS);
	}

	default event void Button.pinvalueADone(error_t error){}
	default event void Button.pinvalueBDone(error_t error){}
	default event void Button.pinvalueCDone(error_t error){}
	default event void Button.pinvalueDDone(error_t error){}
	default event void Button.pinvalueEDone(error_t error){}
	default event void Button.pinvalueFDone(error_t error){}

	command void Button.pinvalueA() {
		signal Button.pinvalueADone(call PortA.get());
	}
	command void Button.pinvalueB() {
		signal Button.pinvalueBDone(call PortB.get());
	}
	command void Button.pinvalueC() {
		signal Button.pinvalueCDone(call PortC.get());
	}
	command void Button.pinvalueD() {
		signal Button.pinvalueDDone(call PortD.get());
	}
	command void Button.pinvalueE() {
		signal Button.pinvalueEDone(call PortE.get());
	}
	command void Button.pinvalueF() {
		signal Button.pinvalueFDone(call PortF.get());
	}
	
	command void Button.stop() {
		signal Button.stopDone(SUCCESS);
	}
}