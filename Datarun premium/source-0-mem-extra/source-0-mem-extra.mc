using Toybox.System as Sys;
using Toybox.SensorHistory;
using Toybox.Lang;
using Toybox.System;
using Toybox.Application.Storage;

class ExtramemView extends DatarunpremiumView {   
	hidden var uHrZones   			        = [ 93, 111, 130, 148, 167, 185 ];	
	hidden var uPowerZones                  = "184:Z1:227:Z2:255:Z3:284:Z4:326:Z5:369";
	hidden var uPower10Zones				= "180:Z1:210:Z2:240:Z3:270:Z4:300:Z5:330:Z6:360:Z7:390:Z8:420:Z9:450:Z10:480";
	hidden var PalPowerzones 				= false;
	hidden var mZone 						= [1, 2, 3, 4, 5, 6, 7, 8];
	var uBlackBackground 					= false;    	
	var counterPace 						= 0;
	var rollingPaceValue 					= new [303];
	var totalRPa 							= 0;
	var rolavPacmaxsecs 					= 30;
	var Averagespeedinmpersec 				= 0;
	var uClockFieldMetric 					= 38; //! Powerzone is default
	var HRzone								= 0;
	hidden var Powerzone					= 0;
	var totalVertPace 						= 0;
	hidden var VertPace						= new [33];
	var AverageVertspeedinmper30sec			= 0;
	var CurrentVertSpeedinmpersec 			= 0;
	var uGarminColors 						= false;
	var Z1color 							= Graphics.COLOR_LT_GRAY;
	var Z2color 							= Graphics.COLOR_YELLOW;
	var Z3color 							= Graphics.COLOR_BLUE;
	var Z4color 							= Graphics.COLOR_GREEN;
	var Z5color 							= Graphics.COLOR_RED;
	var Z6color 							= Graphics.COLOR_PURPLE;
	var disablelabel 						= [1, 2, 3, 4, 5, 6, 7, 8];
	var maxHR								= 999;
	var kCalories							= 0;
	var mElapsedCadence   					= 0;
	var mLastLapCadenceMarker      			= 0;    
    var mCurrentCadence    					= 0; 
    var mLastLapElapsedCadence				= 0;
    var mCadenceTime						= 0;
    var mLapTimerTimeCadence				= 0;    
	var mLastLapTimeCadenceMarker			= 0;
	var mLastLapTimerTimeCadence			= 0;
	var currentCadence						= 0;
	var LapCadence							= 0;
	var LastLapCadence						= 0;
	var AverageCadence 						= 0;
	hidden var tempeTemp 					= 20;
	var utempunits							= false;
	hidden var valueDesc 					= 0;
	hidden var valueAsc 					= 0; 
	hidden var valueAsclast					= 0;
	hidden var valueDesclast				= 0;
	hidden var Diff1 						= 0;
	hidden var Diff2						= 0;
	var utempcalibration					= 0;
	var hrRest;
	var HelpVar;
	hidden var RealPowerTarget 				= 0;
	hidden var RealWorkoutStepNr 			= 0;
	hidden var RealRemainingWorkoutTime		= 0;
	hidden var DistinClockfield				= false;
	hidden var dynamics;
	hidden var groundContactBalance			= 0;
	hidden var rollgroundContactBalance		= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	hidden var AveragerollgroundContactBalance10sec= 0;
	hidden var groundContactTime			= 0;
	hidden var rollgroundContactTime		= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	hidden var AveragerollgroundContactTime10sec= 0;
	hidden var stanceTime					= 0;
	hidden var rollstanceTime				= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	hidden var AveragerollstanceTime10sec	= 0;
	hidden var stepCount					= 0;
	hidden var stepLength					= 0;
	hidden var rollstepLength				= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	hidden var AveragerollstepLength10sec	= 0;
	hidden var verticalOscillation			= 0;
	hidden var rollverticalOscillation		= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	hidden var AveragerollverticalOscillation10sec= 0;
	hidden var verticalRatio				= 0;
	hidden var rollverticalRatio			= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	hidden var AveragerollverticalRatio10sec= 0;
	hidden var startTime					   ;
	hidden var workoutTarget                   ;
	hidden var RemainingWorkoutTime  		= 0;
    hidden var RemainingWorkoutDistance		= 0;
    hidden var WorkoutStepDurationType  	= 9;
    hidden var StartTimeNewStep				= 0;
	var HR1									= 0; 
    var HR2									= 0;
    var HR3									= 0;
    var mGPScolor							= Graphics.COLOR_LT_GRAY;
    var GPSAccuracy							= "null";
    var screenWidth 						= mySettings.screenWidth;
    hidden var Vertgradsmoothed             = 0;
    var uLinecolor                          = 1;
    var mLastLapMaxHR							= 0;
	var mLastLapMinHR							= 0;
	
