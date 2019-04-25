function Stop(TLS)

	TLS.VPrintF('[Y-Stage] Stopping device...');
	try
		TLS.DeviceNet.StopImmediate();
		TLS.Done();
	catch ex
		% Cannot initialise device
		short_warn('[Y-Stage] Unable to stop device!');
		rethrow(ex);
	end

end
