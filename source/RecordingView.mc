using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Activity as Act;
using Toybox.ActivityRecording as Rec;
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.Timer as Timer;
using Toybox.Sensor as Sensor;

var LapTime = 0;
var elapsedLapTimeP = 0;
var elapsedLapDistanceP = 0.0;
var LapCounter = 0;
var lapPace = "";
var lapDistance = "";
var change = 0;
var paceData = new DataQueue(10);
var paceData30 = new DataQueue(30);
var paceData3 = new DataQueue(3);

var screen = 0;

var lapInitDistance = 0.0;
var lapInitTime = 0;
var lapVel = 0.0d;

var vue = 0;
var dataLap = 0;

class RecordingViewInputDelegate extends Ui.InputDelegate {


	function onKey(evt) {
	
		if( evt.getKey() == Ui.KEY_ENTER ) {
			if (App.getApp().getProperty( "TwoTimesPressLap" ) == true){
				//System.println("twopress");
				change = change + 1;
				if (change == 2){
					change = 0;
					TriData.nextDiscipline();
					Ui.requestUpdate();
				}
			}
			else{
				//System.println("onepress");
				TriData.nextDiscipline();
				Ui.requestUpdate();
			}
		}
		
		if( evt.getKey() == Ui.KEY_MENU ) {
			TriData.nextDisciplineDiscard();
			Ui.requestUpdate();
		}
		
		if( evt.getKey() == Ui.KEY_UP ) {
			if (screen == 0){
				if (App.getApp().getProperty( "Choix" ) == 0){
	    			App.getApp().setProperty( "Choix",1);
	    		}else{
	    			App.getApp().setProperty( "Choix",0);
	    		}
	    		screen = 1;
			}else{
				if (App.getApp().getProperty( "FondEcran" ) == 0){
    				App.getApp().setProperty( "FondEcran",1);
    			}else{
    				App.getApp().setProperty( "FondEcran",0);
    			}
				screen = 0;
			}
    		
    		Ui.requestUpdate();
    
        }
        
        
		if( evt.getKey() == Ui.KEY_DOWN ) {
			//System.println("vue : " + vue + " - dataLap " + dataLap + " - Format : " +   App.getApp().getProperty( "Format" ) );
		
			if (vue == 0){
				if (App.getApp().getProperty( "Format" ) == 0){
    				App.getApp().setProperty( "Format",1);
	    		}else{
	    			App.getApp().setProperty( "Format",0);
	    		}
			}
			
			if (vue == 1){
				if (dataLap  ==  0){
					dataLap = 1;
			
				}else{
					dataLap = 0;
				}
			}
			
			
			if (vue == 0){
				vue ++;
			}else{
				vue = 0;
			}
			
    		Ui.requestUpdate();
    
        }
        
        
        if( evt.getKey() ==  Ui.KEY_ESC  ) {
        	//lap idem onTimerLap
        	var cursession = Act.getActivityInfo();
			var elapsedLapTime = 0; // (ms)  
			var elapsedLapDistance = 0.0; // (m)
			var lapVel = 0.0d;
			var elapsedTime = cursession.elapsedTime;
			var elapsedDistance = cursession.elapsedDistance;
			
		
			if ( elapsedTime != null && elapsedTime > 0 && elapsedDistance != null  && elapsedDistance > 0){
				elapsedLapTime = cursession.elapsedTime - lapInitTime;
				elapsedLapDistance = cursession.elapsedDistance - lapInitDistance;
				if ( elapsedLapTime > 0 && elapsedLapDistance > 0 ){
					lapVel = elapsedLapDistance.toDouble()/(elapsedLapTime.toDouble()/1000);
				}
			}
				
			
			TriData.nextLap();
			LapTime = elapsedLapTime;
			
			lapInitTime = lapInitTime + LapTime;
			lapInitDistance = lapInitDistance + elapsedLapDistance;
			
			LapCounter = LapCounter + 1;
			Ui.pushView(new LapView(), new RecordingViewInputDelegate(), Ui.SLIDE_IMMEDIATE);
					
	
			
				
			lapPace = Functions.convertSpeedToPace(lapVel,0);
        	lapDistance = Functions.convertDistance(elapsedLapDistance);
        	
    		Ui.requestUpdate();
    
        }
        
        
	
		
		// Imply that we handle everything
		return true;
	}
	