    function initialize() {
        DatarunpremiumView.initialize();
		var mApp 		 		= Application.getApp();
		uClockFieldMetric 		= mApp.getProperty("pClockFieldMetric");
		rolavPacmaxsecs		  	= mApp.getProperty("prolavPacmaxsecs");
		uBlackBackground    	= mApp.getProperty("pBlackBackground");
		uGarminColors			= mApp.getProperty("pGarminColors");
        uHrZones 				= UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        utempunits	 			= mApp.getProperty("ptempunits");
        disablelabel[1] 		= mApp.getProperty("pdisablelabel1");
		disablelabel[2] 		= mApp.getProperty("pdisablelabel2");
		disablelabel[3] 		= mApp.getProperty("pdisablelabel3");
		disablelabel[4] 		= mApp.getProperty("pdisablelabel4");
		disablelabel[5] 		= mApp.getProperty("pdisablelabel5");
		disablelabel[6] 		= mApp.getProperty("pdisablelabel6");
		disablelabel[7] 		= mApp.getProperty("pdisablelabel7");
		utempcalibration 		= mApp.getProperty("pTempeCalibration");
		uLinecolor              = mApp.getProperty("pLinecolor");
		
		if(Toybox.AntPlus has :RunningDynamics) {
			dynamics = new Toybox.AntPlus.RunningDynamics(null);
		}
		
		for (i = 1; i < 11; ++i) {
			rollgroundContactBalance[i] = 0;
			rollgroundContactTime[i] = 0;
			rollstanceTime[i] = 0;
			rollstepLength[i] = 0;
			rollverticalOscillation[i] = 0;
			rollverticalRatio[i] = 0;
		}
		
		var i; 
		for (i = 1; i < 33; ++i) {
			VertPace[i] = 0;
		}       
		
		var uProfile = Toybox.UserProfile.getProfile();
		hrRest = (uProfile.restingHeartRate != null) ? uProfile.restingHeartRate : 50;	
		hrRest = stringOrNumber(hrRest);
		
		//! Setup back- and foregroundcolours
		if ( uLinecolor == 0 ) {
	    	mColourLine 	 = Graphics.COLOR_GREEN;
	    } else if ( uLinecolor == 1 ) {
	    	mColourLine 	 = Graphics.COLOR_BLUE;
		} else if ( uLinecolor == 2 ) {
	    	mColourLine 	 = Graphics.COLOR_DK_GRAY;
		} else if ( uLinecolor == 3 ) {
	    	mColourLine 	 = Graphics.COLOR_WHITE;
		} else if ( uLinecolor == 4 ) {
	    	mColourLine 	 = Graphics.COLOR_PURPLE;
		} else if ( uLinecolor == 5 ) {
	    	mColourLine 	 = Graphics.COLOR_RED;
		} else if ( uLinecolor == 6 ) {
	    	mColourLine 	 = Graphics.COLOR_BLACK;
	    } else if ( uLinecolor == 7 ) {
	    	mColourLine 	 = Graphics.COLOR_DK_BLUE;
		} else if ( uLinecolor == 8 ) {
	    	mColourLine 	 = Graphics.COLOR_YELLOW;
		} else if ( uLinecolor == 9 ) {
	    	mColourLine 	 = Graphics.COLOR_ORANGE;
		}
		
		//! Setup back- and foregroundcolours
		if (mySettings.screenWidth == 416 and mySettings.screenHeight == 416 ) {
			if (uBlackBackground == true ){
				mColourFont = Graphics.COLOR_WHITE;
				mColourFont1 = Graphics.COLOR_WHITE;
				mColourBackGround = Graphics.COLOR_BLACK;
			} else {
				mColourFont = Graphics.COLOR_BLACK;
				mColourFont1 = Graphics.COLOR_BLACK;
				mColourBackGround = Graphics.COLOR_WHITE;
			}
		} else {
			if (uBlackBackground == true ){
				mColourFont = Graphics.COLOR_WHITE;
				mColourFont1 = Graphics.COLOR_WHITE;
				mColourBackGround = Graphics.COLOR_BLACK;
			} else {
				mColourFont = Graphics.COLOR_BLACK;
				mColourFont1 = Graphics.COLOR_BLACK;
				mColourBackGround = Graphics.COLOR_WHITE;
			}
        }
		
    }

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		DatarunpremiumView.onUpdate(dc);
		
		tempeTemp = (Storage.getValue("mytemp") != null) ? Storage.getValue("mytemp") : 0;		
        
        //! Paint background
        if (mySettings.screenWidth == 416 and mySettings.screenHeight == 416 ) {
			dc.setColor(mColourBackGround, Graphics.COLOR_TRANSPARENT);
			dc.fillRectangle (0, 0, 416, 416);
		} else {
			dc.setColor(mColourBackGround, Graphics.COLOR_TRANSPARENT);
			dc.fillRectangle (0, 0, 280, 280);
        }
        
        //! Calculate lap (Cadence) time
        mLapTimerTimeCadence 	= mCadenceTime - mLastLapTimeCadenceMarker;
        var mLapElapsedCadence 	= mElapsedCadence - mLastLapCadenceMarker;
		AverageCadence 			= Math.round((mCadenceTime != 0) ? mElapsedCadence/mCadenceTime : 0);  		
		LapCadence 				= (mLapTimerTimeCadence != 0) ? Math.round(mLapElapsedCadence/mLapTimerTimeCadence) : 0; 					
		LastLapCadence			= (mLastLapTimerTime != 0) ? Math.round(mLastLapElapsedCadence/mLastLapTimerTime) : 0;
       
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
 
		//! Determine required finish time and calculate required pace 	
        var mRacehour = uRacetime.substring(0, 2);
        var mRacemin = uRacetime.substring(3, 5);
        var mRacesec = uRacetime.substring(6, 8);
        mRacehour = mRacehour.toNumber();
        mRacemin = mRacemin.toNumber();
        mRacesec = mRacesec.toNumber();
        mRacetime = mRacehour*3600 + mRacemin*60 + mRacesec;
	
        //!Calculate 3 sec rolling HR
        		HR3 					= HR2;
        		HR2 					= HR1;
				HR1						= currentHR; 
		var	AverageHR3sec= (HR1+HR2+HR3)/3;
	
