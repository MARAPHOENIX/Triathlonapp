using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Position as Pos;
using Toybox.ActivityRecording as Rec;
using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.Timer as Timer;
using Toybox.Sensor as Sensor;

class TriathlonApp extends App.AppBase {

    //! onStart() is called on application start up
    function onStart(state) {
    	// Load config
    	

		// Make sure we have a default Triathlon mode    	
		var trimode = getProperty( "TriathlonMode" );
		if( trimode == null ) {
			setProperty( "TriathlonMode", 0 );
		}
		
		//var autoLapMode = getProperty( "AutolapMode" );
		//if( autoLapMode == null ) {
			//setProperty( "AutolapMode", true );
		//}
		

    	// Get the GPS ready
    	Pos.enableLocationEvents( Pos.LOCATION_CONTINUOUS, method(:onPosition));
    	var sensorsenabled = Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_BIKESPEED, Sensor.SENSOR_BIKECADENCE]);
    	
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    	//saveProperties();
    	Pos.enableLocationEvents( Pos.LOCATION_DISABLE, method(:onPosition));
    }

    //! Return the initial view of your application here
    function getInitialView() {
    	var view = new TriathlonView();
    	var dele = new TriathlonViewInputDelegate();
        return [ view, dele ];
    }
    
    function onPosition(info) {
    }

}