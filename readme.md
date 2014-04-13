
JLOS for Ios
================================

JLOS is JSON for Local Storage

- I made it for javascript / browser based apps first - and it used local storage

- For ios, it uses the file system.

- Jlos is for people who like loose json structures, and want to use something simple to store data, instead of the built in database functions. 
- Baseically, it creates a json object which you can add elements to and save in you app documents.
- you can use ti to store random bits of data or long data sets which dont necessarily need "core data" capabilities

-----
- Main current limitation is that arrays  (ie lists) can only reside at the root of the json object.
- Lots of querying functionality needs to be added too.

- the jlosdebug object is a use case special object used to log errors and other debugging notes. It replaces nslog (since you can't observe nslog when you aren't logged in.)