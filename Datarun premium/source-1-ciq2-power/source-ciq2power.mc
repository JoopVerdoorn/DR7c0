using Toybox.Application as App;

class CiqView extends DatarunpremiumView {  
    hidden var WorkoutStepLowBoundary		= 0;
    hidden var WorkoutStepHighBoundary		= 999;

    function initialize() {
        DatarunpremiumView.initialize();
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
            mPowerTime		 = (info.currentPower != null and mTimerRunning) ? mPowerTime+1 : mPowerTime;
			runPower 		 = (info.currentPower != null) ? info.currentPower : 0;
			mElapsedPower    = (mTimerRunning) ? mElapsedPower + runPower : mElapsedPower;            
        }
	}

    //! Store last lap quantities and set lap markers after a lap
    function onTimerLap() {
		Lapaction ();
	}

	//! Store last lap quantities and set lap markers after a step within a structured workout
	function onWorkoutStepComplete() {
		Lapaction ();
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
		//! call the parent onUpdate to do the base logic
		DatarunpremiumView.onUpdate(dc);

    	//! Setup back- and foregroundcolours
		mColourFont = (getBackgroundColor() == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK; 
		mColourLine = Graphics.COLOR_BLUE;
		mColourBackGround = (getBackgroundColor() == Graphics.COLOR_WHITE) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
	}

    function Formatting(dc,counter,fieldvalue,fieldformat,fieldlabel,CorString) {    
        var originalFontcolor = mColourFont;
        var Temp; 
        var x = CorString.substring(0, 3);
        var y = CorString.substring(4, 7);
        var xms = CorString.substring(8, 11);
        var xh = CorString.substring(12, 15);
        var yh = CorString.substring(16, 19);
        var xl = CorString.substring(20, 23);
		var yl = CorString.substring(24, 27);   
		var Watchtype = 1111;               
        x = x.toNumber();
        y = y.toNumber();
        xms = xms.toNumber();
        xh = xh.toNumber();        
        yh = yh.toNumber();
        xl = xl.toNumber();
        yl = yl.toNumber();
        var ycorrectionFenix6or6s = 0;
        
        Watchtype = watchType.substring(5, 9);
        
        if ( counter == 6 or counter == 7 ) {
        	if ( Watchtype == 3287 or Watchtype == 3512 ) { //! Fenix 6s
        		ycorrectionFenix6or6s = 3;
        	} else if ( Watchtype == 3289 or Watchtype == 3514 or Watchtype == 3638) { //! Fenix 6
        		ycorrectionFenix6or6s = 4;
        	}
        	y = y + ycorrectionFenix6or6s;
        }

        if ( fieldformat.equals("0decimal" ) == true ) {
        	fieldvalue = fieldvalue.format("%.0f");        	
        } else if ( fieldformat.equals("2decimal" ) == true ) {
            Temp = Math.round(fieldvalue*100)/100;
            var fString = "%.2f";
            if (counter == 3 or counter == 4 or counter ==5) {
   	      		if (Temp > 9.99999) {
    	         	fString = "%.1f";
        	    }
        	} else {
        		if (Temp > 99.99999) {
    	         	fString = "%.1f";
        	    }  
        	}        
        	fieldvalue = Temp.format(fString);        	
        } else if ( fieldformat.equals("pace" ) == true ) {
        	Temp = (fieldvalue != 0 ) ? (unitP/fieldvalue).toLong() : 0;
        	fieldvalue = (Temp / 60).format("%0d") + ":" + Math.round(Temp % 60).format("%02d");
        } else if ( fieldformat.equals("power" ) == true ) {     
        	fieldvalue = Math.round(fieldvalue);       	
        	if (PowerWarning == 1) { 
        		mColourFont = Graphics.COLOR_PURPLE;
        	} else if (PowerWarning == 2) { 
        		mColourFont = Graphics.COLOR_RED;
        	} else if (PowerWarning == 0) { 
        		mColourFont = originalFontcolor;
        	}
        } else if ( fieldformat.equals("timeshort" ) == true  ) {
        	Temp = (fieldvalue != 0 ) ? (fieldvalue).toLong() : 0;
        	fieldvalue = (Temp /60000 % 60).format("%02d") + ":" + (Temp /1000 % 60).format("%02d");
        }

    	dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
    	
        if ( fieldformat.equals("time" ) == true ) {    
	    	if ( counter == 1 or counter == 2 or counter == 6 or counter == 7 ) {  
	    		var fTimerSecs = (fieldvalue % 60).format("%02d");
        		var fTimer = (fieldvalue / 60).format("%d") + ":" + fTimerSecs;  //! Format time as m:ss
	    		var xx = x;
	    		//! (Re-)format time as h:mm(ss) if more than an hour
	    		if (fieldvalue > 3599) {
            		var fTimerHours = (fieldvalue / 3600).format("%d");
            		xx = xms;
            		dc.drawText(xh, yh, Graphics.FONT_LARGE, fTimerHours, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
            		fTimer = (fieldvalue / 60 % 60).format("%02d") + ":" + fTimerSecs;  
        		}
        		if (Watchtype == 3287 or Watchtype == 3512 or Watchtype == 3289 or Watchtype == 3514 or Watchtype == 3638) { //! Fenix 6(s) or Enduro
        			dc.drawText(xx, y, Graphics.FONT_NUMBER_MILD, fTimer, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		} else {
        			dc.drawText(xx, y, Graphics.FONT_NUMBER_MEDIUM, fTimer, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		}	
        	}
        } else {
        	if (Watchtype == 3287 or Watchtype == 3512 or Watchtype == 3289 or Watchtype == 3514 or Watchtype == 3638) { //! Fenix 6(s)  or Enduro
        		dc.drawText(x, y, Graphics.FONT_NUMBER_MILD, fieldvalue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        	} else {
        		dc.drawText(x, y, Graphics.FONT_NUMBER_MEDIUM, fieldvalue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        	}
        }        
        dc.drawText(xl, yl, Graphics.FONT_XTINY,  fieldlabel, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);               
        mColourFont = originalFontcolor;
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
    }

	function Lapaction () {
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

	
}
