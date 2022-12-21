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
		
        dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		//! Show clock with current time in top
		myTime = Toybox.System.getClockTime(); 
    	strTime = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d");
		dc.drawText(140, -3, Graphics.FONT_MEDIUM, strTime, Graphics.TEXT_JUSTIFY_CENTER);

		//! Display metrics
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
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"082,207,085,018,198,093,242");
			} else if ( i == 7 ) {	//!lower row, right
				Formatting(dc,i,fieldValue[i],fieldFormat[i],fieldLabel[i],"198,207,210,142,217,183,242");
       		}       	
		}
		
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
	}

}