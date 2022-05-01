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
		dc.drawLine(70,  49,  346, 49);
        dc.drawLine(0,   159,  412, 159);
        dc.drawLine(0,   270, 412, 270);

        //! Top vertical divider
        dc.drawLine(207, 51,  207, 159);

        //! Centre vertical dividers
        dc.drawLine(126,  159,  126,  270);
        dc.drawLine(284, 159,  284, 270);

        //! Bottom vertical divider
        dc.drawLine(207, 270, 207, 380);
        
        //! Bottom horizontal divider
        dc.drawLine(92, 380, 324, 380);
        
        //! Display GPS accuracy
        dc.setColor(mGPScolor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(18, 9, 114, 40); 
		if (uMilClockAltern == 1) {
		   dc.fillRectangle(313, 9, 95, 40);
		} else {
		   dc.fillRectangle(284, 9, 95, 40);
		}

        dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		//! Show number of laps or clock with current time in top
		myTime = Toybox.System.getClockTime(); 
    	strTime = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d");
		if (uMilClockAltern == 0) {		
			dc.drawText(208, 0, Graphics.FONT_MEDIUM, strTime, Graphics.TEXT_JUSTIFY_CENTER);
		}

		//! Display metrics
		for (var i = 1; i < 8; ++i) {
	    	if ( i == 1 ) {			//!upper row, left
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"120,117,126,022,132,126,064");
			} else if ( i == 2 ) {	//!upper row, right
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"294,117,312,211,132,290,064");
			} else if ( i == 3 ) {  //!middle row, left	
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"062,227,000,000,000,062,174");
			} else if ( i == 4 ) {	//!middle row, middle
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"205,227,000,000,000,205,174");
			} else if ( i == 5 ) {  //!middle row, right	
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"351,227,000,000,000,349,174");
			} else if ( i == 6 ) {	//!lower row, left
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"122,308,126,027,294,138,365");
			} else if ( i == 7 ) {	//!lower row, right
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"294,308,312,211,322,272,365");
       		}       	
		}
		
		//! Bottom battery indicator
	 	var stats = Sys.getSystemStats();
		var pwr = stats.battery;
		var mBattcolor = (pwr > 15) ? mColourFont : Graphics.COLOR_RED;
		dc.setColor(mBattcolor, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(159, 385, 94, 27);
		dc.fillRectangle(253, 392, 6, 12);
	
		dc.setColor(mColourBackGround, Graphics.COLOR_TRANSPARENT);
		var Startstatuspwrbr = 163 + Math.round(pwr*0.86)  ;
		var Endstatuspwrbr = 86 - Math.round(pwr*0.86) ;
		dc.fillRectangle(Startstatuspwrbr, 388, Endstatuspwrbr, 21);	

	   } else {
	   //! Display demo screen
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);

		if (licenseOK == true) {
			dc.drawText(208, 178, Graphics.FONT_TINY, "Registered !!", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(120, 238, Graphics.FONT_XTINY, "License code: ", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(267, 238, Graphics.FONT_MEDIUM, mtest, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			if (c0Version == true) {
				dc.drawText(120, 282, Graphics.FONT_XTINY, "C-Code: ", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
				dc.drawText(253, 282, Graphics.FONT_MEDIUM, CCode, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			}
		} else {
      		dc.drawText(208, 49, Graphics.FONT_XTINY, "License needed !!", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
      		dc.drawText(208, 94, Graphics.FONT_XTINY, "Run is recorded though", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(89, 156, Graphics.FONT_MEDIUM, "ID 0: ", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(249, 147, Graphics.FONT_NUMBER_MEDIUM, ID0, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(89, 230, Graphics.FONT_MEDIUM, "ID 1: " , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(249, 221, Graphics.FONT_NUMBER_MEDIUM, ID1, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(89, 305, Graphics.FONT_MEDIUM, "ID 2: " , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(249, 296, Graphics.FONT_NUMBER_MEDIUM, ID2, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
      	}
	   }
	   
	}

}