PShape map;
Table data;

float scale = 1.0;
float scaleTarget = 1.0;
float scaleSpeed = 1.0;
float scaleStep = 1.1;

boolean dragging = false;
float dragX = 0, dragY = 0;
float posX = 0, posY = 0;
float edgeOffset = 0.1;

float timeLast = 0;

Slider slider;

float minMagnitude, maxMagnitude;
float minDepth, maxDepth;

void setup() {
    size(1600, 800);
    map = loadShape("world_map.svg");
    data = new Table("earthquake_data.csv", true);
    data.sortByMag(); // To make sure smaller earthquakes are drawn on top of bigger ones

    // Set slider
    int minYear = data.rows[0].year;
    int maxYear = minYear;
    minMagnitude = data.rows[0].magnitude;
    maxMagnitude = minMagnitude;
    minDepth = data.rows[0].depth;
    maxDepth = minDepth;
    for (int i = 1; i < data.count; ++i) {
        int year = data.rows[i].year; 
        if (year < minYear) minYear = year;
        else if (year > maxYear) maxYear = year;
        float magnitude = data.rows[i].magnitude;
        if (magnitude < minMagnitude) minMagnitude = magnitude;
        else if (magnitude > maxMagnitude) maxMagnitude = magnitude;
        float depth = data.rows[i].depth;
        if (depth < minDepth) minDepth = depth;
        else if (depth > maxDepth) maxDepth = depth;
    }
    slider = new Slider(0.5*width, 0.9*height, 0.8*width, minYear, maxYear);
}

void update() {
    float timeCurrent = millis();
    float dt = 0.001 * (timeCurrent - timeLast); // Seconds
    timeLast = timeCurrent;

    // Move scale
    float diff = scaleTarget - scale;
    if (diff > 0) {
        scale += dt * scaleSpeed * scale;
        if (scale > scaleTarget) scale = scaleTarget;
    } else if (diff < 0) {
        scale -= dt * scaleSpeed * scale;
        if (scale < scaleTarget) scale = scaleTarget;
    }

    // Drag
    if (dragging) {
        posX += (mouseX - dragX) / scale;
        posY += (mouseY - dragY) / scale;
        dragX = mouseX;
        dragY = mouseY;
    }

    // Make sure the map stays in frame
	float x0 = width - (2*posX + width/scale);
	float y0 = height - (2*posY + height/scale);
	float x1 = width/scale - 2*posX;
	float y1 = height/scale - 2*posY;

	float negOff = -edgeOffset;
	float posOff = 1 + edgeOffset;
	
    if (x0 < negOff*width) posX = (posOff*width - width/scale)/2;
    else if (x1 > posOff*width) posX = (width/scale - posOff*width)/2;
    if (y0 < negOff*height) posY = (posOff*height - height/scale)/2;
    else if (y1 > posOff*height) posY = (height/scale - posOff*height)/2;

    slider.update();
}

void draw() {
    update();

    background(250);
    map.disableStyle();
    noStroke();
    fill(180);

    pushMatrix();
    // Scale
    translate(0.5*width, 0.5*height);
    scale(scale);
    translate(-0.5*width, -0.5*height);
    // Translate
    translate(posX, posY);
    shape(map, 0, 0, width, height);
    shape(map, width, 0, width, height);
    shape(map, -width, 0, width, height);
    for (int i = 0; i < data.count; ++i) {
        if (slider.value == data.rows[i].year)
            coord(data.rows[i].latitude, data.rows[i].longitude, data.rows[i].magnitude, data.rows[i].depth);
    }
    popMatrix();

    // UI
    slider.draw();
}

void coord(float lat, float lon, float mag, float depth) {
    float x = (lon + 180.0f) * width / 360.0f;
    float y = (lat + 90.0f) * height / 180.0f;
    y = height - y; // Upside down

    float diameter = lerp(4, 50, (mag - minMagnitude) / (maxMagnitude - minMagnitude));

    colorMode(HSB, 360, 1, 1);
    fill(0, 0.95, lerp(0.3, 1.0, (depth - minDepth) / (maxDepth - minDepth)));
    colorMode(RGB, 255);
    ellipse(x, y, diameter, diameter);
}

void mouseWheel(MouseEvent e) {
    float scroll = e.getCount();

    float x = 1.0;
    if (scroll < 0) x = -scroll * scaleStep;
    else if (scroll > 0) x = scroll / scaleStep;

    scaleTarget *= x;

    if (scaleTarget < 1.0) { 
        scaleTarget = 1.0;
    } else if (scaleTarget > 10.0) { 
        scaleTarget = 10.0;
    }
    //else { posX *= x; posY *= x; }
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
