using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

//! inherit from the view that contains the commonlogic
class DeviceView extends PowerView {
	var myTime;
	var strTime;

	//! it's good practice to always have an initialize, make sure to call your parent class here!
    function initialize() {
        PowerView.initialize();
    }

	function onUpdate(dc) {
		//! call the parent function in order to execute the logic of the parent
		PowerView.onUpdate(dc);
                
		//! Conditions for showing the demoscreen       
        if (uShowDemo == false) {
        	if (licenseOK == false && jTimertime > 900)  {
        		uShowDemo = true;        		
        	}
        }

	   //! Check whether demoscreen is showed or the metrics 
	   if (uShowDemo == false ) {

		//! Draw separator lines
        dc.setColor(mColourLine, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        //! Horizontal thirds
		dc.drawLine(47,  33,  233, 33);
        dc.drawLine(0,   107,  277, 107);
        dc.drawLine(0,   182, 277, 182);

        //! Top vertical divider
        dc.drawLine(139, 34,  139, 107);

        //! Centre vertical dividers
        dc.drawLine(85,  107,  85,  182);
        dc.drawLine(191, 107,  191, 182);

        //! Bottom vertical divider
        dc.drawLine(139, 182, 139, 256);
        
        //! Bottom horizontal divider
        dc.drawLine(62, 256, 218, 256);


		//! Display metrics
        dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);

		myTime = Toybox.System.getClockTime(); 
    	strTime = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d");
		//! Show number of laps or clock with current time in top
		if (uMilClockAltern == 0) {		
			dc.drawText(140, -3, Graphics.FONT_MEDIUM, strTime, Graphics.TEXT_JUSTIFY_CENTER);
		}

		for (var i = 1; i < 8; ++i) {
	    	if ( i == 1 ) {			//!upper row, left
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"081,079,085,015,089,085,043");
			} else if ( i == 2 ) {	//!upper row, right
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"198,079,210,142,089,195,043");
			} else if ( i == 3 ) {  //!middle row, left	
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"042,153,000,000,000,042,117");
			} else if ( i == 4 ) {	//!middle row, middle
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"138,153,000,000,000,138,117");
			} else if ( i == 5 ) {  //!middle row, right	
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"236,153,000,000,000,235,117");
			} else if ( i == 6 ) {	//!lower row, left
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"082,207,085,018,198,093,244");
			} else if ( i == 7 ) {	//!lower row, right
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"198,207,210,142,217,183,244");
       		}       	
		}
		
//! 		if (jTimertime == 0) {
//! 	    	if (ID0 != 3624 and ID0 != 3588 and ID0 != 3762 and ID0 != 3761 and ID0 != 3757 and ID0 != 3758 and ID0 != 3759) {
//! 		    	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
//! 				dc.drawText(120, 160, Graphics.FONT_MEDIUM, strTime, Graphics.TEXT_JUSTIFY_CENTER);
//! 		    }
//! 		}
		
		//! Bottom battery indicator
	 	var stats = Sys.getSystemStats();
		var pwr = stats.battery;
		var mBattcolor = (pwr > 15) ? mColourFont : Graphics.COLOR_RED;
		dc.setColor(mBattcolor, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(107, 259, 63, 18);
		dc.fillRectangle(170, 264, 4, 8);
	
		dc.setColor(mColourBackGround, Graphics.COLOR_TRANSPARENT);
		var Startstatuspwrbr = 110 + Math.round(pwr*0.58)  ;
		var Endstatuspwrbr = 58 - Math.round(pwr*0.58) ;
		dc.fillRectangle(Startstatuspwrbr, 261, Endstatuspwrbr, 14);	

	   } else {
	   //! Display demo screen
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);

		if (licenseOK == true) {
      		dc.drawText(140, 40, Graphics.FONT_XTINY, "Datarun prem 7 c0", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(140, 120, Graphics.FONT_TINY, "Registered !!", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(81, 160, Graphics.FONT_XTINY, "License code: ", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(180, 160, Graphics.FONT_MEDIUM, mtest, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(81, 190, Graphics.FONT_XTINY, "C-Code: ", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(170, 190, Graphics.FONT_MEDIUM, CCode, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
		} else {
      		dc.drawText(140, 33, Graphics.FONT_XTINY, "License needed !!", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
      		dc.drawText(140, 63, Graphics.FONT_XTINY, "Run is recorded though", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(60, 105, Graphics.FONT_MEDIUM, "ID 0: ", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(161, 99, Graphics.FONT_NUMBER_MEDIUM, ID0, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(60, 155, Graphics.FONT_MEDIUM, "ID 1: " , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(161, 149, Graphics.FONT_NUMBER_MEDIUM, ID1, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(60, 205, Graphics.FONT_MEDIUM, "ID 2: " , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(161, 199, Graphics.FONT_NUMBER_MEDIUM, ID2, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
      	}
	   }
	   
	}

}