void setup(){
  size(720, 720, P3D); //<>//
  smooth(8);
  fill(0);
}
 //<>//
boolean recording = false;
float t=0;
Stepper stp = new Stepper();

void draw(){
  if(recording)
    stp.record(60*4, 4, .6);
  else{
    stp.speed(1);
    stp.start(LOOP);
  }
  background(128);
  
  if(stp.step()){
    t=stp.time();
    ellipse(width/2,t*(height+2*25)-25,50,50);
  }
  if(stp.step(2)){
    t=stp.time();
    rect(t*(width+50)-50,t*height,50,50);
  }
  if(stp.step()){
    t=stp.time();
    ellipse(t*(width+200)-100,height/2,200,42);
  }
  if(stp.step(2,4)){
    t=stp.time(0);
    rect((1-t)*width,t*height,50,50);
  } //<>//
}
