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
	var sum4thPowers						= 0;
	var fourthPowercounter 					= 0;
	var mIntensityFactor					= 0;
	var mTTS								= 0;
	var i 									= 0;
	var setPowerWarning 					= 0;
	var Garminfont = Ui.loadResource(Rez.Fonts.Garmin1);
	var Power 								= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    var uWeight								= 70;
    var uPowerTarget						= 225;
    var uOnlyPwrCorrFactor					= false;
    var uPwrTempcorrect 					= 0;
    var uPwrHumidcorrect 					= 0;
    var uPwrAlticorrect 					= 0; 
    var uFTPTemp							= 20;
    var uManTemp							= 20;
	var PwrCorrFactor							= 1;
    var uRealHumid 							= 40;
    var uFTPHumid 							= 70;
    var uRealAltitude 						= 2;
    var uFTPAltitude 						= 200;
//!    hidden var workoutTarget 						;
    hidden var hasWorkoutStep 				= false;
    hidden var WorkoutStepLowBoundary		= 0;
    hidden var WorkoutStepHighBoundary		= 999;
    hidden var is32kBdevice					= false;
    var AveragePower						= 0;
    var WorkoutStepNr						= 0;
    var WorkoutStepDuration 				= 0; 
//!    hidden var StartTimeNewStep				= 0;
    var StartDistanceNewStep				= 0;
