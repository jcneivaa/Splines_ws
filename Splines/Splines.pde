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
// modes: 
// 0 Bezier (degree 7) 
// 1 Cubic Bezier
// 2 natural cubic spline
// 3 Hermite (This is missing)
int mode;

Scene scene;
Interpolator interpolator;
OrbitNode eye;
boolean drawGrid = true, drawCtrl = true;
ArrayList<Vector> curvePoints = new ArrayList();
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
  for (Frame frame : interpolator.keyFrames()){
    auxVector.add(frame.position());
  }
  curvePoints.clear();
  switch (mode){
  case 0:
    while(x<=1.0){
      bezierCurve(auxVector, x);
      x+=resolution;
    }
    drawCurve();
    scene.beginScreenCoordinates();
    noLights();
    stroke(255);
    noFill();
    text("Bezier (degree 7)", 10, 20);
    scene.endScreenCoordinates();
    break;  
  case 1:
    cubicBezier(auxVector);
    drawCurve();
    scene.beginScreenCoordinates();
    noLights();
    stroke(255);
    noFill();
    text("Cubic Bezier ", 10, 20);
    scene.endScreenCoordinates();
    break; 
  case 2:
    cubicSpline(auxVector);
    drawCurve();
    scene.beginScreenCoordinates();
    noLights();
    stroke(255);
    noFill();
    text("Natural Cubic Spline", 10, 20);
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
    mode = mode < 2 ? mode+1 : 0;
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
     curvePoints.add(points.get(0)); 
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

void drawCurve(){
 stroke(color(0,128,175));
 fill(color(0,128,175)); 
 beginShape(LINES);
   for (int x=0; x<curvePoints.size()-1;++x){
      vertex(curvePoints.get(x).x(),curvePoints.get(x).y(),curvePoints.get(x).z()); 
      vertex(curvePoints.get(x+1).x(),curvePoints.get(x+1).y(),curvePoints.get(x+1).z()); 
   }
     
 endShape(); 
}

void cubicSpline(ArrayList<Vector> points){
  int N = points.size();
  float[][] tridiagonal = new float[N][N];
  float[][] xMatrix = new float[N][1];
  float[][] yMatrix = new float[N][1];
  float[][] zMatrix = new float[N][1];
  for(int i=1;i<N-1;++i){
    tridiagonal[i][i-1] = 1;
    tridiagonal[i][i] = 4;
    tridiagonal[i][i+1] = 1;
    xMatrix[i][0] = 3*(points.get(i+1).x() - points.get(i-1).x());
    yMatrix[i][0] = 3*(points.get(i+1).y() - points.get(i-1).y());
    zMatrix[i][0] = 3*(points.get(i+1).z() - points.get(i-1).z());
  }
  
  xMatrix[0][0] = 3*(points.get(1).x() - points.get(0).x());
  xMatrix[N-1][0] = 3*(points.get(N-1).x() - points.get(N-2).x());
  
  yMatrix[0][0] = 3*(points.get(1).y() - points.get(0).y());
  yMatrix[N-1][0] = 3*(points.get(N-1).y() - points.get(N-2).y());
  
  zMatrix[0][0] = 3*(points.get(1).z() - points.get(0).z());
  yMatrix[N-1][0] = 3*(points.get(N-1).z() - points.get(N-2).z());
  
  tridiagonal[0][0] = tridiagonal[N-1][N-1] = 2;
  tridiagonal[0][1] = tridiagonal[N-1][N-2] = 1;
  
  Matrix m1 = new Matrix(tridiagonal);
  Matrix m2 = new Matrix(tridiagonal);
  Matrix m3 = new Matrix(tridiagonal);
  float[][] solX = m1.solve( new Matrix(xMatrix) ).data;
  float[][] solY = m2.solve( new Matrix(yMatrix) ).data;
  float[][] solZ = m3.solve( new Matrix(yMatrix) ).data;
  //println("OK");
  float[][][] coef = new float[N-1][3][4];
  for(int i=0;i<N-1;++i){   
    
    coef[i][0][0] = points.get(i).x();
    coef[i][0][1] = solX[i][0];
    coef[i][0][2] = 3*(points.get(i+1).x() - points.get(i).x())-2*solX[i][0] - solX[i+1][0];
    coef[i][0][3] = 2*(points.get(i).x() - points.get(i+1).x()) + solX[i][0] + solX[i+1][0];
    
    coef[i][1][0] = points.get(i).y();
    coef[i][1][1] = solY[i][0];
    coef[i][1][2] = 3*(points.get(i+1).y() - points.get(i).y())-2*solY[i][0] - solY[i+1][0];
    coef[i][1][3] = 2*(points.get(i).y() - points.get(i+1).y()) + solY[i][0] + solY[i+1][0];
    
    coef[i][2][0] = points.get(i).z();
    coef[i][2][1] = solZ[i][0];
    coef[i][2][2] = 3*(points.get(i+1).z() - points.get(i).z())-2*solZ[i][0] - solZ[i+1][0];
    coef[i][2][3] = 2*(points.get(i).z() - points.get(i+1).z()) + solZ[i][0] + solZ[i+1][0];
    
    for(float u=0;u<1;u+=resolution){
      float dx= coef[i][0][0] + u*coef[i][0][1] + u*u*coef[i][0][2] + u*u*u*coef[i][0][3];
      float dy= coef[i][1][0] + u*coef[i][1][1] + u*u*coef[i][1][2] + u*u*u*coef[i][1][3];
      float dz= coef[i][2][0] + u*coef[i][2][1] + u*u*coef[i][2][2] + u*u*u*coef[i][2][3];
      curvePoints.add(new Vector(dx,dy,dz));
    }
  }
  
}