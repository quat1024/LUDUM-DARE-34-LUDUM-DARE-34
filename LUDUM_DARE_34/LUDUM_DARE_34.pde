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

float screenshakeAmount = 0;

void setup() {
  size(800,600);
  textAlign(CENTER,CENTER);
  
  font = loadFont("font.vlw");
  
  playButton = new Button(width/2,(2*height/3)-50,60,"PLAY");
  settingsButton = new Button(width/2,(2*height/3)+100,60,"SETTINGS");
  
  smooth(8); //antialiasing :D
}

void draw() {
  background(bgColor);
  translate(0,globalTranslateY*height*1.5);
  rotate(globalTranslateY*-0.7);
  globalTranslateY += (globalTranslateYTarget - globalTranslateY) * 0.08;
  
  //detect if we're in a screen transition right about now
  if(gameState != gameStateNext) {
    //then, if the transiton animation thingie is completes
    if(abs(globalTranslateYTarget - globalTranslateY) < 0.01) {
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
    
    if(mousePressed && ((millis() - lastFireMillis) > 100)) {
      bullets.add(new Bullet(width/2,height/2,mouseX,mouseY,5+(dist(mouseX,mouseY,width/2,height/2)/30f),mouseButton));
      lastFireMillis = millis();
      screenshakeAmount = 5+(dist(mouseX,mouseY,width/2,height/2)/10f);
    }
    
    for(int i=bullets.size()-1;i >= 0; i--) {
      Bullet b = bullets.get(i);
      b.updateAndDraw();
      if(b.isOutsideScreen()) {
        bullets.remove(i);
      }
    }
    
    for(int i=particles.size()-1;i >= 0; i--) {
      Particle p = particles.get(i);
      p.updateAndDraw();
      if(p.isOutsideScreen()) {
        particles.remove(i);
      }
    }
    
    fill(fgColor);
    noStroke();
    ellipse(width/2,height/2,20,20);
    
    
    /*fill(255,0,0);
    textFont(font,30);
    text("bullets in world: " + bullets.size(),360,60);*/
  }
}