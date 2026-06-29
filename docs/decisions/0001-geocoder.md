---
# These are optional metadata elements. Feel free to remove any of them.
status: "accepted"
date: "2026-06-26"
decision-makers: "Jacob Miller"
---

# Consider options for geocoder: chose Nominatim

## Context and Problem Statement

We must create a geocoder to use offline (for compliance) on sensitive patient data.  In particular: on Argon via an apptainer container.

<!-- This is an optional element. Feel free to remove. -->
## Decision Drivers
* Implementable Locally (non-proprietary)
* able to run on a variety of systems with varying permission levels
    * Argon via apptainer/singularity container
* easily customizable
* easy to create linkages with other datasets for researcher applications
* Good API's for customized search logic
    * Bonus: Python since I am already familiar
* Allows for customizable search result rankings
* Bonus: allows for reverse geocoding for research applications

## Considered Options

* [Pelias](https://github.com/pelias)
* [DeGAUSS](https://degauss.org/geocoder)
* [Nominatim](https://github.com/osm-search/Nominatim)

## Decision Outcome

Chosen option: "Nominatim", because Pelias backend while directly customizable is built off of many docker containers which is not easily implemented on Argon.
DeGAUSS is 


Can we identify gaps: data quality clinical informatics precision data lens
gaps in clinical providro decision makers might want to understand


### Consequences

* Good, since version 5.0.0 Nominatim has a well-documented Python API
* Good, Linked with openstreetmap (OSM) database
* Good, actively developed with new features planned
* Good, allows for reverse geocoding using OSM amenity tags for research applications
* Bad, requires custom search logic and syntax parsing on a string/categorical search
* Bad, need to keep good track of versions
* Bad, requires Linux with the possibility of Windows support in the future.
* Neutral, by default uses the entire TIGERLINE database on local import (can be modified)

### DeGAUSS

* Good, is a standard tool used in the space
* Good, because comes with prebuilt data linkages e.g. drive-time, RUCA, and some Land Cover
* Good, uses only TIGERLINE files and so quality is directly linked to US Census data
* Bad, Only uses TIGERLINE data and does not provide direct OSM linking.
* Bad, importance/search ranking accuracy scores are opaque in their documentation 
    * use result vs. query edit distance
* Neutral, other linkages must be custom built
* Neutral, built using Docker and does not have the same level of reproducibility guarantees as other options
