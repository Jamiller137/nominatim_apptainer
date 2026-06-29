# Use SQLite Database

## Context and Problem Statement

Assuming we are using Nominatim from [./0001-geocoder.md](MADR-0001):

We need to make a choice on how the database should be built/administered. By default, Nominatim uses PostgreSQL.
This has been problematic when trying to run on Argon as permissions Nominatim requires:
    * nominatim: owns import process
    * postgres: owns table
    * www-data: queries database during processes
as users. In particualr, the web-server www-user and nominatim user requires read AND execution access to the 
Nominatim project directory which is blocked on Argon and should be assumed to be blocked on 
other potential systems.

## Decision Drivers

* Portability
* Parallelism for batch geocoding
* Low to no permission requirements

## Considered Options
* postgresql
* SQLite


## Decision Outcome
"SQLite" was chosen since trying to implement the default nominatim instance seemed to requires
pre-building the database and even then running queries had to be changed to use UNIX sockets instead of
TCP/IP localhost for the web-server. This was more complicated than is reasonable.

### Consequences
* SQLite conversion is flagged as experimental in Nominatim's documentation
    * keep an eye on this and verify behavior between the SQLite and PostgreSQL databases during testing
