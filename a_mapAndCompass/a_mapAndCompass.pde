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
  

  // calls a function to draw the compass
  drawCompass();
 
 
 // draw some text info so we know we are still running
 fill (255,0,0);
 text( ( "frameRate : " + frameRate), width-20, height-30);
 
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
        
        rotate(radians( compassAngle-90 ));  // compass points at camera
        
        image(compass, 0, 0);
       
    popStyle();
  popMatrix();
  
   // place orientation in degrees under compass
   fill(255,0,0);
   text(compassOrientation, width -70, 270);
}
