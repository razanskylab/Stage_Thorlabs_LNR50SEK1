using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Thorlabs.MotionControl.Benchtop.StepperMotorCLI;
using Thorlabs.MotionControl.DeviceManagerCLI;
using Thorlabs.MotionControl.GenericMotorCLI;
using Thorlabs.MotionControl.GenericMotorCLI.ControlParameters;
using Thorlabs.MotionControl.GenericMotorCLI.AdvancedMotor;
using Thorlabs.MotionControl.GenericMotorCLI.Settings;

namespace BSC_Console_net_managed
{
    class Program
    {
        static void Main(string[] args)
        {
            // get parameters from command line
            int argc = args.Count();
            if (argc < 1)
            {
                Console.WriteLine("Usage = BSC_Console_net_managed [serial_no] [position: optional (0 - 50)] [velocity: optional (0 - 5)]");
                Console.ReadKey();
                return;
            }

            // get the test motor position
            decimal position = 0m;
            if (argc > 1)
            {
                position = decimal.Parse(args[1]);
            }

            // get the test velocity
            decimal velocity = 0m;
            if (argc > 2)
            {
                velocity = decimal.Parse(args[2]);
            }

            // get the test BSC203 serial number
            string serialNo = args[0];

            try
            {
                // Tell the device manager to get the list of all devices connected to the computer
                DeviceManagerCLI.BuildDeviceList();
            }
            catch (Exception ex)
            {
                // an error occurred - see ex for details
                Console.WriteLine("Exception raised by BuildDeviceList {0}", ex);
                Console.ReadKey();
                return;
            }

            // get available Benchtop Stepper Motor and check our serial number is correct
            // NOTE use DevicePrefix70 or DevicePrefix40 as appropriate
            List<string> serialNumbers = DeviceManagerCLI.GetDeviceList(BenchtopStepperMotor.DevicePrefix70);
            if (!serialNumbers.Contains(serialNo))
            {
                // the requested serial number is not a BSC203 or is not connected
                Console.WriteLine("{0} is not a valid serial number", serialNo);
                Console.ReadKey();
                return;
            }

            // create the device
            BenchtopStepperMotor device = BenchtopStepperMotor.CreateBenchtopStepperMotor(serialNo);
            if (device == null)
            {
                // an error occured
                Console.WriteLine("{0} is not a BenchtopStepperMotor", serialNo);
                Console.ReadKey();
                return;
            }

            // open a connection to the device.
            try
            {
                Console.WriteLine("Opening device {0}", serialNo);
                device.Connect(serialNo);
            }
            catch (Exception)
            {
                // connection failed
                Console.WriteLine("Failed to open device {0}", serialNo);
                Console.ReadKey();
                return;
            }

            // get the correct channel
            StepperMotorChannel channel = device.GetChannel(1);
            if (channel == null)
            {
                // connection failed
                Console.WriteLine("Channel unavailable {0}", serialNo);
                Console.ReadKey();
                return;
            }

            // wait for the device settings to initialize
            if(!channel.IsSettingsInitialized())
            {
                try
                {
                    channel.WaitForSettingsInitialized(5000);
                }
                catch (Exception)
                {
                    Console.WriteLine("Settings failed to initialize");
                }
            }

            // start the device polling
            channel.StartPolling(250);
            // needs a delay so that the current enabled state can be obtained
            Thread.Sleep(500);
            // enable the channel otherwise any move is ignored
            channel.EnableDevice();
            // needs a delay to give time for the device to be enabled
            Thread.Sleep(500);

            // call LoadMotorConfiguration on the device to initialize the DeviceUnitConverter object required for real world unit parameters
            // use the channel.DeviceID "70xxxxxx-1" to get the channel 1 settings. This is different to the serial number
            MotorConfiguration motorSettings = channel.LoadMotorConfiguration(channel.DeviceID);
            ThorlabsBenchtopStepperMotorSettings currentDeviceSettings = channel.MotorDeviceSettings as ThorlabsBenchtopStepperMotorSettings;

            // display info about device
            DeviceInfo deviceInfo = channel.GetDeviceInfo();
            Console.WriteLine("Device {0} = {1}", deviceInfo.SerialNumber, deviceInfo.Name);

            Home_Method1(channel);
            // or
            //Home_Method2(channel);
            bool homed = channel.Status.IsHomed;

            // if a position is requested
            if (position != 0)
            {
                // update velocity if required using real world methods
                if (velocity != 0)
                {
                    VelocityParameters velPars = channel.GetVelocityParams();
                    velPars.MaxVelocity = velocity;
                    channel.SetVelocityParams(velPars);
                }

                Move_Method1(channel, position);
                // or
                // Move_Method2(channel, position);

                Decimal newPos = channel.Position;
                Console.WriteLine("Device Moved to {0}", newPos);
            }

            channel.StopPolling();
            device.Disconnect(true);

            Console.ReadKey();
        }

        public static void Home_Method1(IGenericAdvancedMotor device)
        {
            try
            {
                Console.WriteLine("Homing device");
                device.Home(60000);
            }
            catch (Exception)
            {
                Console.WriteLine("Failed to home device");
                Console.ReadKey();
                return;
            }
            Console.WriteLine("Device Homed");
        }

        public static void Move_Method1(IGenericAdvancedMotor device, decimal position)
        {
            try
            {
                Console.WriteLine("Moving Device to {0}", position);
                device.MoveTo(position, 60000);
            }
            catch (Exception)
            {
                Console.WriteLine("Failed to move to position");
                Console.ReadKey();
                return;
            }
            Console.WriteLine("Device Moved");
        }

        private static bool _taskComplete;
        private static ulong _taskID;

        public static void CommandCompleteFunction(ulong taskID)
        {
            if((_taskID > 0) && (_taskID == taskID))
            {
                _taskComplete = true;
            }
        }

        public static void Home_Method2(IGenericAdvancedMotor device)
        {
            Console.WriteLine("Homing device");
            _taskComplete = false;
            _taskID = device.Home(CommandCompleteFunction);
            while(!_taskComplete)
            {
                Thread.Sleep(500);
                StatusBase status = device.Status;
                Console.WriteLine("Device Homing {0}", status.Position);

                // will need some timeout functionality;
            }
            Console.WriteLine("Device Homed");
        }

        public static void Move_Method2(IGenericAdvancedMotor device, decimal position)
        {
            Console.WriteLine("Moving Device to {0}", position);
            _taskComplete = false;
            _taskID = device.MoveTo(position, CommandCompleteFunction);
            while (!_taskComplete)
            {
                Thread.Sleep(500);
                StatusBase status = device.Status;
                Console.WriteLine("Device Moving {0}", status.Position);

                // will need some timeout functionality;
            }
            Console.WriteLine("Device Moved");
        }
    }
}