		var sensorIter = getIterator();
		maxHR = uHrZones[5];
		var i = 0; 
	    for (i = 1; i < 8; ++i) {
	        if (metric[i] == 17) {
	            fieldValue[i] = Averagespeedinmpersec;
    	        fieldLabel[i] = "Sp " + rolavPacmaxsecs + "s";
        	    fieldFormat[i] = "pace";  
        	} else if (metric[i] == 81) {
	        	if (Toybox.Activity.Info has :distanceToNextPoint) {
    	        	fieldValue[i] = (info.distanceToNextPoint != null) ? info.distanceToNextPoint / unitD : 0;
    	        }
        	    fieldLabel[i] = "DistNext";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 82) {
    	        if (Toybox.Activity.Info has :distanceToDestination) {
    	        	fieldValue[i] = (info.distanceToDestination != null) ? info.distanceToNextPoint / unitD : 0;
    	        }
        	    fieldLabel[i] = "DistDest";
            	fieldFormat[i] = "2decimal";
	        } else if (metric[i] == 28) {
    	        fieldValue[i] = (LapHeartrate != 0) ? mLapSpeed*60/LapHeartrate : 0;
        	    fieldLabel[i] = "Lap EF";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 29) {
    	        fieldValue[i] = (LastLapHeartrate != 0) ? mLastLapSpeed*60/LastLapHeartrate : 0;
        	    fieldLabel[i] = "LL EF";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 30) {
	            fieldValue[i] = (info.averageSpeed != null && AverageHeartrate != 0) ? info.averageSpeed*60/AverageHeartrate : 0;
    	        fieldLabel[i] = "Avg EF";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 32) {
	            fieldValue[i] = (info.currentHeartRate != null && info.currentHeartRate != 0) ? mLapSpeed*60/info.currentHeartRate : 0;
    	        fieldLabel[i] = "Cur EF";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 46) {
	            fieldValue[i] = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
    	        fieldLabel[i] = "HR zone";
        	    fieldFormat[i] = "1decimal";        	    
        	} else if (metric[i] == 54) {
    	        fieldValue[i] = (info.trainingEffect != null) ? info.trainingEffect : 0;
        	    fieldLabel[i] = "T effect";
            	fieldFormat[i] = "1decimal";           	
			} else if (metric[i] == 52) {
           		fieldValue[i] = valueAsc;
            	fieldLabel[i] = "EL gain";
            	fieldFormat[i] = "0decimal";
        	}  else if (metric[i] == 53) {
           		fieldValue[i] = valueDesc;
            	fieldLabel[i] = "EL loss";
            	fieldFormat[i] = "0decimal";           	
        	}  else if (metric[i] == 61) {
           		fieldValue[i] = (info.currentCadence != null) ? Math.round(info.currentCadence/2) : 0;
           		fieldLabel[i] = "RCadence";
            	fieldFormat[i] = "0decimal";           	
        	}  else if (metric[i] == 62) {
           		fieldValue[i] = (info.currentSpeed != null) ? 3.6*((Pace1+Pace2+Pace3)/3)*1000/unitP : 0;
            	fieldLabel[i] = "Spd 3s";
            	fieldFormat[i] = "1decimal";           	
        	}  else if (metric[i] == 63) {
           		fieldValue[i] = 3.6*Averagespeedinmpersec*1000/unitP ;
            	fieldLabel[i] = "Sp " + rolavPacmaxsecs + "s";
            	fieldFormat[i] = "1decimal";           	
        	}  else if (metric[i] == 67) {
           		fieldValue[i] = (unitD == 1609.344) ? AverageVertspeedinmper30sec*3.2808 : AverageVertspeedinmper30sec;
            	fieldLabel[i] = "V speed";
				fieldFormat[i] = "1decimal";
			} else if (metric[i] == 83) {
            	fieldValue[i] = (maxHR != 0) ? currentHR*100/maxHR : 0;
            	fieldLabel[i] = "%MaxHR";
            	fieldFormat[i] = "0decimal";   
			} else if (metric[i] == 84) {
    	        fieldValue[i] = (maxHR != 0) ? LapHeartrate*100/maxHR : 0;
        	    fieldLabel[i] = "L %MaxHR";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 85) {
        	    fieldValue[i] = (maxHR != 0) ? LastLapHeartrate*100/maxHR : 0;
            	fieldLabel[i] = "LL %MaxHR";
            	fieldFormat[i] = "0decimal";
	        } else if (metric[i] == 86) {
    	        fieldValue[i] = (maxHR != 0) ? AverageHeartrate*100/maxHR : 0;
        	    fieldLabel[i] = "A %MaxHR";
            	fieldFormat[i] = "0decimal";  
			} else if (metric[i] == 88) {   
            	if (mLastLapSpeed == null or info.currentSpeed==0) {
            		fieldValue[i] = 0;
            	} else {
            		fieldValue[i] = (mLastLapSpeed > 0.001) ? 100/mLastLapSpeed : 0;
            	}
            	fieldLabel[i] = "LL s/100m";
        	    fieldFormat[i] = "1decimal";
	        } else if (metric[i] == 87) {
    	        fieldValue[i] = (info.calories != null) ? info.calories : 0;
        	    fieldLabel[i] = "kCal";
            	fieldFormat[i] = "0decimal";
            } else if (metric[i] == 89) {
    	        fieldValue[i] = (sensorIter != null) ? sensorIter.next().data : 0;
    	        fieldValue[i] = (utempunits == false) ? fieldValue[i] : fieldValue[i]*1.8+32;
        	    fieldLabel[i] = "Temp";
            	fieldFormat[i] = "1decimal";
            } else if (metric[i] == 90) {
    	        fieldValue[i] = LapCadence;
        	    fieldLabel[i] = "Lap Cad";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 91) {
    	        fieldValue[i] = LastLapCadence;
        	    fieldLabel[i] = "LL Cad";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 92) {
	            fieldValue[i] = AverageCadence;
    	        fieldLabel[i] = "Avg Cad";
        	    fieldFormat[i] = "0decimal";
            } else if (metric[i] == 105) {
	            fieldValue[i] = tempeTemp;
	            fieldValue[i] = (utempunits == false) ? fieldValue[i]+utempcalibration : fieldValue[i]*1.8+32+utempcalibration;
    	        fieldLabel[i] = "Tempe T";
    	        fieldFormat[i] = "1decimal";
    	    } else if (metric[i] == 123) {			
				var stats = Sys.getSystemStats();
				fieldValue[i] = stats.battery;
				fieldLabel[i] = "Battery";
            	fieldFormat[i] = "0decimal";
            } else if (metric[i] == 108) {
           		fieldValue[i] = (unitD == 1609.344) ? AverageVertspeedinmper30sec*3.2808*3600 : AverageVertspeedinmper30sec*3600;
            	fieldLabel[i] = "VAM-hour";
            	fieldFormat[i] = "1decimal";
			} else if (metric[i] == 109) {			
				fieldValue[i] = AveragerollgroundContactBalance10sec;
				fieldLabel[i] = "GBalance";
            	fieldFormat[i] = "1decimal"; 
            } else if (metric[i] == 110) {			
				fieldValue[i] = AveragerollgroundContactTime10sec;
				fieldLabel[i] = "GCTime";
            	fieldFormat[i] = "0decimal";
            } else if (metric[i] == 111) {			
				fieldValue[i] = AveragerollstanceTime10sec;
				fieldLabel[i] = "StanceT%";
            	fieldFormat[i] = "1decimal";
            } else if (metric[i] == 113) {			
				fieldValue[i] = AveragerollstepLength10sec;
				fieldValue[i] = (unitD == 1609.344) ? fieldValue[i]*3.2808/1000 : fieldValue[i]/1000;
				fieldLabel[i] = "StepL";
            	fieldFormat[i] = "2decimal";
            } else if (metric[i] == 114) {			
				fieldValue[i] = AveragerollverticalOscillation10sec;
				fieldLabel[i] = "VertOsc";
            	fieldFormat[i] = "1decimal";
            } else if (metric[i] == 115) {			
				fieldValue[i] = AveragerollverticalRatio10sec;
				fieldLabel[i] = "VertRat";
            	fieldFormat[i] = "1decimal";
            } else if (metric[i] == 116) {			
				var myTime = Toybox.System.getClockTime();
				fieldValue[i] = (jTimertime == 0) ? 0 : (1+myTime.hour.toNumber()*3600 + myTime.min.toNumber()*60 + myTime.sec.toNumber()) - (startTime.hour.toNumber()*3600 + startTime.min.toNumber()*60 + startTime.sec.toNumber());
				fieldLabel[i] = "ElapsT";
            	fieldFormat[i] = "time";
			} else if (metric[i] == 125) {
            	if (jTimertime > 0) {
           			fieldValue[i] = (info.totalAscent != null) ? info.totalAscent*60/jTimertime : 0;
           			fieldValue[i] = (unitD == 1609.344) ? fieldValue[i]*3.2808 : fieldValue[i];
           		} else {
           			fieldValue[i] = 0;
           		}
            	fieldLabel[i] = "T-Asc-m";
            	fieldFormat[i] = "0decimal";
            } else if (metric[i] == 126) {
            	if (jTimertime > 0) {
           			fieldValue[i] = (info.totalAscent != null) ? info.totalAscent*3600/jTimertime : 0;
           			fieldValue[i] = (unitD == 1609.344) ? fieldValue[i]*3.2808 : fieldValue[i];
           		} else {
           			fieldValue[i] = 0;
           		}
            	fieldLabel[i] = "T-Asc-h";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 130) {
           		fieldValue[i] = AverageHR3sec;
            	fieldLabel[i] = "HR 3s";
            	fieldFormat[i] = "0decimal";
			}
		}

