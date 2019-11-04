PShape map;
int mapWrap = 0;

Table data;

float scale = 1.0;
float scaleTarget = 1.0;
float scaleSpeed = 2.0;
float scaleStep = 1.2;
float maxScale = 10.0;
float minScale = 1.0;

float scrollX, scrollY;

boolean dragging = false;
float dragX = 0, dragY = 0;
float posX = 0, posY = 0;
float maxXOffset = 0.1;
float maxYOffset = 0.0;

float timeLast = 0;

Slider slider;

float minMagnitude, maxMagnitude;
float minDepth, maxDepth;

float diameterTime = 0.75; // Time for bubbles to scale up/scale down
float opacityTime = 0.75; // Time for bubbles to change opacity
float strokeTime = 0.75; // Time for stroke to fade/appear

void setup() {
    size(1600, 800);
    colorMode(RGB, 255, 255, 255, 1.0);
    
    map = loadShape("world_map_simplified_x2.svg");
    map.disableStyle();
    data = new Table("earthquake_data.csv", true);
    slider = new Slider(0.5*width, 0.9*height, 0.8*width, data.minYear, data.maxYear);
}

boolean first = true;

void update() {
    // Time
    float timeCurrent = millis();
    float dt = 0.001 * (timeCurrent - timeLast); // Seconds
    timeLast = timeCurrent;

    // Move scale
    float diff = scaleTarget - scale;
    float diffStep = 1 / scale;
    if (diff > 0) { // Zoom in
        scale += dt * scaleSpeed * scale;
        if (scale > scaleTarget) scale = scaleTarget;
    } else if (diff < 0) { // Zoom out
        scale -= dt * scaleSpeed * scale;
        if (scale < scaleTarget) scale = scaleTarget;
    }
    if (diff != 0) {
   		diffStep *= scale;
    	// Zoom towards mouse position
        posX += (width * 0.5 / scale) * (diffStep - 1) * lerp(1, -1, (float)scrollX / (float)width);
        posY += (height * 0.5 / scale) * (diffStep - 1) * lerp(1, -1, (float)scrollY / (float)height);
    }

    // Drag
    if (dragging) {
        posX += (mouseX - dragX) / scale;
        posY += (mouseY - dragY) / scale;
        dragX = mouseX;
        dragY = mouseY;
    }

    // Make sure the map stays within the frame
    // Get positions of map corners
	float x0 = width - (2*posX + width/scale);
	float y0 = height - (2*posY + height/scale);
	float x1 = width/scale - 2*posX;
	float y1 = height/scale - 2*posY;

	// Wrap coordinates
	boolean wrapped = false;
	if (x0 < -2*width) {
		posX -= width;
		wrapped = true;
	} else if (x1 > 3*width) {
		posX += width;
		wrapped = true;
	}
	// Recalculate x0 and x1
	if (wrapped) {
    	x0 = width - (2*posX + width/scale);
        x1 = width/scale - 2*posX;
	}

	// Check if the map has to be duplicated horizontally
    if (x0 < 0.0) {
        mapWrap = -1;
    	//posX = (width - width/scale)/2;
    } else if (x1 > width) {
        mapWrap = 1;
        //posX = (width/scale - width)/2;
    } else {
		mapWrap = 0;
    }
    // Contain the map within the frame vertically
    if (y0 < 0.0) {
        posY = (height - height/scale)/2;
    } else if (y1 > height) {
        posY = (height/scale - height)/2;
    }

	int rangePrev = slider.range, valuePrev = slider.value;
    slider.update();
    // Update opacity targets and speeds
    if (first || slider.range != rangePrev || slider.value != valuePrev) {
        first = false;
    	for (int i = 0; i < data.count; ++i) {
            Row row = data.rows[i];
            if (slider.value == row.year) {
				row.opacityTarget = 1.0;            
            } else if (abs(slider.value - row.year) <= slider.range) {
                float t = (float)abs(slider.value - row.year) / (float)slider.range;
            	row.opacityTarget = lerp(0.1, 0.4, t);
            } else {
            	row.opacityTarget = 0.0;
            }
            row.opacitySpeed = abs(row.opacityTarget - row.opacity) / opacityTime;
        }
    }
    
    // Update bubble size and opacity
    for (int i = 0; i < data.count; ++i) {
        Row row = data.rows[i];
        // Size
        if (abs(slider.value - row.year) <= slider.range) {
            // Size
            if (row.diameter < row.diameterTarget) {
               	row.diameter += dt * row.diameterSpeed;
               	if (row.diameter > row.diameterTarget)
               		row.diameter = row.diameterTarget;
        	}
        } else {
            // Size
        	if (row.diameter > 0.0) {
                row.diameter -= dt * row.diameterSpeed;
               	if (row.diameter < 0.0)
                   row.diameter = 0.0;
            }
        }
        // Opacity
        float opacityDiff = row.opacityTarget - row.opacity;
        if (opacityDiff > 0.0) {
            row.opacity += dt * row.opacitySpeed;
            if (row.opacity > row.opacityTarget)
            	row.opacity = row.opacityTarget;
        } else if (opacityDiff < 0.0) {
            row.opacity -= dt * row.opacitySpeed;
            if (row.opacity < row.opacityTarget)
                row.opacity = row.opacityTarget;
        }
        // Stroke opacity
        if (slider.value == row.year) {
            if (row.strokeOpacity < 1.0) {
               row.strokeOpacity += dt * row.strokeOpacitySpeed;
               if (row.strokeOpacity > 1.0)
                   row.strokeOpacity = 1.0;
            }
        } else {
        	if (row.strokeOpacity > 0.0) {
               row.strokeOpacity -= dt * row.strokeOpacitySpeed;
               if (row.strokeOpacity < 0.0)
                   row.strokeOpacity = 0.0;
            }
        }
    }
}

