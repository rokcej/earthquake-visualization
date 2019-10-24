PShape map;
Table data;

float scale = 1.0;
float scaleTarget = 1.0;
float scaleStep = 1.2;
float scaleSpeed = 0.05;

boolean dragging = false;
float dragX = 0, dragY = 0;
float posX = 0, posY = 0;

float timeLast = 0;

void setup() {
    size(1600, 900);
    map = loadShape("world_map.svg");
    data = new Table("earthquake_data.csv", true);
}

void update() {
	float timeCurrent = millis();
	float dt = 0.001 * (timeCurrent - timeLast); // Seconds
	float timeLast = timeCurrent;

	if (scale < scaleTarget) {
    	float diff = scaleTarget - scale;
    	scale += scaleSpeed * dt;
    	if (scale > scaleTarget) scale = scaleTarget;
	} else if (scale > scaleTarget) {
		float diff = scaleTarget - scale;
        scale -= scaleSpeed * dt;
        if (scale < scaleTarget) scale = scaleTarget;
	}
}

void draw() {
    update();
    
    background(250);
    map.disableStyle();
    noStroke();
    fill(180);
    
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
        coord(data.rows[i].latitude, data.rows[i].longitude);
    }
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
    
    scaleTarget *= x;
    
    if (scaleTarget < 1.0) { scaleTarget = 1.0; }
    else if (scaleTarget > 10.0) { scaleTarget = 10.0; }
    else { posX *= x; posY *= x; }
    
}

void mousePressed(MouseEvent e) {
    if (e.getButton() == LEFT) {
        dragging = true;
        dragX = mouseX;
        dragY = mouseY;
    }
}
void mouseReleased(MouseEvent e) {
    if (e.getButton() == LEFT) {
        dragging = false;
        posX += mouseX - dragX;
        posY += mouseY - dragY;
    }
}

/*void mouseDragged() {
    if (dragging) {
        posX += mouseX - dragX;
        posY += mouseY - dragY;
        dragX = mouseX;
        dragY = mouseY;
    }
}*/
