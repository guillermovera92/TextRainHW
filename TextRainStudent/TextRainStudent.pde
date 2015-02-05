/**
 Comp 394 Spring '15 Assignment #1 Text Rain
 **/

// text font size is 16
import processing.video.*;
import java.util.Random;
import java.lang.String;
import java.lang.Math;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
PImage thresholdImage;
boolean inputMethodSelected = false;
PFont f;


int dimension;
int[] thresholdPixels;
boolean thresholdDefined;
int threshold = 128;

boolean debugging = false;
int i;
int r, g, b, pix;
int xPos;
String method = "luminosity";

Letter[] l;

void setup() {
  size(1280, 720);  
  Random rand = new Random();
  inputImage = createImage(width, height, RGB);
  l = new Letter[15];
  for (int i = 0; i < l.length; i++) {
    xPos = rand.nextInt(width + 1);
    l[i] = new Letter("t", xPos, 10, 0, millis(), threshold);
  }
}


void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min (9, cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.


  // STEP 1.  Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable

  if ((cam != null) && (cam.available())) {
    cam.read();
    inputImage.copy(cam, 0, 0, cam.width, cam.height, 0, 0, inputImage.width, inputImage.height);
  } else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0, 0, mov.width, mov.height, 0, 0, inputImage.width, inputImage.height);
  }

  if (!thresholdDefined) {
    dimension = (inputImage.width) * (inputImage.height);
    thresholdPixels = new int[dimension];
  }


  loadPixels();  
  for (int x = 0; x < inputImage.width; x++) {
    for  (int y = 0; y < inputImage.height; y++) {
      i = ((y * inputImage.width) + (x));
      pix = inputImage.pixels[i];
      r = (pix >> 16) & 0xFF;
      g = (pix >> 8) & 0xFF;
      b = pix & 0xFF;
      if (convert(r, g, b) >= threshold) {
        thresholdPixels[i] = color(255);
      } else {
        thresholdPixels[i] = color(0);
      }
      if (debugging) {
        inputImage.pixels[i] = thresholdPixels[i];
      }
    }
  }
  updatePixels();


  // Tip: This code draws the current input image to the screen
  set(0, 0, inputImage);
  f = loadFont("Futura-Medium-16.vlw");
  textFont(f, 16);
  textAlign(CENTER);
  fill(0); 
  for(Letter let : l) {
   let.place(); 
   let.updateY();
  }
}

int convert(int r, int g, int b) {
  if (method.equals("luminosity")) {
    return Math.round(0.21 * r + 0.72 * g + 0.07 * b);
  } else if (method.equals("average")) {
    return (r + g + b) / 3;
  } else {
    return (max(r, g, b) + min(r, g, b)) / 2;
  }
}


void keyPressed() {

  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput.mov");
        mov.loop();
        inputMethodSelected = true;
      } else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }


  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..

  if (key == CODED) {
    if (keyCode == UP) {
      if (threshold < 255) threshold += 5;
    } else if (keyCode == DOWN) {
      if (threshold > 0) threshold -= 5;
    }
  } else if (key == ' ') {
    debugging = !debugging;
  } else if (key == 'a') {
    method = "average";
  } else if (key == 'l') {
    method = "luminosity";
  } else if (key == 'g') {
    method = "lightness";
  }
}

class Letter {
  String character;
  int x;
  int y;
  float currSpeed;
  int startTime;
  int threshold;

  Letter(String s, int tempX, int tempY, float initSpeed, int time, int threshold) {
    character = s;
    this.x = tempX;
    this.y = tempY;
    this.currSpeed = initSpeed;
    this.startTime = time;
    this.threshold = threshold;
  }

  void place() {
    text(character, x, y);
  }
  
  void updateY() {
    int time = (millis() - startTime) / 1000;
    int i = (((this.y + 16 + 5) * inputImage.width) + (this.x));
    if (i <= inputImage.pixels.length){
      int pix = inputImage.pixels[i];
      r = (pix >> 16) & 0xFF;
      g = (pix >> 8) & 0xFF;
      b = pix & 0xFF;
      if (convert(r, g, b) >= threshold){
        this.y += Math.round(0.5 * 0.05 * time * time);
      }
      else {
        int pix2 = inputImage.pixels[(this.y * inputImage.width) + (this.x)];
        r = (pix2 >> 16) & 0xFF;
        g = (pix2 >> 8) & 0xFF;
        b = pix2 & 0xFF;
        if (convert(r, g, b) >= threshold){
          this.y -= Math.round(0.5 * 0.05 * time * time);
        }
      }
    }      
  }
}

