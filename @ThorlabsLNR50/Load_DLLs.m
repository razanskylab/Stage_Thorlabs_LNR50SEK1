function Load_DLLs(TLJ)
	fprintf('[Y-Stage] Adding .NET assemblies...');
	TLJ.DeviceManagerAssembly = NET.addAssembly([TLJ.DLL_PATH, TLJ.DEVICE_MANAGER_DLL]);
	TLJ.MotorAssembly       = NET.addAssembly([TLJ.DLL_PATH, TLJ.MOTOR_DLL]);
	done();
end
