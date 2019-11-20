void tooltip(Row r, float cx, float cy) {
    textSize(height * 0.02);
    float xPad = height * 0.012; // X padding
    float yPad = xPad * 0.75; // Y padding
    float spacing = yPad * 0.33; // Line spacing
    
    String[] keys = {
    	"Date: ",
		"Time: ",
    	"Coordinates: ",
    	"Depth: ",
    	"Magnitude: ",
    	"Type: "
    };
    
    String[] values = {
    	str(r.year) + "/" + str(r.month) + "/" + str(r.day),
    	r.time,
    	str(r.latitude) + "°, " + str(r.longitude) + "°",
    	str(r.depth),
    	str(r.magnitude),
    	r.type
    };
    
    float h1 = textAscent() + textDescent();
    float h = keys.length * h1 + 2*yPad + (keys.length - 1) * spacing;
    float w1 = textWidth(keys[0]);
    float w2 = textWidth(values[0]);
    for (int i = 1; i < keys.length; ++i) {
    	w1 = max(w1, textWidth(keys[i]));
    	w2 = max(w2, textWidth(values[i]));
    }
    float w = w1 + w2 + 2*xPad;
    
    float radius = 0.5 * r.diameterTarget * scale / sqrt(2);
    float x = cx - radius - w;
    float y = cy - radius - h;
    if (x < 0.02 * width) x = cx + radius;
    if (y < 0.02 * height) y = cy + radius;
    
    rectMode(CORNER);
    fill(250, 0.9);
    stroke(120, 1.0);
    strokeWeight(1.0);
	rect(x, y, w, h);

	fill(10);
	for (int i = 0; i < keys.length; ++i) {
        text(keys[i], x + xPad, y + yPad + i*h1 + i*spacing);
        text(values[i], x + xPad + w1, y + yPad + i*h1 + i*spacing);
    }
}