	function onTap(evt) {
		// No tap events
		return true;
	}
	
	function onSwipe(evt) {
		// No tap events
		return true;
	}
	
	function onHold(evt) {
		// No tap events
		return true;
	}
	
	function onRelease(evt) {
		// No tap events
		return true;
	}


}

class RecordingView extends Ui.View {
    hidden const CENTER = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    hidden var textColor = Graphics.COLOR_BLACK;
    hidden var inverseTextColor = Graphics.COLOR_WHITE;
    
	var recordingtimer;
	var i = 0;
	var string_HR;

	
	
    function recordingtimercallback()
    {
        Ui.requestUpdate();
    }

    //! Load your resources here
    function onLayout(dc) {
    	string_HR = "---";
		recordingtimer = new Timer.Timer();
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
    	
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
		dc.clear();
		
		changeReset();
		Sensor.enableSensorEvents(method(:onSnsr));
		
		//drawSegments(dc);
		
		if (App.getApp().getProperty( "Choix" ) == 0){
			drawTitleBar(dc);
			drawGPS(dc);
			drawDataFieldsInit(dc);
		}else{
			//drawTitleBar(dc);
			//drawGPS(dc);
			var color = inverseTextColor;
			if (App.getApp().getProperty( "FondEcran" ) == 0){
			    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
       		    dc.fillRectangle(0, 0, 218, 218);
			}else{
			 	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
       		    dc.fillRectangle(0, 0, 218, 218);
       		    color = textColor;
			}
			drawDataFields(dc,color);
		}
		
		
		
    }
    
