using Toybox.Math;
using Toybox.WatchUi as Ui;
class CiqView extends ExtramemView {  
	var mfillColour 						= Graphics.COLOR_LT_GRAY;
	var counterPower 						= 0;
	var rollingPwrValue 					= new [303];
	var totalRPw 							= 0;
	var rolavPowmaxsecs 					= 30;
	var Averagepowerpersec 					= 0;
	var uBlackBackground 					= false;
	var uFTP								= 250;    
	var uCP									= 250;
	var RSS									= 0;
	hidden var FilteredCurPower				= 0;
	var sum4thPowers						= 0;
	var fourthPowercounter 					= 0;
	var mIntensityFactor					= 0;
	var mTTS								= 0;
	var i 									= 0;
	var runPower							= 0;
	var lastsrunPower						= 0;
	var setPowerWarning 					= 0;
	var Garminfont = Ui.loadResource(Rez.Fonts.Garmin1);
	var Power1 									= 0;
    var Power2 									= 0;
    var Power3 									= 0;	
	var Power4 									= 0;
    var Power5 									= 0;
    var Power6 									= 0;
	var Power7 									= 0;
    var Power8 									= 0;
    var Power9 									= 0;
    var Power10									= 0;
    var uWeight								= 70;
		
    function initialize() {
        ExtramemView.initialize();
		var mApp 		 = Application.getApp();
		rolavPowmaxsecs	 = mApp.getProperty("prolavPowmaxsecs");	
		uPowerZones		 = mApp.getProperty("pPowerZones");	
		PalPowerzones 	 = mApp.getProperty("p10Powerzones");
		uPower10Zones	 = mApp.getProperty("pPPPowerZones");
		uFTP		 	 = mApp.getProperty("pFTP");
		uCP		 	 	 = mApp.getProperty("pCP");
		uWeight			 = mApp.getProperty("pWeight");
		i = 0; 
	    for (i = 1; i < 8; ++i) {		
			if (metric[i] == 57 or metric[i] == 58 or metric[i] == 59) {
				rolavPowmaxsecs = (rolavPowmaxsecs < 30) ? 30 : rolavPowmaxsecs;
			}
		}	
		if (ID0 == 3588 or ID0 == 3832 or ID0 == 3624 or ID0 == 3952 or ID0 == 3762 or ID0 == 3962 or ID0 == 3761 or ID0 == 3961 or ID0 == 3757 or ID0 == 3931 or ID0 == 3758 or ID0 == 3932 or ID0 == 3759 or ID0 == 3959 or ID0 == 3798 or ID0 == 4023 or ID0 == 3799 or ID0 == 4024) {
			Garminfont = Ui.loadResource(Rez.Fonts.Garmin1);		
		} else if (ID0 == 3801 or ID0 == 4026 ) {
			Garminfont = Ui.loadResource(Rez.Fonts.Garmin2);
		} else if (ID0 == 3802 or ID0 == 4027 ) {
			Garminfont = Ui.loadResource(Rez.Fonts.Garmin3);
		}	
    }


