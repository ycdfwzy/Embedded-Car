// Car Serial

interface CarSerial {
	command error_t Forward(uint16_t value);
	command error_t Back(uint16_t value);
	command error_t Left(uint16_t value);
	command error_t Right(uint16_t value);
	command error_t Pause();
	command error_t Angle(uint16_t value, uint8_t id);
	// command error_t Angle_Secon(uint16_t value);
	// command error_t Angle_Third(uint16_t value);
}