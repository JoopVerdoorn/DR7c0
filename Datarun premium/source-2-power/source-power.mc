using Toybox.Attention;

class PowerView extends CiqView { 
    hidden var mElapsedPower	   				= 0;
    hidden var mLastLapElapsedPower				= 0;
    hidden var mPowerTime						= 0;	
    hidden var mLastLapPowerMarker          	= 0;
    hidden var mLastLapStoppedPowerMarker   	= 0;
    hidden var mLastLapStoppedHeartrateMarker   = 0;
	hidden var mLastLapTimePwrMarker			= 0;
    hidden var mLapTimerTimePwr					= 0;	
    hidden var mLastLapTimerTimePwr				= 0;
	hidden var LapPower 						= 0; 
	hidden var LastLapPower 					= 0; 
	var vibrateseconds 							= 0;  
	hidden var uLapPwr4alerts 					= 0;
    hidden var runPower							= 0;
    var overruleWourkout						= false;
    hidden var mPowerWarningunder				= 0;
    hidden var mPowerWarningupper 				= 999;
    hidden var VibrateLowRequired 				= false;
    hidden var VibrateHighRequired 				= false;
    hidden var runalertPower                    = 0;
        
    function initialize() {
        CiqView.initialize();
        var mApp = Application.getApp();
        uRequiredPower		 = mApp.getProperty("pRequiredPower");
        uWarningFreq		 = mApp.getProperty("pWarningFreq");
        uAlertbeep			 = mApp.getProperty("pAlertbeep");
        uLapPwr4alerts       = mApp.getProperty("pLapPwr4alerts");  
        overruleWourkout	 = mApp.getProperty("poverruleWourkout");     
        
        runalertPower = 0;
		if ( uLapPwr4alerts == 0 ) {
	    	runalertPower 	 = runPower;
	    } else if ( uLapPwr4alerts == 1 ) {
	    	runalertPower 	 = AveragePower3sec;
	    } else if ( uLapPwr4alerts == 2 ) {
	    	runalertPower 	 = AveragePower5sec;
		} else if ( uLapPwr4alerts == 3 ) {
	    	runalertPower 	 = AveragePower10sec;
		} else if ( uLapPwr4alerts == 4 ) {
	    	runalertPower 	 = Averagepowerpersec;
		} else if ( uLapPwr4alerts == 5 ) {
	    	runalertPower 	 = LapPower;
		} else if ( uLapPwr4alerts == 6 ) {
	    	runalertPower 	 = (info.averagePower != null) ? info.averagePower : 0;
		}
		
		//! Define predefined static powerzone
        mPowerWarningunder = uRequiredPower.substring(0, 3);
        mPowerWarningupper = uRequiredPower.substring(4, 7);
    }
	
    //! Current activity is ended
    function onTimerReset() {
        mPrevElapsedDistance        = 0;
        mLaps                       = 1;
        mLastLapDistMarker          = 0;
        mLastLapTimeMarker          = 0;
        mLastLapTimerTime           = 0;
        mLastLapElapsedDistance     = 0;
        mStartStopPushed            = 0;
        mLastLapHeartrateMarker     = 0;
        mLastLapElapsedHeartrate    = 0;        
        mLastLapTimerTimeHR     	= 0;   
        mLastLapPowerMarker      	= 0;
        mLastLapElapsedPower     	= 0; 
        mLastLapTimerTimePwr     	= 0;  
    }
	
	function onUpdate(dc) {
		//! call the parent function in order to execute the logic of the parent
		CiqView.onUpdate(dc);
		
	}
}