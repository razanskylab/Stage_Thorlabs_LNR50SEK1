classdef ThorlabsLNR50 < handle

	properties (Constant, Hidden)

		% path to DLL files (edit as appropriate)
		DLL_PATH = 'C:\Program Files\Thorlabs\Kinesis\';

		% DLL files to be loaded
		DEVICE_MANAGER_DLL = 		'Thorlabs.MotionControl.DeviceManagerCLI.dll';
		MOTOR_DLL = 'Thorlabs.MotionControl.Benchtop.StepperMotorCLI.dll';
		% MOTOR_DLL = 'Thorlabs.MotionControl.IntegratedStepperMotorsCLI.dll';


  	POS_RANGE = [0 50]; % [mm]
		% 20 mm/s and mm/s² according to datasheet but software allows for more
		VEL_RANGE = [0 50]; % [mm/s]
  	ACC_RANGE = [0 50]; % [mm2/s]


		DEFAULT_VEL = 50;            % [mm/s] Default velocity
		DEFAULT_ACC = 20;            % [mm2/s] Default acceleration

  	POLLING_TIME = 250; % Default polling time
		TIME_OUT_SETTINGS = 7000;  % [ms] Default timeout time for settings change
		TIME_OUT_MOVE = 100000;    % [ms] Default time out time for motor move
		DEFAUL_SERIAL_NR = '40934140';

		DO_AUTO_CONNECT = true;
		DO_AUTO_HOME = true;
		SET_DEFAULT_VEL_ACC = true;
	end

	properties
		serialNr(1,:) char = '';

		pos(1,1) {mustBeNumeric};
		vel(1,1) {mustBeNumeric};
		acc(1,1) {mustBeNumeric};

		% Net Properties
		DeviceNet;
		DeviceManagerAssembly; % see Load_DLLs
		MotorAssembly; % see Load_DLLs
	end

	properties (Dependent = true)
		isConnected;
		needsHoming;
	end

	methods
		function TLS = ThorlabsLNR50(varargin)
			TLS.Load_DLLs;
			if (nargin == 1) && ischar(varargin{1})
				TLS.serialNr = varargin{1};
			else
				TLS.serialNr = TLS.DEFAUL_SERIAL_NR;
    	end

			if TLS.DO_AUTO_CONNECT && ~TLS.isConnected
				TLS.Connect();
			end
			% home if needed and desired...
			if TLS.DO_AUTO_HOME && TLS.isConnected && TLS.DeviceNet.NeedsHoming()
				TLS.Home();
			end
			if TLS.SET_DEFAULT_VEL_ACC && TLS.isConnected
				TLS.vel = TLS.DEFAULT_VEL;
				TLS.acc = TLS.DEFAULT_ACC;
			end
		end

		function delete(TLS)
			if TLS.isConnected
				TLS.Disconnect();
			end
		end

	end % < end constructur / destructor methodes

	% set/get methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
		%%===========================================================================
		% Moves to position and waits until target positon is reached
		function set.pos(TLS, pos)
			if pos > max(TLS.POS_RANGE) || pos < min(TLS.POS_RANGE)
				short_warn('Requested position out of range!');
			else
				try
        	workDone = TLS.DeviceNet.InitializeWaitHandler(); % Initialise Waithandler for timeout
        	TLS.DeviceNet.MoveTo(pos, workDone); % Move device to position via .NET interface
        	TLS.DeviceNet.Wait(TLS.TIME_OUT_MOVE);              % Wait for move to finish
					% end
				catch me % Cannot initialise device
      		short_warn(['Unable to Move device to ',num2str(pos)]);
					rethrow(me);
    		end
			end
		end

		% Get current device position
		function pos = get.pos(TLS)
				pos = System.Decimal.ToDouble(TLS.DeviceNet.Position);
		end

		%%===========================================================================
		% Sets target velocity of the stage
		function set.vel(TLS, vel)
			if vel > max(TLS.VEL_RANGE) || vel < min(TLS.VEL_RANGE)
				short_warn('Requested velocity out of range!');
			else
				velpars = TLS.DeviceNet.GetVelocityParams();
				velpars.MaxVelocity = vel;
				TLS.DeviceNet.SetVelocityParams(velpars);
			end
		end

    % Read velocity from stage controller
    function vel = get.vel(TLS)
      velpars = TLS.DeviceNet.GetVelocityParams();
      vel = System.Decimal.ToDouble(velpars.MaxVelocity);
    end

		%%===========================================================================
		% Sets target acceleration of the stage
		function set.acc(TLS, acc)
			if acc > max(TLS.ACC_RANGE) || acc < min(TLS.ACC_RANGE)
				short_warn('Requested velocity out of range!');
			else
				velpars = TLS.DeviceNet.GetVelocityParams();
				velpars.Acceleration = acc;
				TLS.DeviceNet.SetVelocityParams(velpars);
			end
		end

    % Read velocity from stage controller
    function acc = get.acc(TLS)
      velpars = TLS.DeviceNet.GetVelocityParams();
      acc = System.Decimal.ToDouble(velpars.Acceleration);
    end

		%%===========================================================================
    function isConnected = get.isConnected(TLS)
      if isobject(TLS.DeviceNet) && TLS.DeviceNet.IsConnected();
        isConnected = true;
      else
        isConnected = false;
      end
    end

		%%===========================================================================
    function needsHoming = get.needsHoming(TLS)
      if TLS.isConnected
        needsHoming = TLS.DeviceNet.NeedsHoming();
			else
				needsHoming = [];
			end
    end

	end % < end set/get methods

end % < end class
