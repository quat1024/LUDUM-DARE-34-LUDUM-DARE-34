interface Particle {
  PVector pos = null;
  PVector vel = null;
  float age = 0;
  
  void update();
  void draw();
  boolean isOutsideScreen();
  void updateAndDraw();
}

class ShapeParticle implements Particle, MovingThing {
  PVector pos;
  PVector vel;
  float r;
  float rv;
  float age = 0;
  
  PVector corner1, corner2, corner3;
  
  color c;
  
  boolean drawWithStroke = false;
  
  int myShape = 0;
  
  ShapeParticle(float x, float y, float s, float new_r, color ccccc, int shape) {
    pos = new PVector(x,y);
    vel = new PVector(cos(new_r)*s,sin(new_r)*s);
    age = random(20,50);
    r = new_r;
    rv = random(-0.8,0.8);
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
    
    drawWithStroke = random(1f)>0.7;
  }
  
  void update() {
    pos.add(vel);
    vel.mult(0.97);
    r += rv;
    rv *= 0.9;
    age--;
  }
  
  void draw() {
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