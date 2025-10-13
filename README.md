# Nominatim Apptainer Container
A self-contained Apptainer/Singularity container which allows for the buildign of 
a nominatim SQLite database for offline address lookup and reverse geocoding using the
Nominatim Python API.

## Overview:
- Version: Nominatim 5.1.0
- Base Image: Ubuntu 24.04
- Database: SQLite (converted from PostgreSQL for portability)
- Default Coverage: Currently Iowa, but can easily be customized.
- Use Case: Airgapped/Airlocked geocoding systems.
- Database Location: Internal path `/nominatim/nominatim.sqlite`

## Build Summary:
1. Initialize PostgreSQL 16
2. Import OSM data with indexing
3. Add TIGER, postcodes, and importance metadata
4. Build PostgreSQL 16 Nominatim Instance
5. Use Experimental Conversion to a standalone SQLite database
6. Remove artifacts to reduce image size.

## Quick Start:
Clone the repository and include necessary files inside of the Nominatim
project folder. If you do not use `iowa-latest.osm.pbf` then you will need to 
update the nominatim.def file to use the correct osm file.

Once this is done you can simply run:
```bash
apptainer build nominatim.sif nominatim.def
```

The build-time depends heavily on data you are importing into Nominatim.

## Usage:
The container comes installed with python3 and some useful packages. You can 
install more by modifying the nominatim.def configuration file.

### Run Scripts:
```bash
# Run Python script
apptainer run nominatim.sif python3 geocode_script.py

# Interactive Python
apptainer run nominatim.sif python3

# Shell access
apptainer run nominatim.sif bash
```

### Python Nominatim API Example:
```python 
from nominatim_api import NominatimAPI
import os

os.chdir('/nominatim')
api = NominatimAPI(project_dir='/nominatim')

# Forward geocoding
results = api.search('Cedar Rapids, Iowa', limit=1)
if results:
    print(f"Lat: {results[0].centroid.lat}, Lon: {results[0].centroid.lon}")

# Reverse geocoding
from nominatim_api import Point
result = api.reverse(Point(41.9779, -91.6656))
print(result.address)

api.close()
```

### External Files:
You can mount files from your system onto the container. By default the 
container has some mounts like your home file system. For more information 
see the apptainer documentation.

```bash
# Bind mount data and script from a host directory
apptainer run --bind $PWD:/data nominatim.sif python3 /data/script.py

# Process CSV file
apptainer run --bind /path/to/data:/data nominatim.sif \
  python3 /data/geocode_csv.py /data/input.csv /data/output.csv

```

## Customization:
By default we are using Iowa OSM data. To use your own data for import into 
Nominatim you should:

1. Replace `iowa-latest.osm.pbf` in the `nominatim_project/` directory.

    Example: 
    ```bash
# Downloading California Data
    wget https://download.geofabrik.de/north-america/us/california-latest.osm.pbf \
      -O nominatim_project/california-latest.osm.pbf
    ```

2. Update `nominatim.def`:

    ```plaintext
    nominatim_project/california-latest.osm.pbf /app/data/california-latest.osm.pbf
    ```
    And update PBF_PATH in %post.

3. Adjust Resources:

    If necessary you should modify the thread count inside the %post section
    ```plaintext
    nominatim import --osm-file /app/data/iowa-latest.osm.pbf --threads [new_thread_count]
    ```






