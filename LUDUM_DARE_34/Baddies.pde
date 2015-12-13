interface Enemy {
  PVector pos = null;
  PVector vel = null;
  
  boolean wasOnScreen = false;
  
  void update();
  void draw();
  void updateAndDraw();
  
  boolean isOutsideScreen();
  boolean boundsCheck(Bullet b);
  
  int c = 69;
}

class CircleEnemy implements Enemy, MovingThing {
  PVector pos;
  PVector vel;
  
  float siz;
  boolean wasOnScreen = false;
  
  int c=0;
  color myColor;
  
  CircleEnemy(float x, float y, float ang, float s) {
    pos = new PVector(x,y);
    vel = new PVector(s*cos(ang),s*sin(ang));
    
    siz = pow(random(13,30),1.2);
    
    if(random(1f) > 0.5)c=1;
    
    if(c == 0) {
      myColor = ball1Color;
    } else {
      myColor = ball2Color;
    }
  }
  
  void update() {
    pos.add(vel);
  }
  
  void draw() {
    fill(myColor);
    noStroke();
    ellipse(pos.x,pos.y,siz,siz);
  }
  
  void updateAndDraw() {
    this.update(); this.draw();
  }
  
  final int buffer = 80;
  boolean isOutsideScreen() {
    if(wasOnScreen && ((pos.x > width+buffer) || (pos.x < -buffer) || (pos.y > height+buffer) || (pos.y < -buffer))) {
      return true;
    }
    
    if ((pos.x < width+buffer) && (pos.x > -buffer) && (pos.y < height+buffer) && (pos.y > -buffer)) {
      wasOnScreen = true;
    }
    return false;
  }
  
  boolean boundsCheck(Bullet b) {
    if(b.c != c) return false;
    
    return dist(b.pos.x,b.pos.y,pos.x,pos.y) < (b.siz+siz)/2;
  }
}