String MOUSE = "MOUSE"; //<>//
String LOOP = "LOOP";
String ONCE = "ONCE";

class Stepper{
  private float totalSteps, currentStep, t, tt, e, speed;
  private Recorder rec = new Recorder();
  
  Stepper(){
    totalSteps=0;
    t=0;
    e=1;
    speed=1;
  }
  
  void record(){
    record(120, 4, .25);
  }
  void record(int numFrames, int samplesPerFrame, float shutterAngle){
    rec.record(numFrames, samplesPerFrame, shutterAngle);
  }
  
  void start(){
    start(MOUSE);
  }
  void start(String str){
    str = str.toUpperCase();
    if(str.equals("LOOP"))
      start(frameCount%(speed*240)/(speed*240));
    else if(str.equals("MOUSE"))
      start((float)mouseX/width);
    else if(str.equals("ONCE"))
      if(frameCount <= speed*240)
        start(frameCount/(speed*240));
  }  
  void start(float globalTime){
    currentStep=0;
    t=globalTime;
  }
  
  boolean step(){
    return step(1);
  }
  boolean step(float s){
    currentStep+=s;
    return step(currentStep-s,currentStep);
  }
  boolean step(float s1, float s2){
    if(totalSteps<s2)
      totalSteps = s2;
    if(s1<=totalSteps*t && totalSteps*t<s2){
      setTime(s2, s2-s1);
      return true;
    } else {
      return false;
    }
  }
  
  private void setTime(float end, float size){
    tt = (t*totalSteps-(end-size))/size;
  }
  
  float time(){
    return time(e);
  }
  float time(float es){
    return ease(tt, es);
  }
  float globalTime(){
    return globalTime(e);
  }
  float globalTime(float es){
    return ease(t, es);
  }
  
  private float ease(float p, float h) {
    if(h==1)
      return pow(p, 2)*(3-2*p);
    else if(h==0)
      return p;
    
    float g=pow(log(0.3125)/log(0.5), h);
    if (p < 0.5) 
      return 0.5*pow(2*p, g);
    else
      return 1-0.5 * pow(2*(1-p), g);
  }
  
  void easeLevel(float es){
    e = es;
  }
  
  void speed(float sp){
    speed = 1/sp;
  }
  
}

private class Recorder{
  
  private boolean sampling = false;
  private int numFrames = 120; 
  private int samplesPerFrame = 4;
  private float shutterAngle = .25;
  private int[][] result;
  private int sa;

  float record(){
    return record(numFrames, samplesPerFrame, shutterAngle);
  }
  
  float record(int nf, int spf, float ang){
    numFrames = nf;
    samplesPerFrame = spf;
    shutterAngle = ang;
    
    if(!sampling){
      result = new int[width*height][3];
        for (int i=0; i<width*height; i++)
          for (int a=0; a<3; a++)
            result[i][a] = 0;
  
      sampling = true;
      for (sa=0; sa<samplesPerFrame; sa++) {
        draw();
        loadPixels();
        for (int i=0; i<pixels.length; i++) {
          result[i][0] += pixels[i] >> 16 & 0xff;
          result[i][1] += pixels[i] >> 8 & 0xff;
          result[i][2] += pixels[i] & 0xff;
        }
      }
      sampling = false;
  
      loadPixels();
      for (int i=0; i<pixels.length; i++)
        pixels[i] = 0xff << 24 | 
          int(result[i][0]*1.0/samplesPerFrame) << 16 | 
          int(result[i][1]*1.0/samplesPerFrame) << 8 | 
          int(result[i][2]*1.0/samplesPerFrame);
      updatePixels();
      saveFrame("gif/f###.gif");
      System.out.println("f###.gif");
      if (frameCount==numFrames){
        System.out.println("done");
        exit();
      }
    }
    
    return map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
    
  } 
}
