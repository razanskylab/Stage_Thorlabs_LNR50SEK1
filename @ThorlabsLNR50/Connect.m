function Connect(TLS)

	if TLS.isConnected
		short_warn('[Y-Stage] Already connected!');
		return;
	else
		Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.BuildDeviceList();  % Build device list
		serialNumbers = Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.GetDeviceList(); % Get device list
		serialNumbers = cell(ToArray(serialNumbers)); % Convert serial numbers to cell array
		if isempty(serialNumbers)
			short_warn('[Y-Stage] No Thorlabs stages found!');
			return;
		end

		% CONNECT TO LAB JACK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		try
			tic;
			deviceFound =  any(strcmp(serialNumbers,TLS.serialNr));

		  if deviceFound
				TLS.VPrintF('[Y-Stage] Device found...');
			else
				short_warn('[Y-Stage] Device not found!');
				return;
          end
		  TLS.DeviceNet = Thorlabs.MotionControl.Benchtop.StepperMotorCLI.BenchtopStepperMotor.CreateBenchtopStepperMotor(TLS.serialNr);

      TLS.VPrintF('connecting...');
		  % TLS.DeviceNet.ClearDeviceExceptions();
		  % Clears the the last device exceptions if any.
		  TLS.DeviceNet.ConnectDevice(TLS.serialNr);
		  TLS.DeviceNet.Connect(TLS.serialNr);
		    % Connects to the device with the supplied serial number.

			TLS.DeviceNet = TLS.DeviceNet.GetChannel(1);
			pause(0.1);

			TLS.VPrintF('initializing...');
		  if ~TLS.DeviceNet.IsSettingsInitialized() % Cannot initialise device
	      error('[Y-Stage] Unable to initialise device!');
		  end

	    TLS.DeviceNet.StartPolling(TLS.POLLING_TIME);   % Start polling via .NET interface
			pause(0.1);
			TLS.DeviceNet.EnableDevice();
			pause(0.1);
	    TLS.DeviceNet.LoadMotorConfiguration(TLS.serialNr);

      % Initializes the current motor configuration.  This will load the
      % settings appropriate for the motor as defined in the
      % DeviceConfiguration settings. This should only be called once. Calling
      % this function will ensure the configuration is setup correctly with
      % the correct device unit converter. This call will also upload the
      % current device settings for the device with only the specified
      % settings prior to returning as defined by the MotorConfiguration
      % settings

			TLS.Done();
		catch ex
	 		% Cannot initialise device
		  short_warn('[Y-Stage] Unable to initialise device!');
			rethrow(ex);
		end
end
