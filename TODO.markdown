# RESTfulCF To-Do List

In no particular order...

## Framework Features

* Regex or similar support for route parameters, e.g. /resources/[0-9]+
* Use of Accept: header for defining the response type, in addition to file extension
* Error handling
    * Handling of CF errors
    * Needs to be extracted from existing WLD implementation and refined
    * Unit tests required
    * Error capturing examples
* Remove dependancy on `CGI['PATH_INFO']` and SES enabling via `web.xml`
* Support for deserialising JSON-encoded body content on `POST`/`PUT`

## Bugs and Known Issues

* Controllers don't know the location of the API to output `Location` headers on successful `POST`
* CF9's (mis)use of the `local` scope ([bug report](http://bit.ly/cg2DC))
* CF9's implicit creation of setters/getters based on <cfproperty> tags

## Supporting Material

* Tests
    * Unit tests required for Dispatcher and Request
* More complex sample application, including:
    * Nested resources
    * Resource collections
* Documentation
    * Much more detail required than just the README
    * "How to use RESTfulCF"
    * "How RESTfulCF works"
    * Packaged within app, or using Github wiki/pages?
    * Should tie in with project website
* Project website including basic details, package downloads, update blog, docs etc
* Build script to package up for download
