using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

//! inherit from the view that contains the commonlogic
class PowerView extends CiqView {
    var mfillColour = Graphics.COLOR_LT_GRAY;
		
	//! it's good practice to always have an initialize, make sure to call your parent class here!
    function initialize() {
        CiqView.initialize();
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

        var i = 0; 
	    for (i = 1; i < 8; ++i) {
	        if (metric[i] == 55) {   
            	if (info.currentSpeed == null or info.currentSpeed==0) {
            		fieldValue[i] = 0;
            	} else {
            		fieldValue[i] = (info.currentSpeed > 0.001) ? 100/info.currentSpeed : 0;
            	}
            	fieldLabel[i] = "s/100m";
        	    fieldFormat[i] = "2decimal";        	    
	        } 
		}

		//! Determine required finish time and calculate required pace 	
        var mRacehour = uRacetime.substring(0, 2);
        var mRacemin = uRacetime.substring(3, 5);
        var mRacesec = uRacetime.substring(6, 8);
        mRacehour = mRacehour.toNumber();
        mRacemin = mRacemin.toNumber();
        mRacesec = mRacesec.toNumber();
        mRacetime = mRacehour*3600 + mRacemin*60 + mRacesec;
		
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


		//! Display colored labels on screen for FR645
		if (ID0 == 3397 or ID0 == 3514) {
			for (i = 1; i < 8; ++i) {
			   	if ( i == 1 ) {			//!upper row, left    	
	    			Coloring2(dc,i,fieldValue[i],"018,029,100,019");
		   		} else if ( i == 2 ) {	//!upper row, right
			   		Coloring2(dc,i,fieldValue[i],"120,029,100,019");
		       	} else if ( i == 3 ) {  //!middle row, left
	    			Coloring2(dc,i,fieldValue[i],"000,093,072,019");
		   		} else if ( i == 4 ) {	//!middle row, middle
			 		Coloring2(dc,i,fieldValue[i],"074,093,089,019");
		      	} else if ( i == 5 ) {  //!middle row, right
	    			Coloring2(dc,i,fieldValue[i],"165,093,077,019");
		   		} else if ( i == 6 ) {	//!lower row, left
			   		Coloring2(dc,i,fieldValue[i],"018,199,100,019");
		      	} else if ( i == 7 ) {	//!lower row, right
	    			Coloring2(dc,i,fieldValue[i],"120,199,100,019");
	    		}
	    	}       	
		}
	   
	}
	
	
	function Coloring2(dc,counter,testvalue,CorString) {
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

}