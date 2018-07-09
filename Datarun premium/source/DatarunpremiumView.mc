using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Activity as info; 

class DatarunpremiumApp extends Toybox.Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new DeviceView() ];  
    }
}

class DatarunpremiumView extends Ui.DataField {
	hidden var stats = Sys.getSystemStats();
	hidden var pwr = stats.battery;

	//!Get device info
	var mySettings = System.getDeviceSettings();
	hidden var ID1;
	hidden var ID2;
	hidden var WatchID = (mySettings.uniqueIdentifier != null) ? mySettings.uniqueIdentifier : 914;
	hidden var watchType = mySettings.partNumber;
	var screenWidth = mySettings.screenWidth;
	var screenShape = mySettings.screenShape;
	var screenHeight = mySettings.screenHeight;
	var isTouchScreen = mySettings.isTouchScreen;  //!boolean
	var numberisTouchScreen = 9;

	hidden var uShowlaps = false;
	hidden var uShowDemo = false;
	hidden var umyNumber = 0;
	hidden var mtest = 63869733;
	hidden var jTimertime = 0;
	hidden var uBlackBackground = false;
	
	hidden var fieldValue = [1, 2, 3, 4, 5, 6, 7, 8];
	hidden var fieldLabel = [1, 2, 3, 4, 5, 6, 7, 8];
	hidden var fieldFormat = [1, 2, 3, 4, 5, 6, 7, 8];
	hidden var mZone = [1, 2, 3, 4, 5, 6, 7, 8];	

    hidden var Averagespeedinmpersec 			= 0;
    hidden var mColour;
    hidden var mColourFont;
	hidden var mColourFont1;
    hidden var mColourLine;
    hidden var mColourBackGround;
   
    hidden var mLapTimerTime   = 0;
	hidden var mElapsedDistance				= 0;
    hidden var mTimerRunning                = false;	
    hidden var uHrZones                     = [ 93, 111, 130, 148, 167, 185 ];
    hidden var unitP                        = 1000.0;
    hidden var unitD                        = 1000.0;
    hidden var Pace1 								= 0;
    hidden var Pace2 								= 0;
    hidden var Pace3 								= 0;
	hidden var Pace4 								= 0;
    hidden var Pace5 								= 0;

    var aaltitude = 0;
    hidden var CurrentSpeedinmpersec			= 0;
    hidden var uRoundedPace                 = true;

    hidden var uBacklight                   = false;

    hidden var uUpperLeftMetric            = 0;    //! Timer is default
    hidden var uUpperRightMetric           = 4;    //! Distance is default
    hidden var uMiddleLeftMetric           = 45;    //! HR is default
    hidden var uMiddleMiddleMetric           = 8;    //! Pace is default    
    hidden var uMiddleRightMetric           = 50;    //! Cadence is default
    hidden var uBottomLeftMetric            = 10;    //! Power is default
    hidden var uBottomRightMetric           = 20;    //! Lap power is default
    hidden var uRequiredPower		 		= "000:999";
    hidden var uWarningFreq		 			= 5;
    hidden var uAlertbeep			 		= false;
	hidden var uNoAlerts 					= false;
	hidden var PowerWarning 				= 0;
    
    hidden var mStartStopPushed             = 0;    //! Timer value when the start/stop button was last pushed

    hidden var mPrevElapsedDistance         = 0;
    hidden var uRacedistance                = 42195;
    hidden var uRacetime					= "03:59:48";
	hidden var mRacetime  					= 0;

    hidden var mLaps                        = 1;
    hidden var mLastLapDistMarker           = 0;
    hidden var mLastLapTimeMarker           = 0;
    hidden var mLastLapStoppedTimeMarker    = 0;
    hidden var mLastLapStoppedDistMarker    = 0;
	hidden var mLastLapElapsedDistance      = 0;
    hidden var mLastLapTimerTime            = 0;
    hidden var mLapSpeed 					= 0;
    hidden var mLastLapSpeed 				= 0;
           
    hidden var uPowerZones                  = "184:Z1:227:Z2:255:Z3:284:Z4:326:Z5:369";
	hidden var metric = [1, 2, 3, 4, 5, 6, 7,8];
	

    function initialize() {
         DataField.initialize();

         uHrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());


