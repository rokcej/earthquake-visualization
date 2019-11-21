// Map resolution and drawing position
float mapWidth, mapHeight;
float mapX;

/// Map
color mapBackgroundColour = color(250);
color mapFillColour = color(180);

// Map wrapping
int mapWrapRight = 0;
int mapWrapLeft = 0;

// Map scaling parameters
float scale = 1.0;
float scaleTarget = 1.0;
float scaleSpeed = 2.0;
float scaleStep = 1.2;
float maxScale = 10.0;
float minScale = 1.0;

// Map scrolling
float scrollX, scrollY; // Mouse position when scrolling

// Map dragging
boolean dragging = false;
float dragX = 0, dragY = 0;
float posX = 0, posY = 0;
float maxXOffset = 0.1;
float maxYOffset = 0.0;

// Shapes
PShape map;
PShape nuclear;
PShape arrow;

// Objects
Table data;
Slider slider;
Legend legend;

// Bubble design
float bubbleSizeMin;
float bubbleSizeMax;
float bubbleStrokeWeight;

// Bubble animation parameters
float diameterTime = 0.75; // Time for bubbles to scale up/scale down
float opacityTime = 0.75; // Time for bubbles to change opacity
float strokeTime = 0.75; // Time for stroke to fade/appear
float minOpacity = 0.05;
float maxOpacity = 0.4;

// Other
float defaultStrokeWeight; // Used stroke 
boolean isHighlighted = true; // If a bubble is already highlighted
float timeLast; // Frame timer

