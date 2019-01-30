class ExtramemView extends DatarunpremiumView {   
	hidden var uHrZones   			        = [ 93, 111, 130, 148, 167, 185 ];	
	hidden var uPowerZones                  = "184:Z1:227:Z2:255:Z3:284:Z4:326:Z5:369";
	hidden var uPower10Zones				= "180:Z1:210:Z2:240:Z3:270:Z4:300:Z5:330:Z6:360:Z7:390:Z8:420:Z9:450:Z10:480";
	hidden var PalPowerzones 				= false;
	var mZone 								= [1, 2, 3, 4, 5, 6, 7, 8];
	var uBlackBackground 					= false;    	
	var counterPace 						= 0;
	var rollingPaceValue 					= new [303];
	var totalRPa 							= 0;
	var rolavPacmaxsecs 					= 30;
	var Averagespeedinmpersec 				= 0;
	var uClockFieldMetric 					= 38; //! Powerzone is default
	var mETA								= 0;
	var uETAfromLap 						= true;
	var HRzone								= 0;
	hidden var Powerzone					= 0;
	
    function initialize() {
        DatarunpremiumView.initialize();
		var mApp 		 = Application.getApp();
		uClockFieldMetric = mApp.getProperty("pClockFieldMetric");
		uETAfromLap		 = mApp.getProperty("pETAfromLap");
		rolavPacmaxsecs  = mApp.getProperty("prolavPacmaxsecs");
		uBlackBackground    = mApp.getProperty("pBlackBackground");
        uHrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
    }

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		DatarunpremiumView.onUpdate(dc);

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
		dc.setColor(mColourBackGround, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, 240, 240);
       
		//! Calculation of rolling average of pace
		var info = Activity.getActivityInfo();
		var zeroValueSecs = 0;
		if (counterPace < 1) {
			for (var i = 1; i < rolavPacmaxsecs+2; ++i) {
				rollingPaceValue [i] = 0; 
			}
		}
		counterPace = counterPace + 1;
		rollingPaceValue [rolavPacmaxsecs+1] = (info.currentSpeed != null) ? info.currentSpeed : 0;
		for (var i = 1; i < rolavPacmaxsecs+1; ++i) {
			rollingPaceValue [i] = rollingPaceValue [i+1];
		}
		for (var i = 1; i < rolavPacmaxsecs+1; ++i) {
			totalRPa = rollingPaceValue [i] + totalRPa;
			if (mHeartrateTime < rolavPacmaxsecs) {
				zeroValueSecs = (rollingPaceValue[i] != 0) ? zeroValueSecs : zeroValueSecs + 1;
			}
		}
		if (rolavPacmaxsecs-zeroValueSecs == 0) {
			Averagespeedinmpersec = 0;
		} else {
			Averagespeedinmpersec = (mHeartrateTime < rolavPacmaxsecs) ? totalRPa/(rolavPacmaxsecs-zeroValueSecs) : totalRPa/rolavPacmaxsecs;
		}
		totalRPa = 0;

		var CurrentEfficiencyFactor		= (info.currentHeartRate != null && info.currentHeartRate != 0) ? mLapSpeed*60/info.currentHeartRate : 0;
		var AverageEfficiencyFactor   	= (info.averageSpeed != null && AverageHeartrate != 0) ? info.averageSpeed*60/AverageHeartrate : 0; 
		var LapEfficiencyFactor   		= (LapHeartrate != 0) ? mLapSpeed*60/LapHeartrate : 0;
		var LastLapEfficiencyFactor   	= (LastLapHeartrate != 0) ? mLastLapSpeed*60/LastLapHeartrate : 0;

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
        			fieldValue[i] = - fieldValue[i];
        		}            	
			} else if (metric[i] == 17) {
	            fieldValue[i] = Averagespeedinmpersec;
    	        fieldLabel[i] = "Pc ..sec";
        	    fieldFormat[i] = "pace";  
	        } else if (metric[i] == 28) {
    	        fieldValue[i] = LapEfficiencyFactor;
        	    fieldLabel[i] = "Lap EF";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 29) {
    	        fieldValue[i] = LastLapEfficiencyFactor;
        	    fieldLabel[i] = "LL EF";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 30) {
	            fieldValue[i] = AverageEfficiencyFactor;
    	        fieldLabel[i] = "Avg EF";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 32) {
	            fieldValue[i] = CurrentEfficiencyFactor;
    	        fieldLabel[i] = "Cur EF";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 46) {
	            fieldValue[i] = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
    	        fieldLabel[i] = "HR zone";
        	    fieldFormat[i] = "1decimal";        	    
        	} else if (metric[i] == 54) {
    	        fieldValue[i] = (info.trainingEffect != null) ? info.trainingEffect : 0;
        	    fieldLabel[i] = "T effect";
            	fieldFormat[i] = "2decimal";           	
			} else if (metric[i] == 52) {
           		fieldValue[i] = (info.totalAscent != null) ? info.totalAscent : 0;
            	fieldValue[i] = (unitD == 1609.344) ? fieldValue[i]*3.2808 : fieldValue[i];
            	fieldLabel[i] = "EL gain";
            	fieldFormat[i] = "0decimal";
        	}  else if (metric[i] == 53) {
           		fieldValue[i] = (info.totalDescent != null) ? info.totalDescent : 0;
           		fieldValue[i] = (unitD == 1609.344) ? fieldValue[i]*3.2808 : fieldValue[i];
            	fieldLabel[i] = "EL loss";
            	fieldFormat[i] = "0decimal";           	
        	}  else if (metric[i] == 61) {
           		fieldValue[i] = (info.currentCadence != null) ? info.currentCadence/2 : 0;
            	fieldLabel[i] = "RCadence";
            	fieldFormat[i] = "0decimal";           	
        	}  else if (metric[i] == 62) {
           		fieldValue[i] = (info.currentSpeed != null) ? 3.6*((Pace1+Pace2+Pace3)/3)*1000/unitP : 0;
            	fieldLabel[i] = "Spd 3s";
            	fieldFormat[i] = "2decimal";           	
        	}  else if (metric[i] == 63) {
           		fieldValue[i] = 3.6*Averagespeedinmpersec*1000/unitP ;
            	fieldLabel[i] = "Spd ..s";
            	fieldFormat[i] = "2decimal";           	
			} 
		}

		var CFMValue = 0;
        var CFMLabel = "error";
        var CFMFormat = "decimal";  
		//!Choice for metric in Clockfield
        	if (uClockFieldMetric == 4) {
    	        CFMValue = (info.elapsedDistance != null) ? info.elapsedDistance / unitD : 0;
        	    CFMLabel = "Distance";
            	CFMFormat = "2decimal";   
	        } else if (uClockFieldMetric == 5) {
    	        CFMValue = mLapElapsedDistance/unitD;
        	    CFMLabel = "Lap D";
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 6) {
    	        CFMValue = mLastLapElapsedDistance/unitD;
        	    CFMLabel = "L-1LapD";
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 7) {
	            CFMValue = (info.elapsedDistance != null) ? info.elapsedDistance / (mLaps * unitD) : 0;
    	        CFMLabel = "AvgLapD";
        	    CFMFormat = "2decimal";
	        } else if (uClockFieldMetric == 8) {
   	        	CFMValue = CurrentSpeedinmpersec;
        	    CFMLabel = "Pace";
            	CFMFormat = "pace";   
	        } else if (uClockFieldMetric == 9) {
    	        CFMValue = Averagespeedinmper5sec; 
        	    CFMLabel = "Pace 5s";
            	CFMFormat = "pace";
	        } else if (uClockFieldMetric == 16) {
    	        CFMValue = Averagespeedinmper3sec; 
        	    CFMLabel = "Pace 3s";
            	CFMFormat = "pace";
	        } else if (uClockFieldMetric == 10) {
    	        CFMValue = mLapSpeed;
        	    CFMLabel = "L Pace";
            	CFMFormat = "pace";
			} else if (uClockFieldMetric == 11) {
    	        CFMValue = mLastLapSpeed;
        	    CFMLabel = "LL Pace";
            	CFMFormat = "pace";
			} else if (uClockFieldMetric == 12) {
	            CFMValue = (info.averageSpeed != null) ? info.averageSpeed : 0;
    	        CFMLabel = "AvgPace";
        	    CFMFormat = "pace";
            } else if (uClockFieldMetric == 13) {
        		CFMLabel  = "Req pace ";
        		CFMFormat = "pace";
        		if (info.elapsedDistance != null and mRacetime != jTimertime and mRacetime > jTimertime) {
        			CFMValue = (uRacedistance - info.elapsedDistance) / (mRacetime - info.timerTime/1000);
        		} 
	        } else if (uClockFieldMetric == 40) {
    	        CFMValue = (info.currentSpeed != null) ? 3.6*info.currentSpeed*1000/unitP : 0;
        	    CFMLabel = "Speed";
            	CFMFormat = "2decimal";   
	        } else if (uClockFieldMetric == 41) {
    	        CFMValue = (info.currentSpeed != null) ? 3.6*((Pace1+Pace2+Pace3+Pace4+Pace5)/5)*1000/unitP : 0;
        	    CFMLabel = "Spd 5s";
            	CFMFormat = "2decimal";
	        } else if (uClockFieldMetric == 42) {
    	        CFMValue = (mLapSpeed != null) ? 3.6*mLapSpeed*1000/unitP  : 0;
        	    CFMLabel = "L Spd";
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 43) {
    	        CFMValue = (mLastLapSpeed != null) ? 3.6*mLastLapSpeed*1000/unitP : 0;
        	    CFMLabel = "LL Spd";
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 44) {
	            CFMValue = (info.averageSpeed != null) ? 3.6*info.averageSpeed*1000/unitP : 0;
    	        CFMLabel = "Avg Spd";
        	    CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 46) {
	            CFMValue = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
    	        CFMLabel = "HR zone";
        	    CFMFormat = "1decimal";   
			} else if (uClockFieldMetric == 47) {
    	        CFMValue = LapHeartrate;
        	    CFMLabel = "Lap HR";
            	CFMFormat = "0decimal";
			} else if (uClockFieldMetric == 48) {
    	        CFMValue = LastLapHeartrate;
        	    CFMLabel = "LL HR";
            	CFMFormat = "0decimal";
			} else if (uClockFieldMetric == 49) {
	            CFMValue = AverageHeartrate;
    	        CFMLabel = "Avg HR";
        	    CFMFormat = "0decimal";        	    
			} else if (uClockFieldMetric == 50) {
				CFMValue = (info.currentCadence != null) ? info.currentCadence : 0; 
    	        CFMLabel = "Cadence";
        	    CFMFormat = "0decimal";
			} else if (uClockFieldMetric == 51) {
		  		CFMValue = (info.altitude != null) ? Math.round(info.altitude).toNumber() : 0;
		       	CFMLabel = "Altitude";
		       	CFMFormat = "0decimal";        		
        	} else if (uClockFieldMetric == 45) {
    	        CFMValue = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
        	    CFMLabel = "HR";
            	CFMFormat = "0decimal";
	        } else if (uClockFieldMetric == 17) {
	            CFMValue = Averagespeedinmpersec;
    	        CFMLabel = "Pc ..sec";
        	    CFMFormat = "pace";            	
			} else if (uClockFieldMetric == 55) {   
            	CFMValue = (info.currentSpeed != null or info.currentSpeed!=0) ? 100/info.currentSpeed : 0;
            	CFMLabel = "s/100m";
        	    CFMFormat = "2decimal";
	        } else if (uClockFieldMetric == 28) {
    	        CFMValue = LapEfficiencyFactor;
        	    CFMLabel = "Lap EF";
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 29) {
    	        CFMValue = LastLapEfficiencyFactor;
        	    CFMLabel = "LL EF";
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 30) {
	            CFMValue = AverageEfficiencyFactor;
    	        CFMLabel = "Avg EF";
        	    CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 32) {
	            CFMValue = CurrentEfficiencyFactor;
    	        CFMLabel = "Cur EF";
        	    CFMFormat = "2decimal";
	        } else if (uClockFieldMetric == 17) {
	            CFMValue = Averagespeedinmpersec;
    	        CFMLabel = "Pc ..sec";
        	    CFMFormat = "pace";  
        	} else if (uClockFieldMetric == 54) {
    	        CFMValue = (info.trainingEffect != null) ? info.trainingEffect : 0;
        	    CFMLabel = "T effect";
            	CFMFormat = "2decimal";           	
			} else if (uClockFieldMetric == 52) {
           		CFMValue = (info.totalAscent != null) ? info.totalAscent : 0;
            	CFMValue = (unitD == 1609.344) ? CFMValue*3.2808 : CFMValue;
            	CFMLabel = "EL gain";
            	CFMFormat = "0decimal";
        	}  else if (uClockFieldMetric == 53) {
           		CFMValue = (info.totalDescent != null) ? info.totalDescent : 0;
           		CFMValue = (unitD == 1609.344) ? CFMValue*3.2808 : CFMValue; 
            	CFMLabel = "EL loss";
            	CFMFormat = "0decimal";           	
        	}  else if (uClockFieldMetric == 61) {
           		CFMValue = (info.currentCadence != null) ? info.currentCadence/2 : 0;
            	CFMLabel = "RCadence";
            	CFMFormat = "0decimal";           	
        	}  else if (uClockFieldMetric == 62) {
           		CFMValue = (info.currentSpeed != null) ? 3.6*((Pace1+Pace2+Pace3)/3)*1000/unitP : 0;
            	CFMLabel = "Spd 3s";
            	CFMFormat = "2decimal";           	
        	}  else if (uClockFieldMetric == 63) {
           		CFMValue = 3.6*Averagespeedinmpersec*1000/unitP ;
            	CFMLabel = "Spd ..s";
            	CFMFormat = "2decimal";           	
			}
			 

		//! Conditions for showing the demoscreen       
        if (uShowDemo == false) {
        	if (licenseOK == false && jTimertime > 900)  {
        		uShowDemo = true;        		
        	}
        }

	   //! Check whether demoscreen is showed or the metrics 
	   if (uShowDemo == false ) {

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

		//! Show number of laps or clock with current time in top
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		if (uMilClockAltern == 2) { //! Show number of laps 
			 dc.drawText(103, -4, Graphics.FONT_MEDIUM, mLaps, Graphics.TEXT_JUSTIFY_CENTER);
			 dc.drawText(140, -1, Graphics.FONT_XTINY, "lap", Graphics.TEXT_JUSTIFY_CENTER);
		} else if (uMilClockAltern == 1) {	//! Show clock with AM and PM 	
			var myTime = Toybox.System.getClockTime(); 
			var AmPmhour = myTime.hour.format("%02d");
			AmPmhour = AmPmhour.toNumber();
			var AmPm = "AM";
			if (AmPmhour > 12) {
				AmPm = "PM";
				AmPmhour = AmPmhour - 12;
			}
	    	var strTime = AmPmhour + ":" + myTime.min.format("%02d") + " " + AmPm;
			dc.drawText(130, -4, Graphics.FONT_MEDIUM, strTime, Graphics.TEXT_JUSTIFY_CENTER);
		} else if (uMilClockAltern == 3) {		//! Display of metric in Clock field
			var originalFontcolor = mColourFont;
			var Temp;
			CFMValue = (uClockFieldMetric==38) ? Powerzone : CFMValue; 
			CFMValue = (uClockFieldMetric==46) ? HRzone : CFMValue;
			if ( CFMFormat.equals("0decimal" ) == true ) {
        		CFMValue = Math.round(CFMValue);
	        } else if ( CFMFormat.equals("1decimal" ) == true ) {
    	        Temp = Math.round(CFMValue*10)/10;
				CFMValue = Temp.format("%.1f");				
	        } else if ( CFMFormat.equals("2decimal" ) == true ) {
    	        Temp = Math.round(CFMValue*100)/100;
        	    var fString = "%.2f";
         		if (Temp > 10) {
	             	fString = "%.1f";
    	        }           
        		CFMValue = Temp.format(fString);        	
	        } else if ( CFMFormat.equals("pace" ) == true ) {
    	    	Temp = (CFMValue != 0 ) ? (unitP/CFMValue).toLong() : 0;
        		CFMValue = (Temp / 60).format("%0d") + ":" + Math.round(Temp % 60).format("%02d");
	        } else if ( CFMFormat.equals("power" ) == true ) {     
    	    	CFMValue = Math.round(CFMValue);       	
        		if (PowerWarning == 1) { 
        			mColourFont = Graphics.COLOR_PURPLE;
	        	} else if (PowerWarning == 2) { 
    	    		mColourFont = Graphics.COLOR_RED;
        		} else if (PowerWarning == 0) { 
        			mColourFont = originalFontcolor;
	        	}
    	    } else if ( CFMFormat.equals("timeshort" ) == true  ) {
        		Temp = (CFMValue != 0 ) ? (CFMValue).toLong() : 0;
        		CFMValue = (Temp /60000 % 60).format("%02d") + ":" + (Temp /1000 % 60).format("%02d");
	        }
	    	dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
	       	dc.drawText(120, 13, Graphics.FONT_MEDIUM, CFMValue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    	    mColourFont = originalFontcolor;
			dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		}
		
		if (jTimertime == 0) {
        	var myTime = Toybox.System.getClockTime(); 
	    	var strTime = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d");
	    	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			dc.drawText(120, 160, Graphics.FONT_MEDIUM, strTime, Graphics.TEXT_JUSTIFY_CENTER);
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
        var mZ1under = 0;
        var mZ2under = 0;
        var mZ3under = 0;
        var mZ4under = 0;
        var mZ5under = 0;
        var mZ5upper = 0; 
        var avgSpeed = (info.averageSpeed != null) ? info.averageSpeed : 0;
		if (metric[counter] == 45 or metric[counter] == 46 or metric[counter] == 47 or metric[counter] == 48 or metric[counter] == 49) {  //! HR=45, HR-zone=46, Lap HR=47, L-1 HR=48, Avg HR=49
            mZ1under = uHrZones[0];
            mZ2under = uHrZones[1];
            mZ3under = uHrZones[2];
            mZ4under = uHrZones[3];
            mZ5under = uHrZones[4];
            mZ5upper = uHrZones[5];
        } else if (metric[counter] == 50) {  //! Cadence
            mZ1under = 120;
            mZ2under = 153;
            mZ3under = 164;
            mZ4under = 174;
            mZ5under = 183;
            mZ5upper = 300; 
        } else if (metric[counter] == 20 or metric[counter] == 21 or metric[counter] == 22 or metric[counter] == 23 or metric[counter] == 24 or metric[counter] == 37 or metric[counter] == 38) {  //! Power=20, Powerzone=38, Pwr 5s=21, L Power=22, L-1 Pwr=23, A Power=24
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
        } else if (metric[counter] == 8 or metric[counter] == 9 or metric[counter] == 10 or metric[counter] == 11 or metric[counter] == 12 or metric[counter] == 40 or metric[counter] == 41 or metric[counter] == 42 or metric[counter] == 43 or metric[counter] == 44) {  //! Pace=8, Pace 5s=9, L Pace=10, L-1 Pace=11, AvgPace=12, Speed=40, Spd 5s=41, L Spd=42, LL Spd=43, Avg Spd=44
            mZ1under = avgSpeed*0.9;
            mZ2under = avgSpeed*0.95;
            mZ3under = avgSpeed;
            mZ4under = avgSpeed*1.05;
            mZ5under = avgSpeed*1.1;
            mZ5upper = avgSpeed*1.15; 
        } else {
            mZ1under = 99999999;
            mZ2under = 99999999;
            mZ3under = 99999999;
            mZ4under = 99999999;
            mZ5under = 99999999;
            mZ5upper = 99999999; 
        }
        mZone[counter] = 0;
        if (testvalue >= mZ5upper) {
            mfillColour = Graphics.COLOR_PURPLE;
			mZone[counter] = 6;			
		} else if (testvalue >= mZ5under) {
			mfillColour = Graphics.COLOR_RED;    	
			mZone[counter] = Math.round(10*(5+(testvalue-mZ5under+0.00001)/(mZ5upper-mZ5under+0.00001)))/10;			
		} else if (testvalue >= mZ4under) {
			mfillColour = Graphics.COLOR_GREEN;    	
			mZone[counter] = Math.round(10*(4+(testvalue-mZ4under+0.00001)/(mZ5under-mZ4under+0.00001)))/10;			
		} else if (testvalue >= mZ3under) {
			mfillColour = Graphics.COLOR_BLUE;        
			mZone[counter] = Math.round(10*(3+(testvalue-mZ3under+0.00001)/(mZ4under-mZ3under+0.00001)))/10;
		} else if (testvalue >= mZ2under) {
			mfillColour = Graphics.COLOR_YELLOW;        
			mZone[counter] = Math.round(10*(2+(testvalue-mZ2under+0.00001)/(mZ3under-mZ2under+0.00001)))/10;
		} else if (testvalue >= mZ1under) {			
			mfillColour = Graphics.COLOR_LT_GRAY;        
			mZone[counter] = 1;
		} else {
			mfillColour = mColourBackGround;        
            mZone[counter] = 0;
		}		

		if ( PalPowerzones == true) {
		  if (metric[counter] == 20 or metric[counter] == 21 or metric[counter] == 22 or metric[counter] == 23 or metric[counter] == 24 or metric[counter] == 37 or metric[counter] == 38) {  //! Power=20, Powerzone=38, Pwr 5s=21, L Power=22, L-1 Pwr=23, A Power=24		
        	mZ1under = uPower10Zones.substring(0, 3);
        	mZ2under = uPower10Zones.substring(7, 10);
        	mZ3under = uPower10Zones.substring(14, 17);
        	mZ4under = uPower10Zones.substring(21, 24);
        	mZ5under = uPower10Zones.substring(28, 31);
        	var mZ6under = uPower10Zones.substring(35, 38);
        	var mZ7under = uPower10Zones.substring(42, 45);
        	var mZ8under = uPower10Zones.substring(49, 52);
        	var mZ9under = uPower10Zones.substring(56, 59);
			var mZ10under = uPower10Zones.substring(63, 66);
        	var mZ10upper = uPower10Zones.substring(71, 74);
             
        	mZ1under = mZ1under.toNumber();
        	mZ2under = mZ2under.toNumber();
	        mZ3under = mZ3under.toNumber();
     	   	mZ4under = mZ4under.toNumber();        
        	mZ5under = mZ5under.toNumber();
	        mZ6under = mZ6under.toNumber();
    	    mZ7under = mZ7under.toNumber();
        	mZ8under = mZ8under.toNumber();
	        mZ9under = mZ9under.toNumber();
    	    mZ10under = mZ10under.toNumber();
        	mZ10upper = mZ10upper.toNumber(); 

		  if (info.currentPower != null) {
                if (testvalue >= mZ10upper) {
                    mfillColour = Graphics.COLOR_BLACK;        //! (aboveZ10)
                    mZone[counter] = 11;
                } else if (testvalue >= mZ10under) {
                    mfillColour = Graphics.COLOR_PURPLE;    	//! (Z10)
                    mZone[counter] = Math.round(10*(10+(testvalue-mZ10under+0.00001)/(mZ10upper-mZ10under+0.00001)))/10;
                } else if (testvalue >= mZ9under) {
                    mfillColour = Graphics.COLOR_PURPLE;    	//! (Z9)
                    mZone[counter] = Math.round(10*(9+(testvalue-mZ9under+0.00001)/(mZ10under-mZ9under+0.00001)))/10;
                } else if (testvalue >= mZ8under) {
                    mfillColour = Graphics.COLOR_PINK;    	//! (Z8)
                    mZone[counter] = Math.round(10*(8+(testvalue-mZ8under+0.00001)/(mZ9under-mZ8under+0.00001)))/10;
                } else if (testvalue >= mZ7under) {
                    mfillColour = Graphics.COLOR_DK_RED;    	//! (Z7)
                    mZone[counter] = Math.round(10*(7+(testvalue-mZ7under+0.00001)/(mZ8under-mZ7under+0.00001)))/10;
                } else if (testvalue >= mZ6under) {
                    mfillColour = Graphics.COLOR_RED;    	//! (Z6)
                    mZone[counter] = Math.round(10*(6+(testvalue-mZ6under+0.00001)/(mZ7under-mZ6under+0.00001)))/10;
                } else if (testvalue >= mZ5under) {
                    mfillColour = Graphics.COLOR_ORANGE;    	//! (Z5)
                    mZone[counter] = Math.round(10*(5+(testvalue-mZ5under+0.00001)/(mZ6under-mZ5under+0.00001)))/10;
                } else if (testvalue >= mZ4under) {
                    mfillColour = Graphics.COLOR_DK_GREEN;    	//! (Z4)
                    mZone[counter] = Math.round(10*(4+(testvalue-mZ4under+0.00001)/(mZ5under-mZ4under+0.00001)))/10;
                } else if (testvalue >= mZ3under) {
                    mfillColour = Graphics.COLOR_GREEN;        //! (Z3)
                    mZone[counter] = Math.round(10*(3+(testvalue-mZ3under+0.00001)/(mZ4under-mZ3under+0.00001)))/10;
                } else if (testvalue >= mZ2under) {
                    mfillColour = Graphics.COLOR_BLUE;        //! (Z2)
                    mZone[counter] = Math.round(10*(2+(testvalue-mZ2under+0.00001)/(mZ3under-mZ2under+0.00001)))/10;
                } else if (testvalue >= mZ1under) {
                    mfillColour = Graphics.COLOR_DK_GRAY;        //! (Z1)
                    mZone[counter] = 1;
                } else {
                    mfillColour = Graphics.COLOR_LT_GRAY;        //! (Z0)
                    mZone[counter] = 0;
                }
		 	  }
		   }
		}

		if (metric[counter] == 20 or metric[counter] == 21 or metric[counter] == 22 or metric[counter] == 23 or metric[counter] == 24 or metric[counter] == 37 or metric[counter] == 38) {
			Powerzone = mZone[counter];
		}
		if (metric[counter] == 45 or metric[counter] == 46 or metric[counter] == 47 or metric[counter] == 48 or metric[counter] == 49) {		
			HRzone = mZone[counter];
		}
		if (metric[counter] == 13 or metric[counter] == 14 or metric[counter] == 15) {
			if (mETA < mRacetime) {
    	    	mfillColour = Graphics.COLOR_GREEN;
        	} else {
        		mfillColour = Graphics.COLOR_RED;
        	}
        }	
		dc.setColor(mfillColour, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, w, h);
	}

	
}
