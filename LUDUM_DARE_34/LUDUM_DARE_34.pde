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
float dedTranslate = 0;
float dedTranslateTarget = 0;

PFont font;

Button playButton;
Button settingsButton;
Button resetButton;

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
AudioSample explode2;
AudioSample lose;
AudioSample hover;
AudioSample unhover;
AudioSample press;
AudioSample explodespecial;

float spawnChance = 0.06;
int timeBetweenSpawns = 800;

int score = 0;

String[] deathMessages = {"oops","rip","dang","whups","ouch","D:","dang it","darn it","oh no","aww"};
String[] resetMessages = {"Try again","Retry","1 more go","Restart","Rewind","Okay","   :(   ","Again"};
String resetMessage = "asdfghjkl";
String deathMessage = "asdfghjkl";

int[] mouseTrailX = new int[10];
int[] mouseTrailY = new int[10];

boolean lastMouseButton;

void setup() {
  size(900,900);
  textAlign(CENTER,CENTER);
  
  font = loadFont("font.vlw");
  
  playButton = new Button(width/2,(2*height/3)-50,60,"PLAY");
  settingsButton = new Button(width/2,(2*height/3)+100,60,"SETTINGS");
  resetButton = new Button(3*width/4,height/2,60,"Try again");
  smooth(8); //antialiasing :D
  
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
  dedTranslateTarget = height*1.3;
  
  initSettings(); //keeping it all in one file ;)
  
  noCursor();
}

void draw() {
  pushMatrix();
  background(bgColor);
  translate(0,globalTranslateY*height*1.5);
  scale(globalTranslateY+1);
  globalTranslateY += (globalTranslateYTarget - globalTranslateY) * 0.08;
  dedTranslate += (dedTranslateTarget - dedTranslate) * 0.1;
  
  //detect if we're in a screen transition right about now
  if(gameState != gameStateNext) {
    //then, if the transiton animation thingie is completes
    if(abs(globalTranslateYTarget - globalTranslateY) < 0.03) {
      //switch the game state and slide back down!
      gameState = gameStateNext;
      globalTranslateYTarget = 0;
      
      if(gameState == 1) { //switching to play mode?
        //let's set things up
        score = 0;
        spawnChance = 0.06;
        timeBetweenSpawns = 800;
        
        bullets   = new ArrayList<Bullet>();
        particles = new ArrayList<Particle>();
        enemies   = new ArrayList<Enemy>();
        
        lastSpawnMillis = millis()+1000;
        dedTranslateTarget = height*1.3;
      }
    }
  }
  
  screenshakeAmount += (0-screenshakeAmount) * 0.2;
  translate(random(-screenshakeAmount,screenshakeAmount),random(-screenshakeAmount,screenshakeAmount));
  
  //MAIN MENU//////////////////////////////////////////////////////////////////////////////////////
  if(gameState == 0) {
    // draw title
    for(int i=0; i < 5; i++) {
      fill(lerpColor(#000000,fgColor,i/5f));
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
    translate((width/2 - mouseX)*0.15,(height/2 - mouseY)*0.15); //"Camera"
    
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
      
      if(n < 0.9) {
        enemies.add(new CircleEnemy(x,y,angToCenter+random(-0.02,0.02),random(2,5)));
      } else if(n < 0.95) {
        enemies.add(new SquareEnemy(x,y,angToCenter+random(-0.02,0.02),random(2,5)));
      } else {
        enemies.add(new TriangleEnemy(x,y,angToCenter+random(-0.02,0.02),random(2,5)));
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
    float r   = 10+(dist(mouseX,mouseY,width/2,height/2)*0.5);
    stroke(fgColor,100);
    strokeWeight(pow(max(r/20,3),1.3));
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
      text(int(frameRate) + "fps",360,180);
      text("score " + score,500,400);
    }
    
    if(gameState == 3) { //player dedded
      fill(0,50);
      stroke(255,100);
      strokeWeight((8*abs(sin(millis()/300f)))+4);
      translate(0,dedTranslate);
      translate(width/2,height/2);
      rotate(-0.1);
      translate(-width/2,-height/2);
      rectMode(CENTER);
      rect(width/2,height/2,width*1.3,230);
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
        spawnChance += 0.01; //Make it a little bit harder
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
        color asdasdasd = enemies.get(h).getColor();
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

void mousePressed() { //Dirty mousePressed fix for multiple buttons.
  mouseButtonsPressed++;
}

void mouseReleased() {
  mouseButtonsPressed--;
}

void keyPressed() {
  saveFrame(millis()+".png");
}