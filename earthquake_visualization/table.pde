class Table {
    Row[] rows;
    int count;
    
    float minMagnitude, maxMagnitude;
    float minDepth, maxDepth;
    int minYear, maxYear;
    
	Table(String file, boolean header) {
		String[] lines = loadStrings(file);
		int offset = (header ? 1 : 0);
		this.count = lines.length - offset;
		this.rows = new Row[this.count];
		for (int i = 0; i < this.count; ++i) {
			rows[i] = new Row(lines[i + offset]);
		}

		this.sortByMag(); // To make sure smaller earthquakes are drawn on top of bigger ones
		this.analyze();

		for (int i = 0; i < this.count; ++i) {
            rows[i].analyze(this);
        }
	}

	void sortByMag() {
		for (int i = 1; i < count; ++i) {
			int j = i;
			while (j > 0 && rows[j].magnitude > rows[j-1].magnitude) {
				Row temp = rows[j-1];
				rows[j-1] = rows[j];
				rows[j] = temp;
				--j;
			}
		}
	}

	// Analyze the data, get min and max values
	void analyze() {
		minYear = rows[0].year;
        maxYear = minYear;
        minMagnitude = rows[0].magnitude;
        maxMagnitude = minMagnitude;
        minDepth = rows[0].depth;
        maxDepth = minDepth;
        for (int i = 1; i < count; ++i) {
            int year = rows[i].year; 
            if (year < minYear) minYear = year;
            else if (year > maxYear) maxYear = year;
            float magnitude = rows[i].magnitude;
            if (magnitude < minMagnitude) minMagnitude = magnitude;
            else if (magnitude > maxMagnitude) maxMagnitude = magnitude;
            float depth = rows[i].depth;
            if (depth < minDepth) minDepth = depth;
            else if (depth > maxDepth) maxDepth = depth;
        }
	}
}

class Row {
    float opacity, opacityTarget, opacitySpeed;
    float strokeOpacity, strokeOpacitySpeed;
    float diameter, diameterTarget, diameterSpeed;
    color clr;
    float x, y;
    
	int year, month, day;
	float latitude, longitude; // Degrees
	String type;
	float depth; // Kilometers
	float magnitude; // Richter scale

	Row(String line) {
    	// Parse data
		String[] fields = split(line, ',');
		// Date
		String[] date = split(fields[0], '/');
		this.day = int(date[1]);
		this.month = int(date[0]);
		this.year = int(date[2]);
		// Coord
		this.latitude = float(fields[2]);
		this.longitude = float(fields[3]);
		// Details
		this.type = fields[4];
		this.depth = float(fields[5]);
		this.magnitude = float(fields[8]);
	}

	
    // Set row parameters
	void analyze(Table data) {
    	// Bubble diameter
        diameterTarget = lerp(4, 50, (magnitude - data.minMagnitude) / (data.maxMagnitude - data.minMagnitude));
        diameter = 0.0;
        diameterSpeed = diameterTarget / diameterTime;

		// Bubble color
		pushStyle();
        colorMode(HSB, 360, 1, 1, 1);
        clr = color(0, 0.95, lerp(0.4, 1.0, (depth - data.minDepth) / (data.maxDepth - data.minDepth)));
        popStyle();
        
        // Bubble position
        x = (longitude + 180.0f) * width / 360.0f;
        y = (latitude + 90.0f) * height / 180.0f;
        y = height - y; // Upside down
        
        // Bubble opacity
        opacity = 0.0;
        opacityTarget = 0.0;
        
        // Stroke opacity
        strokeOpacity = 0.0;
        strokeOpacitySpeed = 1.0 / strokeTime;
	}

	void draw() {
    	if (strokeOpacity > 0.0) {
        	pushStyle();
        	strokeWeight(0.33);
        	stroke(0, strokeOpacity);
        }
        fill(clr, opacity);
        ellipse(x, y, diameter, diameter);
        if (strokeOpacity > 0.0) {
            popStyle();
        }
	}
}
