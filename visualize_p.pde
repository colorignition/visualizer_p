import java.util.ArrayList;
import ddf.minim.*;
import processing.core.PApplet;

// Instance Creation
Minim minim;
ArrayList<AudioPlayer> audioplayer;
ArrayList<AudioMetaData> meta;

// Variables
// Bars
float[] bars;   // Holds the values for the bars shown on the screen at the current frame
float[] barsPrev; // Holds the values for the bars shown on the screen at the previous frame

float barMultiplier = 120; // Multiplies the amplitude to use at the bar

// Amplitude comparison
float ampHeight; // Maximum amplitude value @ frame
float ampHeightPrev; // Maximum amplitude value @ previous frame

// Particles
ArrayList<particle> pBox; // Holds data for the particles
int pBoxLimit = 30; // Limits total amount of particles held within pBox
double particleGenThreshold = 0.2; // Highest maximum amplitude before particles begin generating

boolean particleOn = false; // Turn on particles?

// Song stuff
int currentSong = 0;
int songCount;

int forceSampleRate = 1024;

// Timer
int tempMouseX, tempMouseY;

public void setup() {

  // General Processing setup
  size(1024, 600);
  background(0);

  frameRate(60);
  smooth();

  textFont(createFont("Eurostile Extended", 12));

  // Minim
  minim = new Minim(this);

  // Create a new audioplayer list
  audioplayer = new ArrayList<AudioPlayer>();
  audioplayer.add(minim.loadFile("MOBILE SUIT", forceSampleRate));
  audioplayer.add(minim.loadFile("Love BBB", forceSampleRate));
  audioplayer.add(minim.loadFile("RE_I AM", forceSampleRate));
  audioplayer.add(minim.loadFile("River", forceSampleRate));

  songCount = audioplayer.size();

  meta = new ArrayList<AudioMetaData>();
  for (int mta = 0; mta < audioplayer.size(); mta++)meta.add(audioplayer.get(mta).getMetaData());

  // Other music variables


  // Initializing Graphics Bars
  bars = new float[ forceSampleRate / 10];
  barsPrev = new float[bars.length];
  for (int ni = 0; ni < bars.length; ni++) {
    bars[ni] = 0;
    barsPrev[ni] = 0;
  }

  // Initializing Amplitude Comparison variables
  ampHeight = 0;
  ampHeightPrev = 0;

  // Initializing particle box
  pBox = new ArrayList<particle>();
}

public void draw() {

  // create black background
  fill( 0, 0, 0, 115);
  noStroke();
  rect(0, 0, width, height);

  // draw title

  fill(120, 130);
  int tempCountB = currentSong - 1;
  if (tempCountB < 0) tempCountB = songCount - 1;
  text(meta.get(tempCountB).fileName(), -10 - (16 * meta.get(tempCountB).fileName().length()), height / 2 - 5);

  fill(120, 130);
  int tempCountF = currentSong + 1;
  if (tempCountF >= songCount) tempCountF = 0;
  text(meta.get(tempCountF).fileName(), 50 + (24 * meta.get(currentSong).fileName().length()), height / 2 - 5);

  if (audioplayer.get(currentSong).isPlaying()) fill(255, 160);
  else fill(165, 140);
  textSize(26);
  text(meta.get(currentSong).fileName(), 60, height / 2 - 5);

  // check all amplitudes for highest value
  for (int pei = 0; pei <  (audioplayer.get(currentSong).bufferSize() / 10); pei++) {
    float currentAmp = (float) (abs(audioplayer.get(currentSong).left.get(pei * 10) * 1));

    if (ampHeight < currentAmp) ampHeight = currentAmp;

    if (ampHeightPrev > ampHeight) ampHeightPrev = ampHeight;
    else if (ampHeightPrev < ampHeight) ampHeight *= 0.8;
  }

  // Translating comparison and raw amplitude data into bars, managing bars
  for (int barc = 0; barc < bars.length; barc++) {
    if (barsPrev[barc] <= bars[barc]) bars[barc] += (abs(audioplayer.get(currentSong).left.get(barc * 10)));
    ;
    bars[barc] *= 0.7;
    barsPrev[barc] = bars[barc];
  }

  // Create particles if particleOn is true and box limit not yet met
  if (ampHeight >= particleGenThreshold && pBox.size() <= pBoxLimit && (int)(Math.random() * 2) == 1 && particleOn) 
    for (int erg = 0; erg < Math.random() * 3; erg++) pBox.add(new particle((int) ((Math.random()*10) * 100 + 5), (height / 2)+10));

  // draw particles and step them if particleOn is true
  for (int ie = 0; ie < pBox.size(); ie++) {
    if (particleOn) {
      pBox.get(ie).step();
      pBox.get(ie).show();

      if (pBox.get(ie).recycle) {
        pBox.remove(ie);
        break;
      }
    }
  }

  // Draw the Graphics bars
  for (int i = 0; i < bars.length; i++) {

    // Shadow bars, behind Main bars
    fill(255, 255 - (255 * ampHeight), 255 - (255 * ampHeight), 10);
    noStroke();
    for (int nelo = 0; nelo < 20; nelo ++) {
      rect((i * 10), height / 2, 10, (nelo/2) * abs((float) (bars[i] * barMultiplier * 0.15)));
    }

    // Main bars
    if ((double)(audioplayer.get(currentSong).position() * 110 / audioplayer.get(currentSong).length()) > (double)(i * 100 / bars.length)) fill(255, 180);
    else fill(175, 140);

    rect(i * 10, height / 2, 9, 1 * abs(bars[i] * barMultiplier));

    if (mousePressed && mouseY > height/2 && mouseX >= i * 10 && mouseX < (i*10) + 10 ) {
      fill(255, 190, 190, 180);
      rect((i * 10), (height / 2) + 1, 9, 4);
    }
    rect(i * 10, height / 2, 9, 1);
  }
}