void setup() {
    // Resolution
    size(1800, 900); // Ratio must be 2:1, but works for any resolution
    
    // Map parameters
    mapHeight = height; 
    mapWidth = 2 * height;
    mapX = (width - mapWidth) * 0.5;

    // Project colour mode
    colorMode(RGB, 255, 255, 255, 1.0);

    // Set bubble size
    bubbleSizeMin = (float)height / 200.0;
    bubbleSizeMax = (float)height / 16.0;
    bubbleStrokeWeight = (float)height / 2400.0;

    // Set default stroke weight
    defaultStrokeWeight = (float)height / 800;

    // Load shapes
    map = loadShape("world_map_simplified.svg");
    map.disableStyle();
    nuclear = loadShape("nuclear.svg");
    nuclear.disableStyle();
    arrow = loadShape("arrow.svg");
    arrow.disableStyle();

    // Create objects
    data = new Table("earthquake_data.csv", true);
    slider = new Slider(0.5*width, 0.9*height, 0.8*width, data.minYear, data.maxYear);
    legend = new Legend();

    timeLast = millis();
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
        posX += (mapWidth * 0.5 / scale) * (diffStep - 1) * lerp(1, -1, (float)scrollX / (float)mapWidth);
        posY += (mapHeight * 0.5 / scale) * (diffStep - 1) * lerp(1, -1, (float)scrollY / (float)mapHeight);
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
    float x0 = (2*posX + mapWidth/scale - 2*mapWidth + width) * 0.5 * scale;
    float y0 = mapHeight - (2*posY + mapHeight/scale);
    float x1 = x0 + mapWidth * scale;
    float y1 = mapHeight/scale - 2*posY;

	// Wrap coordinates if map is off-screen and update position
	if (x0 > width) {
		posX -= mapWidth;
		x0 -= mapWidth * scale;
		x1 -= mapWidth * scale;
	} else if (x1 < 0.0) {
		posX += mapWidth;
		x0 += mapWidth * scale;
        x1 += mapWidth * scale;
	}
    
	// Check if the map has to be duplicated horizontally
	mapWrapLeft = 0;
	for (int i = 0; x0 - i*mapWidth > 0.0; ++i)
		++mapWrapLeft;
	mapWrapRight = 0;
    for (int i = 0; x1 + i*mapWidth < width; ++i)
        ++mapWrapRight;
	
    // Contain the map within the frame vertically
    if (y0 < 0.0) {
        posY = (mapHeight - mapHeight/scale)/2;
    } else if (y1 > mapHeight) {
        posY = (mapHeight/scale - mapHeight)/2;
    }

    int rangePrev = slider.range, valuePrev = slider.value;
    slider.update();
    // Update opacity targets and speeds
    if (first || slider.range != rangePrev || slider.value != valuePrev) {
        for (int i = 0; i < data.count; ++i) {
            Row row = data.rows[i];
            if (slider.value == row.year) {
                row.opacityTarget = 1.0;
            } else if (abs(slider.value - row.year) <= slider.range) {
                float t = (float)abs(slider.value - row.year) / (float)slider.range;
                row.opacityTarget = lerp(maxOpacity, minOpacity, t);
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

	// Update legend
    legend.update(dt);
}

void drawMap(int wrap) { // Wrap means how many map lengts to move the map on the x-axis
    shapeMode(CORNER);
    noStroke();
    fill(mapFillColour);

	// Transform mouse coordinates into map coordinates
    float mx = (mouseX - 0.5*mapWidth) / scale + 0.5*mapWidth - posX - wrap*mapWidth;
    float my = (mouseY - 0.5*mapHeight) / scale + 0.5*mapHeight - posY;
    
    pushMatrix(); // Start map transform
    
    // Scale
    translate(0.5*mapWidth, 0.5*mapHeight);
    scale(scale);
    translate(-0.5*mapWidth, -0.5*mapHeight);
    // Translate
    translate(posX, posY);
    if (wrap != 0)
        translate(wrap * mapWidth, 0);
        
    // Draw map
    shape(map, mapX, 0, mapWidth, mapHeight);
    
    // Draw equator
    stroke(0, 0, 0, 0.25);
    strokeWeight(defaultStrokeWeight * 0.25);
    line(mapX, 0.5*mapHeight, mapX + mapWidth, 0.5*mapHeight);
    noStroke();
    
    /// Draw bubbles
    // Bubbles within year range
    Row highlight = null; // Highlighted bubble
    for (int i = 0; i < data.count; ++i) {
        if (data.rows[i].year != slider.value && data.rows[i].diameter > 0.0 && data.rows[i].opacity > 0.0) {
            data.rows[i].draw();
            if (dist(mx, my, data.rows[i].x, data.rows[i].y) < data.rows[i].diameter * 0.5) {
                highlight = data.rows[i];
            }
        }
    }
    
    // Bubbles for current year
    for (int i = 0; i < data.count; ++i) {
        if (data.rows[i].year == slider.value) {
            data.rows[i].draw();
            if (dist(mx, my, data.rows[i].x, data.rows[i].y) < data.rows[i].diameter * 0.5) {
                highlight = data.rows[i];
            }
        }
    }
    
    // Highlight selected bubble
    if (!isHighlighted && highlight != null) {
        isHighlighted = true;
        fill(255, 255, 200, 0.4); // Bright yellow
        stroke(255, 255, 0); // Yellow
        strokeWeight(bubbleStrokeWeight * 3.0);
        ellipse(highlight.x, highlight.y, highlight.diameter, highlight.diameter);
    
    	popMatrix(); // End map transform
    
        float hx = ((highlight.x + wrap*mapWidth + posX - 0.5*mapWidth) * scale + 0.5*mapWidth);
        float hy = (highlight.y + posY - 0.5*mapHeight) * scale + 0.5*mapHeight;
        // Draw tooltip
        tooltip(highlight, hx, hy);
    } else {
    
    	popMatrix(); // End map transform
    
    }
}

void draw() {
    update(); // Call update before draw

    background(mapBackgroundColour);

    /// Map
    isHighlighted = false;
    drawMap(0);
    for (int i = 1; i <= mapWrapLeft; ++i)
        drawMap(-i);
    for (int i = 1; i <= mapWrapRight; ++i)
    	drawMap(i);

    /// UI
    // FPS
    fill(0);
    textAlign(LEFT, TOP);
    text(frameRate, 0, 0);
    
    // Slider
    slider.draw();
    textAlign(LEFT, TOP);

    // Legend
    legend.draw();

    first = false; // Flag that the first iteration is over
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
        if (legend.click()) 
            legend.show = !legend.show;
        else if (legend.hover())
            return;
        else if (!slider.checkHover()) {
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
