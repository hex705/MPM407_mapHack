
// updated March 25
// version 2.0



// integrating geolocation with my map experiment
//  check your permissions!!

// import the library
import ketai.sensors.*; 

// we need sensor class for compass
KetaiSensor sensor;
double longitude, latitude, altitude;

// we need location class for lat/long (set LOCATION permissions)
KetaiLocation location;


// set up the compass -- iamge and orientation
PImage compass;
float compassOrientation;

// map image
PImage rccAndQuad;

// create an object to translate map GPS to pixels
PrecisionMercatorMap mercatorMap;

// create some markers for the map

MapVector rcc357;
MapVector thisDevice;

// this is from the sprite example on processing web page
Animation deviceLocator;

Location timsLocation;
MapVector timsDisplay;

PImage timsLogo;

void setup() {
  
  // variables for display
  size(displayWidth, displayHeight );  
  smooth();
  
  // Load map image
  rccAndQuad = loadImage("rccAndQuad.png");
  
  // load compass image
  compass    = loadImage("compass.gif");
   
  // gets compass data
  sensor = new KetaiSensor(this);
  sensor.start();
  
  // gets geolocation data
  location = new KetaiLocation(this);
  
  // Map with dimension and bounding box
  // need to map to screen
  
  //  from tileMill  -79.3806,43.6579,-79.3765,43.6596  -- need to rearrange.
  //  north, south, west, east
  mercatorMap = new PrecisionMercatorMap(displayWidth, displayHeight, 43.6596d, 43.6579d,-79.3806d,-79.3765d); //in NA these are +big(north),+small(south),-big (more west) ,-small(east)
 
  // marker for class room (home)  -- the 'd' at end of numbers makes the number a double
  // the map vector holds lat/long data as a double
  rcc357  = new MapVector();
  rcc357  = mercatorMap.getScreenLocation( 43.65862d, -79.37672d ); // from google maps (guess) 43.65857,-79.376737
                      
  // will hold lat/long for the device you are holding
  thisDevice   = new MapVector();
  thisDevice   = mercatorMap.getScreenLocation( 43.6580d, -78.3780d );  // startpoint -- it will move once data caught
  
    // this is a series of gif that will radiate around device location
  deviceLocator = new Animation ("loc",5);
 
  // standard text formatting
  textAlign(RIGHT,BOTTOM);
  textSize(36);
  
  // call this last or it messes up the compass!!!!
  orientation(LANDSCAPE);
  println(displayWidth + "\t"+ displayHeight);
}

void draw() {
  
  //draw background map
  image(rccAndQuad, 0, 0, width, height);
  
  // draw fixed Markers -- in this case the classroom
  stroke(255,20,0,100);
  fill(255, 20, 0, 100);
  ellipse( (float) rcc357.x, (float) rcc357.y, 15, 15);
  noFill();
  strokeWeight(4);
  ellipse( (float) rcc357.x, (float) rcc357.y, 30, 30);
  

  
  // draw device location
  // we need to pass current device lat / long to get pixel location
  
  // this device is pixelLocation -- not GPS
  thisDevice = mercatorMap.getScreenLocation( latitude, longitude );
  
  // check if we are on the map
  if (( thisDevice.x > width ) || (thisDevice.x < 0) || (thisDevice.y < 0) || (thisDevice.y>height)) 
       { 
          pushStyle();
             textSize(100);
             fill(255,100,0);
             textAlign(CENTER,CENTER);
             text("thar be dragons \nyou are off the map!",width/2,height/2);
          popStyle();
       }
       
  // animated display
  if (frameCount % 10 == 0)  { deviceLocator.update();} // I added an update so that the animation is slowed down
                                                    // this only move to next gif after 10 frames
                                                    
  deviceLocator.display((float)thisDevice.x, (float)thisDevice.y);     // pass pixel location to Animator to draw rings.
  
  // OR -- comment out the two active lines above and uncoment below -- should look familiar -- <pinch a pic>
  
  // rectangle display
      //  pushMatrix();
      //  
      //    fill( 100,100,0,200 );
      //    rectMode(CENTER);
      //    translate((float)me.x, (float)me.y);
      //    rotate(radians(45));
      //    rect( 0, 0, 20, 20 );
      //    
      //  popMatrix();

  // calls a function to draw the compass
  drawCompass();
 
 // draw some text info so we know we are still running
 fill (255,0,0);
 text( ( "double : " + thisDevice.x + "  " + thisDevice.y), width-20, height-70);
 text( ( "frameRate : " + frameRate),width-20, height-30);
 
}


// location event handler -- updates when we get new coords
void onLocationEvent(double _latitude, double _longitude, double _altitude)
{
  longitude = _longitude;
  latitude  = _latitude;
  altitude  = _altitude;
}

// orientation event updates when we get new compass info
void onOrientationEvent(float x, float y, float z, long time, int accuracy)  //(8)
{
  //  println("compassEvent");
  compassOrientation = x;  
  // Azimuth angle between the magnetic north and device y-axis, around z-axis.
  // Range: 0 to 359 degrees
  // 0=North, 90=East, 180=South, 270=West 
}

// does the actual work of drawing the compass
void drawCompass() {
  
 // we need the compass to point NORTH
  pushMatrix();
    pushStyle();
        // going to draw the pic around a point
        imageMode(CENTER);
        
        // where we will draw the image
        translate(width-120,120); 
        float compassAngle = 0;
         
        // compensate for turning east OR west
        if( compassOrientation > 0 && compassOrientation <=180) {
            compassAngle = - compassOrientation;  
        }
        
        if ( compassOrientation > 180 && compassOrientation <=360) {
            compassAngle = (360 - compassOrientation );         
        }
        
        rotate(radians( compassAngle-90 ));  // -90   compass points at camera
        image(compass, 0, 0);
   
    popStyle();
  popMatrix();
  
  drawBearing(compassAngle);
       
}


void drawBearing(float compassAngle){
  
  // bearing is the angle from north that youare facing
          // compass Angle is 0 to -180 N-E-S 
          // compass Angle is 0 to 180  N-W-S
        
        // one more corection to print the bearing properly 
        // I suspect there is a better way but this works 
        
        float compassDisplay=0;
         if (compassAngle <=0 ) {
              compassDisplay = abs(compassAngle)+90;   
              println(compassAngle + "  " +  compassDisplay);
         }
         
         if ( (compassAngle > 0) && (compassAngle <=90) ){
            compassDisplay = 90-compassAngle;  
              println(compassAngle + "  " +  compassDisplay);
         }
   
         if ( (compassAngle > 90) && (compassAngle <=180) ){
            compassDisplay = map(compassAngle,90,180,360,270); 
              println(compassAngle + "  " +  compassDisplay);
         }
   
  
   // place bearing in degrees under compass
   fill(255,0,0);
   text(  compassDisplay, width -70, 270); 
  
}
