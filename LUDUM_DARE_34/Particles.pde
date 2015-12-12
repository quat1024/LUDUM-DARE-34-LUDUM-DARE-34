interface Particle {
  PVector pos = null;
  PVector vel = null;
  float age = 0;
  
  void update();
  void draw();
  boolean isOutsideScreen();
  void updateAndDraw();
}

class TriangleParticle implements Particle {
  PVector pos;
  PVector vel;
  float r;
  float rv;
  float age = 0;
  
  PVector corner1, corner2, corner3;
  
  color c;
  
  TriangleParticle(float x, float y, float s, float new_r, color ccccc) {
    pos = new PVector(x,y);
    vel = new PVector(cos(new_r)*s,sin(new_r)*s);
    age = random(20,50);
    r = new_r;
    rv = random(-0.8,0.8);
    c=ccccc;
    //generate triangle
    float angle = random(0,TAU/3);
    corner1 = new PVector(cos(angle)*random(5,10),sin(angle)*random(5,10));
    angle = random(TAU/3,2*TAU/3);
    corner2 = new PVector(cos(angle)*random(5,10),sin(angle)*random(5,10));
    angle = random(2*TAU/3,TAU);
    corner3 = new PVector(cos(angle)*random(5,10),sin(angle)*random(5,10));
  }
  
  void update() {
    pos.add(vel);
    vel.mult(0.97);
    r += rv;
    rv *= 0.9;
    age--;
  }
  
  void draw() {
    fill(c,age*10);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(r);
    triangle(corner1.x,corner1.y,corner2.x,corner2.y,corner3.x,corner3.y);
    popMatrix();
  }
  
  final int buffer = 80;
  boolean isOutsideScreen() {
    if(pos.x > width+buffer)  return true;
    if(pos.x < -buffer)       return true;
    if(pos.y > height+buffer) return true;
    if(pos.y < -buffer)       return true;
    if(age < 0) return true; //ded rip
    return false;
  }
  
  void updateAndDraw() {
    this.update();
    this.draw();
  }
}