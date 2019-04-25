function Load_DLLs(TLS)
    tic;
 	TLS.VPrintF('[Y-Stage] Adding .NET assemblies...');
	TLS.DeviceManagerAssembly = NET.addAssembly([TLS.DLL_PATH, TLS.DEVICE_MANAGER_DLL]);
	TLS.MotorAssembly       = NET.addAssembly([TLS.DLL_PATH, TLS.MOTOR_DLL]);
	TLS.Done();
end