		//! Determine GPS accuracy
        GPSAccuracy=info.currentLocationAccuracy;
        if (GPSAccuracy == null or GPSAccuracy == 1) {
        	mGPScolor = Graphics.COLOR_LT_GRAY;
        } else if (GPSAccuracy == 2) {
        	mGPScolor = Graphics.COLOR_RED;
        } else if (GPSAccuracy == 3) {
        	mGPScolor = Graphics.COLOR_PURPLE;
        } else if (GPSAccuracy == 4) {
			mGPScolor = mColourBackGround;
		} else {
		    mGPScolor = Graphics.COLOR_LT_GRAY;
		}
		
		var CFMValue = 0;
        var CFMLabel = "error";
        var CFMFormat = "decimal";  
		//!Choice for metric in Clockfield
        	if (uClockFieldMetric == 4) {
    	        CFMValue = (info.elapsedDistance != null) ? info.elapsedDistance / unitD : 0;
            	CFMFormat = "2decimal";   
	        } else if (uClockFieldMetric == 5) {
    	        CFMValue = mLapElapsedDistance/unitD;
            	CFMFormat = "2decimal"; 
			} else if (uClockFieldMetric == 6) {
    	        CFMValue = mLastLapElapsedDistance/unitD;
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 7) {
	            CFMValue = (info.elapsedDistance != null) ? info.elapsedDistance / (mLaps * unitD) : 0;
        	    CFMFormat = "2decimal";
	        } else if (uClockFieldMetric == 8) {
   	        	CFMValue = CurrentSpeedinmpersec;
            	CFMFormat = "pace";   
	        } else if (uClockFieldMetric == 9) {
    	        CFMValue = Averagespeedinmper5sec; 
            	CFMFormat = "pace";
	        } else if (uClockFieldMetric == 16) {
    	        CFMValue = Averagespeedinmper3sec; 
            	CFMFormat = "pace";
	        } else if (uClockFieldMetric == 10) {
    	        CFMValue = mLapSpeed;
            	CFMFormat = "pace";
			} else if (uClockFieldMetric == 11) {
    	        CFMValue = mLastLapSpeed;
            	CFMFormat = "pace";
			} else if (uClockFieldMetric == 12) {
	            CFMValue = (info.averageSpeed != null) ? info.averageSpeed : 0;
        	    CFMFormat = "pace";
            } else if (uClockFieldMetric == 13) {
        		CFMFormat = "pace";
        		if (info.elapsedDistance != null and mRacetime != jTimertime and mRacetime > jTimertime) {
        			CFMValue = (uRacedistance - info.elapsedDistance) / (mRacetime - info.timerTime/1000);
        		} 
	        } else if (uClockFieldMetric == 40) {
    	        CFMValue = (info.currentSpeed != null) ? 3.6*info.currentSpeed*1000/unitP : 0;
            	CFMFormat = "1decimal";   
	        } else if (uClockFieldMetric == 41) {
    	        CFMValue = (info.currentSpeed != null) ? 3.6*((Pace1+Pace2+Pace3+Pace4+Pace5)/5)*1000/unitP : 0;
            	CFMFormat = "1decimal";
	        } else if (uClockFieldMetric == 42) {
    	        CFMValue = (mLapSpeed != null) ? 3.6*mLapSpeed*1000/unitP  : 0;
            	CFMFormat = "1decimal";
			} else if (uClockFieldMetric == 43) {
    	        CFMValue = (mLastLapSpeed != null) ? 3.6*mLastLapSpeed*1000/unitP : 0;
            	CFMFormat = "1decimal";
			} else if (uClockFieldMetric == 44) {
	            CFMValue = (info.averageSpeed != null) ? 3.6*info.averageSpeed*1000/unitP : 0;
        	    CFMFormat = "1decimal";
			} else if (uClockFieldMetric == 46) {
	            CFMValue = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
        	    CFMFormat = "1decimal";   
			} else if (uClockFieldMetric == 47) {
    	        CFMValue = LapHeartrate;
            	CFMFormat = "0decimal";
			} else if (uClockFieldMetric == 48) {
    	        CFMValue = LastLapHeartrate;
            	CFMFormat = "0decimal";
			} else if (uClockFieldMetric == 49) {
	            CFMValue = AverageHeartrate;
        	    CFMFormat = "0decimal";        	    
			} else if (uClockFieldMetric == 50) {
				CFMValue = (info.currentCadence != null) ? info.currentCadence : 0; 
        	    CFMFormat = "0decimal";
			} else if (uClockFieldMetric == 51) {
		  		CFMValue = (info.altitude != null) ? Math.round(info.altitude).toNumber() : 0;
		  		CFMValue = (unitD == 1609.344) ? CFMValue*3.2808 : CFMValue;
		       	CFMFormat = "0decimal";        		
        	} else if (uClockFieldMetric == 45) {
    	        CFMValue = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
            	CFMFormat = "0decimal";
	        } else if (uClockFieldMetric == 17) {
	            CFMValue = Averagespeedinmpersec;
        	    CFMFormat = "pace";            	
			} else if (uClockFieldMetric == 55) {   
            	CFMValue = (info.currentSpeed != null or info.currentSpeed!=0) ? 100/info.currentSpeed : 0;
            	CFMLabel = "s/100m";
	        } else if (uClockFieldMetric == 28) {
    	        CFMValue = (LapHeartrate != 0) ? mLapSpeed*60/LapHeartrate : 0;
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 29) {
    	        CFMValue = (LastLapHeartrate != 0) ? mLastLapSpeed*60/LastLapHeartrate : 0;
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 30) {
	            CFMValue = (info.averageSpeed != null && AverageHeartrate != 0) ? info.averageSpeed*60/AverageHeartrate : 0;
        	    CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 32) {
	            CFMValue = (info.currentHeartRate != null && info.currentHeartRate != 0) ? mLapSpeed*60/info.currentHeartRate : 0;
        	    CFMFormat = "2decimal";
	        } else if (uClockFieldMetric == 17) {
	            CFMValue = Averagespeedinmpersec;
        	    CFMFormat = "pace";  
        	} else if (uClockFieldMetric == 54) {
    	        CFMValue = (info.trainingEffect != null) ? info.trainingEffect : 0;
            	CFMFormat = "2decimal";           	
			} else if (uClockFieldMetric == 52) {
           		CFMValue = valueAsc;
            	CFMFormat = "0decimal";
        	}  else if (uClockFieldMetric == 53) {
           		CFMValue = valueDesc; 
            	CFMFormat = "0decimal";           	
        	}  else if (uClockFieldMetric == 61) {
           		CFMValue = (info.currentCadence != null) ? Math.round(info.currentCadence/2) : 0;
           		CFMFormat = "0decimal";           	
        	}  else if (uClockFieldMetric == 62) {
           		CFMValue = (info.currentSpeed != null) ? 3.6*((Pace1+Pace2+Pace3)/3)*1000/unitP : 0;
            	CFMFormat = "1decimal";           	
        	}  else if (uClockFieldMetric == 63) {
           		CFMValue = 3.6*Averagespeedinmpersec*1000/unitP ;
            	CFMFormat = "1decimal";           	
        	}  else if (uClockFieldMetric == 67) {
           		CFMValue = (unitD == 1609.344) ? AverageVertspeedinmper30sec*3.2808 : AverageVertspeedinmper30sec;
            	CFMFormat = "2decimal";
            } else if (uClockFieldMetric == 81) {
	        	if (Toybox.Activity.Info has :distanceToNextPoint) {
    	        	CFMValue = (info.distanceToNextPoint != null) ? info.distanceToNextPoint / unitD : 0;
    	        }
            	CFMFormat = "2decimal";
			} else if (uClockFieldMetric == 82) {
    	        if (Toybox.Activity.Info has :distanceToDestination) {
    	        	CFMValue = (info.distanceToDestination != null) ? info.distanceToNextPoint / unitD : 0;
    	        }
            	CFMFormat = "2decimal";
           	} else if (uClockFieldMetric == 83) {
            	CFMValue = (maxHR != 0) ? currentHR*100/maxHR : 0;
            	CFMFormat = "0decimal";   
			} else if (uClockFieldMetric == 84) {
    	        CFMValue = (maxHR != 0) ? LapHeartrate*100/maxHR : 0;
            	CFMFormat = "0decimal";
			} else if (uClockFieldMetric == 85) {
        	    CFMValue = (maxHR != 0) ? LastLapHeartrate*100/maxHR : 0;
            	CFMFormat = "0decimal";
	        } else if (uClockFieldMetric == 86) {
    	        CFMValue = (maxHR != 0) ? AverageHeartrate*100/maxHR : 0;
            	CFMFormat = "0decimal";  
	        } else if (uClockFieldMetric == 87) {
    	        CFMValue = (info.calories != null) ? info.calories : 0;
            	CFMFormat = "0decimal"; 
			} else if (uClockFieldMetric == 88) {   
            	if (mLastLapSpeed == null or info.currentSpeed==0) {
            		CFMValue = 0;
            	} else {
            		CFMValue = (mLastLapSpeed > 0.001) ? 100/mLastLapSpeed : 0;
            	}
        	    CFMFormat = "1decimal";
        	} else if (uClockFieldMetric == 89) {
    	        CFMValue = (sensorIter != null) ? sensorIter.next().data : 0;
    	        CFMValue = (utempunits == false) ? CFMValue : CFMValue*1.8+32;
            	CFMFormat = "1decimal";
            } else if (uClockFieldMetric == 105) {
	            CFMValue = tempeTemp;
	            CFMValue = (utempunits == false) ? CFMValue+utempcalibration : CFMValue*1.8+32+utempcalibration;
        	    CFMFormat = "1decimal";
        	} else if (uClockFieldMetric == 90) {
    	        CFMValue = LapCadence;
            	CFMFormat = "0decimal";
			} else if (uClockFieldMetric == 91) {
    	        CFMValue = LastLapCadence;
            	CFMFormat = "0decimal";
			} else if (uClockFieldMetric == 92) {
	            CFMValue = AverageCadence;
        	    CFMFormat = "0decimal";
        	} else if (uClockFieldMetric == 107) {
	            CFMValue = RealPowerTarget;
        	    CFMFormat = "power";
        	} else if (uClockFieldMetric == 121) {
	            CFMValue = RealWorkoutStepNr;
        	    CFMFormat = "0decimal";
        	} else if (uClockFieldMetric == 122) {
	            if (workoutTarget != null) {
		            if (WorkoutStepDurationType == 0) {
						CFMValue = RemainingWorkoutTime;
        	    		CFMFormat = "time";
					} else if (WorkoutStepDurationType == 1) {
						CFMValue = RemainingWorkoutDistance;
        	    		CFMFormat = "2decimal";
        	    	} else if (WorkoutStepDurationType == 5) {
						CFMValue = jTimertime-StartTimeNewStep;
        	    		CFMFormat = "time";
					} 
				}
   	    	}  else if (uClockFieldMetric == 124) {
           		CFMValue = (unitD == 1609.344) ? AverageVertspeedinmper30sec*3.2808*60 : AverageVertspeedinmper30sec*60;
            	CFMFormat = "0decimal";
   	    	}  else if (uClockFieldMetric == 108) {
           		CFMValue = (unitD == 1609.344) ? AverageVertspeedinmper30sec*3.2808*3600 : AverageVertspeedinmper30sec*3600;
            	CFMFormat = "0decimal";
            } else if (uClockFieldMetric == 125) {
	        	if (jTimertime > 0) {
    	       			CFMValue = (info.totalAscent != null) ? info.totalAscent*60/jTimertime : 0;
    	       			CFMValue = (unitD == 1609.344) ? CFMValue*3.2808 : CFMValue;
        	   		} else {
           				CFMValue = 0;
           			}
           		CFMFormat = "0decimal";
           	} else if (uClockFieldMetric == 126) {
	        	if (jTimertime > 0) {
    	       			CFMValue = (info.totalAscent != null) ? info.totalAscent*3600/jTimertime : 0;
    	       			CFMValue = (unitD == 1609.344) ? CFMValue*3.2808 : CFMValue;
        	   		} else {
           				CFMValue = 0;
           			}
           		CFMFormat = "0decimal";
            } else if (uClockFieldMetric == 109) {			
				CFMValue = AveragerollgroundContactBalance10sec;
            	CFMFormat = "1decimal"; 
            } else if (uClockFieldMetric == 110) {			
				CFMValue = AveragerollgroundContactTime10sec;
            	CFMFormat = "0decimal";
            } else if (uClockFieldMetric == 111) {			
				CFMValue = AveragerollstanceTime10sec;
            	CFMFormat = "1decimal"; 	
            } else if (uClockFieldMetric == 112) {			
				CFMValue = stepCount;
            	CFMFormat = "1decimal";
            } else if (uClockFieldMetric == 113) {			
				CFMValue = AveragerollstepLength10sec;
				CFMValue = (unitD == 1609.344) ? CFMValue*3.2808/1000 : CFMValue/1000;
            	CFMFormat = "2decimal";
            } else if (uClockFieldMetric == 114) {			
				CFMValue = AveragerollverticalOscillation10sec;
            	CFMFormat = "1decimal";
            } else if (uClockFieldMetric == 115) {			
				CFMValue = AveragerollverticalRatio10sec;
            	CFMFormat = "1decimal";
			} else if (uClockFieldMetric == 130) {
	        	CFMValue = AverageHR3sec;
    	       	CFMFormat = "0decimal";
           	} else if (uClockFieldMetric == 131) {
           		CFMValue = Vertgradsmoothed;
            	CFMFormat = "1decimal";
            } else if (uClockFieldMetric == 132) {
    	        CFMValue = mLastLapMaxHR;
            	CFMFormat = "0decimal";   
			} else if (uClockFieldMetric == 133) {
    	        CFMValue = mLastLapMinHR;
            	CFMFormat = "0decimal";
			}
		
