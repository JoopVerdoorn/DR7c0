using Toybox.Activity as info; 

//! inherit from the view that contains the commonlogic
class PowerView extends CiqView {
    hidden var DisplayPower    					= 0;
    hidden var mCurrentPower    				= 0; 
    hidden var mElapsedPower	   				= 0;
    hidden var mLastLapElapsedPower				= 0;
    hidden var mPowerTime						= 0;
	hidden var uNoAlerts 						= false;
    hidden var uPowerZones                  	= "184:Z1:227:Z2:255:Z3:284:Z4:326:Z5:369";	
	hidden var uRequiredPower		 			= "000:999";
    hidden var mLastLapPowerMarker          	= 0;
    hidden var mLastLapStoppedPowerMarker   	= 0;
    hidden var mLastLapStoppedHeartrateMarker   = 0;
	hidden var mLastLapTimePwrMarker			= 0;
    hidden var mLapTimerTimePwr					= 0;	
    hidden var mLastLapTimerTimePwr				= 0;
	var AveragePower 							= 0; 
	var LapPower 								= 0; 
	var LastLapPower 							= 0; 

	    
    
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

            //!Calculate lappower
			mCurrentPower    = (info.currentPower != null) ? info.currentPower : 0;
            mPowerTime		 = (info.currentPower != null) ? mPowerTime+1 : mPowerTime;
			if (mPowerTime == 0) {
				var mElapsedPower = 0;
			} if (mPowerTime == 1) {
				mElapsedPower = mCurrentPower;
			} if (mPowerTime > 1) {	            
            	mElapsedPower    = mElapsedPower + mCurrentPower; 
            } 
        }
              
	}

    //! Store last lap quantities and set lap markers
    function onTimerLap() {
        var info = Activity.getActivityInfo();
        mLastLapElapsedPower  	= (info.currentPower != null) ? mElapsedPower - mLastLapPowerMarker : 0;
        mLastLapTimerTime       = (info.timerTime - mLastLapTimeMarker) / 1000;
        mLastLapTimerTimePwr	= mPowerTime - mLastLapTimePwrMarker;
        mLastLapElapsedDistance = (info.elapsedDistance != null) ? info.elapsedDistance - mLastLapDistMarker : 0;
        mLaps++;
        mLastLapDistMarker            = info.elapsedDistance;
        mLastLapPowerMarker           = mElapsedPower;
        mLastLapTimePwrMarker         = mPowerTime;        
        mLastLapTimeMarker            = info.timerTime;
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
        mLastLapPowerMarker      	= 0;
        mLastLapElapsedPower     	= 0; 
        mLastLapTimerTimePwr     	= 0;   
        mLastLapElapsedPower     	= 0;    
    }
	
	function onUpdate(dc) {
		//! call the parent function in order to execute the logic of the parent
		CiqView.onUpdate(dc);

        //! Calculate lap time and convert timers from milliseconds to seconds
		var info = Activity.getActivityInfo();
        if (info.timerTime != null) {
            mLapTimerTimePwr = info.timerTime/1000 - mLastLapTimePwrMarker;
        }

		//!Calculate powermetrics
    	var mLapElapsedPower 				= 0;
        if (mCurrentPower != null) {
            mLapElapsedPower = mElapsedPower - mLastLapPowerMarker;
        }
		var AveragePower = Math.round((mPowerTime != 0) ? mElapsedPower/mPowerTime : 0);  
		if (mLaps == 1) {
			LapPower = AveragePower;  
		} else {
			LapPower = (mLapTimerTime != 0) ? Math.round(mLapElapsedPower/mLapTimerTimePwr) : 0;
		}
		var LastLapPower			= (mLastLapTimerTimePwr != 0) ? Math.round(mLastLapElapsedPower/mLastLapTimerTimePwr) : 0;




	}

}