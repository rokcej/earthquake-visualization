/// Map
PShape map;
int mapWrap = 0;

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

// Icons
PShape nuclear;
PShape arrow;

// Objects
Table data;
Slider slider;
Legend legend;

// Used stroke weight
float defaultStrokeWeight;

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

float timeLast; // Frame timer

Row highlight = null; // Selected bubble
int highlightWrap = 0;

void setup() {
    // Resolution
    size(1600, 900); // Ratio must be 2:1, but works for any resolution
    
    // Project colour mode
    colorMode(RGB, 255, 255, 255, 1.0);

    // Set bubble size
    bubbleSizeMin = (float)width / 400.0;
    bubbleSizeMax = (float)width / 32.0;
    bubbleStrokeWeight = (float)width / 4800.0;
    
    // Set default stroke weight
    defaultStrokeWeight = (float)width / 1600;

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

    legend.update(dt);
}

void drawMap(int wrap) {
    shapeMode(CORNER);
    noStroke();
    fill(180);

    float mx = (mouseX - 0.5*width) / scale + 0.5*width - posX - wrap*width;
    float my = (mouseY - 0.5*height) / scale + 0.5*height - posY;

    pushMatrix();
    // Scale
    translate(0.5*width, 0.5*height);
    scale(scale);
    translate(-0.5*width, -0.5*height);
    // Translate
    translate(posX, posY);
    if (wrap != 0) {
        translate(wrap * width, 0);
    }
    // Draw map
    shape(map, 0, 0, width, height);
    // Draw equator
    stroke(0, 0, 0, 0.25);
    strokeWeight(defaultStrokeWeight * 0.25);
    line(0, 0.5*height, width, 0.5*height);
    noStroke();
    // Draw bubbles
    // Bubbles within year range
    for (int i = 0; i < data.count; ++i) {
        if (data.rows[i].year != slider.value && data.rows[i].diameter > 0.0 && data.rows[i].opacity > 0.0) {
            data.rows[i].draw();
            if (dist(mx, my, data.rows[i].x, data.rows[i].y) < data.rows[i].diameter * 0.5) {
                highlight = data.rows[i];   
                highlightWrap = wrap;
            }
        }
    }
    // Bubbles for current year
    for (int i = 0; i < data.count; ++i) {
        if (data.rows[i].year == slider.value) {
            data.rows[i].draw();
            if (dist(mx, my, data.rows[i].x, data.rows[i].y) < data.rows[i].diameter * 0.5) {
                highlight = data.rows[i];
                highlightWrap = wrap;
            }
        }
    }
    // Highlight selected bubble
    if (highlight != null) {
        fill(255, 255, 200, 0.4);
        stroke(255, 255, 0);
        strokeWeight(bubbleStrokeWeight * 3.0);
        ellipse(highlight.x, highlight.y, highlight.diameter, highlight.diameter);
    }

    popMatrix();
}

void draw() {
    update();

    background(250);

    // Map
    highlight = null;
    drawMap(0);
    if (mapWrap != 0) {
        drawMap(mapWrap);
    }

    /// UI
    // FPS
    // text(frameRate, 0, 0);
    // Slider
    slider.draw();
    textAlign(LEFT, TOP);

    // Tooltip
    if (highlight != null) {
        float hx = ((highlight.x + highlightWrap*width + posX - 0.5*width) * scale + 0.5*width);
        float hy = (highlight.y + posY - 0.5*height) * scale + 0.5*height;
        // Draw tooltip
        tooltip(highlight, hx, hy);
    }

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
