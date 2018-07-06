class ExtramemView extends DatarunpremiumView {
	var mfillColour 						= Graphics.COLOR_LT_GRAY;
	hidden var mETA							= 0;
	hidden var uETAfromLap 					= true;

    function initialize() {
        DatarunpremiumView.initialize();
        extraMem 		 = true;
		var mApp 		 = Application.getApp();
		uETAfromLap		 = mApp.getProperty("pETAfromLap");
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

		var info = Activity.getActivityInfo();
		var CurrentEfficiencyIndex   	= (info.currentPower != null && info.currentPower != 0) ? Averagespeedinmpersec*60/info.currentPower : 0;
		var AverageEfficiencyIndex   	= (info.averageSpeed != null && AveragePower != 0) ? info.averageSpeed*60/AveragePower : 0;
		var LapEfficiencyIndex   		= (LapPower != 0) ? mLapSpeed*60/LapPower : 0;  
		var LastLapEfficiencyIndex   	= (LastLapPower != 0) ? mLastLapSpeed*60/LastLapPower : 0;  
		var CurrentEfficiencyFactor		= (info.currentHeartRate != null && info.currentHeartRate != 0) ? mLapSpeed*60/info.currentHeartRate : 0;
		var AverageEfficiencyFactor   	= (info.averageSpeed != null && AverageHeartrate != 0) ? info.averageSpeed*60/AverageHeartrate : 0; 
		var LapEfficiencyFactor   		= (LapHeartrate != 0) ? mLapSpeed*60/LapHeartrate : 0;
		var LastLapEfficiencyFactor   	= (LastLapHeartrate != 0) ? mLastLapSpeed*60/LastLapHeartrate : 0;

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

		//! Determine required finish time and calculate required pace 	

        var mRacehour = uRacetime.substring(0, 2);
        var mRacemin = uRacetime.substring(3, 5);
        var mRacesec = uRacetime.substring(6, 8);
        mRacehour = mRacehour.toNumber();
        mRacemin = mRacemin.toNumber();
        mRacesec = mRacesec.toNumber();
        mRacetime = mRacehour*3600 + mRacemin*60 + mRacesec;
      
        var i = 0; 
	    for (i = 1; i < 8; ++i) {
	        if (metric[i] == 37) {
    	        fieldValue[i] = 0; //! becomes Power zone later
        	    fieldLabel[i] = "P zone";
            	fieldFormat[i] = "0decimal";
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
			} else if (metric[i] == 31) {
	            fieldValue[i] = CurrentEfficiencyIndex;
    	        fieldLabel[i] = "Cur EI";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 32) {
	            fieldValue[i] = CurrentEfficiencyFactor;
    	        fieldLabel[i] = "Cur EF";
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
        	}  else if (metric[i] == 52) {
           		fieldValue[i] = mElevationGain;
            	fieldLabel[i] = "EL gain";
            	fieldFormat[i] = "0decimal";
        	}  else if (metric[i] == 53) {
           		fieldValue[i] = mElevationLoss;
            	fieldLabel[i] = "EL loss";
            	fieldFormat[i] = "0decimal";
	        } else if (metric[i] == 14) {
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
				//! Conditions for showing the demoscreen       
        if (uShowDemo == false) {
        	if (umyNumber != mtest && jTimertime > 900)  {
        		uShowDemo = true;        		
        	}
        }

	   //! Check whether demoscreen is showed or the metrics 
	   if (uShowDemo == false ) {

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
            mZ1under = uHrZones[1];
            mZ2under = uHrZones[2];
            mZ3under = uHrZones[3];
            mZ4under = uHrZones[4];
            mZ5under = uHrZones[5];
            mZ5upper = 200; 
        } else if (metric[counter] == 50) {  //! Cadence
            mZ1under = 120;
            mZ2under = 153;
            mZ3under = 164;
            mZ4under = 174;
            mZ5under = 183;
            mZ5upper = 300; 
        } else if (metric[counter] == 20 or metric[counter] == 21 or metric[counter] == 22 or metric[counter] == 23 or metric[counter] == 24) {  //! Power=20, Pwr 5s=21, L Power=22, L-1 Pwr=23, A Power=24
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
			mZone[counter] = 5;
		} else if (testvalue >= mZ4under) {
			mfillColour = Graphics.COLOR_GREEN;    	
			mZone[counter] = 4;
		} else if (testvalue >= mZ3under) {
			mfillColour = Graphics.COLOR_BLUE;        
			mZone[counter] = 3;
		} else if (testvalue >= mZ2under) {
			mfillColour = Graphics.COLOR_YELLOW;        
			mZone[counter] = 2;
		} else if (testvalue >= mZ1under) {
			mfillColour = Graphics.COLOR_LT_GRAY;        
			mZone[counter] = 1;
		} else {
			mfillColour = mColourBackGround;        
            mZone[counter] = 0;
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