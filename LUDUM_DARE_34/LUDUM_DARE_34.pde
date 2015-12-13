import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

//MYGAME

//Todo:
// gameplay lol

int gameState = 0;
int gameStateNext = 0;
float globalTranslateY = 0;
float globalTranslateYTarget = 0;

PFont font;

Button playButton;
Button settingsButton;

color bgColor = #000000;
color fgColor = #FFCC66;
color ball1Color = #F54080;
color ball2Color = #40B7F5;

ArrayList<Bullet>   bullets   = new ArrayList<Bullet>(); //type casting \o/
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<Enemy>    enemies   = new ArrayList<Enemy>();

long lastFireMillis = 0;
long lastSpawnMillis = 0;

float screenshakeAmount = 0;

int mouseButtonsPressed = 0; //workaround for mousePressed bug

Minim minim;
AudioSample explode1;

void setup() {
  size(800,600);
  textAlign(CENTER,CENTER);
  
  font = loadFont("font.vlw");
  
  playButton = new Button(width/2,(2*height/3)-50,60,"PLAY");
  settingsButton = new Button(width/2,(2*height/3)+100,60,"SETTINGS");
  
  smooth(8); //antialiasing :D
  
  surface.setTitle("Shh bby is ok");
  
  minim = new Minim(this);
  
  //frameRate(5);
}

void draw() {
  background(bgColor);
  translate(0,globalTranslateY*height*1.5);
  globalTranslateY += (globalTranslateYTarget - globalTranslateY) * 0.08;
  
  //detect if we're in a screen transition right about now
  if(gameState != gameStateNext) {
    //then, if the transiton animation thingie is completes
    if(abs(globalTranslateYTarget - globalTranslateY) < 0.03) {
      //switch the game state and slide back down!
      gameState = gameStateNext;
      globalTranslateYTarget = 0;
    }
  }
  
  screenshakeAmount += (0-screenshakeAmount) * 0.1;
  translate(random(-screenshakeAmount,screenshakeAmount),random(-screenshakeAmount,screenshakeAmount));
  
  //MAIN MENU//////////////////////////////////////////////////////////////////////////////////////
  if(gameState == 0) {
    // draw title
    fill(fgColor);
    textFont(font,80);
    textAlign(CENTER,CENTER);
    text("Ayy lmao", width/2, height/3);
    
    //draw buddons
    playButton.updateAndDraw();
    settingsButton.updateAndDraw();
    
    if(playButton.isClicked) {
      gameStateNext = 1;
      globalTranslateYTarget = -1;
    }
  } else if(gameState == 1) { //GAMEPLAY SCREEN///////////////////////////////////////////////////////
    translate((width/2 - mouseX)*0.1,(height/2 - mouseY)*0.1); //"Camera"
    
    stroke(40,50,80);
    strokeWeight(1);
    for(int x=-100; x<width+100; x += 50) {
      line(x,-50,x,height+50);
    }
    for(int y=-100; y<height+100; y += 50) {
      line(-50,y,width+50,y);
    }
    
    if((mouseButtonsPressed != 0) && ((millis() - lastFireMillis) > 100)) {
      Bullet b = new Bullet(width/2,height/2,mouseX,mouseY,5+(dist(mouseX,mouseY,width/2,height/2)/30f),mouseButton);
      bullets.add(b);
      lastFireMillis = millis();
      screenshakeAmount = 3+(dist(mouseX,mouseY,width/2,height/2)/10f);
    }
    
    //Spawn enemies (in a large circle around screen)
    if((random(1f) > 0.9) && (millis() - lastSpawnMillis) > 800) {
      float angg = random(0,TWO_PI);
      float x = 900*cos(angg)+width/2;
      float y = 900*sin(angg)+height/2;
      float angToCenter = atan2((height/2)-y,(width/2)-x);
      enemies.add(new CircleEnemy(x,y,angToCenter+random(-0.02,0.02),random(2,5)));
      lastSpawnMillis = millis();
    }
    
    
    //Do the thingie!!!
    tickAll(particles);
    tickAll(bullets);
    tickAll(enemies);
    
    checkCollision();
    
    //Aim line
    float ang = atan2(mouseY-(height/2),mouseX-(width/2));
    float r   = 10+(dist(mouseX,mouseY,width/2,height/2)*0.5);
    stroke(fgColor,100);
    strokeWeight(pow(max(r/20,3),1.3));
    r=min(r,150);
    line(width/2,height/2,(width/2)+r*cos(ang),(height/2)+r*sin(ang));
    
    //Draw player
    fill(fgColor);
    noStroke();
    ellipse(width/2,height/2,20,20);
    
    if(key == 'd') {
      fill(255,0,0);
      textFont(font,30);
      text("bullets in world: " + bullets.size(),360,60);
      text("particles in world: " + particles.size(),360,90);
      text("baddies in world: " + enemies.size(),360,120);
      text(int(frameRate) + "fps",360,150);
    }
  }
}

void tickAll(ArrayList a) {
  for(int i=a.size()-1;i >= 0; i--) {
    MovingThing o = (MovingThing) a.get(i);
    o.updateAndDraw();
    if(o.isOutsideScreen()) {
      a.remove(i);
    }
  }
}

void checkCollision() {
  //check bullet collision
  for(int i=enemies.size()-1;i >= 0; i--) {
    Enemy o = (Enemy) enemies.get(i);
    for(int j=bullets.size()-1; j >= 0; j--) {
      if(o.boundsCheck(bullets.get(j))) {
        enemies.remove(i);
        bullets.remove(j);
        return;
      }
    }
  }
}

void mousePressed() { //Dirty mousePressed fix.
  mouseButtonsPressed++;
}

void mouseReleased() {
  mouseButtonsPressed--;
}

void keyPressed() {
  enemies.add(new CircleEnemy(mouseX,mouseY,random(TWO_PI),3));
}