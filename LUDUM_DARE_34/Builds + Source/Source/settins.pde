Button backButton;
Button particlesButton;

float particlesMult = 1;
float volume = 1;

void initSettings() {
  backButton = new Button(width/2, 3*height/4, 40, "Back");
  particlesButton = new Button(2*width/3, 200, 60, "Normal");
}

void renderSettings() {
  textFont(font, 50);
  textAlign(RIGHT, CENTER);
  fill(fgColor);
  text("Particles", (width/2)-40, 200);
  textFont(font, 10);
  text("lol empty options screen", width/2, height/2);
  backButton.updateAndDraw();
  particlesButton.updateAndDraw();
  if (particlesButton.isClicked) {
    press.trigger();
    particlesButton.enableClick = false;
    if (particlesMult == 1) {
      particlesMult = 0.5;
      particlesButton.setText("Few");
    } else if (particlesMult == 0.5) {
      particlesMult = 2;
      particlesButton.setText("Lots");
    } else if (particlesMult == 2) {
      particlesMult = 1;
      particlesButton.setText("Normal");
    }
  }
  if (backButton.isClicked) {
    press.trigger();
    gameStateNext = 0;
    globalTranslateYTarget = 1;
  }
}