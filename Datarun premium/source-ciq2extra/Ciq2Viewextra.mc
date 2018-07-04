using Toybox.Application as App;

class CiqView extends ExtramemView {  
    hidden var mElapsedHeartrate   			= 0;
	hidden var mLastLapHeartrateMarker      = 0;    
    hidden var mCurrentHeartrate    		= 0; 
    hidden var mLastLapElapsedHeartrate		= 0;
    hidden var mHeartrateTime				= 0;
    hidden var mLapTimerTimeHR				= 0;    
	hidden var mLastLapTimeHRMarker			= 0;
	hidden var mLastLapTimerTimeHR			= 0;
	hidden var LapHeartrate					= 0;
	hidden var LastLapHeartrate				= 0;
	hidden var AverageHeartrate 			= 0; 
    var mlastaltitude = 0;
    hidden var aaltitude = 0;
	hidden var mElevationGain = 0;
    hidden var mElevationLoss = 0;
    var mElevationDiff = 0;
    var mrealElevationGain = 0;
    var mrealElevationLoss = 0;
    var mrealElevationDiff = 0;
    hidden var ID0;

    function initialize() {
        ExtramemView.initialize();
    }

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		ExtramemView.onUpdate(dc);

    	//! Setup back- and foregroundcolours
		if (uBlackBackground == true ){
			mColourFont = Graphics.COLOR_WHITE;
			mColourFont1 = Graphics.COLOR_WHITE;
			mColourLine = Graphics.COLOR_GREEN;
			mColourBackGround = Graphics.COLOR_BLACK;
		} else {
			mColourFont = Graphics.COLOR_BLACK;
			mColourFont1 = Graphics.COLOR_BLACK;
			mColourLine = Graphics.COLOR_BLUE;
			mColourBackGround = Graphics.COLOR_WHITE;
		}

		var mHash = WatchID.hashCode();
		mHash = (mHash > 0) ? mHash : -mHash;
		ID2 = Math.round(mHash / 315127)+329;
		ID1 = mHash % 315127+1864;
		mtest = ((ID2-329)*315127 + ID1-1864) % 74539;
		mtest = (mtest < 1000) ? mtest + 80000 : mtest;

//!====================================================================

		
		//!Calculate HR-metrics
		var info = Activity.getActivityInfo();
		
        mLapTimerTimeHR = jTimertime - mLastLapTimeHRMarker;
        var mLapElapsedHeartrate = mElapsedHeartrate - mLastLapHeartrateMarker;

		AverageHeartrate = Math.round((mHeartrateTime != 0) ? mElapsedHeartrate/mHeartrateTime : 0);  		
		LapHeartrate = (mLapTimerTimeHR != 0) ? Math.round(mLapElapsedHeartrate/mLapTimerTimeHR) : 0;
		LastLapHeartrate			= (mLastLapTimerTime != 0) ? Math.round(mLastLapElapsedHeartrate/mLastLapTimerTime) : 0;		


		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

		var i = 0; 
	    for (i = 1; i < 8; ++i) {
	        if (metric[i] == 40) {
    	        fieldValue[i] = (info.currentSpeed != null) ? 3.6*info.currentSpeed*1000/unitP : 0;
        	    fieldLabel[i] = "Speed";
            	fieldFormat[i] = "2decimal";   
	        } else if (metric[i] == 41) {
    	        fieldValue[i] = (info.currentSpeed != null) ? 3.6*((Pace1+Pace2+Pace3+Pace4+Pace5)/5)*1000/unitP : 0;
        	    fieldLabel[i] = "Spd 5s";
            	fieldFormat[i] = "2decimal";
	        } else if (metric[i] == 42) {
    	        fieldValue[i] = (mLapSpeed != null) ? 3.6*mLapSpeed*1000/unitP  : 0;
        	    fieldLabel[i] = "L Spd";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 43) {
    	        fieldValue[i] = (mLastLapSpeed != null) ? 3.6*mLastLapSpeed*1000/unitP : 0;
        	    fieldLabel[i] = "L-1 Spd";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 44) {
	            fieldValue[i] = (info.averageSpeed != null) ? 3.6*info.averageSpeed*1000/unitP : 0;
    	        fieldLabel[i] = "Avg Spd";
        	    fieldFormat[i] = "2decimal";
        	} else if (metric[i] == 45) {
    	        fieldValue[i] = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
        	    fieldLabel[i] = "HR";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 46) {
	            fieldValue[i] = (info.currentHeartRate != null) ? info.currentHeartRate : 0; //! nog HR zone invoegen
    	        fieldLabel[i] = "HR zone";
        	    fieldFormat[i] = "0decimal";
			} else if (metric[i] == 47) {
    	        fieldValue[i] = LapHeartrate;
        	    fieldLabel[i] = "Lap HR";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 48) {
    	        fieldValue[i] = LastLapHeartrate;
        	    fieldLabel[i] = "L-1 HR";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 49) {
	            fieldValue[i] = AverageHeartrate;
    	        fieldLabel[i] = "Avg HR";
        	    fieldFormat[i] = "0decimal";
			} else if (metric[i] == 50) {
				fieldValue[i] = (info.currentCadence != null) ? info.currentCadence : 0; 
    	        fieldLabel[i] = "Cadence";
        	    fieldFormat[i] = "0decimal";
			} else if (metric[i] == 51) {
		  		fieldValue[i] = (info.altitude != null) ? Math.round(info.altitude).toNumber() : 0;
		       	fieldLabel[i] = "Altitude";
		       	fieldFormat[i] = "0decimal";
            }
        	//!einde invullen field metrics
		}

	}


}