		//! Determine HR-zone for clockfield
        if (uClockFieldMetric==46) {
			if (CFMValue >= uHrZones[5]) {
				HelpVar = 6;			
			} else if (CFMValue >= uHrZones[4]) {    	
				HelpVar = Math.round(10*(5+(CFMValue-uHrZones[4]+0.00001)/(uHrZones[5]-uHrZones[4]+0.00001)))/10;			
			} else if (CFMValue >= uHrZones[3]) {
				HelpVar = Math.round(10*(4+(CFMValue-uHrZones[3]+0.00001)/(uHrZones[4]-uHrZones[3]+0.00001)))/10;			
			} else if (CFMValue >= uHrZones[2]) {
				HelpVar = Math.round(10*(3+(CFMValue-uHrZones[2]+0.00001)/(uHrZones[3]-uHrZones[2]+0.00001)))/10;
			} else if (CFMValue >= uHrZones[1]) {
				HelpVar = Math.round(10*(2+(CFMValue-uHrZones[1]+0.00001)/(uHrZones[2]-uHrZones[1]+0.00001)))/10;
			} else if (CFMValue >= uHrZones[0]) {			
				HelpVar = Math.round(10*(1+(CFMValue-uHrZones[0]+0.00001)/(uHrZones[1]-uHrZones[0]+0.00001)))/10;
			} else {
    	        HelpVar = Math.round(10*((CFMValue-hrRest+0.00001)/(uHrZones[0]-0.00001)))/10;
			}		
			CFMValue = HelpVar;        
        }		 