//!    hidden var RemainingWorkoutTime  		= 0;
//!    hidden var RemainingWorkoutDistance		= 0;
//!    hidden var WorkoutStepDurationType  	= 9;
    hidden var AveragePower3sec  	 		= 0;
    hidden var AveragePower5sec  	 		= 0;
    hidden var AveragePower10sec  	 		= 0;
    hidden var mFontalertColorLow			= Graphics.COLOR_RED;
    var uFontalertColorLow					= 5;
    hidden var mFontalertColorHigh			= Graphics.COLOR_PURPLE;
    var uFontalertColorHigh					= 4;
    hidden var TotalVertSpeedinmpersec 		= 0;
    hidden var calculateVertGrade           = false;
	var DistforGrade                        = new[303];
	var ElevforGrade                        = new[303];
	var Vertgrade                           = 0;
	var stopiteration                       = false;
	var uVertgradeDist                      = 0.1;
	var Vertgradsmooth  	        		= new[6]; 
	var uLabelfontbig 						= true;
	var Labelfont							= Graphics.FONT_TINY;
    
    
            		            				
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
		uPowerTarget	 = mApp.getProperty("pPowerTarget");
		uOnlyPwrCorrFactor= mApp.getProperty("pOnlyPwrCorrFactor");
		uPwrTempcorrect	 = mApp.getProperty("pPwrTempcorrect");
		uFTPTemp	 	 = mApp.getProperty("pFTPTemp");
		uManTemp	 	 = mApp.getProperty("pManTemp");
		uPwrHumidcorrect = mApp.getProperty("pPwrHumidcorrect");
		uRealHumid 		 = mApp.getProperty("pRealHumid");
    	uFTPHumid 		 = mApp.getProperty("pFTPHumid");
    	uPwrAlticorrect  = mApp.getProperty("pPwrAlticorrect");
    	uRealAltitude 	 = mApp.getProperty("pRealAltitude");
    	uFTPAltitude	 = mApp.getProperty("pFTPAltitude");
    	uFontalertColorLow = mApp.getProperty("pFontalertColorLow");
    	uFontalertColorHigh = mApp.getProperty("pFontalertColorHigh");
    	uVertgradeDist   = mApp.getProperty("pVertgradeDist");
    	uLabelfontbig = mApp.getProperty("pLabelfontbig");

        uVertgradeDist = (uVertgradeDist<50) ? 0.050 : uVertgradeDist;
	
		uRealHumid = (uRealHumid != 0 ) ? uRealHumid : 1;
		uFTPHumid = (uFTPHumid != 0 ) ? uFTPHumid : 1;
		
		if (uLabelfontbig == true) {
			Labelfont = Graphics.FONT_TINY;
		} else {
			Labelfont = Graphics.FONT_XTINY;
		}
		
		//! Choose fontcolor for alert when power value is under or above powerzone
        if ( uFontalertColorLow == 0 ) {
	    	mFontalertColorLow 	 = Graphics.COLOR_GREEN;
	    } else if ( uFontalertColorLow == 1 ) {
	    	mFontalertColorLow 	 = Graphics.COLOR_BLUE;
		} else if ( uFontalertColorLow == 2 ) {
	    	mFontalertColorLow 	 = Graphics.COLOR_DK_GRAY;
		} else if ( uFontalertColorLow == 3 ) {
	    	mFontalertColorLow 	 = Graphics.COLOR_WHITE;
		} else if ( uFontalertColorLow == 4 ) {
	    	mFontalertColorLow 	 = Graphics.COLOR_PURPLE;
		} else if ( uFontalertColorLow == 5 ) {
	    	mFontalertColorLow 	 = Graphics.COLOR_RED;
		} else if ( uFontalertColorLow == 6 ) {
	    	mFontalertColorLow 	 = Graphics.COLOR_BLACK;
	   	} else if ( uFontalertColorLow == 7 ) {
	    	mFontalertColorLow 	 = Graphics.COLOR_DK_BLUE;
		}

		if ( uFontalertColorHigh == 0 ) {
	    	mFontalertColorHigh 	 = Graphics.COLOR_GREEN;
	    } else if ( uFontalertColorHigh == 1 ) {
	    	mFontalertColorHigh 	 = Graphics.COLOR_BLUE;
		} else if ( uFontalertColorHigh == 2 ) {
	    	mFontalertColorHigh 	 = Graphics.COLOR_DK_GRAY;
		} else if ( uFontalertColorHigh == 3 ) {
	    	mFontalertColorHigh 	 = Graphics.COLOR_WHITE;
		} else if ( uFontalertColorHigh == 4 ) {
	    	mFontalertColorHigh 	 = Graphics.COLOR_PURPLE;
		} else if ( uFontalertColorHigh == 5 ) {
	    	mFontalertColorHigh 	 = Graphics.COLOR_RED;
		} else if ( uFontalertColorHigh == 6 ) {
	    	mFontalertColorHigh 	 = Graphics.COLOR_BLACK;
	    } else if ( uFontalertColorLow == 7 ) {
	    	mFontalertColorLow 	 = Graphics.COLOR_DK_BLUE;
		}
		
		if (utempunits == true ) {
			uFTPTemp = (uFTPTemp-32)/1.8;
			uManTemp = (uManTemp-32)/1.8;
		}
		
		for (i = 1; i < 301; ++i) {
		    DistforGrade[i] = 0;
		    ElevforGrade[i] = 0;
		}
		
		for (i = 1; i < 6; ++i) {
		    Vertgradsmooth[i] = 0;
		}
		
		i = 0; 
	    for (i = 1; i < 8; ++i) {		
			if (metric[i] == 57 or metric[i] == 58 or metric[i] == 59) {
				rolavPowmaxsecs = (rolavPowmaxsecs < 30) ? 30 : rolavPowmaxsecs;
			}
		}
		i = 0;	
		for (i = 1; i < 8; ++i) {
			Power[i] = 0;
		}
		
		for (i = 1; i < 8; ++i) {
	    	if (metric[i] == 131) {
				calculateVertGrade = true; //!Only calculate vertical grade if needed
			}
		}
		
		if (mySettings.screenWidth == 260 and mySettings.screenHeight == 260) {
			Garminfont = Ui.loadResource(Rez.Fonts.Garmin2);
		} else if (mySettings.screenWidth == 280 and mySettings.screenHeight == 280) {
			Garminfont = Ui.loadResource(Rez.Fonts.Garmin3);
		} else if (mySettings.screenWidth == 416 and mySettings.screenHeight == 416) {
			Garminfont = Ui.loadResource(Rez.Fonts.Garmin4);
		} else {
			Garminfont = Ui.loadResource(Rez.Fonts.Garmin1);
		}
    }


    //! Calculations we need to do every second even when the data field is not visible
    function compute(info) {
        //! If enabled, switch the backlight on in order to make it stay on
        if (uBacklight) {
             Attention.backlight(true);
        }
		
		startTime = (jTimertime == 0) ? Toybox.System.getClockTime() : startTime;
		
		//! Calculating vertical grade
        var k;
	    if (calculateVertGrade == true) {
   				for (k = 1; k < 300; ++k) {			
					DistforGrade[301-k] = DistforGrade[300-k];
					ElevforGrade[301-k] = ElevforGrade[300-k];
				}
				DistforGrade[1]	= (info.elapsedDistance != null) ? info.elapsedDistance : 0;	
				ElevforGrade[1] = (info.altitude != null) ? info.altitude : 0;
				stopiteration = false;
				for (k = 1; k < 301; ++k) {
					if ((DistforGrade[1] - DistforGrade[k])>(uVertgradeDist)) {
					   if (stopiteration == false) {
					       Vertgrade=100*(ElevforGrade[1]-ElevforGrade[k])/(DistforGrade[1]-DistforGrade[k]);
					       stopiteration = true;
					   }
					}
				}
		}

        //!Smoothing of vertical grade over 5 seonds
        Vertgradsmooth[5] 								= Vertgradsmooth[4];
        Vertgradsmooth[4] 								= Vertgradsmooth[3];
        Vertgradsmooth[3] 								= Vertgradsmooth[2];
        Vertgradsmooth[2] 								= Vertgradsmooth[1];
		Vertgradsmooth[1]								= Vertgrade; 
        Vertgradsmoothed = (Vertgradsmooth[1]+Vertgradsmooth[2]+Vertgradsmooth[3]+Vertgradsmooth[4]+Vertgradsmooth[5])/5;
        
		//! We only do some calculations if the timer is running
		if (mTimerRunning) {  
			//! Calculate lap time
    	    mLapTimerTime = jTimertime - mLastLapTimeMarker;	
        	jTimertime = jTimertime + 1;
        	
			//!Calculate lapheartrate
            mHeartrateTime	 = (info.currentHeartRate != null) ? mHeartrateTime+1 : mHeartrateTime;				
           	mElapsedHeartrate= (info.currentHeartRate != null) ? mElapsedHeartrate + info.currentHeartRate : mElapsedHeartrate;
           	
           	//!Calculate lapCadence
            mCadenceTime	 = (info.currentCadence != null) ? mCadenceTime+1 : mCadenceTime;
            if (ucadenceWorkaround == true ) { //! workaround multiply by two for FR945LTE and Fenix 6 series
            	mElapsedCadence= (info.currentCadence != null) ? mElapsedCadence + info.currentCadence*2 : mElapsedCadence;
            } else {
            	mElapsedCadence= (info.currentCadence != null) ? mElapsedCadence + info.currentCadence : mElapsedCadence;
            }
            
            //! Calculate vertical speed
    	    valueDesc = (info.totalDescent != null) ? info.totalDescent : 0;
        	Diff1 = valueDesc - valueDesclast;
    	    valueAsc = (info.totalAscent != null) ? info.totalAscent : 0;
        	Diff2 = valueAsc - valueAsclast;
    	    valueDesclast = valueDesc;
        	valueAsclast = valueAsc;
	        CurrentVertSpeedinmpersec = Diff2-Diff1;
	        TotalVertSpeedinmpersec = TotalVertSpeedinmpersec + CurrentVertSpeedinmpersec;
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
  
            //! Calculate temperature compensation, B-variables reference cell number from cells of conversion excelsheet  		
            var B6 = 22; 			//! is cell B6
            if (uPwrTempcorrect == 0 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 0) {
            	PwrCorrFactor = 1;  //! no temperature compensation
            } else {
            	if (jTimertime < 300 and uPwrTempcorrect == 1 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 0) {
            		PwrCorrFactor = 1;  //! no temperature compensation
            	} else {
            		if (uPwrTempcorrect == 0 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 0) {
            			uFTPTemp = 18;
            			B6 = 18;  
	            		uFTPHumid = 70;
    	        		uRealHumid = 70;
        	    		uFTPAltitude = 200;
            			uRealAltitude =	200;
            		} else if (uPwrTempcorrect == 0 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 1) {
            			uFTPTemp = 18;
            			B6 = 18;  
	            		uFTPHumid = 70;
    	        		uRealHumid = 70;
    	        		uRealAltitude =	(info.altitude != null) ? info.altitude : 0;
            		} else if (uPwrTempcorrect == 0 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 2) {
            			uFTPTemp = 18;
            			B6 = 18;  
	            		uFTPHumid = 70;
    	        		uRealHumid = 70;
            		} else if (uPwrTempcorrect == 0 and uPwrHumidcorrect == 2 and uPwrAlticorrect == 0) {
            			uFTPTemp = 18;
            			B6 = 18;  
        	    		uFTPAltitude = 200;
            			uRealAltitude =	200;
            		} else if (uPwrTempcorrect == 0 and uPwrHumidcorrect == 2 and uPwrAlticorrect == 1) {
            			uFTPTemp = 18;
            			B6 = 18;  
            			uRealAltitude =	(info.altitude != null) ? info.altitude : 0;
            		} else if (uPwrTempcorrect == 0 and uPwrHumidcorrect == 2 and uPwrAlticorrect == 2) {
            			uFTPTemp = 18;
            			B6 = 18;  
            		} else if (uPwrTempcorrect == 1 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 0) {
            			B6 = (utempunits == false) ? tempeTemp : tempeTemp + utempcalibration/1.8 ;  
	            		uFTPHumid = 70;
    	        		uRealHumid = 70;
        	    		uFTPAltitude = 200;
            			uRealAltitude =	200;
            		} else if (uPwrTempcorrect == 1 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 1) {
            			B6 = (utempunits == false) ? tempeTemp : tempeTemp + utempcalibration/1.8 ;  
	            		uFTPHumid = 70;
    	        		uRealHumid = 70;
    	        		uRealAltitude =	(info.altitude != null) ? info.altitude : 0;
            		} else if (uPwrTempcorrect == 1 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 2) {
            			B6 = (utempunits == false) ? tempeTemp : tempeTemp + utempcalibration/1.8 ;  
	            		uFTPHumid = 70;
    	        		uRealHumid = 70;
            		} else if (uPwrTempcorrect == 1 and uPwrHumidcorrect == 2 and uPwrAlticorrect == 0) {
            			B6 = (utempunits == false) ? tempeTemp : tempeTemp + utempcalibration/1.8 ;  
        	    		uFTPAltitude = 200;
            			uRealAltitude =	200;
            		} else if (uPwrTempcorrect == 1 and uPwrHumidcorrect == 2 and uPwrAlticorrect == 1) {
            			B6 = (utempunits == false) ? tempeTemp : tempeTemp + utempcalibration/1.8 ;
            			uRealAltitude =	(info.altitude != null) ? info.altitude : 0;  
            		} else if (uPwrTempcorrect == 1 and uPwrHumidcorrect == 2 and uPwrAlticorrect == 2) {
            			B6 = (utempunits == false) ? tempeTemp : tempeTemp + utempcalibration/1.8 ;  
            		} else if (uPwrTempcorrect == 2 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 0) {
            			B6 = uManTemp;  
	            		uFTPHumid = 70;
    	        		uRealHumid = 70;
        	    		uFTPAltitude = 200;
            			uRealAltitude =	200;
            		} else if (uPwrTempcorrect == 2 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 1) {
            			B6 = uManTemp;  
	            		uFTPHumid = 70;
    	        		uRealHumid = 70;
    	        		uRealAltitude =	(info.altitude != null) ? info.altitude : 0;
            		} else if (uPwrTempcorrect == 2 and uPwrHumidcorrect == 0 and uPwrAlticorrect == 2) {
            			B6 = uManTemp;  
	            		uFTPHumid = 70;
    	        		uRealHumid = 70;
            		} else if (uPwrTempcorrect == 2 and uPwrHumidcorrect == 2 and uPwrAlticorrect == 0) {
            			B6 = uManTemp;  
        	    		uFTPAltitude = 200;
            			uRealAltitude =	200;
            		} else if (uPwrTempcorrect == 2 and uPwrHumidcorrect == 2 and uPwrAlticorrect == 1) {
            			B6 = uManTemp;
            			uRealAltitude =	(info.altitude != null) ? info.altitude : 0;  
            		} else if (uPwrTempcorrect == 2 and uPwrHumidcorrect == 2 and uPwrAlticorrect == 2) {
            			B6 = uManTemp;  
            		}

					var B22 = 101325 * Math.pow((B6+273.15)/((B6+273.15)+(-0.0065 * uRealAltitude)) , ((9.80665 * 0.0289644) / (8.31432 * -0.0065))) * 0.00750062;
					var B23 = 101325 * Math.pow((uFTPTemp+273.15)/((uFTPTemp+273.15)+(-0.0065 * uFTPAltitude)) , ((9.80665 * 0.0289644) / (8.31432 * -0.0065))) * 0.00750062;
					var B24 = (-174.1448622 + 1.0899959 * B22 + -1.5119*0.001 * Math.pow(B22 , 2) + 0.72674 * Math.pow(10 , -6) * Math.pow(B22 , 3)) / 100;
					var B25 = (-174.1448622 + 1.0899959 * B23 + -1.5119*0.001 * Math.pow(B23 , 2) + 0.72674 * Math.pow(10 , -6) * Math.pow(B23 , 3)) / 100;
					var B36 = (257.14 * (Math.ln(Math.pow(2.718281828459, ((18.678-B6/234.5)*(B6/(257.14+B6))))*uRealHumid/100)) / (18.678-(Math.ln(Math.pow(2.718281828459, ((18.678-B6/234.5)*(B6/(257.14+B6))))*uRealHumid/100)))) * 1.8 + 32;
					var B37 = (257.14 * (Math.ln(Math.pow(2.718281828459, ((18.678-uFTPTemp/234.5)*(uFTPTemp/(257.14+uFTPTemp))))*uFTPHumid/100)) / (18.678-(Math.ln(Math.pow(2.718281828459, ((18.678-uFTPTemp/234.5)*(uFTPTemp/(257.14+uFTPTemp))))*uFTPHumid/100)))) * 1.8 + 32;
					var B38;
					var Btemp = B36+B6*1.8+32; 
					if ((Btemp) > 100) {
						B38 = 0.001341 * Math.pow((Btemp) , 2) - 0.249517 * Math.pow((Btemp) , 1) + 11.699986;   
					} else {
			    		B38 = 0;
					}	
					Btemp = B37+uFTPTemp*1.8+32;
					var B39;	
					if ((Btemp) > 100) {
						B39 = 0.001341 * Math.pow((Btemp) , 2) - 0.249517 * Math.pow((Btemp) , 1) + 11.699986;
					} else {
				    	B39 = 0;
					}      
					PwrCorrFactor = 1- (B24 - B25) - (B39-B38)/100;
				}
				
				if (dynamics != null) {
		 		    var data = dynamics.getRunningDynamics(); 
		 		    if (data != null) {
		    			groundContactBalance = data.groundContactBalance;
    					groundContactTime = data.groundContactTime;  
    					stanceTime = data.stanceTime;
    					stepLength = data.stepLength;
    					verticalOscillation = data.verticalOscillation;
    					verticalRatio = data.verticalRatio;
	    			} else {
    					groundContactBalance = 0;
    					groundContactTime = 0;  
    					stanceTime = 0;
    					stepLength = 0;
    					verticalOscillation = 0;
	    				verticalRatio = 0;
    				}
    			} else {
    				groundContactBalance = 0;
   					groundContactTime = 0;  
	   				stanceTime = 0;
   					stepLength = 0;
   					verticalOscillation = 0;
   					verticalRatio = 0;
    			}

        		for (i = 1; i < 8; ++i) {
        			if (metric[i] == 109) {  
        				rollgroundContactBalance[10] 								= rollgroundContactBalance[9];
	            		rollgroundContactBalance[9] 								= rollgroundContactBalance[8];
    	        		rollgroundContactBalance[8] 								= rollgroundContactBalance[7];
        		    	rollgroundContactBalance[7] 								= rollgroundContactBalance[6];
        			    rollgroundContactBalance[6] 								= rollgroundContactBalance[5];
	        			rollgroundContactBalance[5] 								= rollgroundContactBalance[4];
 			       		rollgroundContactBalance[4] 								= rollgroundContactBalance[3];
        				rollgroundContactBalance[3] 								= rollgroundContactBalance[2];
        				rollgroundContactBalance[2] 								= rollgroundContactBalance[1];
        				rollgroundContactBalance[1] 								= groundContactBalance;
						AveragerollgroundContactBalance10sec	= (rollgroundContactBalance[1]+rollgroundContactBalance[2]+rollgroundContactBalance[3]+rollgroundContactBalance[4]+rollgroundContactBalance[5]+rollgroundContactBalance[6]+rollgroundContactBalance[7]+rollgroundContactBalance[8]+rollgroundContactBalance[9]+rollgroundContactBalance[10])/10;
	    			}
    				if (metric[i] == 110) {
    					rollgroundContactTime[10] 						= rollgroundContactTime[9];
	        			rollgroundContactTime[9] 						= rollgroundContactTime[8];
    	    			rollgroundContactTime[8] 						= rollgroundContactTime[7];
        				rollgroundContactTime[7] 						= rollgroundContactTime[6];
	        			rollgroundContactTime[6] 						= rollgroundContactTime[5];
	        			rollgroundContactTime[5] 						= rollgroundContactTime[4];
 			       		rollgroundContactTime[4] 						= rollgroundContactTime[3];
        				rollgroundContactTime[3] 						= rollgroundContactTime[2];
        				rollgroundContactTime[2] 						= rollgroundContactTime[1];
        				rollgroundContactTime[1] 						= groundContactTime;
						AveragerollgroundContactTime10sec	= (rollgroundContactTime[1]+rollgroundContactTime[2]+rollgroundContactTime[3]+rollgroundContactTime[4]+rollgroundContactTime[5]+rollgroundContactTime[6]+rollgroundContactTime[7]+rollgroundContactTime[8]+rollgroundContactTime[9]+rollgroundContactTime[10])/10;	
	    			}
	    			if (metric[i] == 111) {
	    				rollstanceTime[10] 								= rollstanceTime[9];
		        		rollstanceTime[9] 								= rollstanceTime[8];
	    	    		rollstanceTime[8] 								= rollstanceTime[7];
    	    			rollstanceTime[7] 								= rollstanceTime[6];
        				rollstanceTime[6] 								= rollstanceTime[5];
        				rollstanceTime[5] 								= rollstanceTime[4];
 		       			rollstanceTime[4] 								= rollstanceTime[3];
        				rollstanceTime[3] 								= rollstanceTime[2];
	        			rollstanceTime[2] 								= rollstanceTime[1];
    	    			rollstanceTime[1] 								= stanceTime;
						AveragerollstanceTime10sec	= (rollstanceTime[1]+rollstanceTime[2]+rollstanceTime[3]+rollstanceTime[4]+rollstanceTime[5]+rollstanceTime[6]+rollstanceTime[7]+rollstanceTime[8]+rollstanceTime[9]+rollstanceTime[10])/10;
    				}
    				if (metric[i] == 113) {
	    				rollstepLength[10] 								= rollstepLength[9];
		        		rollstepLength[9] 								= rollstepLength[8];
    		    		rollstepLength[8] 								= rollstepLength[7];
        				rollstepLength[7] 								= rollstepLength[6];
        				rollstepLength[6] 								= rollstepLength[5];
        				rollstepLength[5] 								= rollstepLength[4];
	 		       		rollstepLength[4] 								= rollstepLength[3];
    	    			rollstepLength[3] 								= rollstepLength[2];
        				rollstepLength[2] 								= rollstepLength[1];
        				rollstepLength[1] 								= stepLength;
						AveragerollstepLength10sec	= (rollstepLength[1]+rollstepLength[2]+rollstepLength[3]+rollstepLength[4]+rollstepLength[5]+rollstepLength[6]+rollstepLength[7]+rollstepLength[8]+rollstepLength[9]+rollstepLength[10])/10; 
    				}
	    			if (metric[i] == 114) { 
    					rollverticalOscillation[10] 					= rollverticalOscillation[9];
	    	    		rollverticalOscillation[9] 						= rollverticalOscillation[8];
    	    			rollverticalOscillation[8] 						= rollverticalOscillation[7];
        				rollverticalOscillation[7] 						= rollverticalOscillation[6];
        				rollverticalOscillation[6] 						= rollverticalOscillation[5];
	        			rollverticalOscillation[5] 						= rollverticalOscillation[4];
 			       		rollverticalOscillation[4] 						= rollverticalOscillation[3];
        				rollverticalOscillation[3] 						= rollverticalOscillation[2];
        				rollverticalOscillation[2] 						= rollverticalOscillation[1];
        				rollverticalOscillation[1] 						= verticalOscillation;
						AveragerollverticalOscillation10sec	= (rollverticalOscillation[1]+rollverticalOscillation[2]+rollverticalOscillation[3]+rollverticalOscillation[4]+rollverticalOscillation[5]+rollverticalOscillation[6]+rollverticalOscillation[7]+rollverticalOscillation[8]+rollverticalOscillation[9]+rollverticalOscillation[10])/10;
    				}
	    			if (metric[i] == 115) {
    					rollverticalRatio[10] 							= rollverticalRatio[9];
	    	    		rollverticalRatio[9] 							= rollverticalRatio[8];
    	    			rollverticalRatio[8] 							= rollverticalRatio[7];
        				rollverticalRatio[7] 							= rollverticalRatio[6];
        				rollverticalRatio[6] 							= rollverticalRatio[5];
	        			rollverticalRatio[5] 							= rollverticalRatio[4];
 			       		rollverticalRatio[4] 							= rollverticalRatio[3];
        				rollverticalRatio[3] 							= rollverticalRatio[2];
        				rollverticalRatio[2] 							= rollverticalRatio[1];
        				rollverticalRatio[1] 							= verticalRatio;
						AveragerollverticalRatio10sec	= (rollverticalRatio[1]+rollverticalRatio[2]+rollverticalRatio[3]+rollverticalRatio[4]+rollverticalRatio[5]+rollverticalRatio[6]+rollverticalRatio[7]+rollverticalRatio[8]+rollverticalRatio[9]+rollverticalRatio[10])/10;
					}
				}
			}
			
			var vibrateData = [
				new Attention.VibeProfile( 100, 200 )
			];

			if (VibrateHighRequired == true) {
    			Toybox.Attention.vibrate(vibrateData);
    			if (uAlertbeep == true) {
    				Attention.playTone(Attention.TONE_ALERT_HI);
    			}
    			Toybox.Attention.vibrate(vibrateData);
    			VibrateHighRequired = false;
    		}

    		if (VibrateLowRequired == true) {
    			if (uAlertbeep == true) {
    				Attention.playTone(Attention.TONE_ALERT_LO);
    			}
    			Toybox.Attention.vibrate(vibrateData);
    			VibrateLowRequired = false;
    		}
			           	
            //!Calculate lappower
            mPowerTime		 = (info.currentPower != null and mTimerRunning) ? mPowerTime+1 : mPowerTime;
            if (uOnlyPwrCorrFactor == false) {
            	runPower 		 = (info.currentPower != null) ? (info.currentPower+0.001)*PwrCorrFactor : 0;
            } else {
            	runPower 		 = (info.currentPower != null) ? info.currentPower : 0;
            }
			mElapsedPower    = (mTimerRunning) ? mElapsedPower + runPower : mElapsedPower;
			
			if (uCP != 0) {
				if ((runPower+0.001)/uCP < 0.5 ) {
					RSS = RSS + 0.0026516504294491;
				} else if ((runPower+0.001)/uCP > 1.5 ) {
					RSS = RSS + 0.1240054182283927;
				} else {
					RSS = RSS + + 0.03 * Math.pow(((runPower+0.001)/uCP),3.5);
				}
			}	 			             
        }
	}

    function onTimerLap() {
		Lapaction ();
	}

	//! Store last lap quantities and set lap markers after a step within a structured workout
	function onWorkoutStepComplete() {
	var info = Activity.getActivityInfo();
		Lapaction ();
		++WorkoutStepNr;		
		StartTimeNewStep = jTimertime;
        StartDistanceNewStep = (info.elapsedDistance != null) ? info.elapsedDistance / unitD : 0;
	}

	function onWorkoutStarted() {
        var info = Activity.getActivityInfo();
        WorkoutStepNr = 1;
        StartTimeNewStep = jTimertime;
        StartDistanceNewStep = (info.elapsedDistance != null) ? info.elapsedDistance / unitD : 0;
    }

	function onUpdate(dc) {
		//! call the parent onUpdate to do the base logic
		ExtramemView.onUpdate(dc);
		var info = Activity.getActivityInfo();		
		
		//!Calculate 10sec averaged power
        var AveragePower5sec  	 			= 0;
        var AveragePower10sec  	 			= 0;
        var currentPowertest				= 0;
		if (info.currentSpeed != null) {
        	currentPowertest = runPower; 
        }
        if (currentPowertest > 0) {
            if (currentPowertest > 0) {
        		Power[10] 								= Power[9];
        		Power[9] 								= Power[8];
        		Power[8] 								= Power[7];
        		Power[7] 								= Power[6];
        		Power[6] 								= Power[5];
        		Power[5] 								= Power[4];
        		Power[4] 								= Power[3];
        		Power[3] 								= Power[2];
        		Power[2] 								= Power[1];
				if (info.currentPower != null) {
        			Power[1]								= runPower; 
        		} else {
        			Power[1]								= 0;
				}        		
				AveragePower10sec	= (Power[1]+Power[2]+Power[3]+Power[4]+Power[5]+Power[6]+Power[7]+Power[8]+Power[9]+Power[10])/10;
				AveragePower5sec	= (Power[1]+Power[2]+Power[3]+Power[4]+Power[5])/5;
				AveragePower3sec	= (Power[1]+Power[2]+Power[3])/3;
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
		rollingPwrValue [rolavPowmaxsecs+1] = runPower;
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

		var ElapsedDistance = (info.elapsedDistance != null) ? info.elapsedDistance / unitD : 0;
		if (Activity has :getCurrentWorkoutStep) {
			workoutTarget = Toybox.Activity.getCurrentWorkoutStep();
			hasWorkoutStep = true;
			WorkoutStepLowBoundary = (workoutTarget != null) ? (workoutTarget.step.targetValueLow.toNumber() - 1000) : 0;
			WorkoutStepHighBoundary = (workoutTarget != null) ? (workoutTarget.step.targetValueHigh.toNumber() - 1000) : 999;
			WorkoutStepLowBoundary = (WorkoutStepLowBoundary == -1000) ? WorkoutStepLowBoundary+1000 : WorkoutStepLowBoundary; 
			WorkoutStepHighBoundary = (WorkoutStepHighBoundary == -1000) ? WorkoutStepHighBoundary+1000 : WorkoutStepHighBoundary;
			WorkoutStepLowBoundary = (uOnlyPwrCorrFactor == false) ? WorkoutStepLowBoundary : WorkoutStepLowBoundary/PwrCorrFactor;
			WorkoutStepHighBoundary = (uOnlyPwrCorrFactor == false) ? WorkoutStepHighBoundary : WorkoutStepHighBoundary/PwrCorrFactor;
			WorkoutStepDurationType = (workoutTarget != null) ? workoutTarget.step.durationType.toNumber() : 0;

			if (workoutTarget != null) {
				WorkoutStepDuration = (workoutTarget.step.durationValue != null) ? workoutTarget.step.durationValue.toNumber() : 9999999;
			} else {
				WorkoutStepDuration = 0;
			}

			if (WorkoutStepDurationType == 0) {
				RemainingWorkoutTime = WorkoutStepDuration - (jTimertime - StartTimeNewStep);
			} else if (WorkoutStepDurationType == 1) {
				RemainingWorkoutDistance = WorkoutStepDuration/unitD - (ElapsedDistance - StartDistanceNewStep);
			} else if (WorkoutStepDuration == 9999999) {
				RemainingWorkoutDistance = 0;
			}
			
		} else {
			hasWorkoutStep = false;
			WorkoutStepLowBoundary = 0;
			WorkoutStepHighBoundary = 999;
			RemainingWorkoutTime = 0;
			RemainingWorkoutDistance = 0;
		}
		
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		
		i = 0; 
	    for (i = 1; i < 8; ++i) {
	        if (metric[i] == 38) {
    	        fieldValue[i] =  runPower;     	        
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
			} else if (metric[i] == 55) {   
            	if (info.currentSpeed == null or info.currentSpeed==0) {
            		fieldValue[i] = 0;
            	} else {
            		fieldValue[i] = (info.currentSpeed > 0.001) ? 100/info.currentSpeed : 0;
            	}
            	fieldLabel[i] = "s/100m";
        	    fieldFormat[i] = "1decimal";
        	} else if (metric[i] == 25) {
    	        fieldValue[i] = (LapPower != 0) ? mLapSpeed*60/LapPower : 0;
        	    fieldLabel[i] = "Lap EI";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 26) {
    	        fieldValue[i] = (LastLapPower != 0) ? mLastLapSpeed*60/LastLapPower : 0;
        	    fieldLabel[i] = "LL EI";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 27) {
	            fieldValue[i] = (info.averageSpeed != null && AveragePower != 0) ? info.averageSpeed*60/AveragePower : 0;
    	        fieldLabel[i] = "Avg EI";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 31) {
	            fieldValue[i] = (runPower != 0) ? Averagespeedinmper3sec*60/runPower : 0;
    	        fieldLabel[i] = "Cur EI";
        	    fieldFormat[i] = "2decimal";
	        } else if (metric[i] == 33) {
	        	if (LapHeartrate != 0) {
					fieldValue[i] = (0.00001 + LapPower) / LapHeartrate;
				} else {
					fieldValue[i] = 0;
				}
        	    fieldLabel[i] = "L P2HR";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 34) {
				if (LastLapHeartrate != 0) {
					fieldValue[i] = (0.00001 + LastLapPower) / LastLapHeartrate;
				} else {
					fieldValue[i] = 0;
				}   	        
        	    fieldLabel[i] = "LL P2HR";
            	fieldFormat[i] = "2decimal";
			} else if (metric[i] == 35) {
				if (AverageHeartrate != 0) {
					fieldValue[i] = (AveragePower+0.00001)/AverageHeartrate;
				} else {
					fieldValue[i]= 0;
				}
    	        fieldLabel[i] = "A  P2HR";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 36) {
				if (info.currentHeartRate != null && info.currentHeartRate != 0) {
					fieldValue[i] = (0.00001 + runPower)/info.currentHeartRate;
				} else {
					fieldValue[i] = 0;
				}
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
    	        fieldLabel[i] = "Pw " + rolavPowmaxsecs + "s";
        	    fieldFormat[i] = "power";
			} else if (metric[i] == 57) {
	            fieldValue[i] = mNormalizedPow;
    	        fieldLabel[i] = "N Power";
        	    fieldFormat[i] = "power";
	        } else if (metric[i] == 80) {
    	        fieldValue[i] = (info.maxPower != null) ? info.maxPower : 0;
        	    fieldLabel[i] = "Max Pwr";
            	fieldFormat[i] = "power";  
			} else if (metric[i] == 71) {
            	fieldValue[i] = (uFTP != 0) ? runPower*100/uFTP : 0;
            	fieldLabel[i] = "%FTP";
            	fieldFormat[i] = "0decimal";   
	        } else if (metric[i] == 72) {
    	        fieldValue[i] = (uFTP != 0) ? AveragePower3sec*100/uFTP : 0;
        	    fieldLabel[i] = "%FTP 3s";
            	fieldFormat[i] = "0decimal";     	
			} else if (metric[i] == 73) {
    	        fieldValue[i] = (uFTP != 0) ? LapPower*100/uFTP : 0;
        	    fieldLabel[i] = "L %FTP";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 74) {
        	    fieldValue[i] = (uFTP != 0) ? LastLapPower*100/uFTP : 0;
            	fieldLabel[i] = "LL %FTP";
            	fieldFormat[i] = "0decimal";
	        } else if (metric[i] == 75) {
    	        fieldValue[i] = (uFTP != 0) ? AveragePower*100/uFTP : 0;
        	    fieldLabel[i] = "A %FTP";
            	fieldFormat[i] = "0decimal";  
	        } else if (metric[i] == 76) {
    	        fieldValue[i] = (uFTP != 0) ? AveragePower5sec*100/uFTP : 0;
        	    fieldLabel[i] = "%FTP 5s";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 77) {
    	        fieldValue[i] = (uFTP != 0) ? AveragePower10sec*100/uFTP : 0;
        	    fieldLabel[i] = "%FTP 10s";
            	fieldFormat[i] = "0decimal";
			} else if (metric[i] == 78) {
	            fieldValue[i] = (uFTP != 0) ? Averagepowerpersec*100/uFTP : 0;
    	        fieldLabel[i] = "%FTP ..sec";
        	    fieldFormat[i] = "0decimal";
			} else if (metric[i] == 58) {
	            fieldValue[i] = mIntensityFactor;
    	        fieldLabel[i] = "IF";
        	    fieldFormat[i] = "2decimal";
			} else if (metric[i] == 59) {
	            fieldValue[i] = mTTS;
    	        fieldLabel[i] = "TSS";
        	    fieldFormat[i] = "0decimal";
			} else if (metric[i] == 60) {
	            fieldValue[i] = RSS;
    	        fieldLabel[i] = "RSS";
        	    fieldFormat[i] = "0decimal";
        	} else if (metric[i] == 93) {
				if (runPower != 0) {
            		fieldValue[i] = CurrentSpeedinmpersec*uWeight/runPower;
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
            } else if (metric[i] == 106) {
	            fieldValue[i] = (PwrCorrFactor-1)*100;
    	        fieldLabel[i] = "Pw cor%";
        	    fieldFormat[i] = "2decimal";
        	} else if (metric[i] == 107) {
	            if (workoutTarget != null) {
        			fieldValue[i] = (uOnlyPwrCorrFactor == false) ? (mPowerWarningunder + mPowerWarningupper)/2 : (mPowerWarningunder + mPowerWarningupper)/2/PwrCorrFactor;
        		} else {
	            	fieldValue[i] = (uOnlyPwrCorrFactor == false) ? uPowerTarget : uPowerTarget/PwrCorrFactor;
	            }
    	        fieldLabel[i] = "Ptarget";
        	    fieldFormat[i] = "0decimal";
        	} else if (metric[i] == 117) {
	            fieldValue[i] = (workoutTarget != null) ? WorkoutStepLowBoundary : 0;
    		    fieldLabel[i] = "Ltarget";
        		fieldFormat[i] = "0decimal";
        	} else if (metric[i] == 118) {
	            fieldValue[i] = (workoutTarget != null) ? WorkoutStepHighBoundary : 0;
        		fieldLabel[i] = "Htarget";
        	    fieldFormat[i] = "0decimal";
        	} else if (metric[i] == 119) {
	            if (workoutTarget != null) {
	            	fieldValue[i] = (uFTP != 0) ? WorkoutStepLowBoundary*100/uFTP : 0;
    	        } else {
        			fieldValue[i] = 0;
        		}
        		fieldLabel[i] = "L%target";
        	    fieldFormat[i] = "0decimal";
        	} else if (metric[i] == 120) {
	            if (workoutTarget != null) {
		            fieldValue[i] = (uFTP != 0) ? WorkoutStepHighBoundary*100/uFTP : 100;
    	        } else {
        			fieldValue[i] = 100;
        		}
        		fieldLabel[i] = "H%target";
        	    fieldFormat[i] = "0decimal";
        	} else if (metric[i] == 121) {
	            fieldValue[i] = (workoutTarget != null) ? WorkoutStepNr : 0;
        		fieldLabel[i] = "Step nr";
        	    fieldFormat[i] = "0decimal";
        	} else if (metric[i] == 122) {
	            if (workoutTarget != null) {
		            if (WorkoutStepDurationType == 0) {
						fieldValue[i] = RemainingWorkoutTime;
						fieldLabel[i] = "Remain T";
        	    		fieldFormat[i] = "time";
					} else if (WorkoutStepDurationType == 1) {
						fieldValue[i] = RemainingWorkoutDistance;
						fieldLabel[i] = "Remain D";
        	    		fieldFormat[i] = "2decimal";
        	    	} else if (WorkoutStepDurationType == 5) {
						fieldValue[i] = jTimertime-StartTimeNewStep;
						fieldLabel[i] = "Button";
        	    		fieldFormat[i] = "time";
					}     
    	        } else {
        			fieldValue[i] = 0;
        			fieldLabel[i] = "No workout";
        	    	fieldFormat[i] = "0decimal";
        		}
        	} else if (metric[i] == 131) {
           		fieldValue[i] = Vertgradsmoothed;
            	fieldLabel[i] = "V grade";
            	fieldFormat[i] = "1decimal";
			}
        	//!einde invullen field metrics
		}
		
		//!Calculation of powerbased clock field metrics
		if (uClockFieldMetric == 107) {
			if (workoutTarget != null) {
        		RealPowerTarget = (uOnlyPwrCorrFactor == false) ? (mPowerWarningunder + mPowerWarningupper)/2 : (mPowerWarningunder + mPowerWarningupper)/2/PwrCorrFactor;
        	} else {
	           	RealPowerTarget = (uOnlyPwrCorrFactor == false) ? uPowerTarget : uPowerTarget/PwrCorrFactor;
	        }
		} else if (uClockFieldMetric == 121) {
	        RealWorkoutStepNr = (workoutTarget != null) ? WorkoutStepNr : 0;     
       	} else if (uClockFieldMetric == 122) {
            if (workoutTarget != null) {
	            if (WorkoutStepDurationType == 0) {
					RealRemainingWorkoutTime = RemainingWorkoutTime;
					DistinClockfield = false;
				} else if (WorkoutStepDurationType == 1) {
					RealRemainingWorkoutTime = RemainingWorkoutDistance;
					DistinClockfield = true;
       	    	} else if (WorkoutStepDurationType == 5) {
					RealRemainingWorkoutTime = jTimertime-StartTimeNewStep;
					DistinClockfield = false;
				}     
   	        } else {
       			RealRemainingWorkoutTime = 0;
       			DistinClockfield = false;
       		}
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
        	fieldvalue = Math.round(fieldvalue).toNumber();
			if (jTimertime != 0) {
				if (fieldvalue>mPowerWarningupper or fieldvalue<mPowerWarningunder) {	 
	    			if (fieldvalue>mPowerWarningupper) {
    					mColourFont = mFontalertColorHigh;
    				} else if (fieldvalue<mPowerWarningunder){
    					mColourFont = mFontalertColorLow;
    				} else  { 
        				mColourFont = originalFontcolor;
    				}
    			} 
			 }
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
        } else {
       		dc.drawText(x, y, Garminfont, fieldvalue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }        
       	mColourFont = originalFontcolor;
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xl, yl, Labelfont,  fieldlabel, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
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
        
        mLastLapTimerTimeCadence	= mHeartrateTime - mLastLapTimeCadenceMarker;
        mLastLapElapsedCadence 		= (info.currentCadence != null) ? mElapsedCadence - mLastLapCadenceMarker : 0;
        mLastLapCadenceMarker     	= mElapsedCadence;
        mLastLapTimeCadenceMarker   = mCadenceTime;

        mLastLapTimerTimePwr		= mPowerTime - mLastLapTimePwrMarker;
        mLastLapElapsedPower  		= (info.currentPower != null) ? mElapsedPower - mLastLapPowerMarker : 0;
        mLastLapPowerMarker         = mElapsedPower;
        mLastLapTimePwrMarker       = mPowerTime;        

        mLaps++;	
	}
}
