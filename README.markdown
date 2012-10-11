# RESTfulCF

RESTfulCF is a framework for ColdFusion that simplifies the publishing of RESTful API-style interfaces.

## Background

The framework was extracted from work at [White Label Dating](http://www.whitelabeldating.com/).  The goal was to provide an interface to a ColdFusion core to be used by a Ruby on Rails application; rather than giving direct database access and having to maintain two sets of business rules across two different languages, a REST API was built on top of the existing ColdFusion application.

Due to the background of the project, there are a number of "Rails-isms" that have found their way into the framework (such as the way errors are returned, typing for properties in XML resource representations), but in general these are only there to improve interoperability and have certainly not been added just to "make it work like Rails".

## What is REST?

REST stands for "REpresentational State Transfer".  It is a stateless protocol based around the use of "resources" (think objects), each of which is uniquely addressable (in this case, via a URI); components of the system exchange "representations" of resources (the actual data representing the resource, for example an XML or JSON packet, or an HTML or PDF document).

REST interfaces require a constrained set of well-defined operators; in this case we use HTTP methods:

* `GET` for reading resources (both singular and collections)
* `POST` for creating new resources
* `PUT` for updating existing resources
* `DELETE` for deleting existing resources

For a more detailed discussion, see the [Wikipedia REST page](http://en.wikipedia.org/wiki/REST).

> If the system consuming your RESTful application does not support `PUT` and `DELETE` requests, these can be simulated by using the special `_method` parameter via a `POST`.  The arguments should be provided as either a `POST` parameter or in the query string (if both are provided then the `POST` variable takes precedence); pass `_method=PUT` or `_method=DELETE` as appropriate.

## Requirements

* ColdFusion 8/9
* Wildcard mappings for Search Engine Safe (SES) URLs must be enabled
* [MXUnit](http://mxunit.org/) is required for the unit tests

This framework makes use of the `CGI['PATH_INFO']` variable which is populated when a URL such as `script.cfm/path_info` is requested; this behaviour is known as "search engine safe URLs" and is not enabled by default on ColdFusion, and the example URL given would normally result in a `404 Not Found` error.  To allow ColdFusion to handle these types of requests, edit your `web.xml` file and search for the following section:

    <!-- begin SES
    <servlet-mapping id="coldfusion_mapping_6">
        <servlet-name>CfmServlet</servlet-name>
        <url-pattern>*.cfml/*</url-pattern>
    </servlet-mapping>
    ...
    end SES -->

Simply un-comment out the section and restart ColdFusion.

To make non-`GET` requests to a RESTful API (i.e. for creating, updating or deleting resources), you'll need something other than your browser.  `cURL` is good enough for you command-line people, or if you're a Firefox fan try the [Poster](https://addons.mozilla.org/en-US/firefox/addon/2691) plugin.

## Installation

Simply place the `restfulcf` directory either in your webroot or within a custom tag path, or create a mapping called `/restfulcf` to the location of the directory.

## Sample Application: Hello World

A very simple sample application is included in `restfulcf/sample/helloworld` which will perhaps give a clearer example of the components of a RESTfulCF application.  There is a `README` file in that directory which fully explains how to use the example; the code is also well commented so it should be simple enough to follow.

## Overview of the Framework

The following is a breakdown of the main components you'll need to use to implement a REST service using RESTfulCF.

### RESTful Interface End Point (`endpoint.cfm`)

This is the "entrance point" to a RESTfulCF implementation.  It's a custom tag, and a simple implementation would be:

    <cfapplication name="my_restful_app">
    <cfimport taglib="/location/of/restfulcf/framework/tags/" prefix="restfulcf">
    <restfulcf:endpoint
        name     = application.applicationname,
        engine   = "path.to.my.Dispatcher"
        reload   = TRUE
        response = "variables.response">

RESTfulCF makes use of the `Application` scope, so this must be defined using `<cfapplication>` or `Application.cfc` before calling the `endpoint` custom tag.  The call to `endpoint` should be from a publicly-accessible script.  If you'd rather not play with compile-time imports of custom tag libraries, you can easily use `<cfmodule>` instead.

The arguments to the `endpoint` custom tag are as follows:

* `name` -- the unique name of the RESTful implementation (usually the application name)
* `engine` -- the dotted-path to your Dispatcher (a string, not an instance)
* `reload` -- should the engine be reloaded on each request (should be `FALSE` in production)
* `response` -- an optional variable to push the `Response` resulting from the request

### `Dispatcher`

An implementation of RESTfulCF will contain a component which extends `Dispatcher`: this is the file which will define which `Resource`s are available (through which `Route`s), as well as defining any `Authenticator` to use for all calls.

The simplest custom `Dispatcher` would be something like:

    <cfcomponent extends="restfulcf.framework.core.Dispatcher" output="no">
    	<cfset variables.controller_path = "path.to.my.controllers">
    	<cffunction name="init" access="public" returntype="restfulcf.framework.core.Dispatcher" output="no">
    		<cfset super.init(argumentcollection=arguments)>
    		<cfset addResource("resource")>
    		<cfreturn this>
    	</cffunction>
    </cfcomponent>

Here we're simply defining the path to the location of the `Controller` components, and adding a resource called "resource".

#### `addResource()`

This function is a helper for creating `Route`s mapping URIs to certain controllers and functions.  The simplest form is just:

    <cfset addResource("resource")>

This will use a controller called `Resources.cfc` in the `controller_path` set in the `Dispatcher` (see above).  It will then look inside that controller and auto-map certain functions it finds to routes as follows:

* `index` -> `GET /resources`
* `create` -> `POST /resources`
* `read` -> `GET /resources/:id`
* `update` -> `PUT /resources/:id`
* `delete` -> `DELETE /resources/:id`
* `count` -> `GET /resources/count`

`addResource()` can take a number of different arguments to allow for route nesting, aliasing of route names, the path to the actual controller file, whether default routes should be created automatically, and if they should, which ones:

1. `resource` -- unique resource name
2. `nesting` -- array or comma-delimited list of route nesting, to allow generation of routes such as `/resources/:resource_id/subs/:id`
3. `route_alias` -- an alias to use for this resource within the generated routes, so a controller called `MyLongResources` could be aliased to `resources` in the generated routes instead of the default `my_long_resources`
4. `controller` -- used to override the default naming conventions for controllers, mainly to allow for better organisation of controllers (e.g. setting this as `sub.Resources` would add this path to the end of the `controller_path` for where to find the controller)
5. `create_default_routes` -- should default routes be automatically created (default is `TRUE`)
6. `methods` -- if `create_default_routes` is `TRUE`, only creates routes for these functions (or all if not provided)

If you want to use custom (non-default) routes then you should still call `addResource()` to define the controller to handle requests for that resource name.  You can then add individual routes as follows:

    <cfset addResource(name = "resources", create_default_routes = FALSE)>
    <cfset variables.routes.addRoute(
        createobject("component", "restfulcf.framework.core.Route").init(
            verb       = "GET",
            uri        = "/resources/:id",
            controller = "resources",
            method     = "read"
        )
    )>

#### Callbacks

The following callback functions are called per request if defined in your dispatcher:

* `onRouteFound(restfulcf.framework.core.Route)` when route matching has been performed
* `onRequestBuilt(restfulcf.framework.core.Request)` when the `Request` has been initialised, but before it's run
* `onAuthenticated(string)` on successful user authentication (the argument passed is the user name)

### `Route`

A `Route` is effectively a mapping of HTTP request method (`GET`, `POST` etc) and URI pattern to a given controller and function.  For example, a route may be defined that maps `GET /resources/:id` to `path.to.controllers.Resources#read`.  All routes are defined in the `Dispatcher#init` function and are stored within a `RouteCollection` within that `Dispatcher`.

The initialisation arguments for a `Route` are:

* `verb` -- the HTTP method (one of `GET`, `POST`, `PUT` or `DELETE`)
* `uri` -- the URI that matches this route, e.g. /users/:id
* `controller` -- the controller to use for this route (as defined via `Dispatcher#addResource()`)
* `method` -- the name of the function to call in the controller

#### Parameters in URIs and Nested Resources

The URI for a `Route` can (and usually does) contain one or more parameter; these names of these are prefixed with a colon `:`.  For example, the following URI defines a parameter called `id`:

    /resources/:id

During `Route` matching, any parameters are replaced out with a simple regular expression (matching anything except a forward slash `/`), so the above URI would match against any of the following:

    /resources/1
    /resources/qwertyuiop
    /resources/user+name

If a `Route` matches a requested URI, and it contains one or more parameters, the extracted parameters will be passed to the controller as named arguments (named as the parameters):

    <cffunction name="read">
        <cfargument name="id">
        ...
    </cffunction>

The idea of a "nested resource" can be provided by using multiple parameters:

    /resources/:resource_id/foos/:foo_id/bars/:id

Again, the appropriate parameters are passed as named arguments through to the controller:

    <cffunction name="read">
        <cfargument name="resource_id">
        <cfargument name="foo_id">
        <cfargument name="id_id">
        ...
    </cffunction>

### `Controller`

A RESTfulCF application will contain one or more components which extend `Controller`: these are the core of the application.  Each `Controller` instance should implement one or more functions which are mapped to a public `Route` through the `Dispatcher`.  The default functions which can automatically be picked up and `Route`s created for them are listed in the `addResource()` section above.

The base `Controller` component is almost completely empty: it contains a simple `init()` function, and the `HTTP_STATUS_CODES` lookup described below.  You can created any functions you choose here: they're hooked up to the actual REST interface via `Route`s as defined in the `Dispatcher` section above.  In general, a function will take in a number of arguments, and return a `Resource` of some variety:

    <cffunction name="read" access="public" returntype="restfulcf.framework.Resource">
        <cfargument name="id">
        <cfreturn createobject("component", "path.to.my.resources.Resource").init(
            id = arguments.id,
        )>
    </cffunction>

#### `HTTP_STATUS_CODES`

Each controller contains a lookup structure which maps human-readable HTTP status names to their appropriate status codes.  For instance, `ok` is mapped to `200`, `created` to `201`, `not_found` to `404` and so on.  These can be used for readability when setting the response status code from within a `Controller`:

    <cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['created'])>

See details on the `Response` component below for more information.

### `Resource`

At the simplest level, a component that extends `Resource` is the definition of an individual resource; the available fields within a `Resource` are defined by using `<cfproperty>` tags.  In general, most `Resource` files are as simple as this:

    <cfcomponent extends="restfulcf.framework.core.Resource" output="no">
    	<cfproperty name="id"          type="numeric"  default="0">
    	<cfproperty name="name"        type="string"   default="">
    	<cfproperty name="created_at"  type="date"     default="1900-01-01 00:00:00">
    	<cfproperty name="updated_at"  type="date"     default="1900-01-01 00:00:00">
    </cfcomponent>

Each `<cfproperty>` tag must have a unique (within this `Resource`) `name` and a `tyoe`; the `default` is optional but _should_ be provided.  The options for a property's `type` are:

* `numeric`
* `string`
* `date`
* `boolean`

All `defaults` are plain text: you cannot use a ColdFusion function to populate these (hence the long-hand definition of the timestamps in the example above).

Optionally, `numeric` and `date` type properties can be given a `precision` which define how these fields are formatted in a representation of the resource:

* `numeric` -- `integer`, `decimal`, `float`
* `date` -- `datetime` (default), `date`, `time`

A `numeric` type does not have a `precision` default: the property will be output as given.  The exception to this rule is any `numeric` property named `id` or that ends in `_id`, which are automatically treated as `integer`s unless the precision is given otherwise.

#### Setting and Getting Properties

The base `Resource` component makes use of the `onMissingMethod` function to allow implicit setter and getter methods for any property defined using `<cfproperty>`, based on the property name.  For the example given above, the following functions will be available for setting and retrieving property values:

* `getID()` and `setID(number)`
* `getName()` and `setName(string)`
* `getCreated_at()` and `setCreated_at(date)`
* `getUpdated_at()` and `setUpdated_at(date)`

As you can see, the function names don't adhere to the standard camel-cased naming convention.

#### Resource Representations

The conversion from `Resource` to a transferrable representation of that resource is via the functions named `to...()` built in to the base `Resource`.  The `...` part is replaced by the requested type; the built-ins are `xml`, `txt`, `json`, `csv` and `html`.  Any `Resource` can override any of these functions to provide a custom response; a `pdf` type is allowed by the framework, but there is no default handler and the `toPDF()` function must be implemented on a per-`Resource` basis.

The default responses for each representation type are:

* `toTXT()` and `toJSON()` -- both return a JSON-encoded string
* `toHTML()` -- returns a definition list (`<dl>...</dl>`)
* `toXML()` -- returns an XML packet
* `toCSV()` -- returns a CSV document, including a header line detailing the names and order of properties

An example XML representation of the above sample `Resource` is:

    <?xml version="1.0" encoding="UTF-8"?>
    <resource>
        <created_at type="datetime">{ts '1900-01-01 00:00:00'}</created_at>
        <id type="integer">0</id>
        <name></name>
        <updated_at type="datetime">{ts '1900-01-01 00:00:00'}</updated_at>
    </resource>

If you request a response type that a given resource doesn't support, the HTTP response code will be set to `415 Unsupported Media Type` (i.e. your request was understood, but the resource can't be formatted into the required type.)

#### `ResourceCollection` (extends `Resource`)

This component is the first of the "meta-resources" within RESTfulCF, which extends `Resource` and so is treated just like any other `Resource` instance returned from a controller.  A `ResourceCollection` is exactly that: a collection of `Resource`s.  This is generally what will be returned from the `index` method in a controller, so that an example request of `http://localhost/resources.xml`, where `Resources#index` returned a `ResourceCollection`, would result in a response similar to the following:

    <?xml version="1.0" encoding="UTF-8"?>
    <resources type="array">
        <resource>
            ...
        </resource
        <resource>
            ...
        </resource
    </resources>

The controller would initialise and add to a `ResourceCollection` as follows:

    <cfset collection = createobject("component", "restfulcf.framework.core.ResourceCollection").init(name)>
    <cfloop array="#resources#" index="resource">
        <cfset collection.add(resource)>
    </cfloop>
    <cfreturn collection>

#### `ResourceCount` (extends `Resource`)

A `ResourceCount` is another "meta-resource", but in this case it simply returns a count.  A resource of this type should generally be returned when requesting a count of resources, rather than retrieving all the resources as a `ResourceCollection` just to perform a `count()`-type function on the collection.  An example request of `http://localhost/resources/count.xml`, where `Resources#count` returned a `ResourceCount`, would result in a response similar to the following:

    <?xml version="1.0" encoding="UTF-8"?>
    <resources>
        <count type="integer">12345</count>
    </resources>

The controller would initialise a `ResourceCount` as follows:

    <cfset count = createobject("component", "restfulcf.framework.core.ResourceCount").init(name, count)>
    <cfreturn count>

### `Response`

An instance of `Response` is is passed, by reference, to each `Controller` function request under the argument name `_response`.  The data in this object is what defines what is returned at the end of the request.

The `Response` object contains a number of simple setters/getters which are used throughout the framework, but you will find you'll need to set some from within your controllers.  For example, if we're trying to `read` a resource (e.g. `GET /resources/1`) but the given resource doesn't exist, the `setStatusCode()` function should be called to set the response status to `404 Not Found`:

    <cffunction name="read">
        <cfargument name="id">
        <cfif NOT resourceExists(arguments.id)>
            <cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['not_found'])>
            <cfreturn>
        </cfif>
        ...
    </cffunction>

The following is a quick example of a complete `create` function from a sample controller, which makes use of `setStatusCode()`, `addError()` (for validation errors: also see `ErrorCollection` below) and `setResponseURI()` (for setting the `Location` header of the HTTP response to the URI of the newly created resource) from the `Response` object:

    <cffunction name="create">
        <cfargument name="name">
        <cfset var resource = {}>
        <!--- validate the name --->
        <cfif NOT len(arguments.name)>
            <!--- add an error if there's a problem --->
            <cfset arguments['_response'].addError("Name must not be empty")>
        </cfif>
        <!--- if there are any errors, set a fail status and return --->
        <cfif arguments['_response'].hasErrors()>
            <cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['unprocessable_entity'])>
            <cfreturn>
        </cfif>
        <!--- still here, so create the new resource --->
        <cfset resource.id = saveResource(arguments.name)>
        <!--- set the proper response status and URI --->
        <cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['created'])>
        <cfset arguments['_response'].setResponseURI("/resources/" & resource.id)>
        <!--- and return the resource-ified resource --->
        <cfreturn createobject("component", "path.to.my.resources.Resource").init(
            id   = resource.id,
            name = arguments.name
        )>
    </cffunction>

Another function that you may use from within a controller is `setResponseFile()`; If this is set with a local file path (and the file exists) then that file will be sent as the HTTP response.  This is useful for serving up pre-existing static files through the REST interface.

A reference to the `Response` object is also returned if the `response` variable name argument is provided when calling the `endpoint.cfm` custom tag.

### Additional Components

These components are used within the internals of the framework, but you'll rarely need to concern yourself with them.

#### `Authenticator`

This component is a template for locking your REST implementation down using [basic authentication](http://en.wikipedia.org/wiki/Basic_access_authentication).  If you wish to use this, create a new component extending this one, override the `init()` and `isAuthenticated()` functions, and add a line similar to the following to the `init()` function of your app's `Dispatcher` component:

    <cfset setAuthenticator(createobject("component", "path.to.my.Authenticator").init(...))>

This authentication will be used for _every_ request; you cannot simply only protect some resources.

#### `ErrorCollection` (extends `Resource`)

`ErrorCollection` extends `Resource`, and provides the internal error reporting facility for when validation errors occur.

#### `Request`

This component is the internal representation of a request; it's generally not used directly, but is passed to each `Controller` function request under the argument name `_request`.  Through this you can get a handle on the root `Dispatcher` instance, the current `Route`, plus the current URI and requested response type.

#### `RouteCollection`

This is simply a collection of all `Route`s available to the REST implementation; it uses the `findRoute` function to match the HTTP request method and URI to a single route.

### Response Caching

A simple response caching system is available within RESTfulCF which caches the response object for a given request (based on the request type and URI).  Multiple requests for the same (cached) data will bypass the controller and simply return the relevant `Response`.

> Caching is only applicable to `GET` requests.  If the cache status of the response to a non-`GET` request will be ignored and will never be cached (or asked to be retrieved from the cache).

As an example, to use the built-in `application`-scoped cache, add the following line to your `Dispatcher#init`:

    <cfset setCache(createobject("component", "restfulcf.framework.core.cache.ApplicationCache").init())>

Then, in the relevant `Controller` function, set that the response can be cached as follows:

    <cfset arguments['_response'].setCacheStatus(TRUE)>

The default cache time for this cache is 30 minutes; to change this you can pass a timestamp through to the `setCacheStatus()` function.  For example, to set the responses to a given action to cache for an hour you'd add the following to the controller function:

    <cfset arguments['_response'].setCacheStatus(createtimestamp(0,1,0,0))>

> The `ApplicationCache` is not recommended for production use: use it as an example of what you need to do to create your own concrete cache (using memcached or something similar), as described below.

#### Custom Caches

You may create you own cache type by creating a new component that extends `restfulcf.framework.core.cache.AbstractCache` and implementing the following functions:

* `getKey`
* `setKey`
* `deleteKey`

Look at the code for `restfulcf.framework.core.cache.ApplicationCache` for the arguments to these functions etc.

### HTTP Response Status Codes Used

The HTTP response code will be one of the following:

* `200 OK`
* `201 Created`
* `401 Unauthorized` -- if a custom `Authenticator` is used and correct credentials have not been supplied
* `404 Not Found` -- if either a resource (or controller) can't be found
* `415 Unsupported Media Type` -- if an unsupported representation type was requested
* `422 Unprocessable Entity` -- if a resource validation error occurred
* `500 Internal Server Error` -- something went wrong

## Known Issues

### Error Handling

The current version has very little in the way of error handling: if something goes wrong, then you'll likely get a standard ColdFusion error page, which won't be take to kindly by any consumer of your REST interface that's expecting a nicely formatted XML packet back.  Work on this is nearing completion.

## Licensing and Attribution

RESTfulCF is released under the MIT license as detailed in the LICENSE file that should be distributed with this library; the source code is [freely available](http://github.com/timblair/restfulcf).

RESTfulCF was developed by [Tim Blair](http://tim.bla.ir/) during work on [White Label Dating](http://www.whitelabeldating.com/), while employed by [Global Personals Ltd](http://www.globalpersonals.co.uk).  Global Personals Ltd have kindly agreed to the extraction and release of this software under the license terms above.
