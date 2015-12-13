import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LUDUM_DARE_34 extends PApplet {








//MYGAME

//Todo:
// gameplay lol

int gameState = 0;
int gameStateNext = 0;
float globalTranslateY = 0;
float globalTranslateYTarget = 0;
float dedTranslate = 0;
float dedTranslateTarget = 0;

PFont font;

Button playButton;
Button settingsButton;
Button resetButton;

int bgColor = 0xff000000;
int fgColor = 0xffFFCC66;
int ball1Color = 0xffF54080;
int ball2Color = 0xff40B7F5;

ArrayList<Bullet>   bullets   = new ArrayList<Bullet>(); //type casting \o/
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<Enemy>    enemies   = new ArrayList<Enemy>();   

long lastFireMillis = 0;
long lastSpawnMillis = 0;

float screenshakeAmount = 0;

int mouseButtonsPressed = 0; //workaround for mousePressed bug

Minim minim;
AudioSample explode1;
AudioSample explode2;
AudioSample lose;
AudioSample hover;
AudioSample unhover;
AudioSample press;
AudioSample explodespecial;

float spawnChance = 0.06f;
int timeBetweenSpawns = 800;

int score = 0;

String[] deathMessages = {"oops","rip","dang","whups","ouch","D:","dang it","darn it","oh no","aww"};
String[] resetMessages = {"Try again","Retry","1 more go","Restart","Rewind","Okay","   :(   ","Again"};
String resetMessage = "asdfghjkl";
String deathMessage = "asdfghjkl";

int[] mouseTrailX = new int[10];
int[] mouseTrailY = new int[10];

boolean lastMouseButton;

public void setup() {
  
  textAlign(CENTER,CENTER);
  
  font = loadFont("font.vlw");
  
  playButton = new Button(width/2,(2*height/3)-50,60,"PLAY");
  settingsButton = new Button(width/2,(2*height/3)+100,60,"SETTINGS");
  resetButton = new Button(3*width/4,height/2,60,"Try again");
   //antialiasing :D
  
  surface.setTitle("Shh bby is ok");
  
  minim = new Minim(this);
  explode1 = minim.loadSample("explode.wav");
  explode2 = minim.loadSample("explode2.wav");
  lose     = minim.loadSample("lose.wav");
  hover    = minim.loadSample("hover.wav");
  unhover  = minim.loadSample("unhover.wav");
  press    = minim.loadSample("press.wav");
  explodespecial = minim.loadSample("explodespecial.wav");
  
  //frameRate(5);
  dedTranslateTarget = height*1.3f;
  
  initSettings(); //keeping it all in one file ;)
  
  noCursor();
}

public void draw() {
  pushMatrix();
  background(bgColor);
  translate(0,globalTranslateY*height*1.5f);
  scale(globalTranslateY+1);
  globalTranslateY += (globalTranslateYTarget - globalTranslateY) * 0.08f;
  dedTranslate += (dedTranslateTarget - dedTranslate) * 0.1f;
  
  //detect if we're in a screen transition right about now
  if(gameState != gameStateNext) {
    //then, if the transiton animation thingie is completes
    if(abs(globalTranslateYTarget - globalTranslateY) < 0.03f) {
      //switch the game state and slide back down!
      gameState = gameStateNext;
      globalTranslateYTarget = 0;
      
      if(gameState == 1) { //switching to play mode?
        //let's set things up
        score = 0;
        spawnChance = 0.06f;
        timeBetweenSpawns = 800;
        
        bullets   = new ArrayList<Bullet>();
        particles = new ArrayList<Particle>();
        enemies   = new ArrayList<Enemy>();
        
        lastSpawnMillis = millis()+1000;
        dedTranslateTarget = height*1.3f;
      }
    }
  }
  
  screenshakeAmount += (0-screenshakeAmount) * 0.2f;
  translate(random(-screenshakeAmount,screenshakeAmount),random(-screenshakeAmount,screenshakeAmount));
  
  //MAIN MENU//////////////////////////////////////////////////////////////////////////////////////
  if(gameState == 0) {
    // draw title
    for(int i=0; i < 5; i++) {
      fill(lerpColor(0xff000000,fgColor,i/5f));
      textFont(font,80);
      textAlign(CENTER,CENTER);
      text("Center", width/2, (height/3)+i*5);
    }
    
    //draw buddons
    playButton.updateAndDraw();
    settingsButton.updateAndDraw();
    
    if(playButton.isClicked) {
      gameStateNext = 1;
      globalTranslateYTarget = -1; 
      press.trigger();
    }
    
    if(settingsButton.isClicked) {
      gameStateNext = 2;
      globalTranslateYTarget = -1;
      press.trigger();
    }
    //      gameplay          player is ded
  } else if(gameState == 1 || gameState == 3) { //GAMEPLAY SCREEN///////////////////////////////////////////////////////
    translate((width/2 - mouseX)*0.15f,(height/2 - mouseY)*0.15f); //"Camera"
    
    stroke(40,50,80);
    strokeWeight(1);
    for(int x=-200; x<=width+200; x += 50) {
      line(x,-50,x,height+50);
    }
    for(int y=-200; y<=height+200; y += 50) {
      line(-50,y,width+50,y);
    }
    
    //Firing
    if((gameState == 1) && (mouseButtonsPressed != 0) && ((millis() - lastFireMillis) > 100)) {
      Bullet b = new Bullet(width/2,height/2,mouseX,mouseY,3+(dist(mouseX,mouseY,width/2,height/2)/30f),mouseButton);
      bullets.add(b);
      lastFireMillis = millis();
      screenshakeAmount += 1+(dist(mouseX,mouseY,width/2,height/2)/10f);
      explode1.trigger();
    }
    
    //Spawn enemies (in a large circle around screen)
    if(gameState == 1 && ((random(1f) < spawnChance) && (millis() - lastSpawnMillis) > timeBetweenSpawns)) {
      float angg = random(0,TWO_PI);
      float x = 900*cos(angg)+width/2;
      float y = 900*sin(angg)+height/2;
      float angToCenter = atan2((height/2)-y,(width/2)-x);
      
      float n = random(1);
      
      if(n < 0.9f) {
        enemies.add(new CircleEnemy(x,y,angToCenter+random(-0.02f,0.02f),random(2,5)));
      } else if(n < 0.95f) {
        enemies.add(new SquareEnemy(x,y,angToCenter+random(-0.02f,0.02f),random(2,5)));
      } else {
        enemies.add(new TriangleEnemy(x,y,angToCenter+random(-0.02f,0.02f),random(2,5)));
      }
      lastSpawnMillis = millis();
    }
    
    
    //Do the thingie!!! :D:D:D:D::D:D
    tickAll(particles);
    tickAll(bullets);
    tickAll(enemies);
    
    checkCollision();
    
    //Aim line
    float ang = atan2(mouseY-(height/2),mouseX-(width/2));
    float r   = 10+(dist(mouseX,mouseY,width/2,height/2)*0.5f);
    stroke(fgColor,100);
    strokeWeight(pow(max(r/20,3),1.3f));
    r=min(r,150);
    line(width/2,height/2,(width/2)+r*cos(ang),(height/2)+r*sin(ang));
    
    //Draw player
    fill(fgColor);
    noStroke();
    ellipse(width/2,height/2,20,20);
    
    //secret stats B)
    if(key == 'd') {
      fill(255,0,0);
      textFont(font,30);
      text("bullets in world: " + bullets.size(),360,60);
      text("particles in world: " + particles.size(),360,90);
      text("baddies in world: " + enemies.size(),360,120);
      text("spawn chance: " + spawnChance,120,150);
      text("tbs: " + timeBetweenSpawns,500,150);
      text(PApplet.parseInt(frameRate) + "fps",360,180);
      text("score " + score,500,400);
    }
    
    if(gameState == 3) { //player dedded
      fill(0,50);
      stroke(255,100);
      strokeWeight((8*abs(sin(millis()/300f)))+4);
      translate(0,dedTranslate);
      translate(width/2,height/2);
      rotate(-0.1f);
      translate(-width/2,-height/2);
      rectMode(CENTER);
      rect(width/2,height/2,width*1.3f,230);
      fill(fgColor);
      textFont(font,60);
      text(deathMessage,width/4,height/2);
      textFont(font,30);
      text("Score: " + score, width/4, (height/2)+70);
      resetButton.updateAndDraw();
      
      if(abs(dedTranslate-dedTranslateTarget) < 5 && resetButton.isClicked) {
        gameStateNext = 1;
        globalTranslateYTarget = -1;
        press.trigger();
      }
    }
  } else if(gameState == 2) {//Settings//////////////////////////////////////////////////////////////////////
    renderSettings();
  }
  
  popMatrix();
  
  
  if(mousePressed) {
    lastMouseButton = mouseButton == LEFT;
  }
  
  //mouse trail
  for(int i=mouseTrailX.length-2; i > -1; i--) {
    mouseTrailX[i+1] = mouseTrailX[i];
    mouseTrailY[i+1] = mouseTrailY[i];
  }
  mouseTrailX[0] = mouseX;
  mouseTrailY[0] = mouseY;
  
  if(lastMouseButton) {
    stroke(ball1Color);
  } else {
    stroke(ball2Color);
  }
  strokeWeight(3);
  noFill();
  beginShape();
  for(int i=0; i < mouseTrailX.length; i++) {
    curveVertex(mouseTrailX[i],mouseTrailY[i]);
  }
  endShape();
  
  //Mouse
  translate(mouseX,mouseY);
  fill(bgColor);
  stroke(255,80);
  strokeWeight(1);
  ellipse(0,0,15,15);
  rotate(millis()/800f);
  strokeWeight(2);
  stroke(ball1Color);
  line(3,0,6,0);
  line(-3,0,-6,0);
  stroke(ball2Color);
  line(0,3,0,6);
  line(0,-3,0,-6);
}

public void tickAll(ArrayList a) {
  for(int i=a.size()-1;i >= 0; i--) {
    MovingThing o = (MovingThing) a.get(i);
    o.updateAndDraw();
    if(o.isOutsideScreen()) {
      a.remove(i);
    }
  }
}

public void checkCollision() {
  //check bullet collision
  for(int i=enemies.size()-1;i >= 0; i--) {
    
    Enemy o = null;
    try { 
      o = (Enemy) enemies.get(i); //<-- dunno why this sometimes fails.
    } catch (Exception e) {
      //let's just do a typical Ludum Dare Bandaid Fix (tm)
      println("Ayylmao");
      return; //problem solved!
    }
    
    for(int j=bullets.size()-1; j >= 0; j--) {
      if(o.boundsCheck(bullets.get(j))) {
        PVector where = o.getPos();
        if(where == null) println("Ooops!");
        float s = o.getSize();
        for(int k=0; k<s * particlesMult; k++) {
          particles.add(new ShapeParticle(where.x,where.y,random(s/8,s/6),random(TWO_PI),o.getColor(),0));
        }
        for(int k=0; k<(s/2)*particlesMult; k++) {
          particles.add(new ShapeParticle(where.x,where.y,random(s/6,s/4),random(TWO_PI),o.getColor(),1));
        }
        
        if(o instanceof TriangleEnemy) {
          for(int qqqw=0; qqqw<floor(random(3,5)); qqqw++) {
            enemies.add(new CircleEnemy(where.x,where.y,random(TWO_PI),random(4,9),true));
          }
          score += 200;
          explodespecial.trigger();
        }
        
        if(o instanceof SquareEnemy) {
          explodespecial.trigger();
          score += 100;
        }
        
        screenshakeAmount += s/6;
        enemies.remove(i);
        bullets.remove(j);
        explode2.trigger();
        spawnChance += 0.01f; //Make it a little bit harder
        timeBetweenSpawns = max(400,timeBetweenSpawns-5);
        
        if(gameState == 1) {
          score += 240-s;
        }
      }
    }
    
    //check ded collision
    
    if(gameState == 1 && o.boundsCheck(new PVector(width/2,height/2),20)) {
      gameState = 3;
      gameStateNext = 3;
      dedTranslateTarget = 0;
      lose.trigger();
      for(int h=enemies.size()-1; h >= 0; h--) {
        PVector where = enemies.get(h).getPos();
        int asdasdasd = enemies.get(h).getColor();
        float s = enemies.get(h).getSize();
        for(int k=0; k<s * particlesMult; k++) {
          particles.add(new ShapeParticle(where.x,where.y,random(s/8,s/6),random(TWO_PI),asdasdasd,0));
        }
        for(int k=0; k<(s/2)*particlesMult; k++) {
          particles.add(new ShapeParticle(where.x,where.y,random(s/6,s/4),random(TWO_PI),asdasdasd,1));
        }
        enemies.remove(h);
        
        resetMessage = resetMessages[floor(random(0,resetMessages.length))];
        deathMessage = deathMessages[floor(random(0,deathMessages.length))];
        resetButton.setText(resetMessage);
      }
    }
  }
}

public void mousePressed() { //Dirty mousePressed fix for multiple buttons.
  mouseButtonsPressed++;
}

public void mouseReleased() {
  mouseButtonsPressed--;
}

public void keyPressed() {
  saveFrame(millis()+".png");
}
interface Enemy {
  PVector pos = null;
  PVector vel = null;
  
  boolean wasOnScreen = false;
  
  public void update();
  public void draw();
  public void updateAndDraw();
  
  public boolean isOutsideScreen();
  public boolean boundsCheck(Bullet b);
  public boolean boundsCheck(PVector p, float s);
  
  int c = 69; //Huhuhuhu
  
  int myColor = 0xffFF0000;
  
  public PVector getPos();
  public int getColor();
  public float getSize();
}

class CircleEnemy implements Enemy, MovingThing {
  PVector pos;
  PVector vel;
  
  float siz;
  boolean wasOnScreen = false;
  
  int c=0;
  int myColor;
  
  int asdf = 0;
  
  CircleEnemy(float x, float y, float ang, float s) {
    pos = new PVector(x,y);
    vel = new PVector(s*cos(ang),s*sin(ang));
    
    siz = pow(random(14,35),1.3f);
    
    if(random(1f) > 0.5f)c=1;
    
    if(c == 0) {
      myColor = ball1Color;
    } else {
      myColor = ball2Color;
    }
    asdf = 69;
  }
  
  CircleEnemy(float x, float y, float ang, float s, boolean special) {
    pos = new PVector(x,y);
    vel = new PVector(s*cos(ang),s*sin(ang));
    
    siz = pow(random(14,35),1.3f);
    
    if(random(1f) > 0.5f)c=1;
    
    if(c == 0) {
      myColor = ball1Color;
    } else {
      myColor = ball2Color;
    }
  }
  
  public void update() {
    pos.add(vel);
    asdf++;
    if(asdf == 50) {
      float ang = atan2(pos.y-(height/2),pos.x-(width/2))+PI;
      vel.rotate(ang-vel.heading());
      vel.mult(0.2f);
    }
  }
  
  public void draw() {
    fill(myColor);
    noStroke();
    ellipse(pos.x,pos.y,siz,siz);
  }
  
  public void updateAndDraw() {
    this.update(); this.draw();
  }
  
  final int buffer = 80;
  public boolean isOutsideScreen() {
    if(wasOnScreen && ((pos.x > width+buffer) || (pos.x < -buffer) || (pos.y > height+buffer) || (pos.y < -buffer))) {
      return true;
    }
    
    if ((pos.x < width+buffer) && (pos.x > -buffer) && (pos.y < height+buffer) && (pos.y > -buffer)) {
      wasOnScreen = true;
    }
    return false;
  }
  
  public boolean boundsCheck(Bullet b) {
    if(b.c != c) return false;
    
    return dist(b.pos.x,b.pos.y,pos.x,pos.y) < (b.siz+siz)/2;
  }
  
  public boolean boundsCheck(PVector p, float s) {
    return dist(p.x,p.y,pos.x,pos.y) < (s+siz)/2;
  }
  
  public PVector getPos() {
    return pos; //Java for yall
  }
  
  public int getColor() {
    return myColor;
  }
  
  public float getSize() {
    return siz;
  }
}
class Bullet implements MovingThing { //mullet
  PVector pos;
  PVector vel;
  
  int c = 0;
  int myColor;
  
  int oldness = 0;
  
  int siz = 10;
  
  Bullet(float x, float y, float xt, float yt, float s, int buddon) {
    pos = new PVector(x,y);
    float theta = atan2(yt-y,xt-x);
    vel = new PVector(s*cos(theta),s*sin(theta));
    
    if(buddon == LEFT) {
      c = 0;
      myColor = ball1Color;
    } else {
      c = 1;
      myColor = ball2Color;
    }
  }
  
  public void update() {
    pos.add(vel);
    oldness++;
    if(oldness > 5) {
      if(particlesMult != 0) {
        for(float i=0; i < vel.mag()/6; i+=(1/particlesMult)) {
          Particle p = null;
          if(random(1)>0.2f) {
            p = new ShapeParticle(pos.x,pos.y,vel.mag()/3,PI+vel.heading()+random(-0.8f,0.8f),myColor,0);
          } else {
            p = new ShapeParticle(pos.x,pos.y,vel.mag()/1.3f,PI+vel.heading()+random(-0.8f,0.8f),0xff9514DB,0);
          }
          particles.add(p);
        }
      }
    }
  }
  
  public void draw() {
    fill(myColor);
    noStroke();
    ellipse(pos.x,pos.y,siz,siz);
  }
  
  final int buffer = 80;
  public boolean isOutsideScreen() {
    if(pos.x > width+buffer)  return true;
    if(pos.x < -buffer)       return true;
    if(pos.y > height+buffer) return true;
    if(pos.y < -buffer)       return true;
    return false;
  }
  
  public void updateAndDraw() {
    this.update();
    this.draw();
  }
}
interface MovingThing {
  PVector pos = null;
  PVector vel = null;
  
  public void update();
  public void draw();
  public void updateAndDraw();
  
  public boolean isOutsideScreen();
}

//Convenience interface so I can cast everything that moves
//into only one type, so I don't have to copy and paste everything 5000x.
//Basically lets me use the tickAll method found in the main file.
interface Particle {
  PVector pos = null;
  PVector vel = null;
  float age = 0;
  
  public void update();
  public void draw();
  public boolean isOutsideScreen();
  public void updateAndDraw();
}

class ShapeParticle implements Particle, MovingThing {
  PVector pos;
  PVector vel;
  float r;
  float rv;
  float age = 0;
  
  PVector corner1, corner2, corner3;
  
  int c;
  
  boolean drawWithStroke = false;
  
  int myShape = 0;
  
  ShapeParticle(float x, float y, float s, float new_r, int ccccc, int shape) {
    pos = new PVector(x,y);
    vel = new PVector(cos(new_r)*s,sin(new_r)*s);
    age = random(20,50);
    r = new_r;
    rv = random(-0.8f,0.8f);
    c=ccccc;
    
    myShape = shape;
    if(shape == 0) {
      //generate triangle
      float angle = random(0,TAU/3);
      corner1 = new PVector(cos(angle)*random(5,10),sin(angle)*random(5,10));
      angle = random(TAU/3,2*TAU/3);
      corner2 = new PVector(cos(angle)*random(5,10),sin(angle)*random(5,10));
      angle = random(2*TAU/3,TAU);
      corner3 = new PVector(cos(angle)*random(5,10),sin(angle)*random(5,10));
      
    }
    
    drawWithStroke = random(1f)>0.7f;
  }
  
  public void update() {
    pos.add(vel);
    vel.mult(0.97f);
    r += rv;
    rv *= 0.9f;
    age--;
  }
  
  public void draw() {
    noFill();
    if(drawWithStroke) {
      stroke(160,100);
      strokeWeight(1);
    } else {
      noStroke();
    }
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(r);
    if(myShape == 0) {
      fill(c,age*10);
      triangle(corner1.x,corner1.y,corner2.x,corner2.y,corner3.x,corner3.y);
    } else if (myShape == 1) {
      if(!drawWithStroke)fill(c,age*30);
      ellipse(0,0,age,age);
    }
    popMatrix();
  }
  
  final int buffer = 80;
  public boolean isOutsideScreen() {
    if(pos.x > width+buffer)  return true;
    if(pos.x < -buffer)       return true;
    if(pos.y > height+buffer) return true;
    if(pos.y < -buffer)       return true;
    if(age < 0) return true; //ded rip
    return false;
  }
  
  public void updateAndDraw() {
    this.update();
    this.draw();
  }
}
class Button {
  float x;
  float y;
  float w;
  float h;
  String text = "Noc Lute";
  
  float effect;
  float effectTarget;
  
  boolean isClicked = false;
  
  float myRotate = 0.1f;
  
  boolean enableClick = true;
  boolean oldHover = false;
  
  Button(float xx, float yy, float ww, float hh, String hehehe) {
    x = xx;
    y = yy;
    w = ww;
    h = hh;
    text = hehehe;
  }
  
  Button(float xx, float yy, float ss, String hehehe) {
    x = xx;
    y = yy;
    textFont(font,ss);
    w = textWidth(hehehe);
    h = ss;
    text = hehehe;
  }
  
  public void update() {
    if((mouseX > (x - (w/2))) && (mouseX < (x + (w/2))) && (mouseY > (y - (h/2))) && (mouseY < (y + (h/2)))) {
      if(effectTarget == 0) {
        myRotate = random(0.5f,3.0f);
        if(random(1f)>0.5f)myRotate *= -1;
      }
      if(oldHover == false) {
        hover.trigger();
        oldHover = true;
      }
      effectTarget = 1;
      isClicked = mousePressed && enableClick;
    } else {
      effectTarget = 0;
      isClicked = false;
      enableClick = true;
      if(oldHover == true) {
        unhover.trigger();
        oldHover = false;
      }
    }
    
    if(!mousePressed)enableClick = true;
    
    effect += (effectTarget - effect)*0.3f;
  }
  
  public void draw() {
    pushMatrix();
    translate(x,y);
    
    //magic hover effects
    scale(effect+1);
    rotate((effect/10) * myRotate);
    fill(lerpColor(fgColor,bgColor,effect));
    
    //box
    rectMode(CENTER);
    stroke(lerpColor(bgColor,ball2Color,effect));
    strokeWeight(3);
    rect(0,0,w,h);
    
    //wordz
    textAlign(CENTER,CENTER);
    fill(lerpColor(bgColor,ball1Color,effect));
    textFont(font,h*0.9f);
    text(text,0,0);
    popMatrix();
  }
  
  public void updateAndDraw() {
    this.update();
    this.draw();
  }
  
  public void setText(String s) {
    textFont(font,h);
    w = textWidth(s);
    text = s;
  }
}
class SquareEnemy implements Enemy, MovingThing {
  PVector pos;
  PVector vel;
  
  float siz;
  boolean wasOnScreen = false;
  
  int c=0;
  int myColor;
  
  PVector nextPos;
  PVector nextnextPos = new PVector(random(width),random(height));
  long lastMillis;
  int offset = floor(random(0,500));
  SquareEnemy(float x, float y, float ang, float s) {
    pos = new PVector(x,y);
    vel = new PVector(0,0);
    
    siz = pow(random(14,35),1.3f);
    
    if(random(1f) > 0.5f)c=1;
    
    nextPos = new PVector(pos.x,pos.y);
    
    if(c == 0) {
      myColor = ball1Color;
    } else {
      myColor = ball2Color;
    }
    
    lastMillis = millis();
  }
  
  public void update() {
    if((millis() - lastMillis) > 2000) {
      nextPos = new PVector(nextnextPos.x,nextnextPos.y);
      nextnextPos = new PVector(random(width),random(height));
      lastMillis = millis();
    }
    
    pos.x += (nextPos.x - pos.x)*0.04f;
    pos.y += (nextPos.y - pos.y)*0.04f;
  }
  
  public void draw() {
    fill(myColor);
    noStroke();
    pushMatrix();
    translate(pos.x,pos.y);
    rectMode(CENTER);
    rotate((millis()+offset) / 500f);
    rect(0,0,siz,siz);
    popMatrix();
    stroke(myColor);
    strokeWeight(1);
    line(pos.x,pos.y,nextnextPos.x,nextnextPos.y);
  }
  
  public void updateAndDraw() {
    this.update(); this.draw();
  }
  
  final int buffer = 80;
  public boolean isOutsideScreen() {
    if(wasOnScreen && ((pos.x > width+buffer) || (pos.x < -buffer) || (pos.y > height+buffer) || (pos.y < -buffer))) {
      return true;
    }
    
    if ((pos.x < width+buffer) && (pos.x > -buffer) && (pos.y < height+buffer) && (pos.y > -buffer)) {
      wasOnScreen = true;
    }
    return false;
  }
  
  public boolean boundsCheck(Bullet b) {
    if(b.c != c) return false;
    
    return dist(b.pos.x,b.pos.y,pos.x,pos.y) < (b.siz+siz)/2;
  }
  
  public boolean boundsCheck(PVector p, float s) {
    return dist(p.x,p.y,pos.x,pos.y) < (s+(siz*0.9f))/2;
  }
  
  public PVector getPos() {
    return pos; //Java for yall
  }
  
  public int getColor() {
    return myColor;
  }
  
  public float getSize() {
    return siz;
  }
}

class TriangleEnemy implements Enemy, MovingThing {
  PVector pos;
  PVector vel;
  
  float siz;
  boolean wasOnScreen = false;
  
  int c=0;
  int myColor;
  
  int offset = floor(random(0,500));
  TriangleEnemy(float x, float y, float ang, float s) {
    pos = new PVector(x,y);
    vel = new PVector(s*cos(ang)*0.3f,s*sin(ang)*0.3f);
    
    siz = pow(random(14,35),1.4f);
    
    if(random(1f) > 0.5f)c=1;
    
    if(c == 0) {
      myColor = ball1Color;
    } else {
      myColor = ball2Color;
    }
  }
  
  public void update() {
    pos.add(vel);
  }
  
  public void draw() {
    fill(myColor);
    noStroke();
    pushMatrix();
    translate(pos.x,pos.y);
    rectMode(CENTER);
    rotate((-millis()+offset) / 400f);
    beginShape();
    for(int i=0; i < 3; i++) {
      vertex(cos(i*(TWO_PI/3))*siz,sin(i*(TWO_PI/3))*siz);
    }
    endShape(CLOSE);
    popMatrix();
  }
  
  public void updateAndDraw() {
    this.update(); this.draw();
  }
  
  final int buffer = 80;
  public boolean isOutsideScreen() {
    if(wasOnScreen && ((pos.x > width+buffer) || (pos.x < -buffer) || (pos.y > height+buffer) || (pos.y < -buffer))) {
      return true;
    }
    
    if ((pos.x < width+buffer) && (pos.x > -buffer) && (pos.y < height+buffer) && (pos.y > -buffer)) {
      wasOnScreen = true;
    }
    return false;
  }
  
  public boolean boundsCheck(Bullet b) {
    if(b.c != c) return false;
    
    return dist(b.pos.x,b.pos.y,pos.x,pos.y) < (b.siz+siz)/2;
  }
  
  public boolean boundsCheck(PVector p, float s) {
    return dist(p.x,p.y,pos.x,pos.y) < (s+(siz*0.5f))/2;
  }
  
  public PVector getPos() {
    return pos; //Java for yall
  }
  
  public int getColor() {
    return myColor;
  }
  
  public float getSize() {
    return siz;
  }
}
Button backButton;
Button particlesButton;

float particlesMult = 1;
float volume = 1;

public void initSettings() {
  backButton = new Button(width/2, 3*height/4, 40, "Back");
  particlesButton = new Button(2*width/3, 200, 60, "Normal");
}

public void renderSettings() {
  textFont(font, 50);
  textAlign(RIGHT, CENTER);
  fill(fgColor);
  text("Particles", (width/2)-40, 200);
  textFont(font, 10);
  text("lol empty options screen", width/2, height/2);
  backButton.updateAndDraw();
  particlesButton.updateAndDraw();
  if (particlesButton.isClicked) {
    press.trigger();
    particlesButton.enableClick = false;
    if (particlesMult == 1) {
      particlesMult = 0.5f;
      particlesButton.setText("Few");
    } else if (particlesMult == 0.5f) {
      particlesMult = 2;
      particlesButton.setText("Lots");
    } else if (particlesMult == 2) {
      particlesMult = 1;
      particlesButton.setText("Normal");
    }
  }
  if (backButton.isClicked) {
    press.trigger();
    gameStateNext = 0;
    globalTranslateYTarget = 1;
  }
}
  public void settings() {  size(900,900);  smooth(8); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "LUDUM_DARE_34" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
