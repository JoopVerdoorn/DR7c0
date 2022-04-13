using Toybox.Attention;

class PowerView extends CiqView { 
    
    function initialize() {
        CiqView.initialize();
        var mApp = Application.getApp();    
    }
	
	function onUpdate(dc) {
		//! call the parent function in order to execute the logic of the parent
		CiqView.onUpdate(dc);
	}
}