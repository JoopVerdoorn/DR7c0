using Toybox.Activity as info; 

//! inherit from the view that contains the commonlogic
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
	hidden var AveragePower 							= 0; 
	hidden var LapPower 								= 0; 
	hidden var LastLapPower 							= 0; 
    var AveragePower5sec  	 					= 0;
	var Power1 									= 0;
    var Power2 									= 0;
    var Power3 									= 0;
	var Power4 									= 0;
    var Power5 									= 0;
	var vibrateseconds = 0;
	hidden var mT = 0;     
    
	//! it's good practice to always have an initialize, make sure to call your parent class here!
    function initialize() {
        CiqView.initialize();
    }

    //! Calculations we need to do every second even when the data field is not visible
    function compute(info) {
        //! If enabled, switch the backlight on in order to make it stay on
        if (uBacklight) {
             Attention.backlight(true);
        }

		//! We only do some calculations if the timer is running
		if (mTimerRunning) {  
			jTimertime = jTimertime + 1;
			//!Calculate lapheartrate
            mHeartrateTime		 = (info.currentHeartRate != null) ? mHeartrateTime+1 : mHeartrateTime;				
           	mElapsedHeartrate    = (info.currentHeartRate != null) ? mElapsedHeartrate + info.currentHeartRate : mElapsedHeartrate;

            //!Calculate lappower
            mPowerTime		 = (info.currentPower != null) ? mPowerTime+1 : mPowerTime;
			mElapsedPower    = (info.currentPower != null) ? mElapsedPower + info.currentPower : mElapsedPower;              
        }
        
        //! Calculate elevation differences and rounding altitude
        if (info.altitude != null) {        
          aaltitude = Math.round(info.altitude).toNumber();
          mrealElevationDiff = aaltitude - mlastaltitude;
          if (mrealElevationDiff > 0 ) {
          	mrealElevationGain = mrealElevationDiff + mrealElevationGain;
          } else {
          	mrealElevationLoss =  mrealElevationLoss - mrealElevationDiff;
          }  
          mlastaltitude = aaltitude;
          mElevationLoss = Math.round(mrealElevationLoss).toNumber();
          mElevationGain = Math.round(mrealElevationGain).toNumber();
        }        
        
        
	}

    //! Store last lap quantities and set lap markers
    function onTimerLap() {
        var info = Activity.getActivityInfo();
        mLastLapTimerTime       	= jTimertime - mLastLapTimeMarker;
        mLastLapElapsedDistance 	= (info.elapsedDistance != null) ? info.elapsedDistance - mLastLapDistMarker : 0;
        mLastLapDistMarker      	= (info.elapsedDistance != null) ? info.elapsedDistance : 0;
        mLastLapTimeMarker      	= jTimertime;

        mLastLapTimerTimeHR			= mHeartrateTime - mLastLapTimeHRMarker;
        mLastLapElapsedHeartrate 	= (info.currentHeartRate != null) ? mElapsedHeartrate - mLastLapHeartrateMarker : 0;
        mLastLapHeartrateMarker     = mElapsedHeartrate;
        mLastLapTimeHRMarker        = mHeartrateTime;

        mLastLapTimerTimePwr		= mPowerTime - mLastLapTimePwrMarker;
        mLastLapElapsedPower  		= (info.currentPower != null) ? mElapsedPower - mLastLapPowerMarker : 0;
        mLastLapPowerMarker         = mElapsedPower;
        mLastLapTimePwrMarker       = mPowerTime;        

        mLaps++;

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
        mT = 0;   
    }
	
	function onUpdate(dc) {
		//! call the parent function in order to execute the logic of the parent
		CiqView.onUpdate(dc);

        //! Calculate power-lap time and convert timers from milliseconds to seconds
		var info = Activity.getActivityInfo();
        mLapTimerTimePwr = jTimertime - mLastLapTimePwrMarker;

		//!Calculate powermetrics
		var mLapElapsedPower = mElapsedPower - mLastLapPowerMarker;
        
		AveragePower = Math.round((mPowerTime != 0) ? mElapsedPower/mPowerTime : 0);  

		if (mLapTimerTimePwr == 1 ) {  
			LapPower = (info.currentPower != null) ? info.currentPower : 0;
			mLapElapsedPower = LapPower;
		} else if (mLapTimerTimePwr == 2 ) {
			LapPower = (info.currentPower != null) ? info.currentPower : 0;
			mLapElapsedPower = 2*LapPower;		
		} else {   
			LapPower = (mLapTimerTimePwr != 0) ? Math.round(mLapElapsedPower/mLapTimerTimePwr) : 0; 	
		}
		LapPower = (mLaps == 1) ? AveragePower : LapPower; 
		LastLapPower			= (mLastLapTimerTimePwr != 0) ? Math.round(mLastLapElapsedPower/mLastLapTimerTimePwr) : 0;


		//!Calculate average power
        var AveragePower5sec  	 			= 0;
        var currentPowertest				= 0;
		if (info.currentSpeed != null && info.currentPower != null) {
        	currentPowertest = info.currentPower; 
        }
        if (currentPowertest > 0) {
            if (currentPowertest > 0) {
            	//! Calculate average power
				if (info.currentPower != null) {
        			Power1								= info.currentPower; 
        		} else {
        			Power1								= 0;
				}
        		Power5 								= Power4;
        		Power4 								= Power3;
        		Power3 								= Power2;
        		Power2 								= Power1;
				AveragePower5sec= (Power1+Power2+Power3+Power4+Power5)/5;
			}
 		}

		//! Alert when out of predefined powerzone
		//!Calculate power metrics
        var mPowerWarningunder = uRequiredPower.substring(0, 3);
        var mPowerWarningupper = uRequiredPower.substring(4, 7);
        mPowerWarningunder = mPowerWarningunder.toNumber();
        mPowerWarningupper = mPowerWarningupper.toNumber(); 
		var vibrateData = [
			new Attention.VibeProfile( 100, 100 )
		];
		//!var DisplayPower  = (info.currentPower != null) ? info.currentPower : 0;
		if (AveragePower5sec>mPowerWarningupper or AveragePower5sec<mPowerWarningunder) {
			 //!Toybox.Attention.playTone(TONE_LOUD_BEEP);		 
			 if (Toybox.Attention has :vibrate && uNoAlerts == false) {
			 	vibrateseconds = vibrateseconds + 1;	 		  			
    			if (AveragePower5sec>mPowerWarningupper) {
    				PowerWarning = 1;
    				if (vibrateseconds == uWarningFreq) {
    					Toybox.Attention.vibrate(vibrateData);
    					Toybox.Attention.vibrate(vibrateData);
    					Toybox.Attention.vibrate(vibrateData);
    					Toybox.Attention.vibrate(vibrateData);
    					Toybox.Attention.vibrate(vibrateData);
    					Toybox.Attention.vibrate(vibrateData);
    					Toybox.Attention.vibrate(vibrateData);
    					Toybox.Attention.vibrate(vibrateData);
    					if (uAlertbeep == true) {
    						Attention.playTone(Attention.TONE_KEY);
    					}
    					vibrateseconds = 0;
    				}
    			} else if (AveragePower5sec<mPowerWarningunder){
    				PowerWarning = 2;
    				if (vibrateseconds == uWarningFreq) {
    					
    						if (uAlertbeep == true) {
    							Attention.playTone(Attention.TONE_LOUD_BEEP);
    						}
    					Toybox.Attention.vibrate(vibrateData);
    					vibrateseconds = 0;
    				}
    			} else {
    				PowerWarning = 0;
    			}	
			 }
			 
		}		

		
		var i = 0; 
	    for (i = 1; i < 8; ++i) {	    
        	if (metric[i] == 20) {
            	fieldValue[i] = (info.currentPower != null) ? info.currentPower : 0;
            	fieldLabel[i] = "Power";
            	fieldFormat[i] = "power";   
	        } else if (metric[i] == 21) {
    	        fieldValue[i] = AveragePower5sec;
        	    fieldLabel[i] = "Pwr 5s";
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
    	        fieldValue[i] = AveragePower;
        	    fieldLabel[i] = "A Power";
            	fieldFormat[i] = "power";   
			}
		//!einde invullen field metrics
		}

	}

}