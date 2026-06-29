---
status: "proposed"
date: "2026-06-29"
decision-makers: "Jacob Miller"
---

# Geocoding Strategy for U.S. Addresses Using Nominatim with Legacy Parser and Phonetic Matching

## Context and Problem Statement

We need to geocode free-form United States address strings into latitude/longitude coordinates 
with high accuracy and reasonable robustness. The current standard (DeGAUSS) 
uses only TIGERLINE files and is zip-code / string query based.
It is possible that some datasets do not contain zip-codes or has syntax 
search via zip-codes give misleading results.

Common Address Dataset Problems:
* abbreviations 
* misspellings
* ordinal street names
* Contain P.O. Boxes 
* Intersections and relative locations
* misleading entries: particularly and city
    * to clarify: rural areas tend to identify with a city past the city-limits
* permutations of address entry values

## Decision Drivers

* the returned coordinate should represent the intended physical or postal location.
* be able to handle common address dataset errors
* avoid additional computation when independent search strategies agree
    * feasibly implemented in batch or rolling
* provide sane fallbacks to minimize unnecessary manual review
* Transparency: consumers should receive principled confidence/accuracy scores for ranking results

## Considered Options

* Single free-form string Nominatim query only -> flagged for manual review if no exact match
* Structured Nominatim query with parsed components -> flagged for manual review if no exact match
* City-centroid based string query with syntax fallbacks
* ZIP-centroid based string query with syntax fallbacks
* Multi-strategy search with consensus short-circuit
* Multi-strategy search with consensus short-circuit, plus phonetic matching and number-word expansion

## Decision Outcome

Chosen option: "Multi-strategy string queries with consensus, phonetic matching, and number-word expansion"

### Reasoning: 
* Uses the legacy (DeGAUSS) inspired parser, adds redundancy and fuzzy matching
* consensus mechanism keeps the common case fast while being robust
* multi-strategy allows for more informed scoring of results beyond just query edit distance


### Consequences

* Good, because multiple independent searches increase the chance of finding the correct location
* Good, because the consensus reduces complexity for common cases
* Good, avoids handling errors from misspellings, abbreviations, and ordinal street names manually
* Bad, phonetic matching can occasionally produce false positives for similarly-sounding but different place names.
* Bad, scoring accuracy of queries using multiple strategies is more complex
