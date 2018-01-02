// InterfaceRegular.pde

// ====================================================================================================

void interfaceRegular(){
  drawCorners(canvasOffset, canvasOffset, canvasSize, canvasSize, 18);
  drawGrid(canvasOffset, canvasOffset, canvasSize, canvasSize, 10);
  drawSamplePoints(canvasOffset,canvasSize,false);

  showPoints(shapePoints,col2,5);
  showPoints(livePoints,col3,3);
  cp5.draw();
}