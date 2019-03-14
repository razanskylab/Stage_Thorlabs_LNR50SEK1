function Home(TLJ)

	if TLJ.DeviceNet.CanHome
		fprintf('[Y-Stage] Homing device...');
		try
			workDone = TLJ.DeviceNet.InitializeWaitHandler(); % Initialise Waithandler for timeout
			TLJ.DeviceNet.Home(workDone); % Move device to position via .NET interface
			TLJ.DeviceNet.Wait(TLJ.TIME_OUT_MOVE);              % Wait for move to finish
			done();
		catch ex
			% Cannot initialise device
			short_warn('[Y-Stage] Unable to home device!');
			rethrow(ex);
		end
	else
		short_warn('[Y-Stage] Device can''t home!');
	end

end
