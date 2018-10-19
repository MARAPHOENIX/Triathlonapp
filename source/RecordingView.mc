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

var LapTime50 = 0;
var elapsedLapTimeP50 = 0;
var elapsedLapDistanceP50 = 0.0;
var LapCounter50 = 0;
var lapPace50 = "";
var lapDistance50 = "";

var change = 0;
var paceData = new DataQueue(10);
var paceData30 = new DataQueue(30);
var paceData3 = new DataQueue(3);

var screen = 0;

var lapInitDistance = 0.0;
var lapInitTime = 0;
var lapVel = 0.0d;

var lapInitDistance50 = 0.0;
var lapInitTime50 = 0;
var lapVel50 = 0.0d;
var elapsedLapDistance50 = 0.0;


var lapManuel = false;

var lapManuel50 = false;

var vue = 0;
var dataLap = 0;

var distance = 0;
var distanceCalc = 0;
var chrono = 0;
var delta = 0;
var avgSpeedCalc= 0;

//properties
var lapCalc;
var lapCalcOn=false;


var isHR = 0;
var avgColor;
var hr;

class RecordingViewInputDelegate extends Ui.InputDelegate {


    function onKey(evt) {
   
        if( evt.getKey() == Ui.KEY_ENTER ) {
            if (App.getApp().getProperty( "TwoTimesPressLap" ) == true){
                change = change + 1;
                if (change == 2){
                    change = 0;
                    TriData.nextDiscipline();
                    Ui.requestUpdate();
                }
            }
            else{
                TriData.nextDiscipline();
                Ui.requestUpdate();
            }
        }
       
        if( evt.getKey() == Ui.KEY_MENU ) {
            TriData.nextDisciplineDiscard();
            Ui.requestUpdate();
        }
       
        if( evt.getKey() == Ui.KEY_UP ) {
            if (lapCalcOn){
                if (lapCalc == 0){
                    lapCalc = 1;
                }else{
                    lapCalc = 0;
                }
            }else{
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
            }
           
            Ui.requestUpdate();
   
        }
       
       
        if( evt.getKey() == Ui.KEY_DOWN ) {
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
           
                     
            if (vue < 2){
                vue ++;
            }else if (vue==2){
                vue = 0;
            }

            Ui.requestUpdate();
        }
       
       
        if( evt.getKey() ==  Ui.KEY_ESC  ) {
            if (lapCalcOn){
                if (lapCalc == 1){
                    var res = 0;
                       if (Math.round(distance.toNumber() % 1000)>=500){
                           res = 1000 - Math.round(distance.toNumber() % 1000);
                           delta = res;
                       }else{
                           res = Math.round(distance.toNumber() % 1000);
                           delta = -res;
                       }
                }
            }
           
           
            lapManuel = true;
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
        lapCalc = App.getApp().getProperty( "LapCalc");
        lapCalcOn = lapCalc == 1 ? true : false;
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
              
        if (App.getApp().getProperty( "Choix" ) == 0){
            drawGPS1(dc);
            drawDataFields1(dc);
        }else{
            var color = inverseTextColor;
            var inverseColor = textColor;
            avgColor =  Graphics.COLOR_GREEN;
            if (App.getApp().getProperty( "FondEcran" ) == 0){
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                   dc.fillRectangle(0, 0, 240, 240);
                   avgColor =  Graphics.COLOR_GREEN;
            }else{
                 dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
                   dc.fillRectangle(0, 0, 240, 240);
                   color = textColor;
                   inverseColor = inverseTextColor;
            }
            drawDataFields(dc,color,inverseColor);
        }
       
       
       
    }
   
    function onSnsr(sensor_info) {
        var HR = sensor_info.heartRate;
        hr = HR;
        var bucket;       
        if( sensor_info.heartRate != null )  {
            string_HR = HR.toString();
           
            if (App.getApp().getProperty( "Choix" ) == 0){
                string_HR = string_HR + "bpm";
            }
            isHR = 1;
        }
        else  {
            string_HR = "---";
            isHR = 0;
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
   
     function drawGPS1(dc) {
        var gpsinfo = Pos.getInfo();
        var gpsIsOkay = ( gpsinfo.accuracy == Pos.QUALITY_GOOD || gpsinfo.accuracy == Pos.QUALITY_USABLE );
       
        dc.setColor( Functions.getGPSQualityColour(gpsinfo), Gfx.COLOR_BLACK);
        dc.fillRectangle(0, 125, dc.getWidth(), 2);
    }


   
   
    function drawDataFields1(dc) {
        var y = 44;
       
        var cursession = Act.getActivityInfo();
        paceData.add(cursession.currentSpeed);
       
        var computeAvgSpeed = Functions.computeAverageSpeed(paceData);
        var computeAvgSpeedLisse = Functions.computeAverageSpeedLisse(paceData);
        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        dc.drawText(110, 180, Graphics.FONT_NUMBER_HOT,Functions.convertSpeedToBike(cursession.currentSpeed,0), CENTER);
       
        var font =  Graphics.FONT_NUMBER_THAI_HOT;
            dc.drawText(dc.getWidth()/2, 57, font, Functions.convertSpeedToBike(computeAvgSpeedLisse,0), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
       
    }
   
   	
   
    function drawDataFields(dc,color,inverseColor) {
        //on calcule le lap pace
        calculateLapPace();
        
        //chrono
	    var elapsedTime = Sys.getTimer() - TriData.disciplines[0].startTime;
	    chrono = elapsedTime;
	    var cursession = Act.getActivityInfo();
	    distance = cursession.elapsedDistance != null ? cursession.elapsedDistance : 0;
	    var avg = Functions.convertSpeedToBike(cursession.averageSpeed,0);
	    var data = Functions.getMinutesPerKmOrMile(cursession.currentSpeed);    
	    
	    
        if (vue<2){

	   
	        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
	       
	       
	        //vitesse moy 10s
	        paceData.add(cursession.currentSpeed);
	        paceData30.add(cursession.currentSpeed);
	        paceData3.add(cursession.currentSpeed);
	        var computeAvgSpeed = Functions.computeAverageSpeed(paceData);
	        var computeAvgSpeed3s = Functions.computeAverageSpeed(paceData3);
	        var computeAvgSpeed30s = Functions.computeAverageSpeed(paceData30);
	       
	       
	        var font = Graphics.FONT_NUMBER_HOT;
	       
	        data = Functions.getMinutesPerKmOrMile(computeAvgSpeed);
	       
	        if(App.getApp().getProperty( "PaceField" ) == 0){
	            data = Functions.getMinutesPerKmOrMile(cursession.currentSpeed);
	        }
	        
	        if(App.getApp().getProperty( "PaceField" ) == 1){
	            data = Functions.getMinutesPerKmOrMile(lapVel);
	        }
	              
	        var largeur = dc.getWidth()/2 + 3;
	        avg = Functions.getMinutesPerKmOrMile(cursession.averageSpeed);
	       
	        if (dataLap == 1){
	            avg = Functions.getMinutesPerKmOrMile(lapVel);
	        }
	
	        if (App.getApp().getProperty( "Format" ) == 1){
	            data = Functions.convertSpeedToBike(computeAvgSpeed,0);
	           
	            if(App.getApp().getProperty( "PaceField" ) == 0){
	                data = Functions.convertSpeedToBike(cursession.currentSpeed,0);
	            }
	          
	            largeur =  dc.getWidth()/2 + 3;
	            avg = Functions.convertSpeedToBike(cursession.averageSpeed,0);
	           
	            if (dataLap == 1){
	                avg = Functions.convertSpeedToBike(lapVel,0);
	            }
	            
	            if(App.getApp().getProperty( "PaceField" ) == 1){
	            	data = Functions.convertSpeedToBike(lapVel,0);
	        	}
	        }
	       
	        distanceCalc = distance;
	       
	     
	        if (lapCalc == 1){
	            if (distance>0 && chrono>0){
	               distanceCalc = distance + delta;
	               avg = Functions.getMinutesPerKmOrMile(distanceCalc / chrono * 1000);
	              
	               if (App.getApp().getProperty( "Format" ) == 1) {
	                       avg = Functions.convertSpeedToBike((distanceCalc / chrono * 1000),0);
	               }
	            }
	        }
	       
	        if (computeAvgSpeed>=1.67){
	            font =  Graphics.FONT_NUMBER_THAI_HOT;
	            dc.drawText(dc.getWidth()/2, 62, font, data, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	        }else{
	            dc.drawText(dc.getWidth()/2, 72, font, data, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	        }
	
	       
	       
	        //hr
	        if (isHR == 1){
	            dc.drawText(37, 76, Graphics.FONT_NUMBER_MILD, string_HR, CENTER);
	        }else{
	            dc.drawText(33, 76, Graphics.FONT_MEDIUM, Functions.convertSpeedToBike(cursession.currentSpeed,0), CENTER);
	        }
	       
	      
	        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
	        dc.drawText(120, 185, Graphics.FONT_NUMBER_HOT,avg, CENTER);
	       
	        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
	        if (dataLap == 1){
	            dc.drawText(170, 131,  Graphics.FONT_NUMBER_MEDIUM, Functions.msToTime(LapTime.toNumber()), CENTER);
	            dc.drawText(dc.getWidth()/2+63, dc.getHeight()/2+62, Gfx.FONT_SMALL, LapCounter, Gfx.TEXT_JUSTIFY_CENTER);
	           
	            dc.setColor(color, Gfx.COLOR_TRANSPARENT);
	        }else{
	            dc.drawText(170, 131,  Graphics.FONT_NUMBER_MEDIUM, Functions.msToTime(elapsedTime), CENTER);
	        }
	       
	        //distance
	        if (dataLap == 1){
	            dc.drawText(50 , 131, Graphics.FONT_NUMBER_MEDIUM, lapDistance, CENTER);
	        }else{
	            dc.drawText(50 , 131, Graphics.FONT_NUMBER_MEDIUM, Functions.convertDistance(distanceCalc), CENTER);
	        }
	       
	   
	       
	        //cadence
	        var cadence = cursession.currentCadence != null ? cursession.currentCadence : 0;
	        var cadenceStr = "---";
	       
	        if (cadence > 0){
	            cadenceStr = cadence.format("%d");
	        }
	        dc.drawText(dc.getWidth()-37, 76, Graphics.FONT_NUMBER_MILD, cadenceStr, CENTER);
	       
	        if (isHR == 1){
	            dc.drawText(dc.getWidth()-32, 167, Graphics.FONT_TINY, Functions.convertSpeedToBike(cursession.currentSpeed,0), CENTER);
	        }
	       
	       
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
	            vMoy = lapVel != null ? lapVel : 0;
	        }
	       
	        if (lapCalc == 1){
	            if (distance>0 && chrono>0){
	               distanceCalc = distance + delta;
	               vMoy = distanceCalc / chrono * 1000;
	            }
	        }
	       
	        if (vMoy>computeAvgSpeed30s){
	             dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
	             dc.fillPolygon([[30,170],[50, 170],[40,185]]);//DOWN
	        }else if (computeAvgSpeed30s>=vMoy){
	            dc.setColor(avgColor, Gfx.COLOR_TRANSPARENT);
	            dc.fillPolygon([[30,185],[50, 185],[40,170]]);//UP
	        }
	
	       
	        //grid
	        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
	        if (lapCalc == 1){
	             dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
	             dc.drawLine(0, 99, dc.getWidth(), 99);
	             dc.drawLine(0, 155, dc.getWidth(), 155);
	        }
	        dc.drawLine(0, 100, dc.getWidth(), 100);
	        dc.drawLine(0, 156, dc.getWidth(), 156);
	       
	        if (computeAvgSpeed30s > 4.16666667){
	             color = Graphics.COLOR_GREEN;
	            
	             if (computeAvgSpeed30s > 4.444444444){
	                 color = Graphics.COLOR_BLUE;
	             }
	            
	             if (computeAvgSpeed30s > 5){
	                 color = Graphics.COLOR_YELLOW;
	             }
	             dc.setColor(color, Graphics.COLOR_TRANSPARENT);
	             dc.fillRectangle(dc.getWidth()/2-10,220,20,10);         
	        }
	       
	        dc.setColor(inverseTextColor, Graphics.COLOR_TRANSPARENT);
        }   else{
 //VUE2       
        	 //time
	        var clockTime = System.getClockTime();
	        var time = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%.2d")]);
	   
	        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
	        dc.fillRectangle(0,0,218,20);
	        dc.setColor(inverseTextColor, Graphics.COLOR_TRANSPARENT);
	        dc.drawText(106, 10, Graphics.FONT_TINY, time, CENTER);
	        var battery = System.getSystemStats().battery;
	        dc.drawText(142, 11, Graphics.FONT_XTINY,battery.format("%d"), CENTER);
        
        	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        	//dc.drawText(33, 76, Graphics.FONT_MEDIUM, Functions.convertSpeedToBike(cursession.currentSpeed,0), CENTER);
        	
        	
        	if (dataLap == 1){
        		dc.drawText(dc.getWidth()/2+2, 50, Graphics.FONT_NUMBER_HOT, Functions.msToTime(LapTime.toNumber()), CENTER);
        		dc.drawText(dc.getWidth() /2+60 , 121, Graphics.FONT_NUMBER_HOT, Functions.getMinutesPerKmOrMile(lapVel), CENTER);
	    		dc.drawText(dc.getWidth()/2, 180, Graphics.FONT_NUMBER_HOT,  lapDistance, CENTER);//convertDistance(distance)    		
        	}else{
        	    dc.drawText(dc.getWidth()/2+2, 50, Graphics.FONT_NUMBER_HOT, Functions.msToTime(elapsedTime), CENTER);
        	    dc.drawText(dc.getWidth() /2+60 , 121, Graphics.FONT_NUMBER_HOT, avg, CENTER);
	    		dc.drawText(dc.getWidth()/2, 180, Graphics.FONT_NUMBER_HOT,  Functions.convertDistance(distance), CENTER);//convertDistance(distance)    	    
        	}
        	        	
        	
        	
			
			dc.drawText(dc.getWidth() /2-60 , 121, Graphics.FONT_NUMBER_HOT,data , CENTER);
			
			
	        //GRID
	        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
	        dc.drawLine(0,80, dc.getWidth(), 80);
	        dc.drawLine(0,81, dc.getWidth(), 81);
	        dc.drawLine(0,150, dc.getWidth(), 150);
	        dc.drawLine(0,151, dc.getWidth(), 151);
	        
	        dc.drawLine(dc.getWidth()/2,81, dc.getWidth()/2, 150);
	        
	        
	        if (hr>=100 && hr<150){
	        	dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);	
	        	dc.fillRectangle(0,210,240,30);
	        }else if (hr>=150 && hr<160){
	         	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
	         	dc.fillRectangle(0,210,240,30);
	        }else if (hr>=160 && hr<170){
	         	dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
	         	dc.fillRectangle(0,210,240,30);
	        }else if (hr>=170 && hr<180){
	         	dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
	         	dc.fillRectangle(0,210,240,30);
	        }else if (hr>=180){
	         	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
	         	dc.fillRectangle(0,210,240,20);
	        }
	                
	        //HR
	        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
	        dc.drawText(dc.getWidth()/2 ,223, Graphics.FONT_NUMBER_MILD, string_HR, CENTER);// hr.format("%d")
	        
	        
	        //tendance speed
	        if (cursession.averageSpeed != null){
		        if(cursession.averageSpeed>lapVel){
		        	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		        	Functions.drawBlocSpeed(dc,cursession.averageSpeed,lapVel,0);
		        }else if (lapVel>cursession.averageSpeed){
		         	dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		            Functions.drawBlocSpeed(dc,lapVel,cursession.averageSpeed,0);
		        }
		    }
	        
	        if (Functions.computeAverageSpeed(paceData)>lapVel && lapVel>0){
	        	dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
	            Functions.drawBlocSpeed(dc,Functions.computeAverageSpeed(paceData),lapVel,120);
	        }else if (lapVel> Functions.computeAverageSpeed(paceData) && lapVel>0){
	         	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
	         	Functions.drawBlocSpeed(dc,lapVel,Functions.computeAverageSpeed(paceData),120);
	        }
        
	        
        }
        

       
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
       
            if (App.getApp().getProperty( "AutolapMode" ) == true || lapManuel == true){
                var autolapdistance = Functions.convertToMeters(App.getApp().getProperty( "AutolapDistance" ));
               
               
               
                if (elapsedLapDistance >= autolapdistance || lapManuel == true){
                    TriData.nextLap();
                   
                    if (lapManuel == true){
                        LapTime = elapsedLapTime;
                        lapInitTime = lapInitTime + LapTime;
                        lapInitDistance = lapInitDistance + elapsedLapDistance;
                    }else{
                        LapTime = elapsedLapTimeP + (autolapdistance - elapsedLapDistanceP)/(elapsedLapDistance - elapsedLapDistanceP)*(elapsedLapTime - elapsedLapTimeP);
                        lapInitTime = lapInitTime + LapTime;
                        lapInitDistance = lapInitDistance + autolapdistance;
                    }
                   
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
   
    function calculatePace50(){
        var cursession = Act.getActivityInfo();
        var elapsedLapTime50 = 0; // (ms) 
        elapsedLapDistance50 = 0.0; // (m)

       
        var elapsedTime50 = cursession.elapsedTime;
        var elapsedDistance50 = cursession.elapsedDistance;
       
        if (TriData.ChangedDiscipline == true){
            lapInitTime50 = 0;
            lapInitDistance50 = 0.0;
            LapCounter50 = 0;
            TriData.ChangedDiscipline = false;
        }else{
            if ( elapsedTime50 != null && elapsedTime50 > 0 && elapsedDistance50 != null  && elapsedDistance50 > 0){
                elapsedLapTime50 = cursession.elapsedTime - lapInitTime50;
                elapsedLapDistance50 = cursession.elapsedDistance - lapInitDistance50;
                if ( elapsedLapTime50 > 0 && elapsedLapDistance50 > 0 ){
                    lapVel50 = elapsedLapDistance50.toDouble()/(elapsedLapTime50.toDouble()/1000);
                }
            }
       
            if (true){
                var autolapdistance50 = 50.0;
                //System.println("elapseLap " + elapsedLapDistance50.toNumber());
               
                if (elapsedLapDistance50 >= autolapdistance50){
                    //TriData.nextLap();
                   
                    if (lapManuel50 == true){
                        LapTime50 = elapsedLapTime50;
                        lapInitTime50 = lapInitTime50 + LapTime50;
                        lapInitDistance50 = lapInitDistance50 + elapsedLapDistance50;
                    }else{
                        LapTime50 = elapsedLapTimeP50 + (autolapdistance50 - elapsedLapDistanceP50)/(elapsedLapDistance50 - elapsedLapDistanceP50)*(elapsedLapTime50 - elapsedLapTimeP50);
                        lapInitTime50 = lapInitTime50 + LapTime50;
                        lapInitDistance50 = lapInitDistance50 + autolapdistance50;
                    }
                   
                    LapCounter50 = LapCounter50 + 1;
                    //Ui.pushView(new LapView(), new RecordingViewInputDelegate(), Ui.SLIDE_IMMEDIATE);
                }
                elapsedLapTimeP50 = elapsedLapTime50;
                elapsedLapDistanceP50 = elapsedLapDistance50;
            }
        }   
        lapPace50 = Functions.convertSpeedToPace(lapVel50,0);
        lapDistance50 = Functions.convertDistance(elapsedLapDistance50);
        LapTime50 = elapsedLapTime50;
        return lapPace50;
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
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM)/2 -45, Gfx.FONT_NUMBER_MEDIUM, Functions.msToTimeWithDecimals(LapTime.toLong()), Gfx.TEXT_JUSTIFY_CENTER);
        if (App.getApp().getProperty( "Format" ) == 1){
            dc.drawText(dc.getWidth()/2, dc.getHeight()/2-10 , Gfx.FONT_NUMBER_HOT, Functions.convertSpeedToBike(lapVel,0), Gfx.TEXT_JUSTIFY_CENTER);
        }else{
            dc.drawText(dc.getWidth()/2, dc.getHeight()/2-10 , Gfx.FONT_NUMBER_HOT, lapPace, Gfx.TEXT_JUSTIFY_CENTER);
        }
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 +60, Gfx.FONT_NUMBER_MEDIUM, lapDistance, Gfx.TEXT_JUSTIFY_CENTER);
       
       
        if (counter < 8){
            counter = counter + 1;
        }
        else{
            lapManuel = false;
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