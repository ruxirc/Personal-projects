import processing.serial.*;

int cols = 30;  
int rows = 25;  
int cellSize = 30;  

// Grid to store map information (0 = empty, 1 = wall)
int[][] grid = new int[cols][rows];

color wallColor = color(0, 102, 153);  
color backgroundColor = color(34, 139, 34);
color snakeHeadColor = color(82, 35, 168);
color snakeBodyColor = color(161, 35, 138);  

Serial myPort;
PVector direction = new PVector(1, 0);
PVector apple;

int score = 0;
boolean gameOver = false;
boolean restartButtonHovered = false;

ArrayList<PVector> snake = new ArrayList<PVector>();

void setup() {
  size(900, 750);  
  createMap();  
  initializeSnake();
  spawnApple();
  
  myPort = new Serial(this, Serial.list()[0], 9600);
  
  frameRate(10);
}

void draw() {
  if (gameOver == true) {
    drawGameOverScreen();
  } else { 
    drawGrid();
    drawSnake();
    drawApple();
    
    moveSnake();
    checkCollisions();
    readSerialInput();
    showScore();
  }
}

void readSerialInput() {
  while (myPort.available() > 0) {
    String input = myPort.readStringUntil('\n');
    if (input != null) {
      input = input.trim();
      if (input.equals("UP") && direction.y == 0) {
        direction.set(0, -1);
      } else if (input.equals("DOWN") && direction.y == 0) {
        direction.set(0, 1);
      } else if (input.equals("LEFT") && direction.x == 0) {
        direction.set(-1, 0);
      } else if (input.equals("RIGHT") && direction.x == 0) {
        direction.set(1, 0);
      }
    }
  }
}

void moveSnake() {
  PVector newHead = snake.get(0).copy().add(direction);
  snake.add(0, newHead);  // Add new head
  
  if (newHead.equals(apple)) {
    score += 10;  
    spawnApple();  
  } else {
    snake.remove(snake.size() - 1);  // Remove tail if no apple eaten
  }
}


void checkCollisions() {
  PVector head = snake.get(0);

  // Wall collision
  if (grid[(int)head.x][(int)head.y] == 1 || head.x < 0 || head.y < 0 || head.x >= cols || head.y >= rows) {
    gameOver = true;
  }

  // Self-collision
  for (int i = 1; i < snake.size(); i++) {
    if (head.equals(snake.get(i))) {
      gameOver = true;
    }
  }
}

void restartGame() {
  snake.clear();  
  initializeSnake();  
  spawnApple();  
  direction.set(1, 0);  
  score = 0;  
  gameOver = false;  
  loop(); 
}

void spawnApple() {
  do {
    apple = new PVector((int)random(cols), (int)random(rows));
  } while (grid[(int)apple.x][(int)apple.y] == 1 || snake.contains(apple));  // Avoid walls or snake
}

void createMap() {
  for (int i = 0; i < cols; i++) {
    grid[i][0] = 1;               
    grid[i][rows - 1] = 1;       
  }
  for (int i = 0; i < rows; i++) {
    grid[0][i] = 1;               
    grid[cols - 1][i] = 1;        
  }
}

void initializeSnake() {
  snake.add(new PVector(10, 10));  
  snake.add(new PVector(9, 10));  
  snake.add(new PVector(8, 10)); 
  snake.add(new PVector(7, 10)); 
  snake.add(new PVector(6, 10)); 
}


void drawGrid() {
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      if (grid[x][y] == 1) { 
        drawWall(x, y);
      } else {
        drawGrass(x, y);
      }
    }
  }
}

void drawSnake() {
  for (int i = 0; i < snake.size(); i++) {
    PVector segment = snake.get(i);

    if (i == 0) {  // Head
    
      fill(snakeHeadColor);
      
      stroke(200, 100, 160, 50);  // Glow
      
      rect(segment.x * cellSize, segment.y * cellSize, cellSize, cellSize);

      float eye1X = segment.x * cellSize + cellSize * 0.3;
      float eye1Y = segment.y * cellSize + cellSize * 0.3;
    
      float eye2X = segment.x * cellSize + cellSize * 0.3;
      float eye2Y = segment.y * cellSize + cellSize * 0.7;
      
      fill(255, 255, 255, 150);  
      ellipse(eye1X, eye1Y, cellSize * 0.2, cellSize * 0.2);
      ellipse(eye2X, eye2Y, cellSize * 0.2, cellSize * 0.2);
      
    } else {  // Body
    
      float gradientFactor = map(i, 1, snake.size(), 0, 1.0);  // Gradient
      fill(lerpColor(snakeBodyColor, color(230, 88, 176), gradientFactor)); 
      stroke(200, 100, 160, 50);  
      
      rect(segment.x * cellSize, segment.y * cellSize, cellSize, cellSize);

      fill(255, 255, 255, 80);  
      ellipse(segment.x * cellSize + cellSize * 0.3, segment.y * cellSize + cellSize * 0.3, cellSize * 0.3, cellSize * 0.3);
      ellipse(segment.x * cellSize + cellSize * 0.6, segment.y * cellSize + cellSize * 0.6, cellSize * 0.2, cellSize * 0.2);
    }
  }
}

void drawApple() {
  fill(255, 0, 0);
  ellipse(apple.x * cellSize + cellSize / 2, apple.y * cellSize + cellSize / 2, cellSize * 0.8, cellSize * 0.8);
}

void drawWall(int x, int y) {
  float noiseFactor = noise(x * 0.1, y * 0.1);
  color randomWallColor = lerpColor(wallColor, color(70, 130, 180), noiseFactor);  // Color variation
  fill(randomWallColor);
  stroke(255, 255, 255, 50);  // Soft grid lines
  rect(x * cellSize, y * cellSize, cellSize, cellSize);


  stroke(255, 100);  // Transparent white for texture
  for (int i = 0; i < cellSize; i += 4) {
    line(x * cellSize, y * cellSize + i, x * cellSize + i, y * cellSize);  // Diagonal texture
  }
}

void drawGrass(int x, int y) {
  color baseColor = color(34, 139, 34);
  float noiseFactor = noise(x * 0.2, y * 0.2);
  color grassColor = lerpColor(baseColor, color(50, 205, 50), noiseFactor);
  fill(grassColor);
  noStroke();
  rect(x * cellSize, y * cellSize, cellSize, cellSize);
}

void drawGameOverScreen() {
  background(0);
  fill(255, 0, 0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Game Over! Press the Restart button", width / 2, height / 2 - 50);
  
  drawRestartButton();
}

void drawRestartButton() {
  fill(0, 255, 0);
  stroke(0);
  rect(width / 2 - 75, height / 2 + 20, 150, 50, 10);
  
  fill(0);
  textSize(18);
  textAlign(CENTER, CENTER);
  text("Restart", width / 2, height / 2 + 45);
  
  if (mouseX >= width / 2 - 75 && mouseX <= width / 2 + 75 &&
      mouseY >= height / 2 + 20 && mouseY <= height / 2 + 70) {
    restartButtonHovered = true;
  } else {
    restartButtonHovered = false;
  }
}

void mousePressed() {
  if (restartButtonHovered) {
    restartGame();
  }
}

void showScore() {
  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Score: " + score, 10, 10);
}
