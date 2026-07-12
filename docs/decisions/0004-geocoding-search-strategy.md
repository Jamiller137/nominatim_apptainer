---
status: "in progress"
date: "2026-06-29"
decision-makers: "Jacob Miller"
---

# Geocoding Strategy for U.S. (Iowa/Midwest) Addresses Using Nominatim

## Context and Problem Statement

We need to geocode United States addresses into latitude/longitude coordinates 
with high accuracy and reasonably robust to rural addresses for the purpose of linking to other datasets.
The current standard (DeGAUSS) uses only TIGERLINE files and is zip-code / string query based.
For research applications it can be valuable to allow for OSM results or queries for amenities near a point.
It is possible that some datasets either do not contain zip-codes or they are inaccurate.

Common Address Dataset Problems:
* abbreviations 
* misspellings
* ordinal street names
* Contain P.O. Boxes 
* Intersection / relative location
* misleading entries: particularly and city
    * to clarify: rural areas tend to identify with a city past the city-limits
* permutations of address entry values

## Decision Drivers

* the returned coordinate should represent the intended physical or postal location.
* returned coordinate should be decorated with accuracy/confidence scores
* easily parsable
* handle common address dataset errors
* avoid excess computation
* customizable output
* provide sane fallbacks to minimize unnecessary manual review

## Considered Options
* Single free-form string Nominatim query only -> flagged for manual review if no rank 30 match
* Structured Nominatim query with parsed components -> flagged for manual review if no rank 30 match
* City-centroid based string query with fallbacks
* ZIP-centroid based string query with fallbacks
* Multi-strategy search with consensus short-circuit

## Decision Outcome

Chosen option: "Categorical -> Multi-strategy string queries with consensus"

### Reasoning: 
* complexity of implementation is not a disqualifying factor
* Uses the legacy (DeGAUSS) inspired parser, adds redundancy and fuzzy matching
* consensus mechanism keeps robustness
* allows more informed scoring of results


### Consequences

* Good, because multiple independent searches increase the chance of finding the correct location (robust bonus)
* Good, because the consensus allows us to stop early
* Good, avoids handling common errors from misspellings, abbreviations, and ordinal street names manually
* Bad, phonetic matching can occasionally produce false positives for similarly-sounding but different place names (should be done last)
* Bad, scoring accuracy of queries using multiple strategies is more complex


### Outline of Strategy
1. Categorical search with available information
    * if this works then stop
2. String search from zip-centroid/city-centroid
    * if works stop

