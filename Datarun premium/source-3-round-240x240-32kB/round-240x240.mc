using Toybox.Graphics as Gfx;
using Toybox.System as Sys;


class DeviceView extends PowerView {
	var myTime;
	var strTime;

    function initialize() {
        PowerView.initialize();
    }

	function onUpdate(dc) {
		PowerView.onUpdate(dc);

		//! Draw separator lines
        dc.setColor(mColourLine, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        //! Horizontal thirds
        dc.drawLine(40,  28,  200, 28);
        dc.drawLine(0,   92,  237, 92);
        dc.drawLine(0,   156, 237, 156);

        //! Top vertical divider
        dc.drawLine(119, 29,  119, 92);

        //! Centre vertical dividers
        dc.drawLine(73,  92,  73,  156);
        dc.drawLine(164, 92,  164, 156);

        //! Bottom vertical divider
        dc.drawLine(119, 156, 119, 219);
        
        //! Bottom horizontal divider
        dc.drawLine(53, 219, 187, 219);

		//! Display metrics
        dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);

		//! Show military clock in top
		myTime = Toybox.System.getClockTime(); 
    	strTime = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d");
		dc.drawText(120, -4, Graphics.FONT_MEDIUM, strTime, Graphics.TEXT_JUSTIFY_CENTER);

		for (var i = 1; i < 8; ++i) {
	    	if ( i == 1 ) {			//!upper row, left
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"069,067,073,013,077,073,037");
	       	} else if ( i == 2 ) {	//!upper row, right
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"170,067,180,121,077,167,037");
	       	} else if ( i == 3 ) {  //!middle row, left
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"036,131,000,000,000,036,101");
	       	} else if ( i == 4 ) {	//!middle row, middle
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"118,131,000,000,000,118,101");
	       	} else if ( i == 5 ) {  //!middle row, right
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"202,131,000,000,000,201,101");
	       	} else if ( i == 6 ) {	//!lower row, left
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"070,177,073,014,170,080,207");
	       	} else if ( i == 7 ) {	//!lower row, right
	    		Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"170,177,180,121,185,157,207");
       		}       	
		}
		
		if (jTimertime == 0) {
	    	if (uShowRedClock == true) {
		    	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
				dc.drawText(120, 160, Graphics.FONT_MEDIUM, strTime, Graphics.TEXT_JUSTIFY_CENTER);
		    }
		}
		
		//! Bottom battery indicator
	 	var stats = Sys.getSystemStats();
		var pwr = stats.battery;
		var mBattcolor = (pwr > 15) ? mColourFont : Graphics.COLOR_RED;
		dc.setColor(mBattcolor, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(92, 222, 54, 15);
		dc.fillRectangle(146, 225, 3, 8);
		
		dc.setColor(mColourBackGround, Graphics.COLOR_TRANSPARENT);
		var Startstatuspwrbr = 94 + pwr*0.5  ;
		var Endstatuspwrbr = 50 - pwr*0.5 ;
		dc.fillRectangle(Startstatuspwrbr, 224, Endstatuspwrbr, 11);	
	}

}