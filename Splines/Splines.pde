/**
 * Splines.
 *
 * Here we use the interpolator.keyFrames() nodes
 * as control points to render different splines.
 *
 * Press ' ' to change the spline mode.
 * Press 'g' to toggle grid drawing.
 * Press 'c' to toggle the interpolator path drawing.
 */

import frames.input.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

// global variables
// modes: 0 natural cubic spline; 1 Hermite;
// 2 (degree 7) Bezier; 3 Cubic Bezier
int mode;

Scene scene;
Interpolator interpolator;
OrbitNode eye;
boolean drawGrid = true, drawCtrl = true;
ArrayList<Vector> bezierVector = new ArrayList();
float resolution =0.01;

//Choose P3D for a 3D scene, or P2D or JAVA2D for a 2D scene
String renderer = P3D;

void setup() {
  size(800, 800, renderer);
  scene = new Scene(this);
  eye = new OrbitNode(scene);
  eye.setDamping(0);
  scene.setEye(eye);
  scene.setFieldOfView(PI / 3);
  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.setRadius(150);
  scene.fitBallInterpolation();
  interpolator = new Interpolator(scene, new Frame());
  // framesjs next version, simply go:
  //interpolator = new Interpolator(scene);

  // Using OrbitNodes makes path editable
  for (int i = 0; i < 8; i++) {
    Node ctrlPoint = new OrbitNode(scene);
    ctrlPoint.randomize();
    interpolator.addKeyFrame(ctrlPoint);
  }
}

void draw() {
  background(175);
  if (drawGrid) {
    stroke(255, 255, 0);
    scene.drawGrid(200, 50);
  }
  if (drawCtrl) {
    fill(255, 0, 0);
    stroke(255, 0, 255);
    for (Frame frame : interpolator.keyFrames())
      scene.drawPickingTarget((Node)frame);
  } else {
    fill(255, 0, 0);
    stroke(255, 0, 255);
    scene.drawPath(interpolator);
  }
  //for (Frame frame : interpolator.keyFrames()){
  //Vector x=frame.position();
  //println(x);
  //}
  ArrayList<Vector> auxVector = new ArrayList();
  float x=0;
  switch (mode){
  case 0:
    for (Frame frame : interpolator.keyFrames()){
    auxVector.add(frame.position());
    }
    bezierVector.clear();

    while(x<=1.0){
      bezierCurve(auxVector, x);
      x+=resolution;
    }
    drawBezier();
    scene.beginScreenCoordinates();
    noLights();
    stroke(255);
    noFill();
    //fill(255);
    text("Bezier (degree 7)", 10, 20);
    scene.endScreenCoordinates();
    break;  
  case 1:
    for (Frame frame : interpolator.keyFrames()){
    auxVector.add(frame.position());
    }
    bezierVector.clear();
    cubicBezier(auxVector);
    drawBezier();
    scene.beginScreenCoordinates();
    noLights();
    stroke(255);
    noFill();
    //fill(255);
    text("Cubic Bezier ", 10, 20);
    scene.endScreenCoordinates();
    break; 
    
    
  }
  
  // implement me
  // draw curve according to control polygon an mode
  // To retrieve the positions of the control points do:
  // for(Frame frame : interpolator.keyFrames())
  //   frame.position();
}

void keyPressed() {
  if (key == ' ')
    mode = mode < 1 ? mode+1 : 0;
  if (key == 'g')
    drawGrid = !drawGrid;
  if (key == 'c')
    drawCtrl = !drawCtrl;
}

void bezierCurve(ArrayList<Vector> points, float t){
  if (points.size() >1){ 
    ArrayList<Vector> aux = new ArrayList();
    for (int x=0;x<points.size()-1;++x){
       aux.add(newVector(points.get(x),points.get(x+1),t));
     }
     bezierCurve(aux,t);
  }else{
     bezierVector.add(points.get(0)); 
  }
}

void cubicBezier(ArrayList<Vector> points){
    ArrayList<Vector> aux = new ArrayList();
    ArrayList<Vector> aux2 = new ArrayList();
    Vector punto = new Vector();
    punto = newVector (points.get(3),points.get(4),0.5);
    aux2.add(punto);
    for (int x=0;x<4;++x){
      aux.add(points.get(x));
      aux2.add(points.get(x+4));
    }
    aux.add(punto);
    float x=0;
    while(x<=1.0){
      bezierCurve(aux, x);
      x+=resolution;
    }
    x=0;
    while(x<=1.0){
      bezierCurve(aux2, x);
      x+=resolution;
    }
}

Vector newVector (Vector v1, Vector v2, float t){
  Vector pos = new Vector();
  pos.setX(lerp(v1.x(),v2.x(),t));
  pos.setY(lerp(v1.y(),v2.y(),t));
  pos.setZ(lerp(v1.z(),v2.z(),t));
  return pos;
}

void drawBezier(){
 stroke(color(0,128,175));
 fill(color(0,128,175)); 
 beginShape(LINES);
   for (int x=0; x<bezierVector.size()-1;++x){
      vertex(bezierVector.get(x).x(),bezierVector.get(x).y(),bezierVector.get(x).z()); 
      vertex(bezierVector.get(x+1).x(),bezierVector.get(x+1).y(),bezierVector.get(x+1).z()); 
   }
     
 endShape(); 
  
}