		//! Display colored labels on screen	
		if (mySettings.screenWidth == 260 and mySettings.screenHeight == 260 ) {  //! Fenix 6 pro labels
			for (i = 1; i < 8; ++i) {
			   	if ( i == 1 ) {			//!upper row, left    	
	    			if (disablelabel[1] == false) {
	    				Coloring(dc,i,fieldValue[i],"018,031,110,020");
	    			}	    		
		   		} else if ( i == 2 ) {	//!upper row, right
		   			if (disablelabel[2] == false) {
		   				Coloring(dc,i,fieldValue[i],"130,031,108,020");
		   			}
		       	} else if ( i == 3 ) {  //!middle row, left
		    		if (disablelabel[3] == false) {
		    			Coloring(dc,i,fieldValue[i],"000,101,078,019");
		    		}
			   	} else if ( i == 4 ) {	//!middle row, middle
		 			if (disablelabel[4] == false) {
		 				Coloring(dc,i,fieldValue[i],"079,101,098,019");
		 			}
		      	} else if ( i == 5 ) {  //!middle row, right
		    		if (disablelabel[5] == false) {
		    			Coloring(dc,i,fieldValue[i],"179,101,083,019");
		    		}
			   	} else if ( i == 6 ) {	//!lower row, left
		   			if (disablelabel[6] == false) {
		   				Coloring(dc,i,fieldValue[i],"018,218,111,019");
		   			}
		      	} else if ( i == 7 ) {	//!lower row, right
		    		if (disablelabel[7] == false) {
		    			Coloring(dc,i,fieldValue[i],"130,218,108,019");
		    		}
	    		}       	
			}		
		} else if (mySettings.screenWidth == 280 and mySettings.screenHeight == 280 ) {     //! Fenix 6x pro labels
			for (i = 1; i < 8; ++i) {
			   	if ( i == 1 ) {			//!upper row, left    	
					if (disablelabel[1] == false) {
						Coloring(dc,i,fieldValue[i],"021,034,117,020");
					}	    
			   	} else if ( i == 2 ) {	//!upper row, right
					if (disablelabel[2] == false) {
						Coloring(dc,i,fieldValue[i],"140,034,117,020");
					}
				} else if ( i == 3 ) {  //!middle row, left		
					if (disablelabel[3] == false) {
						Coloring(dc,i,fieldValue[i],"000,108,084,020");
					}	
		   		} else if ( i == 4 ) {	//!middle row, middle
					if (disablelabel[4] == false) {
						Coloring(dc,i,fieldValue[i],"086,108,105,020");
					}
				} else if ( i == 5 ) {  //!middle row, right		
					if (disablelabel[5] == false) {
						Coloring(dc,i,fieldValue[i],"192,108,090,020");
					}	
			   	} else if ( i == 6 ) {	//!lower row, left
					if (disablelabel[6] == false) {
						Coloring(dc,i,fieldValue[i],"021,235,118,021");
					}
				} else if ( i == 7 ) {	//!lower row, right	
					if (disablelabel[7] == false) {
						Coloring(dc,i,fieldValue[i],"140,235,117,021");
					}	
	    		}        	
			}	
		} else if (mySettings.screenWidth == 416 and mySettings.screenHeight == 416 ) {     //! Epix 2labels
			for (i = 1; i < 8; ++i) {
			   	if ( i == 1 ) {			//!upper row, left    	
					if (disablelabel[1] == false) {
						Coloring(dc,i,fieldValue[i],"031,051,176,030");
					}	    
			   	} else if ( i == 2 ) {	//!upper row, right
					if (disablelabel[2] == false) {
						Coloring(dc,i,fieldValue[i],"208,051,174,030");
					}
				} else if ( i == 3 ) {  //!middle row, left		
					if (disablelabel[3] == false) {
						Coloring(dc,i,fieldValue[i],"000,160,126,030");
					}	
		   		} else if ( i == 4 ) {	//!middle row, middle
					if (disablelabel[4] == false) {
						Coloring(dc,i,fieldValue[i],"127,160,158,030");
					}
				} else if ( i == 5 ) {  //!middle row, right		
					if (disablelabel[5] == false) {
						Coloring(dc,i,fieldValue[i],"285,160,134,030");
					}	
			   	} else if ( i == 6 ) {	//!lower row, left
					if (disablelabel[6] == false) {
						Coloring(dc,i,fieldValue[i],"031,350,176,030");
					}
				} else if ( i == 7 ) {	//!lower row, right	
					if (disablelabel[7] == false) {
						Coloring(dc,i,fieldValue[i],"208,350,174,030");
					}	
	    		}        	
			}	
		} else if (mySettings.screenWidth == 218 and mySettings.screenHeight == 218 ) {     //! FR255s(m) labels
			for (i = 1; i < 8; ++i) {
			   	if ( i == 1 ) {			//!upper row, left    	
					if (disablelabel[1] == false) {
						Coloring(dc,i,fieldValue[i],"016,027,92,016");
					}	    
			   	} else if ( i == 2 ) {	//!upper row, right
					if (disablelabel[2] == false) {
						Coloring(dc,i,fieldValue[i],"109,027,92,016");
					}
				} else if ( i == 3 ) {  //!middle row, left		
					if (disablelabel[3] == false) {
						Coloring(dc,i,fieldValue[i],"000,084,066,016");
					}	
		   		} else if ( i == 4 ) {	//!middle row, middle
					if (disablelabel[4] == false) {
						Coloring(dc,i,fieldValue[i],"067,084,083,016");
					}
				} else if ( i == 5 ) {  //!middle row, right		
					if (disablelabel[5] == false) {
						Coloring(dc,i,fieldValue[i],"149,084,070,016");
					}	
			   	} else if ( i == 6 ) {	//!lower row, left
					if (disablelabel[6] == false) {
						Coloring(dc,i,fieldValue[i],"016,183,092,016");
					}
				} else if ( i == 7 ) {	//!lower row, right	
					if (disablelabel[7] == false) {
						Coloring(dc,i,fieldValue[i],"109,183,091,016");
					}	
	    		}        	
			}	
		} else {
			for (i = 1; i < 8; ++i) {
			   	if ( i == 1 ) {			//!upper row, left    	
		    		if (disablelabel[1] == false) {
		    			Coloring(dc,i,fieldValue[i],"018,029,100,019");	
		    		}    		
			   	} else if ( i == 2 ) {	//!upper row, right
		   			if (disablelabel[2] == false) {
		   				Coloring(dc,i,fieldValue[i],"120,029,100,019");
		   			}
		       	} else if ( i == 3 ) {  //!middle row, left
		    		if (disablelabel[3] == false) {
		    			Coloring(dc,i,fieldValue[i],"000,093,072,019");
		    		}
			   	} else if ( i == 4 ) {	//!middle row, middle
		 			if (disablelabel[4] == false) {
		 				Coloring(dc,i,fieldValue[i],"074,093,089,019");
		 			}
		      	} else if ( i == 5 ) {  //!middle row, right
		    		if (disablelabel[5] == false) {
		    			Coloring(dc,i,fieldValue[i],"165,093,077,019");
		    		}
			   	} else if ( i == 6 ) {	//!lower row, left
		   			if (disablelabel[6] == false) {
		   				Coloring(dc,i,fieldValue[i],"018,200,101,019");
		   			}
		      	} else if ( i == 7 ) {	//!lower row, right
		    		if (disablelabel[7] == false) {
		    			Coloring(dc,i,fieldValue[i],"120,200,100,019");
		    		}
	    		}        	
			}	
		}


