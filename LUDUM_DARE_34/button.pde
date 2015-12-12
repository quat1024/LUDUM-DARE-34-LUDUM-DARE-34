class Button {
  float x;
  float y;
  float w;
  float h;
  String text = "Noc Lute";
  
  float effect;
  float effectTarget;
  
  boolean isClicked = false;
  
  Button(float xx, float yy, float ww, float hh, String hehehe) {
    x = xx;
    y = yy;
    w = ww;
    h = hh;
    text = hehehe;
  }
  
  Button(float xx, float yy, float ss, String hehehe) {
    x = xx;
    y = yy;
    textFont(font,ss);
    w = textWidth(hehehe);
    h = ss;
    text = hehehe;
  }
  
  void update() {
    if((mouseX > (x - (w/2))) && (mouseX < (x + (w/2))) && (mouseY > (y - (h/2))) && (mouseY < (y + (h/2)))) {
      effectTarget = 1;
      isClicked = mousePressed;
    } else {
      effectTarget = 0;
      isClicked = false;
    }
    
    effect += (effectTarget - effect)*0.3;
  }
  
  void draw() {
    pushMatrix();
    translate(x,y);
    
    //magic hover effects
    scale(effect+1);
    rotate(effect/10);
    fill(lerpColor(fgColor,bgColor,effect));
    
    //box
    rectMode(CENTER);
    stroke(lerpColor(bgColor,ball2Color,effect));
    strokeWeight(3);
    rect(0,0,w,h);
    
    //wordz
    textAlign(CENTER,CENTER);
    fill(lerpColor(bgColor,ball1Color,effect));
    textFont(font,h*4);
    scale(0.25);
    text(text,0,0);
    popMatrix();
  }
  
  void updateAndDraw() {
    this.update();
    this.draw();
  }
}