         var mApp = Application.getApp();
         metric[1]    	= mApp.getProperty("pUpperLeftMetric");
         metric[2]   	= mApp.getProperty("pUpperRightMetric");
    	 metric[3]   	= mApp.getProperty("pMiddleLeftMetric");
    	 metric[4] 		= mApp.getProperty("pMiddleMiddleMetric");    
    	 metric[5]		= mApp.getProperty("pMiddleRightMetric");
         metric[6]   	= mApp.getProperty("pBottomLeftMetric");
         metric[7]  	= mApp.getProperty("pBottomRightMetric");
         uRoundedPace        = mApp.getProperty("pRoundedPace");
         uBacklight          = mApp.getProperty("pBacklight");
         umyNumber			 = mApp.getProperty("myNumber");
         uShowDemo			 = mApp.getProperty("pShowDemo");
         uBlackBackground    = mApp.getProperty("pBlackBackground");
         uRequiredPower		 = mApp.getProperty("pRequiredPower");
         uWarningFreq		 = mApp.getProperty("pWarningFreq");
         uAlertbeep			 = mApp.getProperty("pAlertbeep");
         uPowerZones		 = mApp.getProperty("pPowerZones");
         uRacedistance		 = mApp.getProperty("pRacedistance");
         uRacetime			 = mApp.getProperty("pRacetime");


