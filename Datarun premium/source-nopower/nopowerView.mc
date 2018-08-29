using Toybox.Graphics as Gfx;

//! inherit from the view that contains the commonlogic
class PowerView extends CiqView {
    var mlastaltitude = 0;
	var mElevationGain = 0;
    var mElevationLoss = 0;
    var mElevationDiff = 0;
    var mrealElevationGain = 0;
    var mrealElevationLoss = 0;
    var mrealElevationDiff = 0;
    hidden var mElapsedHeartrate   			= 0;
	hidden var mLastLapHeartrateMarker      = 0;    
    hidden var mCurrentHeartrate    		= 0; 
    hidden var mLastLapElapsedHeartrate		= 0;
    hidden var mHeartrateTime				= 0;
    hidden var mLapTimerTimeHR				= 0;    
	hidden var mLastLapTimeHRMarker			= 0;
	hidden var mLastLapTimerTimeHR			= 0;
	
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
            mCurrentHeartrate    = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
            mHeartrateTime		 = (info.currentHeartRate != null) ? mHeartrateTime+1 : 0;
			if (mHeartrateTime == 0) {
				var mElapsedHeartrate = 0;
			} if (mHeartrateTime == 1) {
				mElapsedHeartrate = mCurrentHeartrate;
			} if (mHeartrateTime > 1) {				
            	mElapsedHeartrate    = mElapsedHeartrate + mCurrentHeartrate;
            }
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
        mLastLapElapsedHeartrate = (info.currentHeartRate != null) ? mElapsedHeartrate - mLastLapHeartrateMarker : 0;
        mLastLapTimerTime        = (info.timerTime - mLastLapTimeMarker) / 1000;
        mLastLapTimerTimeHR		= mHeartrateTime - mLastLapTimeHRMarker;        
        mLastLapElapsedDistance  = (info.elapsedDistance != null) ? info.elapsedDistance - mLastLapDistMarker : 0;
        mLaps++;
        mLastLapDistMarker           = info.elapsedDistance;
        mLastLapHeartrateMarker      = mElapsedHeartrate;
        mLastLapTimeHRMarker         = mHeartrateTime;
        mLastLapTimeMarker           = info.timerTime;
    }

	function onWorkoutStepComplete() {
        var info = Activity.getActivityInfo();
        mLastLapElapsedHeartrate = (info.currentHeartRate != null) ? mElapsedHeartrate - mLastLapHeartrateMarker : 0;
        mLastLapTimerTime        = (info.timerTime - mLastLapTimeMarker) / 1000;
        mLastLapTimerTimeHR		= mHeartrateTime - mLastLapTimeHRMarker;        
        mLastLapElapsedDistance  = (info.elapsedDistance != null) ? info.elapsedDistance - mLastLapDistMarker : 0;
        mLaps++;
        mLastLapDistMarker           = info.elapsedDistance;
        mLastLapHeartrateMarker      = mElapsedHeartrate;
        mLastLapTimeHRMarker         = mHeartrateTime;
        mLastLapTimeMarker           = info.timerTime;
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
        mLastLapHeartrateMarker      = 0;
        mLastLapElapsedHeartrate     = 0;        
    }

	function onUpdate(dc) {
		//! call the parent function in order to execute the logic of the parent
		CiqView.onUpdate(dc);
		

	}

}