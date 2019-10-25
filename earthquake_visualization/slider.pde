class Slider {
    float x, y, w;
    int value, min, max;
    boolean dragging = false;
    
    float x0, x1;
    float wSlider = 15, hSlider = 30;
    
    Slider(float x, float y, float w, int min, int max) {
    	this.x = x; this.y = y; this.w = w;
    	this.min = min; this.max = max;
    	value = (min + max) / 2;
    
    	x0 = x - w/2;
    	x1 = x + w/2;
    }
    
    void update() {
    	if (dragging) {
    		if (mouseX <= x0) value = min;
    		else if (mouseX >= x1) value = max;
    		else value = min + round((max - min) * (mouseX - x0) / w);
    	}
    }
    
    void draw() {
    	// Line
    	fill(0, 100);
    	rectMode(CENTER);
    	rect(x, y, w, 5);
    	textAlign(RIGHT, CENTER);
    	text(min, x0 - 10, y);
    	textAlign(LEFT, CENTER);
        text(max, x1 + 10, y);
    	// Slider
    	fill(50, 255);
    	rect(xSlider(), y, wSlider, hSlider);
    	textAlign(CENTER, BOTTOM);
    	text(value, xSlider(), y - hSlider/2);
    }
    
    boolean checkHover() {
        float xSlider = xSlider();
    	float x0 = xSlider - wSlider/2;
    	float x1 = xSlider + wSlider/2;
    	float y0 = y - hSlider/2;
    	float y1 = y + hSlider/2;
    
    	return mouseX >= x0 && mouseX <= x1 && mouseY >= y0 && mouseY <= y1;
    }
    
    float xSlider() {
    	return x0 + w * (value - min) / (max - min);
    }

}