    //! Calculations we need to do every second even when the data field is not visible
    function compute(info) {
        //! If enabled, switch the backlight on in order to make it stay on
        if (uBacklight) {
             Attention.backlight(true);
        }
		//! We only do some calculations if the timer is running
		if (mTimerRunning) {  
			jTimertime 		 = jTimertime + 1;
			//!Calculate lapheartrate
            mHeartrateTime	 = (info.currentHeartRate != null) ? mHeartrateTime+1 : mHeartrateTime;				
           	mElapsedHeartrate= (info.currentHeartRate != null) ? mElapsedHeartrate + info.currentHeartRate : mElapsedHeartrate;
            //!Calculate lappower
            mPowerTime		 = (info.currentPower != null) ? mPowerTime+1 : mPowerTime; 		
            runPower 		 = (info.currentPower != null) ? info.currentPower : 0;
			mElapsedPower    = mElapsedPower + runPower;
			lastsrunPower 	 = runPower;
			RSS 			 = (info.currentPower != null) ? RSS + 0.03 * Math.pow(((runPower+0.001)/uCP),3.5) : RSS; 			             
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

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		ExtramemView.onUpdate(dc);
        		
		//!Calculate HR-metrics
		var info = Activity.getActivityInfo();
		
		var CurrentEfficiencyIndex   	= (info.currentPower != null && info.currentPower != 0) ? Averagespeedinmper3sec*60/info.currentPower : 0;
		var AverageEfficiencyIndex   	= (info.averageSpeed != null && AveragePower != 0) ? info.averageSpeed*60/AveragePower : 0;
		var LapEfficiencyIndex   		= (LapPower != 0) ? mLapSpeed*60/LapPower : 0;  
		var LastLapEfficiencyIndex   	= (LastLapPower != 0) ? mLastLapSpeed*60/LastLapPower : 0;  

		var CurrentPower2HRRatio 		= 0.00; 				
		if (info.currentPower != null && info.currentHeartRate != null && info.currentHeartRate != 0) {
			CurrentPower2HRRatio 		= (0.00001 + info.currentPower)/info.currentHeartRate;
		}
		var AveragePower2HRRatio 		= 0.00;
		if (AverageHeartrate != 0) {
			AveragePower2HRRatio 		= (AveragePower+0.00001)/AverageHeartrate;
		}
		var LapPower2HRRatio 			= 0.00;
		if (LapHeartrate != 0) {
			LapPower2HRRatio 			= (0.00001 + LapPower) / LapHeartrate;
		}
		var LastLapPower2HRRatio 		= 0.00;
		if (LastLapHeartrate != 0) {
			LastLapPower2HRRatio 		= (0.00001 + LastLapPower) / LastLapHeartrate;
		}			

		//!Calculate 10sec averaged power
        var AveragePower5sec  	 			= 0;
        var AveragePower10sec  	 			= 0;
        var currentPowertest				= 0;
		if (info.currentSpeed != null && info.currentPower != null) {
        	currentPowertest = info.currentPower; 
        }
        if (currentPowertest > 0) {
            if (currentPowertest > 0) {
				if (info.currentPower != null) {
        			Power1								= info.currentPower; 
        		} else {
        			Power1								= 0;
				}
        		Power10 							= Power9;
        		Power9 								= Power8;
        		Power8 								= Power7;
        		Power7 								= Power6;
        		Power6 								= Power5;
        		Power5 								= Power4;
        		Power4 								= Power3;
        		Power3 								= Power2;
        		Power2 								= Power1;
				AveragePower10sec	= (Power1+Power2+Power3+Power4+Power5+Power6+Power7+Power8+Power9+Power10)/10;
				AveragePower5sec	= (Power1+Power2+Power3+Power4+Power5)/5;
				AveragePower3sec	= (Power1+Power2+Power3)/3;
			}
 		}

		//! Calculation of rolling average of power 
		var zeroValueSecs = 0;
		if (counterPower < 1) {
			for (var i = 1; i < rolavPowmaxsecs+2; ++i) {
				rollingPwrValue [i] = 0; 
			}
		}
		counterPower = counterPower + 1;
		rollingPwrValue [rolavPowmaxsecs+1] = (info.currentPower != null) ? info.currentPower : 0;
		FilteredCurPower = rollingPwrValue [rolavPowmaxsecs+1]; 
		for (var i = 1; i < rolavPowmaxsecs+1; ++i) {
			rollingPwrValue[i] = rollingPwrValue[i+1];
		}
		for (var i = 1; i < rolavPowmaxsecs+1; ++i) {
			totalRPw = rollingPwrValue[i] + totalRPw;
		
			if (mPowerTime < rolavPowmaxsecs) {
				zeroValueSecs = (rollingPwrValue[i] != 0) ? zeroValueSecs : zeroValueSecs + 1;
			}
		}
		if (rolavPowmaxsecs-zeroValueSecs == 0) {
			Averagepowerpersec = 0;
		} else {
			Averagepowerpersec = (mPowerTime < rolavPowmaxsecs) ? totalRPw/(rolavPowmaxsecs-zeroValueSecs) : totalRPw/rolavPowmaxsecs;
		}
		totalRPw = 0;       

		//!Calculate normalized power
		var mNormalizedPow = 0;
		var rollingPwr30s = 0;
		var j = 0; 		
	    for (j = 1; j < 8; ++j) {
			if (metric[j] == 57 or metric[j] == 58 or metric[j] == 59) {

				if (jTimertime > 30) {
					for (var i = 1; i < 31; ++i) {
						rollingPwr30s = rollingPwr30s + rollingPwrValue [rolavPowmaxsecs+2-i];
					}
					rollingPwr30s = rollingPwr30s/30;
					if (mTimerRunning == true) {
						sum4thPowers = sum4thPowers + Math.pow(rollingPwr30s,4);
						fourthPowercounter = fourthPowercounter + 1; 
					}
				mNormalizedPow = Math.round(Math.pow(sum4thPowers/fourthPowercounter,0.25));				
				}
			}
		}		


		//! Calculate IF and TTS
		mIntensityFactor = (uFTP != 0) ? mNormalizedPow / uFTP : 0;
		mTTS = (uFTP != 0) ? (jTimertime * mNormalizedPow * mIntensityFactor)/(uFTP * 3600) * 100 : 999;

		
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		var Actualpower = (info.currentPower != null) ? info.currentPower : 0;
		
		i = 0; 
	    for (i = 1; i < 8; ++i) {
	        if (metric[i] == 38) {
    	        fieldValue[i] =  (info.currentPower != null) ? info.currentPower : 0;     	        
        	    fieldLabel[i] = "Cur Pzone";
            	fieldFormat[i] = "1decimal";
            } else if (metric[i] == 99) {
    	        fieldValue[i] =  AveragePower3sec;     	        
        	    fieldLabel[i] = "3s P zone";
            	fieldFormat[i] = "1decimal";
            } else if (metric[i] == 100) {
    	        fieldValue[i] =  AveragePower5sec;     	        
        	    fieldLabel[i] = "5s P zone";
            	fieldFormat[i] = "1decimal"; 
            } else if (metric[i] == 101) {
    	        fieldValue[i] =  AveragePower10sec;     	        
        	    fieldLabel[i] = "10s P zone";
            	fieldFormat[i] = "1decimal";  
            } else if (metric[i] == 102) {
    	        fieldValue[i] =  LapPower;     	        
        	    fieldLabel[i] = "Lap Pzone";
            	fieldFormat[i] = "1decimal";  
            } else if (metric[i] == 103) {
    	        fieldValue[i] =  LastLapPower;     	        
        	    fieldLabel[i] = "LL Pzone";
            	fieldFormat[i] = "1decimal";
            } else if (metric[i] == 104) {
    	        fieldValue[i] =  AveragePower;     	        
        	    fieldLabel[i] = "Av Pzone";
            	fieldFormat[i] = "1decimal";           	
			} else if (metric[i] == 17) {
	            fieldValue[i] = Averagespeedinmpersec;
    	        fieldLabel[i] = "Pc ..sec";
        	    fieldFormat[i] = "pace";            	
			} else if (metric[i] == 55) {   
            	if (info.currentSpeed == null or info.currentSpeed==0) {
            		fieldValue[i] = 0;
            	} else {
            		fieldValue[i] = (info.currentSpeed > 0.001) ? 100/info.currentSpeed : 0;
            	}
            	fieldLabel[i] = "s/100m";
        	    fieldFormat[i] = "1decimal";
        	} else if (metric[i] == 25) {
    	        fieldValue[i] = LapEfficiencyIndex;
        	    fieldLabel[i] = "Lap EI";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 26) {
    	        fieldValue[i] = LastLapEfficiencyIndex;
        	    fieldLabel[i] = "LL EI";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 27) {
	            fieldValue[i] = AverageEfficiencyIndex;
    	        fieldLabel[i] = "Avg EI";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 31) {
	            fieldValue[i] = CurrentEfficiencyIndex;
    	        fieldLabel[i] = "Cur EI";
        	    fieldFormat[i] = "2decimal";
	        } else if (metric[i] == 33) {
    	        fieldValue[i] = LapPower2HRRatio;
        	    fieldLabel[i] = "L P2HR";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 34) {
    	        fieldValue[i] = LastLapPower2HRRatio;   	        
        	    fieldLabel[i] = "LL P2HR";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 35) {
	            fieldValue[i] = AveragePower2HRRatio;
    	        fieldLabel[i] = "A  P2HR";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 36) {
	            fieldValue[i] = CurrentPower2HRRatio;
    	        fieldLabel[i] = "C P2HR";
        	    fieldFormat[i] = "2decimal";
        	} else if (metric[i] == 70) {
    	        fieldValue[i] = AveragePower5sec;
        	    fieldLabel[i] = "Pwr 5s";
            	fieldFormat[i] = "power";
			} else if (metric[i] == 39) {
    	        fieldValue[i] = AveragePower10sec;
        	    fieldLabel[i] = "Pwr 10s";
            	fieldFormat[i] = "power";
			} else if (metric[i] == 37) {
	            fieldValue[i] = Averagepowerpersec;
    	        fieldLabel[i] = "Pw ..sec";
        	    fieldFormat[i] = "power";
			} else if (metric[i] == 57) {
	            fieldValue[i] = mNormalizedPow;
    	        fieldLabel[i] = "N Power";
        	    fieldFormat[i] = "0decimal";
	        } else if (metric[i] == 80) {
    	        fieldValue[i] = (info.maxPower != null) ? info.maxPower : 0;
        	    fieldLabel[i] = "Max Pwr";
            	fieldFormat[i] = "power";  
			} else if (metric[i] == 71) {
            	fieldValue[i] = (uFTP != 0) ? Actualpower*100/uFTP : 0;
            	fieldLabel[i] = "%FTP";
            	fieldFormat[i] = "power";   
	        } else if (metric[i] == 72) {
    	        fieldValue[i] = (uFTP != 0) ? AveragePower3sec*100/uFTP : 0;
        	    fieldLabel[i] = "%FTP 3s";
            	fieldFormat[i] = "power";     	
			} else if (metric[i] == 73) {
    	        fieldValue[i] = (uFTP != 0) ? LapPower*100/uFTP : 0;
        	    fieldLabel[i] = "L %FTP";
            	fieldFormat[i] = "power";
			} else if (metric[i] == 74) {
        	    fieldValue[i] = (uFTP != 0) ? LastLapPower*100/uFTP : 0;
            	fieldLabel[i] = "LL %FTP";
            	fieldFormat[i] = "power";
	        } else if (metric[i] == 75) {
    	        fieldValue[i] = (uFTP != 0) ? AveragePower*100/uFTP : 0;
        	    fieldLabel[i] = "A %FTP";
            	fieldFormat[i] = "power";  
	        } else if (metric[i] == 76) {
    	        fieldValue[i] = (uFTP != 0) ? AveragePower5sec*100/uFTP : 0;
        	    fieldLabel[i] = "%FTP 5s";
            	fieldFormat[i] = "power";
			} else if (metric[i] == 77) {
    	        fieldValue[i] = (uFTP != 0) ? AveragePower10sec*100/uFTP : 0;
        	    fieldLabel[i] = "%FTP 10s";
            	fieldFormat[i] = "power";
			} else if (metric[i] == 78) {
	            fieldValue[i] = (uFTP != 0) ? Averagepowerpersec*100/uFTP : 0;
    	        fieldLabel[i] = "%FTP ..sec";
        	    fieldFormat[i] = "power";
			} else if (metric[i] == 58) {
	            fieldValue[i] = mIntensityFactor;
    	        fieldLabel[i] = "IF";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 59) {
	            fieldValue[i] = mTTS;
    	        fieldLabel[i] = "TTS";
        	    fieldFormat[i] = "0decimal";
			} else if (metric[i] == 60) {
	            fieldValue[i] = RSS;
    	        fieldLabel[i] = "RSS";
        	    fieldFormat[i] = "0decimal";
        	} else if (metric[i] == 93) {
				if (info.currentPower != null and info.currentPower != 0) {
            		fieldValue[i] = CurrentSpeedinmpersec*uWeight/info.currentPower;
            	} else {
            		fieldValue[i] = 0;
            	}
            	fieldLabel[i] = "RE cur";
            	fieldFormat[i] = "2decimal";   
			} else if (metric[i] == 94) {
				if (AveragePower3sec != 0) {
            		fieldValue[i] = Averagespeedinmper3sec*uWeight/AveragePower3sec;
            	} else {
            		fieldValue[i] = 0;
            	}
            	fieldLabel[i] = "RE 3sec";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 95) {
				if (AveragePower5sec != 0) {
            		fieldValue[i] = Averagespeedinmper5sec*uWeight/AveragePower5sec;
            	} else {
            		fieldValue[i] = 0;
            	}
            	fieldLabel[i] = "RE 5sec";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 96) {
				if (LapPower != 0) {
            		fieldValue[i] = mLapSpeed*uWeight/LapPower;
            	} else {
            		fieldValue[i] = 0;
            	}
            	fieldLabel[i] = "RE lap";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 98) {
				if (AveragePower != 0) {
            		fieldValue[i] = info.averageSpeed*uWeight/AveragePower;
            	} else {
            		fieldValue[i] = 0;
            	}
            	fieldLabel[i] = "RE Aver";
            	fieldFormat[i] = "2decimal";
        	} 
        	//!einde invullen field metrics
		}
		//! Conditions for showing the demoscreen       
        if (uShowDemo == false) {
        	if (licenseOK == false && jTimertime > 900)  {
        		uShowDemo = true;        		
        	}
        }

	   //! Check whether demoscreen is showed or the metrics 
	   if (uShowDemo == false ) {

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
        	PowerWarning = (setPowerWarning == 1) ? 1 : PowerWarning;    	
        	PowerWarning = (setPowerWarning == 2) ? 2 : PowerWarning;
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
       			dc.drawText(xx, y, Garminfont, fTimer, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        	}
        } else {
       		dc.drawText(x, y, Garminfont, fieldvalue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
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
