PShape map;
Table data;

float scale = 1.0;
float scaleStep = 1.1;

boolean dragging = false;
float dragX = 0, dragY = 0;
float posX = 0, posY = 0;

float timeLast = 0;

Slider slider;

void setup() {
    size(1600, 800);
    map = loadShape("world_map.svg");
    data = new Table("earthquake_data.csv", true);
    
  	// Set slider
  	int minYear = data.rows[0].year;
  	int maxYear = minYear;
  	for (int i = 1; i < data.count; ++i) {
      	int year = data.rows[i].year; 
		if (year < minYear) minYear = year;
		else if (year > maxYear) maxYear = year;
  	}
  	slider = new Slider(0.5*width, 0.9*height, 0.8*width, minYear, maxYear);
}

void update() {
	float timeCurrent = millis();
	float dt = 0.001 * (timeCurrent - timeLast); // Seconds
	float timeLast = timeCurrent;

	slider.update();
}

void draw() {
    update();
    
    background(250);
    map.disableStyle();
    noStroke();
    fill(180);
    
    
    pushMatrix();
    // Translate
    if (dragging) {
        posX += mouseX - dragX;
        posY += mouseY - dragY;
        dragX = mouseX;
        dragY = mouseY;
    }
    translate(posX, posY);
    // Scale
    translate(0.5*width, 0.5*height);
    scale(scale);
    translate(-0.5*width, -0.5*height);
    
    shape(map, 0, 0, width, height);
    for (int i = 0; i < data.count; ++i) {
        if (slider.value == data.rows[i].year)
        	coord(data.rows[i].latitude, data.rows[i].longitude);
    }
    popMatrix();
    
    // UI
    slider.draw();
}

void coord(float lat, float lon) {
    float x = (lon + 180.0f) * width / 360.0f;
    float y = (lat + 90.0f) * height / 180.0f;
    y = height - y; // Upside down
    fill(235, 30, 30);
    ellipse(x, y, 4, 4);
}

void mouseWheel(MouseEvent e) {
    float scroll = e.getCount();
    
    float x = 1.0;
    if (scroll < 0) x = -scroll * scaleStep;
    else if (scroll > 0) x = scroll / scaleStep;
    
    scale *= x;
    
    if (scale < 1.0) { scale = 1.0; }
    else if (scale > 10.0) { scale = 10.0; }
    else { posX *= x; posY *= x; }
    
}

void mousePressed(MouseEvent e) {
    if (e.getButton() == LEFT) {
        if (slider.checkHover()) {
            slider.dragging = true;
        } else {
            dragging = true;
            dragX = mouseX;
            dragY = mouseY;
        }
    }
}
void mouseReleased(MouseEvent e) {
    if (e.getButton() == LEFT) {
        slider.dragging = false;
        if (dragging) {
            dragging = false;
            posX += mouseX - dragX;
            posY += mouseY - dragY;
        }
    }
}
