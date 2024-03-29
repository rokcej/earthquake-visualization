class Legend {
    Line[] lines;

    float titleSize = height * 0.045;
    float textSize = height * 0.022;

    color txtClr = color(20);
    color txtClr2 = color(85);

    float pad = 0.02 * height;
    float space = 0.033 * height;

    float em = 0.01 * height;

    float w = height * 0.5; // Legend width
    float h = height * 0.75; // Legend height
    
    float x0 = -w - defaultStrokeWeight; // x when hidden
    float x1 = -defaultStrokeWeight; // x when shown
    float x = x0; // Current x
    float y = 0.05 * height; // Current y

    float bh = height * 0.08; // Button height
    float bw = bh * 0.4; // Button width
    
    boolean show = false;
    float showSpeed = w * 2.0;
    
    color legendColor = color(255, 0.98);
    color buttonColor = legendColor;
    color hoverColor = color(220, 0.99);
    color strokeColor = color(150);

    Legend() {
        lines = new Line[6];
        for (int i = 0; i < lines.length; ++i) {
            lines[i] = new Line(pad, pad + i*space, w - 2*pad, 50);
        }
    }

	boolean click() {
		return mouseX >= x + w && mouseX <= x + w + bw && mouseY >= y && mouseY <= y + bh;
	}

	boolean hover() {
		return mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h || this.click();
	}

	void update(float dt) {
		if (this.click()) {
			this.buttonColor = this.hoverColor;
		} else {
			this.buttonColor = this.legendColor;
		}
		
		if (this.show && x < x1) {
    		x += showSpeed * dt;
    		if (x > x1) x = x1;
		} else if (!this.show && x > x0) {
			x -= showSpeed * dt;
			if (x < x0) x = x0;
		}
	}

    void draw() {
        // Button
        strokeWeight(defaultStrokeWeight);
        stroke(strokeColor);
        rectMode(CORNER);
        fill(buttonColor);
        rect(x+w, y, bw, bh);
        fill(txtClr2);
        noStroke();
        shapeMode(CORNER);
        if (show)
            shape(arrow, x+w, y, bw, bh);
        else
            shape(arrow, x+w+bw, y, -bw, bh);
        
        if (x > x0) { // Don't draw the legend if it's hidden
            // Box
            stroke(strokeColor);
            fill(legendColor);
            rect(x, y, w, h);
            
            // Box content and title
            textAlign(LEFT, TOP);
            textSize(titleSize * 1.00);
            fill(100, 0.3);
            text("Legend", x + (w - textWidth("Legend")) * 0.5 + 0.2*em, y + 2*pad + 0.2*em);
            textSize(titleSize);
            fill(30);
            text("Legend", x + (w - textWidth("Legend")) * 0.5, y + 2*pad);
    
            pushMatrix();
    
    		// Settings
            textAlign(LEFT, CENTER);
            translate(0, textAscent() + textDescent() + 1.5*space);
            textSize(textSize);
            fill(txtClr);
            float hText = textAscent() + textDescent();
    
    		// Magnitude
            translate(x + pad, hText + 2*space);
            pushMatrix();
            String[] txt = {"Magnitude (Richter): ", str(data.minMagnitude), " ...  " + str(data.maxMagnitude)};
            fill(txtClr);
            text(txt[0], 0, 0);
            fill(txtClr2);
            translate(textWidth(txt[0]), 0);
            text(txt[1], 0, 0);
            fill(255, 0, 0);
            stroke(0);
            ellipseMode(CENTER);
            translate(textWidth(txt[1]) + em, 0);
            ellipse(0 + 0, 0, 0.8*em, 0.8*em);
            translate(1 * em, 0);
            fill(txtClr2);
            text(txt[2], 0, 0);
            fill(255, 0, 0);
            translate(textWidth(txt[2]) + 5*em, 0);
            ellipse(0 + 0, 0, 7*em, 7*em);
            popMatrix();
    
    		// Depth
            translate(0, hText + space);
            pushMatrix();
            fill(txtClr);
            String[] txt2 = {"Depth: ", str(data.minDepth) + "km ", str(data.maxDepth) + "km"};
            text(txt2[0], 0, 0);
            fill(txtClr2);
            translate(textWidth(txt2[0]), 0);
            text(txt2[1], 0, 0);
            translate(textWidth(txt2[1]) + em, 0);
            float gradLen = 17*em;
            for (int i = 0; i < gradLen; ++i) {
                strokeWeight(defaultStrokeWeight);
                stroke(lerpColor(color(102, 5, 5), color(255, 13, 13), (float)i/gradLen));
                line(i, 1.5*em, i, -1.5*em);
            }
            stroke(0, 0.5);
            fill(0, 0);
            rect(0, -1.5*em, gradLen, 3*em);
            translate(gradLen + em, 0);
            fill(txtClr2);
            text(txt2[2], 0, 0);
            popMatrix();
    
    		// Time
            translate(0, hText + space);
            fill(txtClr);
            pushMatrix();
            String[] txt3 = {"Time: ", "Past/Future ", "...  Present "};
            text(txt3[0], 0, 0);
            fill(txtClr2);
            translate(textWidth(txt3[0]), 0);
            text(txt3[1], 0, 0);
            fill(255, 0, 0, 0.1);
            stroke(0, 0.1);
            ellipseMode(CENTER);
            translate(textWidth(txt3[1]) + 3*em, 0);
            ellipse(0 + 0, 0, 5*em, 5*em);
            translate(4 * em, 0);
            fill(txtClr2);
            text(txt3[2], 0, 0);
            fill(255, 0, 0);
            stroke(0);
            translate(textWidth(txt3[2]) + 3*em, 0);
            ellipse(0 + 0, 0, 5*em, 5*em);
            popMatrix();
    
    		// Type
            translate(0, hText + space);
            fill(txtClr);
            pushMatrix();
            String[] txt4 = {"Type: ", "-Earthquake ", "-Nuclear explosion", "-Other"};
            text(txt4[0], 0, 0);
            fill(txtClr2);
            translate(2*em, hText + space);
            text(txt4[1], 0, 0);
            fill(255, 0, 0);
            stroke(0);
            ellipseMode(CENTER);
            pushMatrix();
            translate(0.8*w, 0);
            ellipse(0 + 0, 0, 5*em, 5*em);
            popMatrix();
            translate(0, hText + space);
            fill(txtClr2);
            text(txt4[2], 0, 0);
            fill(255, 0, 0);
            stroke(0);
            pushMatrix();
            translate(0.8*w, 0);
            fill(255, 215, 13);
            ellipse(0, 0, 5*em, 5*em);
            shapeMode(CENTER);
            fill(0);
            shape(nuclear, 0, 0, 5*em, 5*em);
            popMatrix();
            translate(0, hText + space);
    		fill(txtClr2);
            text(txt4[3], 0, 0);
            fill(255, 0, 0);
            stroke(0);
            translate(0.8*w, 0);
            fill(134, 13, 255);
            ellipse(0 , 0, 5*em, 5*em);
            popMatrix();
            
            // Slider
            translate(0, 4 * (hText + space));
            fill(txtClr);
            pushMatrix();
            String[] txt5 = {"Slider: ", "-Displayed year ", "-Displayed year range"};
            text(txt5[0], 0, 0);
            fill(txtClr2);
            translate(2*em, hText + space);
            text(txt5[1], 0, 0);
            pushMatrix();
            translate(0.8*w, 0);
            fill(50);
            stroke(255, 0.4);
            rectMode(CENTER);
            rect(0, 0, slider.wSlider, slider.hSlider);
            popMatrix();
            translate(0, hText + space);
            fill(txtClr2);
            text(txt5[2], 0, 0);
            fill(255);
            stroke(0, 0.4);
            translate(0.8*w, 0);
            rect(0, 0, slider.wRange, slider.hRange);
            popMatrix();
    
            popMatrix();
		}
    }
}


class Line {
    float x, y, w, h;
    Line(float x, float y, float w, float h) {
        this.x = x; 
        this.y = y;
        this.w = w; 
        this.h = h;
    }
}
