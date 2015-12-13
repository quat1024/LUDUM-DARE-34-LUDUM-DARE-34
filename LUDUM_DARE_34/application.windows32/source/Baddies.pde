interface Enemy {
  PVector pos = null;
  PVector vel = null;
  
  boolean wasOnScreen = false;
  
  void update();
  void draw();
  void updateAndDraw();
  
  boolean isOutsideScreen();
  boolean boundsCheck(Bullet b);
  boolean boundsCheck(PVector p, float s);
  
  int c = 69; //Huhuhuhu
  
  color myColor = #FF0000;
  
  PVector getPos();
  color getColor();
  float getSize();
}

class CircleEnemy implements Enemy, MovingThing {
  PVector pos;
  PVector vel;
  
  float siz;
  boolean wasOnScreen = false;
  
  int c=0;
  color myColor;
  
  int asdf = 0;
  
  CircleEnemy(float x, float y, float ang, float s) {
    pos = new PVector(x,y);
    vel = new PVector(s*cos(ang),s*sin(ang));
    
    siz = pow(random(14,35),1.3);
    
    if(random(1f) > 0.5)c=1;
    
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
    
    siz = pow(random(14,35),1.3);
    
    if(random(1f) > 0.5)c=1;
    
    if(c == 0) {
      myColor = ball1Color;
    } else {
      myColor = ball2Color;
    }
  }
  
  void update() {
    pos.add(vel);
    asdf++;
    if(asdf == 50) {
      float ang = atan2(pos.y-(height/2),pos.x-(width/2))+PI;
      vel.rotate(ang-vel.heading());
      vel.mult(0.2);
    }
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
  
  boolean boundsCheck(PVector p, float s) {
    return dist(p.x,p.y,pos.x,pos.y) < (s+siz)/2;
  }
  
  PVector getPos() {
    return pos; //Java for yall
  }
  
  color getColor() {
    return myColor;
  }
  
  float getSize() {
    return siz;
  }
}