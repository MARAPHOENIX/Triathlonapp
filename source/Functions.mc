using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.ActivityRecording as Rec;
using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.Timer as Timer;

module Functions {

    function msToTime(ms) {
    	var seconds = (ms / 1000) % 60;
    	var minutes = (ms / 60000) % 60;
    	var hours = ms / 3600000;
    	
    	return Lang.format("$1$:$2$:$3$", [hours, minutes.format("%02d"), seconds.format("%02d")]); 
    }
    
    function msToTimeWithDecimals(ms) {
    	var decimals = (ms % 1000) / 10;
    	var seconds = (ms / 1000) % 60;
    	var minutes = (ms / 60000) % 60;
    	var hours = ms / 3600000;
    	var string = "";
    	
    	if (hours > 0){
    		string = Lang.format("$1$:$2$:$3$", [hours, minutes.format("%02d"), seconds.format("%02d")]);
    	}
    	else{
    		string = Lang.format("$1$:$2$.$3$", [minutes.format("%02d"), seconds.format("%02d"), decimals.format("%02d")]);
    	}
    	
    	return string; 
    }
    
    function convertSpeedToSwim(speed) {
    	var result_min;
    	var result_sec;
    	var result_per;
    	var conversionvalue;
    	var settings = Sys.getDeviceSettings();
    	
		result_min = 0;
		result_sec = 0;
		if( settings.paceUnits == Sys.UNIT_METRIC ) {
			result_per = "/100m";
			conversionvalue = 100.0d;
		} else {
    		result_per = "/100m";
    		conversionvalue = 100.0d;
    	}

		if( speed != null && speed > 0 ) {
	    	var secpermetre = 1.0d / speed;	// speed = m/s
	    	result_sec = secpermetre * conversionvalue;
			result_min = result_sec / 60;
			result_min = result_min.format("%d").toNumber();
			result_sec = result_sec - ( result_min * 60 );	// Remove the exact minutes, should leave remainder seconds
		}
		
    	return Lang.format("$1$:$2$$3$", [result_min, result_sec.format("%02d"), result_per]);
    }
    
    function convertSpeedToBike (speed,unite) {
    	var conversionvalue;
    	var result_speed;
    	var result_format;
    	var settings = Sys.getDeviceSettings();
    	
    	result_speed=0;
    	if( settings.paceUnits == Sys.UNIT_METRIC ) {
			result_format = "km/h";
			if (unite==0){
				result_format = "";
			}
			conversionvalue = 1000.0d;
		} else {
    		result_format = "mi/h";
    		if (unite==0){
				result_format = "";
			}
    		conversionvalue = 1609.34d;
    	}
    	if( speed != null && speed > 0 ) {
	    	result_speed =speed*3600/conversionvalue;
		}
		
		var speedStr = result_speed.format("%02.2f");
		if (unite==0){
			speedStr = result_speed.format("%02.1f");
		}
    	return Lang.format("$1$ $2$", [speedStr, result_format]); 
    }
    
    function convertSpeedToPace(speed,unite) {
    	var result_min;
    	var result_sec;
    	var result_per;
    	var conversionvalue;
    	var settings = Sys.getDeviceSettings();
    	
		result_min = 0;
		result_sec = 0;
		if( settings.paceUnits == Sys.UNIT_METRIC ) {
			result_per = "/km";
			if (unite==0){
				result_per = "";
			}
			conversionvalue = 1000.0d;
		} else {
    		result_per = "/mi";
    		if (unite==0){
				result_per = "";
			}
    		//conversionvalue = 1609.34d;
    		conversionvalue = 1000.0d;
    	}

		if( speed != null && speed > 0 ) {
	    	var secpermetre = 1.0d / speed;	// speed = m/s
	    	result_sec = secpermetre * conversionvalue;
			result_min = result_sec / 60;
			result_min = result_min.format("%d").toNumber();
			result_sec = result_sec - ( result_min * 60 );	// Remove the exact minutes, should leave remainder seconds
		}
		
    	return Lang.format("$1$:$2$$3$", [result_min, result_sec.format("%02d"), result_per]);
    }
    
    
    function getMinutesPerKmOrMile(speedMetersPerSecond) {
        if (speedMetersPerSecond != null && speedMetersPerSecond > 0.2) {
            var metersPerMinute = speedMetersPerSecond * 60.0;
            var minutesPerKmOrMilesDecimal = 1000 / metersPerMinute;
            var minutesPerKmOrMilesFloor = minutesPerKmOrMilesDecimal.toNumber();
            var seconds = (minutesPerKmOrMilesDecimal - minutesPerKmOrMilesFloor) * 60;
            return minutesPerKmOrMilesDecimal.format("%2d") + ":" + seconds.format("%02d");
        }
        return "-:--";
    }
    
