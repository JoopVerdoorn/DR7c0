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
	var Averagespeedinmpersec 				= 0;
	var HRzone								= 0;
	hidden var Powerzone					= 0;
	var VertPace							= [1, 2, 3, 4, 5, 6];
	var uGarminColors 						= false;
	var Z1color = Graphics.COLOR_LT_GRAY;
	var Z2color = Graphics.COLOR_YELLOW;
	var Z3color = Graphics.COLOR_BLUE;
	var Z4color = Graphics.COLOR_GREEN;
	var Z5color = Graphics.COLOR_RED;
	var Z6color = Graphics.COLOR_PURPLE;
	var disablelabel 						= [1, 2, 3, 4, 5, 6, 7, 8];
	var maxHR								= 999;
	var kCalories							= 0;
	hidden var tempeTemp 					= 20;
	var utempunits							= false;
	var valueAsclast						= 0;
	var valueDesclast						= 0;
	var Diff1 								= 0;
	var Diff2 								= 0;
	var utempcalibration					= 0;
	var hrRest;
	
    function initialize() {
        DatarunpremiumView.initialize();
		var mApp 		 		= Application.getApp();
		uBlackBackground    	= mApp.getProperty("pBlackBackground");
		uGarminColors			= mApp.getProperty("pGarminColors");
        uHrZones 				= UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        utempunits	 			= mApp.getProperty("ptempunits");
        disablelabel[1] 			= mApp.getProperty("pdisablelabel1");
		disablelabel[2] 			= mApp.getProperty("pdisablelabel2");
		disablelabel[3] 			= mApp.getProperty("pdisablelabel3");
		disablelabel[4] 			= mApp.getProperty("pdisablelabel4");
		disablelabel[5] 			= mApp.getProperty("pdisablelabel5");
		disablelabel[6] 			= mApp.getProperty("pdisablelabel6");
		disablelabel[7] 			= mApp.getProperty("pdisablelabel7");
		utempcalibration 			= mApp.getProperty("pTempeCalibration");    

		var i; 
		for (i = 1; i < 6; ++i) {
			VertPace[i] = 0;
		} 
		
		var uProfile = Toybox.UserProfile.getProfile();
		hrRest = (uProfile.restingHeartRate != null) ? uProfile.restingHeartRate : 50;	
		hrRest = stringOrNumber(hrRest);
    }

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		DatarunpremiumView.onUpdate(dc);
		var info = Activity.getActivityInfo();
		tempeTemp = (Storage.getValue("mytemp") != null) ? Storage.getValue("mytemp") : 0;

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
        
       
		//! Determine required finish time and calculate required pace 	
        var mRacehour = uRacetime.substring(0, 2);
        var mRacemin = uRacetime.substring(3, 5);
        var mRacesec = uRacetime.substring(6, 8);
        mRacehour = mRacehour.toNumber();
        mRacemin = mRacemin.toNumber();
        mRacesec = mRacesec.toNumber();
        mRacetime = mRacehour*3600 + mRacemin*60 + mRacesec;
	
		//! Calculate vertical speed
		var valueDesc = (info.totalDescent != null) ? info.totalDescent : 0;
        valueDesc = (unitD == 1609.344) ? valueDesc*3.2808 : valueDesc;
        Diff1 = valueDesc - valueDesclast;
		var valueAsc = (info.totalAscent != null) ? info.totalAscent : 0;
        valueAsc = (unitD == 1609.344) ? valueAsc*3.2808 : valueAsc;
        Diff2 = valueAsc - valueAsclast;
        valueDesclast = valueDesc;
        valueAsclast = valueAsc;
        var CurrentVertSpeedinmpersec = Diff2-Diff1;
		VertPace[5] 								= VertPace[4];
		VertPace[4] 								= VertPace[3];
		VertPace[3] 								= VertPace[2];
        VertPace[2] 								= VertPace[1];
        VertPace[1]								= CurrentVertSpeedinmpersec; 
		var AverageVertspeedinmper5sec= (VertPace[1]+VertPace[2]+VertPace[3]+VertPace[4]+VertPace[5])/5;       
		
		var sensorIter = getIterator();
		maxHR = uHrZones[5];
		var i = 0; 
	    for (i = 1; i < 8; ++i) {
	        if (metric[i] == 46) {
	            fieldValue[i] = (info.currentHeartRate != null) ? info.currentHeartRate : 0;
    	        fieldLabel[i] = "HR zone";
        	    fieldFormat[i] = "1decimal";      
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
        	} else if (metric[i] == 54) {
    	        fieldValue[i] = (info.trainingEffect != null) ? info.trainingEffect : 0;
        	    fieldLabel[i] = "T effect";
            	fieldFormat[i] = "2decimal";           	         	         	
			} else if (metric[i] == 52) {
           		fieldValue[i] = valueAsc;
            	fieldLabel[i] = "EL gain";
            	fieldFormat[i] = "0decimal";
        	}  else if (metric[i] == 53) {
           		fieldValue[i] = valueDesc;
            	fieldLabel[i] = "EL loss";
            	fieldFormat[i] = "0decimal";   
        	}  else if (metric[i] == 62) {
           		fieldValue[i] = (info.currentSpeed != null) ? 3.6*((Pace1+Pace2+Pace3)/3)*1000/unitP : 0;
            	fieldLabel[i] = "Spd 3s";
            	fieldFormat[i] = "2decimal";           	
        	}  else if (metric[i] == 63) {
           		fieldValue[i] = 3.6*Averagespeedinmpersec*1000/unitP ;
            	fieldLabel[i] = "Spd ..s";
            	fieldFormat[i] = "2decimal";           	
        	}  else if (metric[i] == 67) {
           		fieldValue[i] = (unitD == 1609.344) ? AverageVertspeedinmper5sec*3.2808 : AverageVertspeedinmper5sec;
            	fieldLabel[i] = "V speed";
            	fieldFormat[i] = "1decimal";  
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
            } else if (metric[i] == 105) {
	            fieldValue[i] = tempeTemp;
	            fieldValue[i] = (utempunits == false) ? fieldValue[i]+utempcalibration : fieldValue[i]*1.8+32+utempcalibration;
    	        fieldLabel[i] = "Tempe T";
    	        fieldFormat[i] = "1decimal";
			} 
		}

		var CFMValue = 0;
        var CFMLabel = "error";
        var CFMFormat = "decimal";  
		 

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
		   				Coloring(dc,i,fieldValue[i],"018,199,100,019");
		   			}
		      	} else if ( i == 7 ) {	//!lower row, right
		    		if (disablelabel[7] == false) {
		    			Coloring(dc,i,fieldValue[i],"120,199,100,019");
		    		}
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
		} 
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
