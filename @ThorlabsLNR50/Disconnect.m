function Disconnect(TLS)
	TLS.PrintF('[Y-Stage] Disconnecting device...');

  if TLS.isConnected
    try
			tic;
      TLS.DeviceNet.StopPolling();  % Stop polling device via .NET interface
      TLS.DeviceNet.Disconnect();   % Disconnect device via .NET interface
			TLS.Done();
		catch ex
	 		% Cannot initialise device
		  short_warn('[Y-Stage] Unable to disconnect device!');
			rethrow(ex);
		end
  else % Cannot disconnect because device not connected
    short_warn('Device already disconnected.');
  end
end