    function convertDistance(metres) {
    	var result;
    	
    	if( metres == null ) {
    		result = 0;
    	} else {
	    	var settings = Sys.getDeviceSettings();
	    	if( settings.distanceUnits == Sys.UNIT_METRIC ) {
	    		result = metres / 1000.0;
	    	} else {
	    		result = metres / 1609.34;
	    	}
	    	
	    }
    	
    	return Lang.format("$1$", [result.format("%.2f")]);
    }
    
    function convertToMeters(distance){
    	var meters;
    	
    	if (distance == null){
    		meters = 0;	
    	}
    	else{
    		var settings = Sys.getDeviceSettings();
    		if( settings.distanceUnits == Sys.UNIT_METRIC ) {
	    		meters = distance * 1000.0;
	    	} else {
	    		meters = distance * 1609.34;
	    	}
    	}
    	return meters;
    }

	function drawChevron(dc, leftX, rightX, centreY, chevronHeight, isFirst, isLast) {
	
		// Draw event segments
		var poly;
		var segwidth = dc.getWidth() / 5;
		
		if( isFirst && isLast ) {
			poly = new [0];
			dc.fillRectangle(leftX, centreY - (chevronHeight / 2), rightX - leftX, chevronHeight);
			return;
		} else if( isFirst ) {
			poly = [
				[leftX, centreY - (chevronHeight / 2)],
				[rightX - (chevronHeight / 2), centreY - (chevronHeight / 2)],
				[rightX + (chevronHeight / 2), centreY],
				[rightX - (chevronHeight / 2), centreY + (chevronHeight / 2)],
				[leftX, centreY + (chevronHeight / 2)]
				];
		} else if( isLast ) {
			poly = [
				[leftX - (chevronHeight / 2), centreY - (chevronHeight / 2)],
				[rightX, centreY - (chevronHeight / 2)],
				[rightX, centreY + (chevronHeight / 2)],
				[leftX - (chevronHeight / 2), centreY + (chevronHeight / 2)],
				[leftX + (chevronHeight / 2), centreY]
				];
		} else {
			poly = [
				[leftX - (chevronHeight / 2), centreY - (chevronHeight / 2)],
				[rightX - (chevronHeight / 2), centreY - (chevronHeight / 2)],
				[rightX + (chevronHeight / 2), centreY],
				[rightX - (chevronHeight / 2), centreY + (chevronHeight / 2)],
				[leftX - (chevronHeight / 2), centreY + (chevronHeight / 2)],
				[leftX + (chevronHeight / 2), centreY]
				];
		}
		
		dc.fillPolygon(poly);
	}
	
