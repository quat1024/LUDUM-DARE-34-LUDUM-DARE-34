class SquareEnemy implements Enemy, MovingThing {
  PVector pos;
  PVector vel;
  
  float siz;
  boolean wasOnScreen = false;
  
  int c=0;
  color myColor;
  
  PVector nextPos;
  PVector nextnextPos = new PVector(random(width),random(height));
  long lastMillis;
  int offset = floor(random(0,500));
  SquareEnemy(float x, float y, float ang, float s) {
    pos = new PVector(x,y);
    vel = new PVector(0,0);
    
    siz = pow(random(14,35),1.3);
    
    if(random(1f) > 0.5)c=1;
    
    nextPos = new PVector(nextnextPos.x,nextnextPos.y);
    
    if(c == 0) {
      myColor = ball1Color;
    } else {
      myColor = ball2Color;
    }
    
    lastMillis = millis();
  }
  
  void update() {
    if((millis() - lastMillis) > 2000) {
      nextPos = new PVector(nextnextPos.x,nextnextPos.y);
      nextnextPos = new PVector(random(width),random(height));
      lastMillis = millis();
    }
    
    pos.x += (nextPos.x - pos.x)*0.04;
    pos.y += (nextPos.y - pos.y)*0.04;
  }
  
  void draw() {
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
    return dist(p.x,p.y,pos.x,pos.y) < (s+(siz*0.9))/2;
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