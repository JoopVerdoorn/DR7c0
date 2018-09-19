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

    function initialize() {
        ExtramemView.initialize();
    }

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		ExtramemView.onUpdate(dc);


//!====================================================================

		
		//!Calculate HR-metrics
		var info = Activity.getActivityInfo();
		
        mLapTimerTimeHR = mHeartrateTime - mLastLapTimeHRMarker;
        var mLapElapsedHeartrate = mElapsedHeartrate - mLastLapHeartrateMarker;

		AverageHeartrate = Math.round((mHeartrateTime != 0) ? mElapsedHeartrate/mHeartrateTime : 0);  		
		LapHeartrate = (mLapTimerTimeHR != 0) ? Math.round(mLapElapsedHeartrate/mLapTimerTimeHR) : 0; 					
		LapHeartrate = (mLaps == 1) ? AverageHeartrate : LapHeartrate;
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

		if ( metric[counter] == 46 or metric[counter] == 38 ) { 
			fieldvalue = mZone[counter];
		}

        if ( fieldformat.equals("0decimal" ) == true ) {
        	fieldvalue = Math.round(fieldvalue);
        } else if ( fieldformat.equals("1decimal" ) == true ) {
            Temp = Math.round(fieldvalue*10)/10;
        	fieldvalue = Temp.format("%.1f");
        } else if ( fieldformat.equals("2decimal" ) == true ) {
            Temp = Math.round(fieldvalue*100)/100;
            var fString = "%.2f";
         	if (Temp > 10) {
             	fString = "%.1f";
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
            		dc.drawText(xh, yh, Graphics.FONT_NUMBER_MILD, fTimerHours, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
            		fTimer = (fieldvalue / 60 % 60).format("%02d") + ":" + fTimerSecs;  
        		}
        			dc.drawText(xx, y, Graphics.FONT_NUMBER_MEDIUM, fTimer, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);	
        	}
        } else {
        	dc.drawText(x, y, Graphics.FONT_NUMBER_MEDIUM, fieldvalue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }        
        dc.drawText(xl, yl, Graphics.FONT_XTINY,  fieldlabel, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);               
        mColourFont = originalFontcolor;
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
    }

	function hashfunction(string) {
    	var val = 0;
    	var bytes = string.toUtf8Array();
    	for (var i = 0; i < bytes.size(); ++i) {
        	val = (val * 997) + bytes[i];
    	}
    	return val + (val >> 5);
	}

}

