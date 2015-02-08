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
boolean flip;
int i;
int r, g, b, pix, temp;
int xPos;
String method = "luminosity";
TextGenerator tg;

ArrayList<Letter> letters;
Random rand = new Random();

void setup() {
  size(1280, 720);  
  Random rand = new Random();
  inputImage = createImage(width, height, RGB);
  letters = new ArrayList<Letter>();
  tg = new TextGenerator("ran1.txt");
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
    flip = true;
  } else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0, 0, mov.width, mov.height, 0, 0, inputImage.width, inputImage.height);
    flip = true;
  }

  if (!thresholdDefined) {
    dimension = (inputImage.width) * (inputImage.height);
    thresholdPixels = new int[dimension];
  }


  loadPixels();  
  for (int y = 0; y < inputImage.height; y++) {
    for  (int x = 0; x < inputImage.width; x++) {
      i = ((y * inputImage.width) + (x));
      if (i % inputImage.width < floor(inputImage.width / 2) && flip) {
        temp = inputImage.pixels[y * inputImage.width + inputImage.width - 1 - x];
        inputImage.pixels[y * inputImage.width + inputImage.width - 1 - x] = inputImage.pixels[i];
        inputImage.pixels[i] = temp;
      }
      pix = inputImage.pixels[i];
      if (greyscale(pix) >= threshold) {
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
  if (Math.random() < 0.2) {
    letters.add(new Letter(tg.getNextLetter(), 10, millis(), threshold));
  }
  for (Letter let : letters) {
    let.place();
    let.updateY();
  }
  flip = false ;
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


int greyscale(int pixel) {
  r = (pixel >> 16) & 0xFF;
  g = (pixel >> 8) & 0xFF;
  b = pixel & 0xFF;
  return convert(r, g, b);
}

void reverseImage(int x, int y, int i) {
  temp = inputImage.pixels[y * inputImage.width + inputImage.width - 1 - x];
  inputImage.pixels[y * inputImage.width + inputImage.width - 1 - x] = inputImage.pixels[i];
  inputImage.pixels[i] = temp;
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
  int startTime;
  int threshold;

  Letter(String s, int tempY, int time, int threshold) {
    character = s;
    this.x = rand.nextInt(width);
    this.y = tempY;
    this.startTime = time;
    this.threshold = threshold;
  }

  void place() {
    text(character, x, y);
    fill(0, 0, 102, 204);
  }

  void updateY() {
    int time = (millis() - startTime) / 1000;
    int i = ((this.y + 16 + 3) * inputImage.width) + this.x;
    if (i < inputImage.pixels.length) {
      int pix = inputImage.pixels[i];
      if (greyscale(pix) >= threshold) {
        this.y += Math.round(0.5 * time * time);
      } else {
        int i2 = (this.y * inputImage.width) + this.x;
        int pix2 = inputImage.pixels[i2];
        //        int dy = Math.round(0.5 * 0.1 * time * time);
        while (greyscale (pix2) <= threshold && this.y > 1) {
          this.y -= 1;
          i2 = (this.y * inputImage.width) + this.x;
          pix2 = inputImage.pixels[i2];
        }
        startTime = millis();
      }
    }
  }
}

