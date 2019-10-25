class Table {
    Row[] rows;
    int count;
    
	Table(String file, boolean header) {
		String[] lines = loadStrings(file);
		int offset = (header ? 1 : 0);
		this.count = lines.length - offset;
		this.rows = new Row[this.count];
		for (int i = 0; i < this.count; ++i) {
			rows[i] = new Row(lines[i + offset]);
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
}

class Row {
	int year, month, day;
	float latitude, longitude; // Degrees
	String type;
	float depth; // Kilometers
	float magnitude; // Richter scale

	Row(String line) {
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
}
