function Home(TLS)

	if TLS.DeviceNet.CanHome
		tic;
		TLS.VPrintF('[Y-Stage] Homing device...');
		try
			workDone = TLS.DeviceNet.InitializeWaitHandler(); % Initialise Waithandler for timeout
			TLS.DeviceNet.Home(workDone); % Move device to position via .NET interface
			TLS.DeviceNet.Wait(TLS.TIME_OUT_MOVE);              % Wait for move to finish
			TLS.Done();
		catch ex
			% Cannot initialise device
			short_warn('[Y-Stage] Unable to home device!');
			rethrow(ex);
		end
	else
		short_warn('[Y-Stage] Device can''t home!');
	end

end
