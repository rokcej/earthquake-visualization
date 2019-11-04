class Slider {
    float x, y, w;
    int value, min, max;
    boolean dragging = false;
    
    int minRange, maxRange;
    boolean draggingRangeL = false;
    boolean draggingRangeR = false;
    
    float x0, x1;
    float wSlider = 0.012 * width, hSlider = 0.045 * height;
    float wRange = wSlider * 0.5, hRange = hSlider * 0.66;
    int range = 0; // Display values [-range, range]
    float hLine = height * 0.006, hLineRange = hLine * 1.2;
    
    Slider(float x, float y, float w, int min, int max) {
    	this.x = x; this.y = y; this.w = w;
    	this.min = min; this.max = max;
    	value = (min + max) / 2;
    	minRange = value; maxRange = value;
    
    	x0 = x - w/2;
    	x1 = x + w/2;
    }
    
    void update() {
    	if (dragging) {
    		if (mouseX <= x0) value = min;
    		else if (mouseX >= x1) value = max;
    		else value = min + round((max - min) * (mouseX - x0) / w);
  
    		// Adjust min and max range
    		minRange = max(min, value - range);
    		maxRange = min(max, value + range);
    	} else if (draggingRangeL) {
        	float mx = mouseX + (wSlider + wRange) * 0.5;
    		if (mx <= x0) range = value - min;
            else if (mx >= xSlider()) range = 0;
            else range = abs(min + round((max - min) * (mx - x0) / w) - value);
            
            // Adjust min and max range
            minRange = max(min, value - range);
            maxRange = min(max, value + range);
    	} else if (draggingRangeR) {
            float mx = mouseX - (wSlider + wRange) * 0.5;
    		if (mx <= xSlider()) range = 0;
            else if (mx >= x1) range = max - value;
            else range = abs(min + round((max - min) * (mx - x0) / w) - value);
            
            // Adjust min and max range
            minRange = max(min, value - range);
            maxRange = min(max, value + range);
    	}
    }
    
    void draw() {
        noStroke();
        float xSlider = xSlider();
        
        textSize(height * 0.02);
        float dy = (textAscent() + textDescent()) * 0.5;
        
    	// Line
    	fill(0, 0.5);
    	rectMode(CENTER);
    	rect(x, y, w, hLine);
    	textAlign(RIGHT, TOP);
        fill(0, 0.7);
    	text(min, x0 - width * 0.015, y - dy);
    	textAlign(LEFT, TOP);
        text(max, x1 + width * 0.015, y - dy);
        
        float xRangeL = xRangeL(), xRangeR = xRangeR();
        // Range line
        //fill(255, 181, 8);
        strokeWeight(1.0);
        fill(255);
        stroke(0, 0.4);
        rect((xRangeL + xRangeR)*0.5, y, xRangeL - xRangeR, hLineRange);
        
        // Range
        //fill(255, 144, 8);
        fill(255);
        stroke(0, 0.4);
        rect(xRangeL, y, wRange, hRange);
        rect(xRangeR, y, wRange, hRange);
        
        
        textSize(height * 0.025);
    	// Slider
    	fill(50);
        stroke(255, 0.4);
    	rect(xSlider, y, wSlider, hSlider);
    	textAlign(CENTER, BOTTOM);
    	String content = (range == 0 ? str(value) : str(minRange) + " - " + str(maxRange));
        fill(255);
        text(content, xSlider + 0.0005*width, y - hSlider/2 + 0.0008*height);
        fill(50);
    	text(content, xSlider, y - hSlider/2);
    }
    
    boolean checkHover() {
        if (dragging || draggingRangeL || draggingRangeR) return true;
        
    	dragging = hitBox(xSlider(), y, wSlider, hSlider);
    
		if (!dragging) {
    		draggingRangeL = hitBox(xRangeL(), y, wRange, hRange);
    		if (!draggingRangeL) {
        		draggingRangeR = hitBox(xRangeR(), y, wRange, hRange);
    		}
		}
   
    	return dragging || draggingRangeL || draggingRangeR;
    }
    
    void release() {
    	dragging = false;
   		draggingRangeL = false;
   		draggingRangeR = false;
    }
    
    float xSlider() {
    	return x0 + w * (value - min) / (max - min);
    }
    float xRangeL() {
        return (x0 + w * (minRange - min) / (max - min)) - (wSlider + wRange)*0.5;
    }
    float xRangeR() {
    	return (x0 + w * (maxRange - min) / (max - min)) + (wSlider + wRange)*0.5;
    }

}

boolean hitBox(float x, float y, float w, float h) {
    float x0 = x - w*0.5;
    float x1 = x + w*0.5;
    float y0 = y - h*0.5;
    float y1 = y + h*0.5;

    return mouseX >= x0 && mouseX <= x1 && mouseY >= y0 && mouseY <= y1;
}
