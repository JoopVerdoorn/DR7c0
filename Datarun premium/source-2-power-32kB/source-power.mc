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
    var AveragePower3sec  	 					= 0;
	var Power1 									= 0;
    var Power2 									= 0;
    var Power3 									= 0;
	var vibrateseconds 							= 0;  
	hidden var uLapPwr4alerts 					= false;
    hidden var runPower							= 0;
    hidden var mPowerWarningunder				= 0;
    hidden var mPowerWarningupper 				= 999;
        
    function initialize() {
        CiqView.initialize();
         var mApp = Application.getApp();
         uRequiredPower		 = mApp.getProperty("pRequiredPower");
         uWarningFreq		 = mApp.getProperty("pWarningFreq");
         uAlertbeep			 = mApp.getProperty("pAlertbeep");
         uLapPwr4alerts      = mApp.getProperty("pLapPwr4alerts");       
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
        
		LapPower = (mLapTimerTimePwr != 0) ? Math.round(mLapElapsedPower/mLapTimerTimePwr) : 0; 	
		LastLapPower = (mLastLapTimerTimePwr != 0) ? Math.round(mLastLapElapsedPower/mLastLapTimerTimePwr) : 0;

		//!Calculate average power
        var AveragePower3sec  	 			= 0;
        var currentPowertest				= 0;
		if (info.currentSpeed != null && info.currentPower != null) {
        	currentPowertest = runPower; 
        }
        if (currentPowertest > 0) {
            if (currentPowertest > 0) {
            	//! Calculate average power
        		Power3 								= Power2;
        		Power2 								= Power1;
				if (info.currentPower != null) {
        			Power1								= runPower; 
        		} else {
        			Power1								= 0;
				}
				AveragePower3sec= (Power1+Power2+Power3)/3;
			}
 		}

		//! Alert when out of predefined powerzone
		//!Calculate power metrics
        mPowerWarningunder = uRequiredPower.substring(0, 3);
        mPowerWarningupper = uRequiredPower.substring(4, 7);
        mPowerWarningunder = mPowerWarningunder.toNumber();
        mPowerWarningupper = mPowerWarningupper.toNumber(); 

		var vibrateData = [
			new Attention.VibeProfile( 100, 200 )
		];
		
		var runalertPower = 0;
		if ( uLapPwr4alerts == true ) {
	    	runalertPower 	 = LapPower;
	    } else {
	    	runalertPower 	 = AveragePower3sec;
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
    	        fieldValue[i] = Math.round((mPowerTime != 0) ? mElapsedPower/mPowerTime : 0);
        	    fieldLabel[i] = "A Power";
            	fieldFormat[i] = "power";   
			}
		}
	}
}