interface Enemy {
  PVector pos = null;
  PVector vel = null;
  
  void update();
  void draw();
  void updateAndDraw();
  
  boolean isOutsideScreen();
  boolean boundsCheck(Bullet b);
}

class CircleEnemy implements Enemy {
  PVector pos;
  PVector vel;
  
  CircleEnemy(float x, float y, float ang, float s) {
    pos = new PVector(x,y);
    vel = new PVector(s*cos(ang),s*sin(ang));
  }
}