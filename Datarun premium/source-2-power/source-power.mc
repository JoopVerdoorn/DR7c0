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
        
    function initialize() {
        CiqView.initialize();
         var mApp = Application.getApp();
         uRequiredPower		 = mApp.getProperty("pRequiredPower");
         uWarningFreq		 = mApp.getProperty("pWarningFreq");
         uAlertbeep			 = mApp.getProperty("pAlertbeep");
         uLapPwr4alerts      = mApp.getProperty("pLapPwr4alerts");  
         overruleWourkout	 = mApp.getProperty("poverruleWourkout");     
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

        //! Calculate power-lap time and convert timers from milliseconds to seconds
		var info = Activity.getActivityInfo();
        mLapTimerTimePwr = mPowerTime - mLastLapTimePwrMarker;

		//!Calculate powermetrics
		var mLapElapsedPower = mElapsedPower - mLastLapPowerMarker;
        AveragePower = Math.round((mPowerTime != 0) ? mElapsedPower/mPowerTime : 0);
		LapPower = (mLapTimerTimePwr != 0) ? Math.round(mLapElapsedPower/mLapTimerTimePwr) : 0; 	
		LastLapPower = (mLastLapTimerTimePwr != 0) ? Math.round(mLastLapElapsedPower/mLastLapTimerTimePwr) : 0;

		//! Alert when out of predefined powerzone
		//!Calculate power metrics
        mPowerWarningunder = uRequiredPower.substring(0, 3);
        mPowerWarningupper = uRequiredPower.substring(4, 7);
        mPowerWarningunder = mPowerWarningunder.toNumber();
        mPowerWarningupper = mPowerWarningupper.toNumber(); 

        if (Activity has :getCurrentWorkoutStep and overruleWourkout == false) {
        	if (is32kBdevice == false) {
	        	if (WorkoutStepHighBoundary > 0) {
	        		mPowerWarningunder = WorkoutStepLowBoundary;
    	    		mPowerWarningupper = WorkoutStepHighBoundary; 
        		} else {
        			mPowerWarningunder = 0;
        			mPowerWarningupper = 999;
        		}
        	}
        }

		var vibrateData = [
			new Attention.VibeProfile( 100, 200 )
		];
		
		var runalertPower = 0;
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
		PowerWarning = 0;
		if (jTimertime != 0) {
		  if (runalertPower>mPowerWarningupper or runalertPower<mPowerWarningunder) {	 
			 if (Toybox.Attention has :vibrate && uNoAlerts == false) {
			 	vibrateseconds = vibrateseconds + 1;	 		  			
    			if (runalertPower>mPowerWarningupper) {
    				PowerWarning = 1;
    				if (vibrateseconds == uWarningFreq) {
    					Toybox.Attention.vibrate(vibrateData);
    					if (uAlertbeep == true) {
    						Attention.playTone(Attention.TONE_ALERT_HI);
    					}
    					Toybox.Attention.vibrate(vibrateData);
    					vibrateseconds = 0;
    				}
    			} else if (runalertPower<mPowerWarningunder){
    				PowerWarning = 2;
    				if (vibrateseconds == uWarningFreq) {
    					
    						if (uAlertbeep == true) {
    							Attention.playTone(Attention.TONE_ALERT_LO);
    						}
    					Toybox.Attention.vibrate(vibrateData);
    					vibrateseconds = 0;
    				}
    			} 
			 }
		  }	 
		}		
		var i = 0; 
	    for (i = 1; i < 8; ++i) {	    
        	if (metric[i] == 20) {
            	fieldValue[i] = (info.currentPower != null) ? runPower : 0;
            	fieldLabel[i] = "Power";
            	fieldFormat[i] = "power";   
	        } else if (metric[i] == 21) {
    	        fieldValue[i] = AveragePower3sec;
        	    fieldLabel[i] = "Pwr 3s";
            	fieldFormat[i] = "power";
			} else if (metric[i] == 22) {
    	        fieldValue[i] = LapPower;
        	    fieldLabel[i] = "L Power";
            	fieldFormat[i] = "power";
			} else if (metric[i] == 23) {
        	    fieldValue[i] = LastLapPower;
            	fieldLabel[i] = "LL Pwr";
            	fieldFormat[i] = "power";
	        } else if (metric[i] == 24) {
    	        fieldValue[i] = Math.round((mPowerTime != 0) ? AveragePower : 0);
        	    fieldLabel[i] = "A Power";
            	fieldFormat[i] = "power";   
			}
		}
	}
}