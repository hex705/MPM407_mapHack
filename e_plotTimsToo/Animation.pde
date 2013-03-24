
// source code:

//  http://processing.org/learning/topics/animatedsprite.html

// Class for animating a sequence of GIFs

class Animation {
  PImage[] images;
  int imageCount;
  int frame;
  
  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = imagePrefix + nf(i, 4) + ".gif";
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos) {
    pushStyle();
    imageMode(CENTER);
    //frame = (frame+1) % imageCount;
    image(images[frame], xpos, ypos);
    popStyle();
  }
  
  // determines which frame is to be drawn -- by moving this out of display -- we can control
  // speed through the images while still drawing an image each frame.
  void update(){
     frame = (frame+1) % imageCount;
  }
  
  int getWidth() {
    return images[0].width;
  }
}
