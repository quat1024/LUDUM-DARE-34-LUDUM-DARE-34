class Bullet implements MovingThing { //mullet
  PVector pos;
  PVector vel;
  
  int c = 0;
  color myColor;
  
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
  
  void update() {
    pos.add(vel);
    oldness++;
    if(oldness > 5) {
      for(int i=0; i < vel.mag()/6; i++) {
        Particle p = new TriangleParticle(pos.x,pos.y,vel.mag()/3,PI+vel.heading()+random(-0.8,0.8),myColor);
        particles.add(p);
      }
    }
  }
  
  void draw() {
    fill(myColor);
    noStroke();
    ellipse(pos.x,pos.y,10,10);
  }
  
  final int buffer = 80;
  boolean isOutsideScreen() {
    if(pos.x > width+buffer)  return true;
    if(pos.x < -buffer)       return true;
    if(pos.y > height+buffer) return true;
    if(pos.y < -buffer)       return true;
    return false;
  }
  
  void updateAndDraw() {
    this.update();
    this.draw();
  }
}