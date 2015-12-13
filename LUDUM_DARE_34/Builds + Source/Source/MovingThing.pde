interface MovingThing {
  PVector pos = null;
  PVector vel = null;
  
  void update();
  void draw();
  void updateAndDraw();
  
  boolean isOutsideScreen();
}

//Convenience interface so I can cast everything that moves
//into only one type, so I don't have to copy and paste everything 5000x.
//Basically lets me use the tickAll method found in the main file.