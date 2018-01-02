//
//
// =========================================================================================================== //
//                                                                                                             //
//                                                   VERY                                                      //
//                                                   HUGE                                                      //
//                                                   MACHINE                                                   //
//                                                                                                             //
//                                                   >--<                                                      //
//                                                                                                             //
//                                            >- Diplomarbeit -<                                               //
//                                                                                                             //
//                                                   >--<                                                      //
//                                                                                                             //
//   Maximilian Hans | Staatliche Akademie der Bildenden Künste Stuttgart | Industrial Design | WS 2017/2018   //
//                                                                                                             //
// =========================================================================================================== //

// Imports

import processing.video.*;
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;

import java.io.*;
import controlP5.*;
import mqtt.*;
import websockets.*;
import blobDetection.*;

// ====================================================================================================

// System

  // Current machine state
  int caseByte = 0;
  
  // Console window
  Textarea consoleText;
  Println console;

// ====================================================================================================

// Tracking

  // Camera
  
  Capture cam;
  boolean newFrame=false;
  
  // OpenCV
  
  OpenCV opencv;
  PImage img;
  PImage warpedCanvas;
  ArrayList<PVector> transformPoints = new ArrayList<PVector>();
  ArrayList<DragPoint> dragPoints = new ArrayList<DragPoint>();
  PVector imageTransformDelta;
  
  // Point Tracking
  
  BlobDetection theBlobDetection;
  float blobThreshDelta = 0.001f;
  float detectionThreshold = 0.3f;

  // Marker
  
  Marker marker;

// ====================================================================================================

// Sampling & AI

  int sampleFreq = 500;
  int lastSample;
  boolean isSampling = false;
  
  boolean sampleStatusPrinted = false;
  boolean isImporting = false;

  ArrayList<Sample> samples = new ArrayList<Sample>();
  
  // AI
  
  boolean waitingForPos = false;
  boolean modelTrained = false;
  
  // Sketching
  
  boolean isSketching = false;
  
  // Drawing
  
  boolean isDrawing = false;
  int currentDrawIndex = 0;
  int repeat = 1;                  // Count of repeats of drawing
  int repeatCounter = 0;
  
// ====================================================================================================

  // Motors
  Motor[] motorArray = new Motor[2];
  
// ====================================================================================================

// Communication

  // MQTT Communication
  
  MQTTClient client;
  String mqttAdress = "mqtt://192.168.2.100";
  int mqttPort = 1883;
  
  // Websocket Communication
  
  WebsocketClient wsc;
  String wsAdress = "ws://localhost";
  int wsPort = 8080;
  int lastAliveTime;
  
  String trackingChannel = "track";
  String requestChannel = "rq";
  
  ArrayList<PVector> shapePoints;
  ArrayList<PVector> livePoints;

// ====================================================================================================

// System Variables

int state = 0;

// ====================================================================================================

void setup() {

  size(1920, 1080);
  //fullScreen();
  
  background(darkblue);

  cp5 = new ControlP5(this);
  
  setupCamera("USB 2.0 Camera");

  client = new MQTTClient(this);
  client.connect(mqttAdress + ':' + mqttPort, "main");

  client.subscribe("/+/pos");
  client.subscribe("/+/sts");

  wsc = new WebsocketClient(this,wsAdress + ":" + wsPort);
  lastAliveTime = millis();

  createInterface();

  shapePoints = new ArrayList<PVector>();
  livePoints = new ArrayList<PVector>();

  motorArray[0] = new Motor(0);
  motorArray[1] = new Motor(1);

  printArray(motorArray);

  // Start camera interface

  imageTransformDelta = new PVector(122, 122);

  opencv = new OpenCV(this, cam);
  img = new PImage(canvasSize/2, canvasSize/2);

  // Start computer vision stuff

  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(detectionThreshold);

  warpedCanvas = new PImage(canvasSize, canvasSize);

  resetTransformArray(cam);

  for (PVector P : transformPoints) {
    dragPoints.add(new DragPoint(P));
  }
  
  marker = new Marker(0.5, 0.5, canvasSize, canvasSize);

  console = cp5.addConsole(consoleText);
}

// ====================================================================================================

void draw()
{
  background(darkblue);
  switch(caseByte) {
  case 0:
    {
      checkFrames();
      interfaceRegular();
      displayWarped();
      checkSampling();
      checkDraw();
      keepAlive();
      break;
    }
  case 1:
    {
      interfaceRemap();
      break;
    }
  }
}