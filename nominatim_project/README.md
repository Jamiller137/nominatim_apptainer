- This is where we put files for our nominatim instance. 

### These files will need to be mounted to the container for use in building nominatim database:
1. A osm.pbf file. For us this is `iowa-latest.osm-pbf` sourced from geofabrik

- The rest are optional:

2. TIGER-LINE files: `tiger-nominatim-preprocessed-latest.csv.tar.gz`
3. US Postcodes: `us_postcodes.csv.gz`
4. Importance files
    - `wikimedia-importance.csv.gz`
    - `secondary_importance.csv.gz`
