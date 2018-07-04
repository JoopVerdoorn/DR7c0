using Toybox.Application as App;

class CiqView extends DatarunpremiumView {  
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
        DatarunpremiumView.initialize();
    }

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		DatarunpremiumView.onUpdate(dc);

    	//! Setup back- and foregroundcolours
		mColourFont = Graphics.COLOR_BLACK;
		mColourFont1 = Graphics.COLOR_BLACK;
		mColourLine = Graphics.COLOR_BLUE;
		mColourBackGround = Graphics.COLOR_WHITE;

//! specifieke code hierboven	
//!====================================================================

		var mHash = WatchID.hashCode();
		mHash = (mHash > 0) ? mHash : -mHash;
		ID2 = Math.round(mHash / 315127)+329;
		ID1 = mHash % 315127+1864;
		mtest = ((ID2-329)*315127 + ID1-1864) % 74539;
		mtest = (mtest < 1000) ? mtest + 80000 : mtest; 

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
        	    fieldLabel[i] = "LL Spd";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 44) {
	            fieldValue[i] = (info.averageSpeed != null) ? 3.6*info.averageSpeed*1000/unitP : 0;
    	        fieldLabel[i] = "Avg Spd";
        	    fieldFormat[i] = "2decimal";
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
        	    fieldLabel[i] = "LL HR";
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
        	
		}

	}

//! specifieke code hieronder	
//!====================================================================

	function Coloring(dc,counter,testvalue) {
        var mZ1under = 0;
        var mZ2under = 0;
        var mZ3under = 0;
        var mZ4under = 0;
        var mZ5under = 0;
        var mZ5upper = 0; 
        var avgSpeed = (info.averageSpeed != null) ? info.averageSpeed : 0;
        if (metric[i] == 20 or metric[i] == 21 or metric[i] == 22 or metric[i] == 23 or metric[i] == 24) {  //! Power=20, Pwr 5s=21, L Power=22, L-1 Pwr=23, A Power=24
        	mZ1under = uPowerZones.substring(0, 3);
        	mZ2under = uPowerZones.substring(7, 10);
        	mZ3under = uPowerZones.substring(14, 17);
        	mZ4under = uPowerZones.substring(21, 24);
        	mZ5under = uPowerZones.substring(28, 31);
        	mZ5upper = uPowerZones.substring(35, 38);          
        	mZ1under = mZ1under.toNumber();
	        mZ2under = mZ2under.toNumber();
    	    mZ3under = mZ3under.toNumber();
	        mZ4under = mZ4under.toNumber();        
    	    mZ5under = mZ5under.toNumber();
        	mZ5upper = mZ5upper.toNumber();
        }       
        if (TestValue >= mZ5upper) {
            mfillColour[i] = Graphics.COLOR_PURPLE;        
			mZone[i] = 6;
		} else if (TestValue >= mZ5under) {
			mfillColour[i] = Graphics.COLOR_RED;    	
			mZone[i] = 5;
		} else if (TestValue >= mZ4under) {
			mfillColour[i] = Graphics.COLOR_GREEN;    	
			mZone[i] = 4;
		} else if (TestValue >= mZ3under) {
			mfillColour[i] = Graphics.COLOR_BLUE;        
			mZone[i] = 3;
		} else if (TestValue >= mZ2under) {
			mfillColour[i] = Graphics.COLOR_YELLOW;        
			mZone[i] = 2;
		} else if (TestValue >= mZ1under) {
			mfillColour[i] = Graphics.COLOR_LT_GRAY;        
			mZone[i] = 1;
		} else {
			if (uBlackBackground == true ){
				mfillColour[i] = Graphics.COLOR_BLACK; 
			} else {
				mfillColour[i] = Graphics.COLOR_WHITE;
			}        
            mZone[i] = 0;
		}
	}



}

