using Toybox.Math;
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
	var uWorkoutType						= 0;
	var uWorkoutAzones						= "100-190 ; 240-260 ; 100-190 ; 260-280 ; 100-190 ; 280-300 ; 100-190 ; 300-320 ; 100-190 ; 320-340 ; 3100-190 ; 00-320 ; 100-190 ; 280-300 ; 100-190 ; 260-280 ; 100-190 ; 100-150";
	var uWorkoutRzones						= "0300s100-190 ; 8x(0120s240-260 ; 0060s190-210) ; 0900s100-190";
	var uWorkoutrepeats						= 8;
	var repeats								= 8;
	var uWorkoutzones						= "0300s100-190 ; 0800d240-260 ; 0100d100-190 ; 0800d260-280 ; 0100d100-190 ; 0800d280-300 ; 0100d100-190 ; 0800d300-320 ; 0100d100-190 ; 0800d320-340 ; 0100d100-190 ; 0800d300-320 ; 0100d100-190 ; 0800d280-300 ; 0100d100-190 ; 0800d260-280 ; 0100d100-190 ; 0300s100-190";
	var mWorkoutAmount						= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
	var mWorkoutType						= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
	var mWorkoutLzone						= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
	var mWorkoutHzone						= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
	var mWorkoutstepNumber					= 1;
	var nextAlertD							= 0;
	var nextAlertT							= 0;
	var nextAlertType						= "t";
	var workoutUnit							= "sec";
	var i 									= 0;
	var hideText 							= false;
	var jDistance 							= 0;
	var uspikeTreshold						= 2000;
	var runPower							= 0;
	var lastsrunPower						= 0;
	var sethideText 						= false;
	var setPowerWarning 					= 0;
		
    function initialize() {
        ExtramemView.initialize();
		var mApp 		 = Application.getApp();
		rolavPowmaxsecs	 = mApp.getProperty("prolavPowmaxsecs");	
		uPowerZones		 = mApp.getProperty("pPowerZones");	
		PalPowerzones 	 = mApp.getProperty("p10Powerzones");
		uPower10Zones	 = mApp.getProperty("pPPPowerZones");
		uFTP		 	 = mApp.getProperty("pFTP");
		uCP		 	 	 = mApp.getProperty("pCP");
		uWorkoutType	 = mApp.getProperty("pWorkoutType");
		uWorkoutAzones	 = mApp.getProperty("pWorkoutAzones");
		uWorkoutRzones	 = mApp.getProperty("pWorkoutRzones");
		uWorkoutzones	 = mApp.getProperty("pWorkoutzones");
		uspikeTreshold	 = mApp.getProperty("pspikeTreshold");
		i = 0; 
	    for (i = 1; i < 8; ++i) {		
			if (metric[i] == 57 or metric[i] == 58 or metric[i] == 59) {
				rolavPowmaxsecs = (rolavPowmaxsecs < 30) ? 30 : rolavPowmaxsecs;
			}
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
//!temporary solution for power spikes > spikeTreshold Watt 		
            runPower 		 = (info.currentPower != null) ? info.currentPower : 0;
            runPower 		 = (runPower > uspikeTreshold) ? lastsrunPower : runPower;
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
		Workoutstepalert();
	}

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		ExtramemView.onUpdate(dc);
        		
		//!Calculate HR-metrics
		var info = Activity.getActivityInfo();

		jDistance = (info.elapsedDistance != null) ? info.elapsedDistance : 0;
		
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

		//! Calculation of rolling average of power 
		var zeroValueSecs = 0;
		if (counterPower < 1) {
			for (var i = 1; i < rolavPowmaxsecs+2; ++i) {
				rollingPwrValue [i] = 0; 
			}
		}
		counterPower = counterPower + 1;
		rollingPwrValue [rolavPowmaxsecs+1] = (info.currentPower != null) ? info.currentPower : 0;
//!temporary solution for power spikes > spikeTreshold Wat 		
		rollingPwrValue [rolavPowmaxsecs+1] = (rollingPwrValue [rolavPowmaxsecs+1] > uspikeTreshold) ? rollingPwrValue [rolavPowmaxsecs] : rollingPwrValue [rolavPowmaxsecs+1];
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
		mTTS = (jTimertime * mNormalizedPow * mIntensityFactor)/(uFTP * 3600) * 100;

		//!Workout variables setup
		if (uWorkoutType == 1) { 					//! Set up alerts for Connect workout 
			i = 0; 
	    	for (i = 1; i < 19; ++i) {			
				mWorkoutLzone[i]	= uWorkoutAzones.substring(0+(i-1)*10, 3+(i-1)*10);
				mWorkoutHzone[i]	= uWorkoutAzones.substring(4+(i-1)*10, 7+(i-1)*10);
			}		
		} else if (uWorkoutType == 2) { 			//! Set up powerbased workout repeats
			uWorkoutrepeats		= uWorkoutRzones.substring(15, 16);
		    mWorkoutAmount[1]	= uWorkoutRzones.substring(0, 4);
		    mWorkoutType[1]		= uWorkoutRzones.substring(4, 5);
		    mWorkoutLzone[1]	= uWorkoutRzones.substring(5, 8);
		    mWorkoutHzone[1]	= uWorkoutRzones.substring(9, 12);
			repeats		= 2*uWorkoutrepeats.toNumber();
			i = 0; 
	    	for (i = 2; i < repeats+2; ++i) {			
				if (i % 2 == 0) { 
					mWorkoutAmount[i]	= uWorkoutRzones.substring(18, 22);					
			    	mWorkoutType[i]		= uWorkoutRzones.substring(22, 23);			    	
			    	mWorkoutLzone[i]	= uWorkoutRzones.substring(23, 26);			    	
		    		mWorkoutHzone[i]	= uWorkoutRzones.substring(27, 30);		    		
		    	} else {
		    		mWorkoutAmount[i]	= uWorkoutRzones.substring(33, 37);		    		
			    	mWorkoutType[i]		= uWorkoutRzones.substring(37, 38);			    	
			    	mWorkoutLzone[i]	= uWorkoutRzones.substring(38, 41);			    
		    		mWorkoutHzone[i]	= uWorkoutRzones.substring(42, 45);		    		
				}
		    mWorkoutAmount[18]	= uWorkoutRzones.substring(49, 53);
		    mWorkoutType[18]	= uWorkoutRzones.substring(53, 54);
		    mWorkoutLzone[18]	= uWorkoutRzones.substring(54, 57);
		    mWorkoutHzone[18]	= uWorkoutRzones.substring(58, 61);
			}
		} else if (uWorkoutType == 3) { 			//! Set up powerbased workout non-repeats
			i = 0; 
	    	for (i = 1; i < 19; ++i) {			
		    	mWorkoutAmount[i]	= uWorkoutzones.substring(0+(i-1)*15, 4+(i-1)*15);		    	
		    	mWorkoutType[i]		= uWorkoutzones.substring(4+(i-1)*15, 5+(i-1)*15);		    	
				mWorkoutLzone[i]	= uWorkoutzones.substring(5+(i-1)*15, 8+(i-1)*15);				
				mWorkoutHzone[i]	= uWorkoutzones.substring(9+(i-1)*15, 12+(i-1)*15);
			}		
		}


		//!Setup workout notifcations
		sethideText = false;
		var vibrateData = [
			new Attention.VibeProfile( 100, 100 )
		    ];
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		if (uWorkoutType == 2 or uWorkoutType == 3) {
			if (jTimertime == 0) {  //! Activity not yet started
				mWorkoutstepNumber = 1;
				if (mWorkoutType[1].equals("t")) {
					dc.drawText(120, 135, Graphics.FONT_MEDIUM,  mWorkoutAmount[mWorkoutstepNumber].toNumber() + " sec @ " + mWorkoutLzone[mWorkoutstepNumber].toNumber() + "-" + mWorkoutHzone[mWorkoutstepNumber].toNumber() , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);	
					nextAlertT = jTimertime + mWorkoutAmount[mWorkoutstepNumber].toNumber();
					nextAlertType = "t";
				} else if (mWorkoutType[1].equals("d")) {
					dc.drawText(120, 135, Graphics.FONT_MEDIUM,  mWorkoutAmount[mWorkoutstepNumber].toNumber() + " met @ " + mWorkoutLzone[mWorkoutstepNumber].toNumber() + "-" + mWorkoutHzone[mWorkoutstepNumber].toNumber() , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);	
					nextAlertD = jDistance + mWorkoutAmount[mWorkoutstepNumber].toNumber();
					nextAlertType = "d";
				} 			
			} else if (jTimertime > 0){  //! timer is running
				setPowerWarning = 0;
				//! Executing alerts
				if (runPower > mWorkoutHzone[mWorkoutstepNumber].toNumber() or runPower < mWorkoutLzone[mWorkoutstepNumber].toNumber()) {		 
					 if (Toybox.Attention has :vibrate && uNoAlerts == false) {
					 	vibrateseconds = vibrateseconds + 1;	 		  			
    					if (runPower>mWorkoutHzone[mWorkoutstepNumber].toNumber()) {
    						setPowerWarning = 1;
    						if (vibrateseconds == uWarningFreq) {
    							Toybox.Attention.vibrate(vibrateData);
    							if (uAlertbeep == true) {
    								Attention.playTone(Attention.TONE_KEY);
		    					}
    							vibrateseconds = 0;
    						}
    					} else if (runPower<mWorkoutLzone[mWorkoutstepNumber].toNumber()){
    						setPowerWarning = 2;
    						if (vibrateseconds == uWarningFreq) {
    							if (uAlertbeep == true) {
    								Attention.playTone(Attention.TONE_LOUD_BEEP);
	    						}
    						Toybox.Attention.vibrate(vibrateData);
    						vibrateseconds = 0;
	    					}
    					} 
					 } 
				}		
				workoutUnit = (mWorkoutType[mWorkoutstepNumber+1].equals("t")) ? "sec" : "met";
				if (nextAlertType.equals("t")) {
					if (nextAlertT > jTimertime+5 and nextAlertT < jTimertime+10) {      //! Notification nearing the end of a time-based step 				 	
					  if (mWorkoutAmount[mWorkoutstepNumber].equals("0000") == false or mWorkoutstepNumber < 18) {
						dc.drawText(120, 135, Graphics.FONT_MEDIUM,  mWorkoutAmount[mWorkoutstepNumber+1].toNumber() + " " + workoutUnit + " @ " + mWorkoutLzone[mWorkoutstepNumber+1].toNumber() + "-" + mWorkoutHzone[mWorkoutstepNumber+1].toNumber() , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);				
						Toybox.Attention.vibrate(vibrateData);
						Attention.playTone(Attention.TONE_LOUD_BEEP);
						Attention.playTone(Attention.TONE_KEY);
					  } else if (mWorkoutAmount[mWorkoutstepNumber].equals("0000") == true or mWorkoutstepNumber == 18) {
					    dc.drawText(120, 135, Graphics.FONT_MEDIUM,  "Ending" , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);				
						Toybox.Attention.vibrate(vibrateData);
						Attention.playTone(Attention.TONE_LOUD_BEEP);
						Attention.playTone(Attention.TONE_KEY);
						mWorkoutstepNumber = 18;
					  }
					}
					  if (nextAlertT == jTimertime) {   //! After the notifications determine next workouttype
						nextAlertType = mWorkoutType[mWorkoutstepNumber+1];
					  } 
				}			
				if (nextAlertType.equals("d")) {
					if (nextAlertD > jDistance+5*CurrentSpeedinmpersec and nextAlertD < jDistance+10*CurrentSpeedinmpersec) {       //! Notification nearing the end of a distance-based step 
					  if (mWorkoutAmount[mWorkoutstepNumber].equals("0000") == false or mWorkoutstepNumber < 18) {
						dc.drawText(120, 135, Graphics.FONT_MEDIUM,  mWorkoutAmount[mWorkoutstepNumber+1].toNumber() + " " + workoutUnit + " @ " + mWorkoutLzone[mWorkoutstepNumber+1].toNumber() + "-" + mWorkoutHzone[mWorkoutstepNumber+1].toNumber(), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);				
						Toybox.Attention.vibrate(vibrateData);
						Attention.playTone(Attention.TONE_LOUD_BEEP);
						Attention.playTone(Attention.TONE_KEY);
					  } else if (mWorkoutAmount[mWorkoutstepNumber].equals("0000") == true or mWorkoutstepNumber == 18) {
					    dc.drawText(120, 135, Graphics.FONT_MEDIUM,  "Ending" , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);				
						Toybox.Attention.vibrate(vibrateData);
						Attention.playTone(Attention.TONE_LOUD_BEEP);
						Attention.playTone(Attention.TONE_KEY);
						mWorkoutstepNumber = 18;
					  }
					}
					if (nextAlertD > jDistance) {   //! After the notifications determine next workouttype
						nextAlertType = mWorkoutType[mWorkoutstepNumber+1];
					}					 
				}		
				if (jTimertime == nextAlertT and nextAlertType.equals("t")) {			//! Setting up next alert at the end of a time-based step
						onTimerLap();
						Workoutstepalert(dc);
						sethideText = true;
						if (mWorkoutAmount[mWorkoutstepNumber].equals("0000") == false or mWorkoutstepNumber < 18) {
						  if (mWorkoutType[mWorkoutstepNumber].equals("t")) { 	//! setting up next time-based alert       
							mWorkoutstepNumber = mWorkoutstepNumber + 1;
							nextAlertT = jTimertime + mWorkoutAmount[mWorkoutstepNumber].toNumber();
							nextAlertType = "t";				
						  } else if (mWorkoutType[mWorkoutstepNumber].equals("d")) {		//! setting up next distance-based alert
							mWorkoutstepNumber = mWorkoutstepNumber + 1;
							nextAlertD = jDistance + mWorkoutAmount[mWorkoutstepNumber].toNumber();
							nextAlertType = "d";
						  }
						}
				}
				if ( jDistance > nextAlertD and nextAlertType.equals("d")) {			//! Setting up next alert at the end of a distance-based step			 
					if (nextAlertD < jDistance + CurrentSpeedinmpersec) {
						onTimerLap();
						Workoutstepalert(dc);
						sethideText = true;
						if (mWorkoutAmount[mWorkoutstepNumber].equals("0000") == false or mWorkoutstepNumber < 18) {
						  if (mWorkoutType[mWorkoutstepNumber].equals("t")) { 	//! setting up time-based next alert       
							mWorkoutstepNumber = mWorkoutstepNumber + 1;
							nextAlertT = jTimertime + mWorkoutAmount[mWorkoutstepNumber].toNumber();
							nextAlertType = "t";	
						  } else if (mWorkoutType[mWorkoutstepNumber].equals("d")) {	//! setting up next distance-based alert
							mWorkoutstepNumber = mWorkoutstepNumber + 1;
							nextAlertD = jDistance + mWorkoutAmount[mWorkoutstepNumber].toNumber();
							nextAlertType = "d";
						  }
						}
					}  
				}
			}			
		}
		
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		
		i = 0; 
	    for (i = 1; i < 8; ++i) {
	        if (metric[i] == 38) {
    	        fieldValue[i] =  (info.currentPower != null) ? info.currentPower : 0;     	        
        	    fieldLabel[i] = "P zone";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 56) {
	            fieldValue[i] = FilteredCurPower;
    	        fieldLabel[i] = "Filt Pwr";
        	    fieldFormat[i] = "0decimal";            	
			} else if (metric[i] == 17) {
	            fieldValue[i] = Averagespeedinmpersec;
    	        fieldLabel[i] = "Pc ..sec";
        	    fieldFormat[i] = "pace";            	
			} else if (metric[i] == 55) {   
            	fieldValue[i] = (info.currentSpeed != null or info.currentSpeed!=0) ? 100/info.currentSpeed : 0;
            	fieldLabel[i] = "s/100m";
        	    fieldFormat[i] = "2decimal";
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
			} else if (metric[i] == 37) {
	            fieldValue[i] = Averagepowerpersec;
    	        fieldLabel[i] = "Pw ..sec";
        	    fieldFormat[i] = "power";
			} else if (metric[i] == 57) {
	            fieldValue[i] = mNormalizedPow;
    	        fieldLabel[i] = "N Power";
        	    fieldFormat[i] = "0decimal";
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

		fieldvalue = (metric[counter]==38) ? Powerzone : fieldvalue; 
		fieldvalue = (metric[counter]==46) ? HRzone : fieldvalue;
		
        if ( fieldformat.equals("0decimal" ) == true ) {
        	fieldvalue = fieldvalue.format("%.0f");        	
        } else if ( fieldformat.equals("2decimal" ) == true ) {
            Temp = Math.round(fieldvalue*100)/100;
            var fString = "%.2f";
         	if (Temp > 9.99999) {
             	fString = "%.1f";
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
        
		//! Don't display middle row metrics, if there is a workout notification
		hideText = false;
		if (uWorkoutType == 2 or uWorkoutType == 3) {
			if (counter == 3 or counter == 4 or counter == 5) { 
				if (jTimertime == 0) {
					hideText = true;
				} 								
				if (nextAlertT > jTimertime+5 and nextAlertT < jTimertime+10) {
					hideText = true;
				}
				if (nextAlertD > jDistance+5*CurrentSpeedinmpersec and nextAlertD < jDistance+10*CurrentSpeedinmpersec) {
					hideText = true;
				}
			}
		}
		
		if (sethideText == true) {
			if (counter == 3 or counter == 4 or counter == 5) {
				hideText = true;
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
            		if (hideText == false) {
            			dc.drawText(xh, yh, Graphics.FONT_NUMBER_MILD, fTimerHours, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
            		}
            		fTimer = (fieldvalue / 60 % 60).format("%02d") + ":" + fTimerSecs;  
        		}
        		if (hideText == false) {
        			dc.drawText(xx, y, Graphics.FONT_NUMBER_MEDIUM, fTimer, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		}	
        	}
        } else {
        	if (hideText == false) {
        		dc.drawText(x, y, Graphics.FONT_NUMBER_MEDIUM, fieldvalue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        	}
        }        
        if (hideText == false) {
        	dc.drawText(xl, yl, Graphics.FONT_XTINY,  fieldlabel, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }               
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

	function Workoutstepalert(dc) {
		hideText = true;
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		var vibrateData = [
			new Attention.VibeProfile( 100, 100 )
		];
		if (mWorkoutstepNumber < 18 ) {
			if (mWorkoutAmount[mWorkoutstepNumber].equals("0000") == false) { 
				dc.drawText(120, 135, Graphics.FONT_MEDIUM,  " Next step " , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			} else { 
				dc.drawText(120, 135, Graphics.FONT_MEDIUM,"The end", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			}
			Toybox.Attention.vibrate(vibrateData);
			Attention.playTone(Attention.TONE_LOUD_BEEP);
			Attention.playTone(Attention.TONE_KEY);
		} else if (mWorkoutstepNumber == 18 ) {
			dc.drawText(120, 135, Graphics.FONT_MEDIUM,"The end", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
		}
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
	}
}
