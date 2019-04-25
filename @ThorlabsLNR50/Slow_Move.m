function Slow_Move(TLS,pos)
	SAFETY_MARGIN = 3; % add extra time to be on safe side
	% move to position at low speed
	% calculates estimated movement time and sets timeout function accordingly
	if pos > max(TLS.POS_RANGE) || pos < min(TLS.POS_RANGE)
		short_warn('Requested position out of range!');
	else
		try
			distance = abs(TLS.pos - pos);
			waitTime = TLS.vel/TLS.acc*2 + (distance-(TLS.vel.^2/TLS.acc))./TLS.vel; % get travel time in seconds (ignore acceleration)
			TLS.VPrintF('[Y-Stage] Slow-moving to %2.1f mm @ %2.1f mm/s in %2.1fs\n',...
				pos,TLS.vel,waitTime);
			waitTime = waitTime + SAFETY_MARGIN;
			workDone = TLS.DeviceNet.InitializeWaitHandler(); % Initialise Waithandler for timeout
			TLS.DeviceNet.MoveTo(pos, workDone); % Move device to position via .NET interface
			TLS.DeviceNet.Wait(waitTime*1000);  % Wait for move to finish, in ms
		catch me % Cannot initialise device
			short_warn(['Unable to Move device to ',num2str(pos)]);
			rethrow(me);
		end
	end

end
