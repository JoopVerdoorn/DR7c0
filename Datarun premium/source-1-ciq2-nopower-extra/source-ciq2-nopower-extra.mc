using Toybox.WatchUi as Ui;
class CiqView extends ExtramemView {
	hidden var uETAfromLap 					= true;
	var Garminfont = Ui.loadResource(Rez.Fonts.Garmin1);
	hidden var TotalVertSpeedinmpersec = 0;
	hidden var i;
	
    function initialize() {
        ExtramemView.initialize();	
        Garminfont = (Watchtype == 3077) ? Ui.loadResource(Rez.Fonts.Garmin1) : Graphics.FONT_NUMBER_MEDIUM;	
    }

    //! Calculations we need to do every second even when the data field is not visible
    function compute(info) {
        //! If enabled, switch the backlight on in order to make it stay on
        if (uBacklight) {
             Attention.backlight(true);
        }
		
		startTime = (jTimertime == 0) ? Toybox.System.getClockTime() : startTime;
		
		//! We only do some calculations if the timer is running
		if (mTimerRunning) {  
			//! Calculate lap time
    	    mLapTimerTime = jTimertime - mLastLapTimeMarker;	
        	jTimertime = jTimertime + 1;
        	
			//!Calculate lapheartrate
            mHeartrateTime		 = (info.currentHeartRate != null) ? mHeartrateTime+1 : mHeartrateTime;				
           	mElapsedHeartrate    = (info.currentHeartRate != null) ? mElapsedHeartrate + info.currentHeartRate : mElapsedHeartrate;
           	
           	//!Calculate lapCadence
            mCadenceTime	 = (info.currentCadence != null) ? mCadenceTime+1 : mCadenceTime;
            mElapsedCadence= (info.currentCadence != null) ? mElapsedCadence + info.currentCadence : mElapsedCadence;
            
            
            //! Calculate vertical speed
    	    valueDesc = (info.totalDescent != null) ? info.totalDescent : 0;
        	Diff1 = valueDesc - valueDesclast;
    	    valueAsc = (info.totalAscent != null) ? info.totalAscent : 0;
        	Diff2 = valueAsc - valueAsclast;
    	    valueDesclast = valueDesc;
        	valueAsclast = valueAsc;
	        CurrentVertSpeedinmpersec = Diff2-Diff1;
	        TotalVertSpeedinmpersec = TotalVertSpeedinmpersec + CurrentVertSpeedinmpersec;
	        var i;
    	     for (i = 1; i < 8; ++i) {
	    	    if (metric[i] == 67 or metric[i] == 108) {
					for (var j = 1; j < 30; ++j) {			
						VertPace[31-j] = VertPace[30-j];
					}
					VertPace[1]	= CurrentVertSpeedinmpersec;
					for (var j = 1; j < 31; ++j) {
						totalVertPace = VertPace[j] + totalVertPace;
					}
					if (jTimertime>0) {		
						AverageVertspeedinmper30sec= (jTimertime<31) ? totalVertPace/jTimertime : totalVertPace/30;
						totalVertPace = 0;
					}
				}
			}
        } 
	}

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		ExtramemView.onUpdate(dc);		
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
        x = x.toNumber();
        y = y.toNumber();
        xms = xms.toNumber();
        xh = xh.toNumber();        
        yh = yh.toNumber();
        xl = xl.toNumber();
        yl = yl.toNumber();
 
		fieldvalue = (metric[counter]==38) ? mZone[counter] : fieldvalue;
		fieldvalue = (metric[counter]==99) ? mZone[counter] : fieldvalue;
		fieldvalue = (metric[counter]==100) ? mZone[counter] : fieldvalue;
		fieldvalue = (metric[counter]==101) ? mZone[counter] : fieldvalue;
		fieldvalue = (metric[counter]==102) ? mZone[counter] : fieldvalue;
		fieldvalue = (metric[counter]==103) ? mZone[counter] : fieldvalue;
		fieldvalue = (metric[counter]==104) ? mZone[counter] : fieldvalue;  
		fieldvalue = (metric[counter]==46) ? mZone[counter] : fieldvalue;
		
        if ( fieldformat.equals("0decimal" ) == true ) {
        	fieldvalue = fieldvalue.format("%.0f");  
        } else if ( fieldformat.equals("1decimal" ) == true ) {
            Temp = Math.round(fieldvalue*10)/10;
			fieldvalue = Temp.format("%.1f");
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
        } else if ( fieldformat.equals("timeshort" ) == true  ) {
        	Temp = (fieldvalue != 0 ) ? (fieldvalue).toLong() : 0;
        	fieldvalue = (Temp /60000 % 60).format("%02d") + ":" + (Temp /1000 % 60).format("%02d");
        }
        
        //! Make ETA related metrics green if ETA is as desired or better, otherwise red
      	if (metric[counter] == 13 or metric[counter] == 14 or metric[counter] == 15) {
	      	if (mETA < mRacetime) {
    	    	mColourFont = Graphics.COLOR_GREEN;
        	} else {
        		mColourFont = Graphics.COLOR_RED;
        	}
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
       			dc.drawText(xx, y, Garminfont, fTimer, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        	}
        } else {
       		dc.drawText(x, y, Garminfont, fieldvalue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }        
       	mColourFont = originalFontcolor;
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
       	dc.drawText(xl, yl, Graphics.FONT_XTINY,  fieldlabel, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
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
        
        mLastLapTimerTimeCadence	= mHeartrateTime - mLastLapTimeCadenceMarker;
        mLastLapElapsedCadence 		= (info.currentCadence != null) ? mElapsedCadence - mLastLapCadenceMarker : 0;
        mLastLapCadenceMarker     	= mElapsedCadence;
        mLastLapTimeCadenceMarker   = mCadenceTime;
    }

}
