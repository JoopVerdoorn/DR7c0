using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

//! inherit from the view that contains the commonlogic
class PowerView extends CiqView {
    var mlastaltitude = 0;
    var mElevationDiff = 0;
    var mrealElevationGain = 0;
    var mrealElevationLoss = 0;
    var mrealElevationDiff = 0;
    var mfillColour = Graphics.COLOR_LT_GRAY;
    var uETAfromLap = true;
    var mETA = 0;
	
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
        }
    }

    //! Store last lap quantities and set lap markers
    function onTimerLap() {
		LapactionNoPower ();
	}

	//! Store last lap quantities and set lap markers after a step within a structured workout
	function onWorkoutStepComplete() {
		LapactionNoPower ();
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
    }

	function onUpdate(dc) {
		//! call the parent function in order to execute the logic of the parent
		CiqView.onUpdate(dc);
		var info = Activity.getActivityInfo();
	
        //! Calculate ETA
        if (info.elapsedDistance != null && info.timerTime != null) {
            if (uETAfromLap == true ) {
            	if (mLastLapTimerTime > 0 && mLastLapElapsedDistance > 0 && mLaps > 1) {
            		if (uRacedistance > info.elapsedDistance) {
            			mETA = info.timerTime/1000 + (uRacedistance - info.elapsedDistance)/ mLastLapSpeed;
            		} else {
            			mETA = 0;
            		}
            	}
            } else {
            	if (info.elapsedDistance > 5) {
            		mETA = uRacedistance / (1000*info.elapsedDistance/info.timerTime);
            	}
            }
        }

        var i = 0; 
	    for (i = 1; i < 8; ++i) {
	        if (metric[i] == 14) {
    	        fieldValue[i] = Math.round(mETA).toNumber();
        	    fieldLabel[i] = "ETA";
            	fieldFormat[i] = "time";               	        	
	        } else if (metric[i] == 15) {
        	    fieldLabel[i] = "Deviation";
            	fieldFormat[i] = "time";
	        	if ( mLaps == 1 ) {
    	    		fieldValue[i] = 0;
        		} else {
        			fieldValue[i] = Math.round(mRacetime - mETA).toNumber() ;
	        	}
    	    	if (fieldValue[i] < 0) {
        			fieldValue[i] = - fieldValue;
        		}            	
			}
		}


		
		//! Display colored labels on screen
		for (var i = 1; i < 8; ++i) {
		   	if ( i == 1 ) {			//!upper row, left    	
	    		Coloring(dc,i,fieldValue[i],"018,029,100,019");
		   	} else if ( i == 2 ) {	//!upper row, right
		   		Coloring(dc,i,fieldValue[i],"120,029,100,019");
	       	} else if ( i == 3 ) {  //!middle row, left
	    		Coloring(dc,i,fieldValue[i],"000,093,072,019");
		   	} else if ( i == 4 ) {	//!middle row, middle
		 		Coloring(dc,i,fieldValue[i],"074,093,089,019");
	      	} else if ( i == 5 ) {  //!middle row, right
	    		Coloring(dc,i,fieldValue[i],"165,093,077,019");
		   	} else if ( i == 6 ) {	//!lower row, left
		   		Coloring(dc,i,fieldValue[i],"018,199,100,019");
	      	} else if ( i == 7 ) {	//!lower row, right
	    		Coloring(dc,i,fieldValue[i],"120,199,100,019");
	    	}       	
		}
	   
	}
	
	
	function Coloring(dc,counter,testvalue,CorString) {
		var info = Activity.getActivityInfo();
        var x = CorString.substring(0, 3);
        var y = CorString.substring(4, 7);
        var w = CorString.substring(8, 11);
        var h = CorString.substring(12, 15);
        x = x.toNumber();
        y = y.toNumber();
        w = w.toNumber();
        h = h.toNumber(); 
		if (metric[counter] == 13 or metric[counter] == 14 or metric[counter] == 15) {
			if (mETA < mRacetime) {
    	    	mfillColour = Graphics.COLOR_GREEN;
        	} else {
        		mfillColour = Graphics.COLOR_RED;
        	}
			dc.setColor(mfillColour, Graphics.COLOR_TRANSPARENT);
        	dc.fillRectangle(x, y, w, h);
        }
	}

	function LapactionNoPower () {
        var info = Activity.getActivityInfo();
        mLastLapTimerTime       	= jTimertime - mLastLapTimeMarker;
        mLastLapElapsedDistance 	= (info.elapsedDistance != null) ? info.elapsedDistance - mLastLapDistMarker : 0;
        mLastLapDistMarker      	= (info.elapsedDistance != null) ? info.elapsedDistance : 0;
        mLastLapTimeMarker      	= jTimertime;

        mLastLapTimerTimeHR			= mHeartrateTime - mLastLapTimeHRMarker;
        mLastLapElapsedHeartrate 	= (info.currentHeartRate != null) ? mElapsedHeartrate - mLastLapHeartrateMarker : 0;
        mLastLapHeartrateMarker     = mElapsedHeartrate;
        mLastLapTimeHRMarker        = mHeartrateTime;
        mLaps++;
    }

}