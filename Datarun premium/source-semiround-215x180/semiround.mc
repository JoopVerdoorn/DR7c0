using Toybox.Graphics as Gfx;

//! inherit from the view that contains the commonlogic
class DeviceView extends PowerView {

	//! it's good practice to always have an initialize, make sure to call your parent class here!
    function initialize() {
        PowerView.initialize();
    }

	function onUpdate(dc) {
		//! call the parent function in order to execute the logic of the parent
		PowerView.onUpdate(dc);
		var info = Activity.getActivityInfo();

        var fString = "%.2f";
         if (mElapsedDistance > 100) {
             fString = "%.1f";
         }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

		for (var i = 1; i < 8; ++i) {
	    	if ( i == 1 ) {			//!upper row, left
        		dc.drawText(56, 69, Graphics.FONT_NUMBER_MEDIUM, Formatting(fieldValue[i],fieldFormat[i]), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		dc.drawText(73, 38, Graphics.FONT_XTINY,  fieldLabel[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	       	} else if ( i == 2 ) {	//!upper row, right
    	    	dc.drawText(170, 69, Graphics.FONT_NUMBER_MEDIUM, Formatting(fieldValue[i],fieldFormat[i]), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		dc.drawText(167, 38, Graphics.FONT_XTINY,  fieldLabel[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	       	} else if ( i == 3 ) {  //!middle row, left
    	    	dc.drawText(34, 133, Graphics.FONT_NUMBER_MEDIUM, Formatting(fieldValue[i],fieldFormat[i]), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		dc.drawText(36, 101, Graphics.FONT_XTINY,  fieldLabel[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	       	} else if ( i == 4 ) {	//!middle row, middle
    	    	dc.drawText(118, 133, Graphics.FONT_NUMBER_MEDIUM, Formatting(fieldValue[i],fieldFormat[i]), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		dc.drawText(118, 101, Graphics.FONT_XTINY,  fieldLabel[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	       	} else if ( i == 5 ) {  //!middle row, right
    	    	dc.drawText(198, 133, Graphics.FONT_NUMBER_MEDIUM, Formatting(fieldValue[i],fieldFormat[i]), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		dc.drawText(201, 101, Graphics.FONT_XTINY,  fieldLabel[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	       	} else if ( i == 6 ) {	//!lower row, left
    	    	dc.drawText(69, 177, Graphics.FONT_NUMBER_MEDIUM, Formatting(fieldValue[i],fieldFormat[i]), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		dc.drawText(80, 207, Graphics.FONT_XTINY,  fieldLabel[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	       	} else if ( i == 7 ) {	//!lower row, right
    	    	dc.drawText(165, 177, Graphics.FONT_XTINY, Formatting(fieldValue[i],fieldFormat[i]), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        		dc.drawText(154, 207, Graphics.FONT_XTINY,  fieldLabel[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
       		}       	
		}
	}

}