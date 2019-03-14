function Stop(TLJ)

	fprintf('[Y-Stage] Stopping device...');
	try
		TLJ.DeviceNet.StopImmediate();
		done();
	catch ex
		% Cannot initialise device
		short_warn('[Y-Stage] Unable to stop device!');
		rethrow(ex);
	end

end