	function drawReverseChevron(dc, leftX, rightX, centreY, chevronHeight, isFirst, isLast) {
	
		// Draw event segments
		var poly;
		var segwidth = dc.getWidth() / 5;
		
		if( isFirst && isLast ) {
			poly = new [0];
			dc.fillRectangle(leftX, centreY - (chevronHeight / 2), rightX - leftX, chevronHeight);
			return;
		} else if( isFirst ) {
			poly = [
				[leftX, centreY - (chevronHeight / 2)],
				[rightX + (chevronHeight / 2), centreY - (chevronHeight / 2)],
				[rightX - (chevronHeight / 2), centreY],
				[rightX + (chevronHeight / 2), centreY + (chevronHeight / 2)],
				[leftX, centreY + (chevronHeight / 2)]
				];
		} else if( isLast ) {
			poly = [
				[leftX + (chevronHeight / 2), centreY - (chevronHeight / 2)],
				[rightX, centreY - (chevronHeight / 2)],
				[rightX, centreY + (chevronHeight / 2)],
				[leftX + (chevronHeight / 2), centreY + (chevronHeight / 2)],
				[leftX - (chevronHeight / 2), centreY]
				];
		} else {
			poly = [
				[leftX + (chevronHeight / 2), centreY - (chevronHeight / 2)],
				[rightX + (chevronHeight / 2), centreY - (chevronHeight / 2)],
				[rightX - (chevronHeight / 2), centreY],
				[rightX + (chevronHeight / 2), centreY + (chevronHeight / 2)],
				[leftX + (chevronHeight / 2), centreY + (chevronHeight / 2)],
				[leftX - (chevronHeight / 2), centreY]
				];
		}
		
		dc.fillPolygon(poly);
	}
	
	function getGPSQualityColour(gpsInfo) {
		var gpsnfo;
		if( gpsInfo == null ) {
			gpsnfo = Pos.getInfo();
		} else {
			gpsnfo = gpsInfo;
		}
	
		if( gpsnfo.accuracy == Pos.QUALITY_GOOD ) {
			return Gfx.COLOR_DK_GREEN;
		} else if( gpsnfo.accuracy == Pos.QUALITY_USABLE ) {
			return Gfx.COLOR_YELLOW;
		}
		return Gfx.COLOR_DK_RED;
	}
	
	 function computeAverageSpeed(tableau) {
        var size = 0;
        var data = tableau.getData();
        var sumOfData = 0.0;
        for (var i = 0; i < data.size(); i++) {
            if (data[i] != null) {
                sumOfData = sumOfData + data[i];
                size++;
            }
        }
        if (sumOfData > 0) {
            return sumOfData / size;
        }
        return 0.0;
    }
    
    
    function computeAverageSpeedLisse(tableau) {
	       var size = 0;
	       var data = tableau.getData();
	       var sumOfData = 0.0;
	       var sizeAvg = 0;
	
	       //for (var i = 0; i < data.size(); i++) {
	       //    if (data[i] != null) {
	       //        sumOfData = sumOfData + data[i];
	       //        size++;
	       //    }
	       //}
	
	       //if (sumOfData > 0) {
	       //    return sumOfData / size;
	       //}
	       
	       //si tableau rempli
	       //if (data.size() == 10){
	       //   paceDataAvg.add(data[0]);
	       //   for (var j = 0; j < 6; j++){
	       //   	 paceDataAvg.add((data[j]+data[j+1]+data[j+2]+data[j+3]+data[j+4])/5);
	       //   }
	       //   paceDataAvg.add((data[7]+data[8]+data[9])/3);
	       //}
		   
		   //si tableau rempli
	       if (data.size() == 10){
	       	  	var calculOk=1;
       			for (var i = 0; i < data.size(); i++) {
	           		if (data[i] == null && calculOk == 1) {
	              		calculOk=0;
	           		}
	       		}	     
	       	  if (calculOk==1){
		          sumOfData = (data[0]+data[1]+data[2])/3;
		          sizeAvg++;
		          for (var j = 0; j < 6; j++){
		          	 sumOfData = sumOfData + ((data[j]+data[j+1]+data[j+2]+data[j+3]+data[j+4])/5);
		          	 sizeAvg++;
		          }
		          sumOfData = sumOfData + ((data[7]+data[8]+data[9])/3);
		          sizeAvg++;
		      }
	       }
		   //var dataAvg = paceDataAvg.getData();
	
	
	       if (sumOfData > 0) {
	           return sumOfData / sizeAvg;
	       }
	
	       return 0.0;
   	  }
}