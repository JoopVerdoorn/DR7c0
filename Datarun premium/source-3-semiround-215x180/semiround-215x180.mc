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

		//! Draw separator lines
        dc.setColor(mColourLine, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        //! Horizontal thirds
        dc.drawLine(0,   63,  215, 63);
        dc.drawLine(0,   122, 215, 122);

        //! Top vertical divider
        dc.drawLine(107, 26,  107, 63);

        //! Centre vertical dividers
        dc.drawLine(66,  63,  66,  122);
        dc.drawLine(149, 63,  149, 122);

        //! Bottom vertical divider
        dc.drawLine(107, 122, 107, 180);
                
        //! Bottom horizontal divider
        dc.drawLine(50, 202, 175, 202);

        //! Top centre mini-field separator
        dc.drawRoundedRectangle(72, -10, 72, 36, 4);

		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		//! Show clock with current time in top
		myTime = Toybox.System.getClockTime(); 
    	strTime = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d"); 		
		dc.drawText(98, -4, Graphics.FONT_NUMBER_MILD, strTime, Graphics.TEXT_JUSTIFY_CENTER);

		//! Display metrics
		for (var i = 1; i < 8; ++i) {
	    	if ( i == 1 ) {			//!upper row, left
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"062,041,065,015,047,052,015");
	       	} else if ( i == 2 ) {	//!upper row, right
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"154,041,160,111,047,168,015");
	       	} else if ( i == 3 ) {  //!middle row, left
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"031,100,000,000,000,033,071");
	       	} else if ( i == 4 ) {	//!middle row, middle
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"107,100,000,000,000,107,071");
	       	} else if ( i == 5 ) {  //!middle row, right
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"180,100,000,000,000,181,071");
	       	} else if ( i == 6 ) {	//!lower row, left
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"062,143,066,017,139,072,171");
	       	} else if ( i == 7 ) {	//!lower row, right
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"150,143,158,111,149,148,171");
       		}       	
		}


		//! Top battery indicator
	 	var stats = Sys.getSystemStats();
		var pwr = stats.battery;
		var mBattcolor = (pwr > 15) ? mColourFont : Graphics.COLOR_RED;
		dc.setColor(mBattcolor, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(125, 3, 15, 19);
		dc.fillRectangle(128, 1, 9, 3);
		
		dc.setColor(mColourBackGround, Graphics.COLOR_TRANSPARENT);
		var Endstatuspwrbr = 0.15*(100-pwr)  ;
		var Startstatuspwrbr = 5  ;
		dc.fillRectangle(127, Startstatuspwrbr, 11, Endstatuspwrbr);	   
	}

}