		//! Show number of laps or clock with current time in top
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		if (uMilClockAltern == 2) { //! Show number of laps 
			if (mySettings.screenWidth == 260 and mySettings.screenHeight == 260) {
				 dc.drawText(113, -3, Graphics.FONT_MEDIUM, mLaps, Graphics.TEXT_JUSTIFY_CENTER);
				 dc.drawText(150, -1, Graphics.FONT_XTINY, "lap", Graphics.TEXT_JUSTIFY_CENTER);
			} else if (mySettings.screenWidth == 280 and mySettings.screenHeight == 280) {
				 dc.drawText(123, -2, Graphics.FONT_MEDIUM, mLaps, Graphics.TEXT_JUSTIFY_CENTER);
				 dc.drawText(160, -1, Graphics.FONT_XTINY, "lap", Graphics.TEXT_JUSTIFY_CENTER);		
			} else if (mySettings.screenWidth == 416 and mySettings.screenHeight == 416) {
				 dc.drawText(183, -4, Graphics.FONT_MEDIUM, mLaps, Graphics.TEXT_JUSTIFY_CENTER);
				 dc.drawText(238, 2, Graphics.FONT_XTINY, "lap", Graphics.TEXT_JUSTIFY_CENTER);		
			} else if (mySettings.screenWidth == 218 and mySettings.screenHeight == 218) {
				 dc.drawText(96, -4, Graphics.FONT_MEDIUM, mLaps, Graphics.TEXT_JUSTIFY_CENTER);
				 dc.drawText(125, 2, Graphics.FONT_XTINY, "lap", Graphics.TEXT_JUSTIFY_CENTER);
			} else {	
				 dc.drawText(103, -4, Graphics.FONT_MEDIUM, mLaps, Graphics.TEXT_JUSTIFY_CENTER);
				 dc.drawText(140, -1, Graphics.FONT_XTINY, "lap", Graphics.TEXT_JUSTIFY_CENTER);
			}
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
	    	if (mySettings.screenWidth == 260 and mySettings.screenHeight == 260) {
				dc.drawText(140, 1, Graphics.FONT_SMALL, strTime, Graphics.TEXT_JUSTIFY_CENTER);
	    	} else if (mySettings.screenWidth == 280 and mySettings.screenHeight == 280) {
				dc.drawText(150, 2, Graphics.FONT_SMALL, strTime, Graphics.TEXT_JUSTIFY_CENTER);
	    	} else if (mySettings.screenWidth == 416 and mySettings.screenHeight == 416) {
				dc.drawText(223, 4, Graphics.FONT_SMALL, strTime, Graphics.TEXT_JUSTIFY_CENTER);
	    	} else if (mySettings.screenWidth == 218 and mySettings.screenHeight == 218) {
				dc.drawText(117, 0, Graphics.FONT_SMALL, strTime, Graphics.TEXT_JUSTIFY_CENTER);
	    	} else {
				dc.drawText(130, 1, Graphics.FONT_SMALL, strTime, Graphics.TEXT_JUSTIFY_CENTER);
			}
		} else if (uMilClockAltern == 3) {		//! Display of metric in Clock field
			var originalFontcolor = mColourFont;
			var Temp;
			if ( CFMFormat.equals("0decimal" ) == true ) {
        		Temp = Math.round(CFMValue);
        		CFMValue = Temp.format("%.0f");
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
	    	if (mySettings.screenWidth == 260 and mySettings.screenHeight == 260) {
	    	   	dc.drawText(130, 14, Graphics.FONT_MEDIUM, CFMValue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	    	} else if (mySettings.screenWidth == 280 and mySettings.screenHeight == 280) {
	    	   	dc.drawText(140, 15, Graphics.FONT_MEDIUM, CFMValue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	       	} else if (mySettings.screenWidth == 416 and mySettings.screenHeight == 416) {
	    	   	dc.drawText(208, 25, Graphics.FONT_MEDIUM, CFMValue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	       	} else if (mySettings.screenWidth == 218 and mySettings.screenHeight == 218) {
	    	   	dc.drawText(109, 13, Graphics.FONT_MEDIUM, CFMValue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	       	} else {
		       	dc.drawText(120, 13, Graphics.FONT_MEDIUM, CFMValue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    	    }
    	    mColourFont = originalFontcolor;
	    	dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
	   }		
	}

	function Coloring(dc,counter,testvalue,CorString) {
		var info = Activity.getActivityInfo();
        var x = CorString.substring(0, 3);
        var y = CorString.substring(4, 7);
        var w = CorString.substring(8, 11);
        var h = CorString.substring(12, 15);
        var baseline = 0;
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
            baseline = hrRest;
            if (uGarminColors == true) {
        		Z1color = Graphics.COLOR_LT_GRAY;
        		Z2color = Graphics.COLOR_BLUE;
        		Z3color = Graphics.COLOR_GREEN;
        		Z4color = Graphics.COLOR_ORANGE;
        		Z5color = Graphics.COLOR_RED;
        		Z6color = Graphics.COLOR_PURPLE;
    	    } else {
        		Z1color = Graphics.COLOR_LT_GRAY;
        		Z2color = Graphics.COLOR_YELLOW;
        		Z3color = Graphics.COLOR_BLUE;
        		Z4color = Graphics.COLOR_GREEN;
        		Z5color = Graphics.COLOR_RED;
        		Z6color = Graphics.COLOR_PURPLE;
    		}
        } else if (metric[counter] == 50) {  //! Cadence
            mZ1under = 120;
            mZ2under = 153;
            mZ3under = 164;
            mZ4under = 174;
            mZ5under = 183;
            mZ5upper = 300; 
            if (uGarminColors == true) {
        		Z1color = Graphics.COLOR_LT_GRAY;
        		Z2color = Graphics.COLOR_RED;
        		Z3color = Graphics.COLOR_ORANGE;
        		Z4color = Graphics.COLOR_GREEN;
        		Z5color = Graphics.COLOR_BLUE;
        		Z6color = Graphics.COLOR_PURPLE;
    	    } else {
        		Z1color = Graphics.COLOR_LT_GRAY;
        		Z2color = Graphics.COLOR_YELLOW;
        		Z3color = Graphics.COLOR_BLUE;
        		Z4color = Graphics.COLOR_GREEN;
        		Z5color = Graphics.COLOR_RED;
        		Z6color = Graphics.COLOR_PURPLE;
    		}
        } else if (metric[counter] == 20 or metric[counter] == 21 or metric[counter] == 22 or metric[counter] == 23 or metric[counter] == 24 or metric[counter] == 37 or metric[counter] == 38 or metric[counter] == 70 or metric[counter] == 39 or metric[counter] == 80  or metric[counter] == 99 or metric[counter] == 100 or metric[counter] == 101 or metric[counter] == 102 or metric[counter] == 103 or metric[counter] == 104) {  //! Power=20, Powerzone=38, Pwr 5s=21, L Power=22, L-1 Pwr=23, A Power=24
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
        	if (uGarminColors == true) {
        		Z1color = Graphics.COLOR_LT_GRAY;
        		Z2color = Graphics.COLOR_BLUE;
        		Z3color = Graphics.COLOR_GREEN;
        		Z4color = Graphics.COLOR_ORANGE;
        		Z5color = Graphics.COLOR_RED;
        		Z6color = Graphics.COLOR_PURPLE;
    	    } else {
        		Z1color = Graphics.COLOR_LT_GRAY;
        		Z2color = Graphics.COLOR_YELLOW;
        		Z3color = Graphics.COLOR_BLUE;
        		Z4color = Graphics.COLOR_GREEN;
        		Z5color = Graphics.COLOR_RED;
        		Z6color = Graphics.COLOR_PURPLE;
    		}
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
            mfillColour = Z6color;
			mZone[counter] = 6;			
		} else if (testvalue >= mZ5under) {
			mfillColour = Z5color;    	
			mZone[counter] = Math.round(10*(5+(testvalue-mZ5under+0.00001)/(mZ5upper-mZ5under+0.00001)))/10;			
		} else if (testvalue >= mZ4under) {
			mfillColour = Z4color;    	
			mZone[counter] = Math.round(10*(4+(testvalue-mZ4under+0.00001)/(mZ5under-mZ4under+0.00001)))/10;			
		} else if (testvalue >= mZ3under) {
			mfillColour = Z3color;        
			mZone[counter] = Math.round(10*(3+(testvalue-mZ3under+0.00001)/(mZ4under-mZ3under+0.00001)))/10;
		} else if (testvalue >= mZ2under) {
			mfillColour = Z2color;        
			mZone[counter] = Math.round(10*(2+(testvalue-mZ2under+0.00001)/(mZ3under-mZ2under+0.00001)))/10;
		} else if (testvalue >= mZ1under) {			
			mfillColour = Z1color;        
			mZone[counter] = Math.round(10*(1+(testvalue-mZ1under+0.00001)/(mZ2under-mZ1under+0.00001)))/10;
		} else {
			mfillColour = mColourBackGround;        
            mZone[counter] = Math.round(10*((testvalue-baseline+0.00001)/(mZ1under-0.00001)))/10;
		}		

		if ( PalPowerzones == true) {
		  if (metric[counter] == 20 or metric[counter] == 21 or metric[counter] == 22 or metric[counter] == 23 or metric[counter] == 24 or metric[counter] == 37 or metric[counter] == 38  or metric[counter] == 99 or metric[counter] == 100 or metric[counter] == 101 or metric[counter] == 102 or metric[counter] == 103 or metric[counter] == 104) {  //! Power=20, Powerzone=38, Pwr 5s=21, L Power=22, L-1 Pwr=23, A Power=24		
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
                    mZone[counter] = Math.round(10*(1+(testvalue-mZ1under+0.00001)/(mZ2under-mZ1under+0.00001)))/10;
                } else {
                    mfillColour = Graphics.COLOR_LT_GRAY;        //! (Z0)
                    mZone[counter] = Math.round(10*((testvalue-baseline+0.00001)/(mZ1under-0.00001)))/10;
                }
		 	  }
		   }
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

//! Create a method to get the SensorHistoryIterator object
function getIterator() {
    //! Check device for SensorHistory compatibility
    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
        return Toybox.SensorHistory.getTemperatureHistory({});
    }
    return null;
}

function stringOrNumber(valueorcharacter) {
	if (valueorcharacter instanceof Toybox.Lang.Number) {
		//!process Number	
		return valueorcharacter;
	} else {
		//!process String	
		return 50;
	}
}