public class particle {

  int x, y;
  double xvel, yvel;
  boolean recycle;

  public particle(int xloc, int yloc) {
    x = xloc;
    y = yloc;

    xvel = -30 + (Math.random()*60);
    yvel = 0;

    recycle = false;
  }

  public void show() {
    for (int woe = 0; woe < 10; woe++) {
      fill(255, (int)(255 - (8 *yvel)), (int)(255 - (8 *yvel)), (int)(45 - (2 *yvel)));
      ellipse(x, y, 2*woe, 2*woe);
    }
  }

  public void step() {
    yvel += 1;
    xvel *= 0.9;

    move();

    if (y > height) recycle = true;
  }

  public void move() {
    x += xvel;
    y += yvel;
  }
}

//  public void keyPressed(){
//
//    switch(key){
//    case ' ':
//      if(audioplayer.get(currentSong).isPlaying()) mPause();
//      else mPlay(false);
//      break;
//    case 'r':
//      mPause();
//      mRewind();
//      break;
//    case '1':
//      mSongChange(0);
//      break;
//    case '2':
//      mSongChange(1);
//      break;
//    case '3':
//      mSongChange(2);
//      break;
//    case CODED:
//      if(keyCode == LEFT)mSongChange(-2);
//      else if(keyCode == RIGHT) mSongChange(-1);
//      break;
//    }
//  }

public void mousePressed() {
  tempMouseX = mouseX;
  tempMouseY = mouseY;
}

public void mouseReleased() {

  if (abs(tempMouseX - mouseX) <= 15) {
    if (abs(tempMouseY - mouseY) > 15 && tempMouseY - mouseY < 0) {
      mRewind();
    }
    else {
      if (audioplayer.get(currentSong).isPlaying()) mPause();
      else mPlay(false);
    }
  }
  else {

    if (tempMouseY <= height / 2) {
      if (tempMouseX - mouseX > 0) mSongChange(-1);
      else mSongChange(-2);
    }
    else {
      mSongScroll(((double)mouseX/(double)width));
    }
  }
}

public void mPlay(boolean loopreq) {
  if (audioplayer.get(currentSong).position()  > 0.9 * audioplayer.get(currentSong).length()) mRewind();

  if (!loopreq)audioplayer.get(currentSong).play();
  else audioplayer.get(currentSong).loop();
}

public void mPause() {
  audioplayer.get(currentSong).pause();
}

public void mRewind() {
  audioplayer.get(currentSong).rewind();
}

public void mSongChange(int input) {
  mPause();
  mRewind();
  if (input > -1 && input < songCount) currentSong = input;
  if (input == -1) {
    if (currentSong + 1 >= songCount) currentSong = 0;
    else currentSong++;
  }
  if (input == -2) {
    if (currentSong - 1 < 0) currentSong = songCount - 1;
    else currentSong--;
  }
}

public void mSongScroll(double perc) {
  audioplayer.get(currentSong).cue((int)(audioplayer.get(currentSong).length() * 0.9 * perc));
}

public void stop()//for minim
{
  for (int epd = 0; epd < audioplayer.size(); epd++)audioplayer.get(epd).close();
  minim.stop();
  super.stop();
}