void drawMap(int wrap) {
    noStroke();
    fill(180);
    
	pushMatrix();
    // Scale
    translate(0.5*width, 0.5*height);
    scale(scale);
    translate(-0.5*width, -0.5*height);
    // Translate
    translate(posX, posY);
    if (wrap != 0)
    	translate(wrap * width, 0);
    shape(map, 0, 0, width, height);
    for (int i = 0; i < data.count; ++i) {
        if (data.rows[i].year != slider.value && data.rows[i].diameter > 0.0 && data.rows[i].opacity > 0.0)
        	data.rows[i].draw();
    }
    for (int i = 0; i < data.count; ++i) {
        if (data.rows[i].year == slider.value)
            data.rows[i].draw();
    }
    //translate(-wrap * width, 0);
    popMatrix();
}

void draw() {
    update();

    background(250);
	
	// Map
	drawMap(0);
	if (mapWrap != 0) {
		drawMap(mapWrap);
	}

    // UI
    slider.draw();
    textAlign(LEFT, TOP);
    text(frameRate, 0, 0);
}

void coord(float lat, float lon, float mag, float depth) {
    float x = (lon + 180.0f) * width / 360.0f;
    float y = (lat + 90.0f) * height / 180.0f;
    y = height - y; // Upside down

    float diameter = lerp(4, 50, (mag - data.minMagnitude) / (data.maxMagnitude - data.minMagnitude));

    colorMode(HSB, 360, 1, 1);
    fill(0, 0.95, lerp(0.3, 1.0, (depth - data.minDepth) / (data.maxDepth - data.minDepth)));
    colorMode(RGB, 255);
    ellipse(x, y, diameter, diameter);
}

void mouseWheel(MouseEvent e) {
    float scroll = e.getCount();

    float x = 1.0;
    if (scroll < 0) x = -scroll * scaleStep;
    else if (scroll > 0) x = scroll / scaleStep;

    scaleTarget *= x;

    if (scaleTarget < minScale) { 
        scaleTarget = minScale;
    } else if (scaleTarget > maxScale) { 
        scaleTarget = maxScale;
    }
    
    scrollX = mouseX;
    scrollY = mouseY;
}

void mousePressed(MouseEvent e) {
    if (e.getButton() == LEFT) {
        if (!slider.checkHover()) {
            dragging = true;
            dragX = mouseX;
            dragY = mouseY;
        }
    }
}
void mouseReleased(MouseEvent e) {
    if (e.getButton() == LEFT) {
        slider.release();
        if (dragging) {
            dragging = false;
            posX += mouseX - dragX;
            posY += mouseY - dragY;
        }
    }
}