    function onSnsr(sensor_info) {
        var HR = sensor_info.heartRate;
        var bucket;
        if( sensor_info.heartRate != null )  {
            string_HR = HR.toString();
            
            if (App.getApp().getProperty( "Choix" ) == 0){
            	string_HR = string_HR + "bpm"; 
            }

        }
        else  {
            string_HR = "---";
        }
        
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
	///////////////////////////////////////////////////////////////////////////////////// Render functions
    function drawGPS(dc) {
		var gpsinfo = Pos.getInfo();
		var gpsIsOkay = ( gpsinfo.accuracy == Pos.QUALITY_GOOD || gpsinfo.accuracy == Pos.QUALITY_USABLE );
		
		dc.setColor( Functions.getGPSQualityColour(gpsinfo), Gfx.COLOR_BLACK);
		dc.fillRectangle(0, 40, dc.getWidth(), 2);
    }

	function drawSegments(dc) {
		var segwidth = (dc.getWidth() - 8) / 4;
		var xfwidth = segwidth / 2;
		
		var curx = 0;
		
		
		dc.setColor( getSegmentColour(0), Gfx.COLOR_BLACK );
		Functions.drawChevron(dc, curx, curx + segwidth, 38, 10, true, false);
		curx += segwidth + 2;
		
		dc.setColor( getSegmentColour(1), Gfx.COLOR_BLACK );
		Functions.drawChevron(dc, curx, curx + xfwidth, 38, 10, false, false);
		curx += xfwidth + 2;

		dc.setColor( getSegmentColour(2), Gfx.COLOR_BLACK );
		Functions.drawChevron(dc, curx, curx + segwidth, 38, 10, false, false);
		curx += segwidth + 2;

		dc.setColor( getSegmentColour(3), Gfx.COLOR_BLACK );
		Functions.drawChevron(dc, curx, curx + xfwidth, 38, 10, false, false);
		curx += xfwidth + 2;

		dc.setColor( getSegmentColour(4), Gfx.COLOR_BLACK );
		Functions.drawChevron(dc, curx, dc.getWidth(), 38, 10, false, true);
	}
	
	function getSegmentColour(segmentNumber) {
		if( TriData.currentDiscipline == segmentNumber ) {
			return Gfx.COLOR_ORANGE;
		} else if( TriData.currentDiscipline > segmentNumber ) {
			return Gfx.COLOR_DK_GREEN;
		}
		return Gfx.COLOR_LT_GRAY;
	}
	
	function drawTitleBar(dc) {
		var elapsedTime = Sys.getTimer() - TriData.disciplines[0].startTime;
		
		dc.drawBitmap( 55, 5, TriData.disciplines[TriData.currentDiscipline].currentIcon );
		
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		//dc.drawText(69, 0, Gfx.FONT_MEDIUM, "Total:", Gfx.TEXT_JUSTIFY_LEFT);
		dc.drawText(dc.getWidth() - 60, 10, Gfx.FONT_MEDIUM, Functions.msToTime(elapsedTime), Gfx.TEXT_JUSTIFY_RIGHT);
	}
	
	function drawDataFieldsInit(dc) {
		var y = 44;
		
		
		// Discipline Time
		var elapsedTime = Sys.getTimer() - TriData.disciplines[TriData.currentDiscipline].startTime;
		y = drawDataField( dc, "Temps :", Functions.msToTime(elapsedTime), y );
		
		if( TriData.currentDiscipline == 1 || TriData.currentDiscipline == 3 ) {
			y = drawDataField( dc, null, "Transistion", y );
		} else {
			var cursession = Act.getActivityInfo();
			y = drawDataField( dc, "Distance:", Functions.convertDistance(cursession.elapsedDistance), y );
			if ( TriData.disciplines[TriData.currentDiscipline].currentStage == 0 ){ 
				y = drawDataField( dc, "Pace:", Functions.convertSpeedToSwim(cursession.currentSpeed), y );
			} 
			else if ( TriData.disciplines[TriData.currentDiscipline].currentStage == 2 ){
				y = drawDataField( dc, "Vel.:", Functions.convertSpeedToBike(cursession.currentSpeed,1), y );
			}
			else if ( TriData.disciplines[TriData.currentDiscipline].currentStage == 4 ){
				paceData.add(cursession.currentSpeed);
				paceData30.add(cursession.currentSpeed);
    			paceData3.add(cursession.currentSpeed);
				calculateLapPace();
				if(App.getApp().getProperty( "PaceField" ) == 0){
					y = drawDataField( dc, "Pace:", Functions.convertSpeedToPace(Functions.computeAverageSpeed(paceData),1), y );
				}
				else if (App.getApp().getProperty( "PaceField" ) == 1){
					y = drawDataField( dc, "Avg. Pace:", Functions.convertSpeedToPace(cursession.averageSpeed,1), y );
				}
				else{
					//System.println("lapPace : " + lapPace + " - " + Functions.convertSpeedToPace(Functions.computeAverageSpeed(paceData),1) + " - " +  Functions.convertSpeedToPace(cursession.averageSpeed,1));
					//System.println("lapPace : " + lapPace + " - " + LapTime);
					
					y = drawDataField( dc, "Lap Pace:", lapPace, y );
				}
			}
		}
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
		dc.drawText(35, y + (dc.getFontHeight( Gfx.FONT_MEDIUM ) - dc.getFontHeight( Gfx.FONT_SMALL )) / 2, Gfx.FONT_MEDIUM, "HR:", Gfx.TEXT_JUSTIFY_LEFT);
		dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(dc.getWidth() - 35, y, Gfx.FONT_LARGE, string_HR, Gfx.TEXT_JUSTIFY_RIGHT);
		y += dc.getFontHeight( Gfx.FONT_LARGE );
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
		dc.drawLine( 0, y, dc.getWidth(), y );
		
        //dc.drawText(dc.getWidth()/2-3, 57, Graphics.FONT_NUMBER_THAI_HOT, Functions.getMinutesPerKmOrMile(Functions.computeAverageSpeed(paceData)), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		
	}
	
	
	function drawDataFields(dc,color) {
		dc.setColor(color, Gfx.COLOR_TRANSPARENT);
		var cursession = Act.getActivityInfo();
		//vitesse moy 10s
		paceData.add(cursession.currentSpeed);
		paceData30.add(cursession.currentSpeed);
    	paceData3.add(cursession.currentSpeed);
		var computeAvgSpeed = Functions.computeAverageSpeed(paceData);
		var computeAvgSpeed3s = Functions.computeAverageSpeed(paceData3);
		var computeAvgSpeed30s = Functions.computeAverageSpeed(paceData30);
		
		var font = Graphics.FONT_NUMBER_HOT;
		
		var data = Functions.getMinutesPerKmOrMile(computeAvgSpeed);
		var largeur = dc.getWidth()/2 - 3;
		var avg = Functions.getMinutesPerKmOrMile(cursession.averageSpeed);
		
		if (dataLap == 1){
			avg =Functions.getMinutesPerKmOrMile(lapVel);
		}
		
		if (App.getApp().getProperty( "Format" ) == 1){
			data = Functions.convertSpeedToBike(computeAvgSpeed,0);
			largeur =  dc.getWidth()/2 + 3;
			avg = Functions.convertSpeedToBike(cursession.averageSpeed,0);
			if (dataLap == 1){
				avg = Functions.convertSpeedToBike(lapVel,0);
			}
			
		}
		
	    if (computeAvgSpeed>=1.67){
        	font =  Graphics.FONT_NUMBER_THAI_HOT;
        	dc.drawText(largeur, 57, font, data, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }else{
        	dc.drawText(largeur, 68, font, data, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

		
		
		//hr
		dc.drawText(30, 76, Graphics.FONT_NUMBER_MEDIUM, string_HR, CENTER);
		
		//vmoy
		dc.drawText(110, 180, Graphics.FONT_NUMBER_HOT,avg, CENTER);
		
		//chrono 
		var elapsedTime = Sys.getTimer() - TriData.disciplines[0].startTime;
		
		
		if (dataLap == 1){
			dc.drawText(150, 131,  Graphics.FONT_NUMBER_MEDIUM, Functions.msToTime(LapTime), CENTER);
			dc.drawText(dc.getWidth()/2+68, dc.getHeight()/2+50, Gfx.FONT_SMALL, LapCounter, Gfx.TEXT_JUSTIFY_CENTER);
		}else{
			dc.drawText(150, 131,  Graphics.FONT_NUMBER_MEDIUM, Functions.msToTime(elapsedTime), CENTER);
		}
		
		
		//dataLap = 1;
		
		//dc.drawText(dc.getWidth()/2, dc.getFontHeight(Gfx.FONT_LARGE)-30, Gfx.FONT_LARGE, "Lap " + LapCounter, Gfx.TEXT_JUSTIFY_CENTER);
		//dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM)/2 -45, Gfx.FONT_NUMBER_HOT, Functions.msToTimeWithDecimals(LapTime.toLong()), Gfx.TEXT_JUSTIFY_CENTER);
		//dc.drawText(dc.getWidth()/2, dc.getHeight()/2-10 , Gfx.FONT_NUMBER_MEDIUM, lapPace, Gfx.TEXT_JUSTIFY_CENTER);
		//dc.drawText(dc.getWidth()/2, dc.getHeight()/2 +40, Gfx.FONT_NUMBER_MEDIUM, lapDistance, Gfx.TEXT_JUSTIFY_CENTER);
		
		
		//distance
		if (dataLap == 1){
			dc.drawText(50 , 131, Graphics.FONT_NUMBER_MEDIUM, lapDistance, CENTER);
		}else{
			dc.drawText(50 , 131, Graphics.FONT_NUMBER_MEDIUM, Functions.convertDistance(cursession.elapsedDistance), CENTER);
		}
		
		
		
		//cadence
		var cadence = cursession.currentCadence != null ? cursession.currentCadence : 0;
		var cadenceStr = "---";
		
		if (cadence > 0){
			cadenceStr = cadence.format("%d");
		} 
		dc.drawText(dc.getWidth()-35, 76, Graphics.FONT_NUMBER_MEDIUM, cadenceStr, CENTER);
		
		//time
        var clockTime = System.getClockTime();
        var time = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%.2d")]);
    
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0,0,218,20);
        dc.setColor(inverseTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(106, 10, Graphics.FONT_TINY, time, CENTER);
        var battery = System.getSystemStats().battery;
        dc.drawText(142, 11, Graphics.FONT_XTINY,battery.format("%d"), CENTER);
        
        var color = inverseTextColor;
        if (App.getApp().getProperty( "FondEcran" ) == 1){
        	color = textColor;
        }
        
        //tendance vitesse
        if (computeAvgSpeed >=computeAvgSpeed3s ){
		   dc.setColor(color, Graphics.COLOR_TRANSPARENT);
		   dc.fillPolygon([[30,40],[50, 40],[40,55]]);
		}else if (computeAvgSpeed3s > computeAvgSpeed){
			dc.setColor(color, Graphics.COLOR_TRANSPARENT);
		    dc.fillPolygon([[30,55],[50, 55],[40,40]]);
		}
		
		//tendance avg
        var vMoy = cursession.averageSpeed != null ? cursession.averageSpeed : 0;
        if (dataLap == 1){
        	vMoy = lapVel;
        }
        
        //System.println("Vmoy " + vMoy +" - " + computeAvgSpeed30s);
        if (vMoy>computeAvgSpeed30s){
             dc.setColor(color, Graphics.COLOR_TRANSPARENT);
             dc.fillPolygon([[30,170],[50, 170],[40,185]]);//DOWN
        }else if (computeAvgSpeed30s>=vMoy){
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon([[30,185],[50, 185],[40,170]]);//UP
        }
        
        calculateLapPace();
        
        //System.println("lapace : " + lapPace + " - " + lapDistance + " - " + LapTime + " - " + Functions.convertSpeedToBike(lapVel,0) + " - " + avg ); 
        //System.println("lapPace : " + lapPace + " - " + LapTime + " - " + lapDistance);
        
        
        //grid
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, 100, dc.getWidth(), 100);
        dc.drawLine(0, 156, dc.getWidth(), 156);
	}
	
	function drawDataField(dc, label, value, y) {
		var smalloffset = (dc.getFontHeight( Gfx.FONT_MEDIUM ) - dc.getFontHeight( Gfx.FONT_SMALL )) / 2;
		
		if( label == null ) {
			dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
			dc.drawText(dc.getWidth() / 2, y, Gfx.FONT_LARGE, value, Gfx.TEXT_JUSTIFY_CENTER);
		} else {
			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
			dc.drawText(20, y + smalloffset, Gfx.FONT_MEDIUM, label, Gfx.TEXT_JUSTIFY_LEFT);
			dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
			dc.drawText(dc.getWidth() - 20, y, Gfx.FONT_LARGE, value, Gfx.TEXT_JUSTIFY_RIGHT);
		}
		y += dc.getFontHeight( Gfx.FONT_LARGE );
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
		dc.drawLine( 0, y, dc.getWidth(), y );
		y++;
		return y;
	}
	
	
	function calculateLapPace(){
		var cursession = Act.getActivityInfo();
		var elapsedLapTime = 0; // (ms)  
		var elapsedLapDistance = 0.0; // (m)
		
		var elapsedTime = cursession.elapsedTime;
		var elapsedDistance = cursession.elapsedDistance;
		
		if (TriData.ChangedDiscipline == true){
			lapInitTime = 0;
			lapInitDistance = 0.0;
			LapCounter = 0;
			TriData.ChangedDiscipline = false;
		}else{
			if ( elapsedTime != null && elapsedTime > 0 && elapsedDistance != null  && elapsedDistance > 0){
				elapsedLapTime = cursession.elapsedTime - lapInitTime;
				elapsedLapDistance = cursession.elapsedDistance - lapInitDistance;
				if ( elapsedLapTime > 0 && elapsedLapDistance > 0 ){
					lapVel = elapsedLapDistance.toDouble()/(elapsedLapTime.toDouble()/1000);
				}
			}
			
			if (App.getApp().getProperty( "AutolapMode" ) == true){
				var autolapdistance = Functions.convertToMeters(App.getApp().getProperty( "AutolapDistance" ));
				if (elapsedLapDistance >= autolapdistance){
					TriData.nextLap();
					LapTime = elapsedLapTimeP + (autolapdistance - elapsedLapDistanceP)/(elapsedLapDistance - elapsedLapDistanceP)*(elapsedLapTime - elapsedLapTimeP);
					lapInitTime = lapInitTime + LapTime;
					lapInitDistance = lapInitDistance + autolapdistance;
					LapCounter = LapCounter + 1;
					Ui.pushView(new LapView(), new RecordingViewInputDelegate(), Ui.SLIDE_IMMEDIATE);
				}
				elapsedLapTimeP = elapsedLapTime;
				elapsedLapDistanceP = elapsedLapDistance;
			}
		}	
		lapPace = Functions.convertSpeedToPace(lapVel,0);
		lapDistance = Functions.convertDistance(elapsedLapDistance);
		LapTime = elapsedLapTime;
		return lapPace;
	}
	
	var resetChange = 0;
	
	function changeReset(){
		if (change == 1){
			resetChange = resetChange + 1;
			if (resetChange == 2){
				resetChange = 0;
				change = 0;
			}
		} 
	}
	
}

// View when a lap is completed
class LapView extends Ui.View {
	
	var laptimer;
	var counter = 0;
	
	function laptimercallback()
    {
        Ui.requestUpdate();
    }
	
	function onLayout(dc){
		laptimer = new Timer.Timer();
		laptimer.start( method(:laptimercallback), 1000, false );
	}
	
	function onUpdate(dc){
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(dc.getWidth()/2, dc.getFontHeight(Gfx.FONT_LARGE)-30, Gfx.FONT_LARGE, "Lap " + LapCounter, Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM)/2 -45, Gfx.FONT_NUMBER_HOT, Functions.msToTimeWithDecimals(LapTime.toLong()), Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(dc.getWidth()/2, dc.getHeight()/2-10 , Gfx.FONT_NUMBER_MEDIUM, lapPace, Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(dc.getWidth()/2, dc.getHeight()/2 +40, Gfx.FONT_NUMBER_MEDIUM, lapDistance, Gfx.TEXT_JUSTIFY_CENTER);
		
		
		if (counter < 5){
			counter = counter + 1;
		}
		else{
			Ui.popView(Ui.SLIDE_IMMEDIATE);
		}
	}	
}

//! A circular queue implementation.
//! @author Konrad Paumann
class DataQueue {

    //! the data array.
    hidden var data;
    hidden var maxSize = 0;
    hidden var pos = 0;

    //! precondition: size has to be >= 2
    function initialize(arraySize) {
        data = new[arraySize];
        maxSize = arraySize;
    }
    
    //! Add an element to the queue.
    function add(element) {
        data[pos] = element;
        pos = (pos + 1) % maxSize;
    }
    
    //! Reset the queue to its initial state.
    function reset() {
        for (var i = 0; i < data.size(); i++) {
            data[i] = null;
        }
        pos = 0;
    }
    
    //! Get the underlying data array.
    function getData() {
        return data;
    }
}