        if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
            unitP = 1609.344;
        }

        if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
            unitD = 1609.344;
        }

        
    }

    //! Timer transitions from stopped to running state
    function onTimerStart() {
        startStopPushed();
        mTimerRunning = true;
    }


    //! Timer transitions from running to stopped state
    function onTimerStop() {
        startStopPushed();
        mTimerRunning = false;
    }


    //! Timer transitions from paused to running state (i.e. resume from Auto Pause is triggered)
    function onTimerResume() {
        mTimerRunning = true;
    }


    //! Timer transitions from running to paused state (i.e. Auto Pause is triggered)
    function onTimerPause() {
        mTimerRunning = false;
    }

    
    //! Start/stop button was pushed - emulated via timer start/stop
    function startStopPushed() {     
    	var info = Activity.getActivityInfo();   
        var doublePressTimeMs = null;
        if ( mStartStopPushed > 0  &&  info.elapsedTime > 0 ) {
            doublePressTimeMs = info.elapsedTime - mStartStopPushed;
        }
        if ( doublePressTimeMs != null  &&  doublePressTimeMs < 5000 ) {
            uNoAlerts = !uNoAlerts;
        }
        mStartStopPushed = (info.elapsedTime != null) ? info.elapsedTime : 0;
    }
    


    //!! this is called whenever the screen needs to be updated
    function onUpdate(dc) {

        //! Calculate lap (HR) time and convert timers from milliseconds to seconds
		var info = Activity.getActivityInfo();
        mLapTimerTime = jTimertime - mLastLapTimeMarker;

    	//! Check license (base, further check in CIQ1 and CIQ2)
    	if (isTouchScreen == false) {
        	numberisTouchScreen = 3;
    	} else {
    		numberisTouchScreen = 6;
    	}
		ID0 = watchType.substring(5, 9);
		ID0 = 511+ID0.toNumber();
		
        //! Calculate lap distance
        var mLapElapsedDistance = 0.0;
        if (info.elapsedDistance != null) {
            mLapElapsedDistance = info.elapsedDistance - mLastLapDistMarker;
        }
        
		//! Calculate lap speeds
        if (mLapTimerTime > 0 && mLapElapsedDistance > 0) {
            mLapSpeed = mLapElapsedDistance / mLapTimerTime;
        }
        if (mLastLapTimerTime > 0 && mLastLapElapsedDistance > 0) {
            mLastLapSpeed = mLastLapElapsedDistance / mLastLapTimerTime;
        }

		//! Calculate average speed
        var currentSpeedtest				= 0;
        if (info.currentSpeed != null) {
        	currentSpeedtest = info.currentSpeed; 
        }
        if (currentSpeedtest > 0) {
            	//! Calculate average pace
				if (info.currentSpeed != null) {
        		Pace5 								= Pace4;
        		Pace4 								= Pace3;
        		Pace3 								= Pace2;
        		Pace2 								= Pace1;
        		Pace1								= info.currentSpeed; 
        		} else {
					Pace5 								= Pace4;
    	    		Pace4 								= Pace3;
        			Pace3 								= Pace2;
        			Pace2 								= Pace1;
        			Pace1								= 0;
				}
				Averagespeedinmpersec= (uRoundedPace) ? unitP/(Math.round( (unitP/(Pace1+Pace2+Pace3+Pace4+Pace5)*5) / 5 ) * 5) : (Pace1+Pace2+Pace3+Pace4+Pace5)/5;
				CurrentSpeedinmpersec= (uRoundedPace) ? unitP/(Math.round( unitP/currentSpeedtest / 5 ) * 5) : currentSpeedtest;
			
		}



		//! Determine required finish time and calculate required pace 	

        var mRacehour = uRacetime.substring(0, 2);
        var mRacemin = uRacetime.substring(3, 5);
        var mRacesec = uRacetime.substring(6, 8);
        mRacehour = mRacehour.toNumber();
        mRacemin = mRacemin.toNumber();
        mRacesec = mRacesec.toNumber();
        mRacetime = mRacehour*3600 + mRacemin*60 + mRacesec;


		//!Fill field metrics
		var i = 0; 
	    for (i = 1; i < 8; ++i) {	    
        	if (metric[i] == 0) {
            	fieldValue[i] = (info.timerTime != null) ? info.timerTime / 1000 : 0;
            	fieldLabel[i] = "Timer";
            	fieldFormat[i] = "time";   
	        } else if (metric[i] == 1) {
    	        fieldValue[i] = mLapTimerTime;
        	    fieldLabel[i] = "Lap T";
            	fieldFormat[i] = "time";
			} else if (metric[i] == 2) {
    	        fieldValue[i] = mLastLapTimerTime;
        	    fieldLabel[i] = "L-1LapT";
            	fieldFormat[i] = "time";
			} else if (metric[i] == 3) {
        	    fieldValue[i] = (info.timerTime != null) ? info.timerTime / (mLaps * 1000) : 0;
            	fieldLabel[i] = "AvgLapT";
            	fieldFormat[i] = "time";
	        } else if (metric[i] == 4) {
    	        fieldValue[i] = (info.elapsedDistance != null) ? info.elapsedDistance / unitD : 0;
        	    fieldLabel[i] = "Distance";
            	fieldFormat[i] = "2decimal";   
	        } else if (metric[i] == 5) {
    	        fieldValue[i] = mLapElapsedDistance/unitD;
        	    fieldLabel[i] = "Lap D";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 6) {
    	        fieldValue[i] = mLastLapElapsedDistance/unitD;
        	    fieldLabel[i] = "L-1LapD";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 7) {
	            fieldValue[i] = (info.elapsedDistance != null) ? info.elapsedDistance / (mLaps * unitD) : 0;
    	        fieldLabel[i] = "AvgLapD";
        	    fieldFormat[i] = "2decimal";
	        } else if (metric[i] == 8) {
   	        	fieldValue[i] = CurrentSpeedinmpersec;
        	    fieldLabel[i] = "Pace";
            	fieldFormat[i] = "pace";   
	        } else if (metric[i] == 9) {
    	        fieldValue[i] = Averagespeedinmpersec; 
        	    fieldLabel[i] = "Pace 5s";
            	fieldFormat[i] = "pace";
	        } else if (metric[i] == 10) {
    	        fieldValue[i] = mLapSpeed;
        	    fieldLabel[i] = "L Pace";
            	fieldFormat[i] = "pace";
			} else if (metric[i] == 11) {
    	        fieldValue[i] = mLastLapSpeed;
        	    fieldLabel[i] = "LL Pace";
            	fieldFormat[i] = "pace";
			} else if (metric[i] == 12) {
	            fieldValue[i] = (info.averageSpeed != null) ? info.averageSpeed : 0;
    	        fieldLabel[i] = "AvgPace";
        	    fieldFormat[i] = "pace";
            } else if (metric[i] == 13) {
        		fieldLabel[i]  = "Req pace ";
        		fieldFormat[i] = "pace";
        		if (info.elapsedDistance != null and info.timerTime != null and mRacetime != info.timerTime/1000 and mRacetime > info.timerTime/1000) {
        			fieldValue[i] = (uRacedistance - info.elapsedDistance) / (mRacetime - info.timerTime/1000);
        		} 
        	} else if (metric[i] == 45) {
    	        fieldValue[i] = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
        	    fieldLabel[i] = "HR";
            	fieldFormat[i] = "0decimal";

			}
		//!einde invullen field metrics
		
	  }
    }
    

}
