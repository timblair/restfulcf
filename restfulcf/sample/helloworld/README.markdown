# RESTfulCF Sample App: Hello World

The staple introductory or sample application for any language or framework, we present: RESTfulCF Hello World.

## Setup and Requirements

The assumed setup is:

* ColdFusion 8;
* Apache with `mod_rewrite` enabled and allowed for per-directory settings (e.g. using `.htaccess`);
* That the `restfulcf` directory is in your local web root.

The sample application uses an `application`-scoped "database" for storing `World` instances, so no database is required.

To make non-`GET` requests to a RESTfulCF implementation (i.e. for creating, updating or deleting resources), you'll need something other than your browser.  `cURL` is good enough for you command-line people, or if you're a Firefox fan try the [Poster](https://addons.mozilla.org/en-US/firefox/addon/2691) plugin.

> **Note**: if you are not using Apache with `mod_rewrite` enabled within an `.htaccess` file, you'll need to add `rest.cfm` to each of the URLs listed below, for example: `...public/worlds` should become `...public/rest.cfm/worlds`.

## Files

This sample application is structured as follows (all within `restfulcf/sample/helloworld`):

    README.markdown        – this file
    public                 – the "webroot" of this application
        .htaccess          – Apache rewrite (to remove /rest.cfm/ from URLs)
        rest.cfm           – public interface to the REST implementation
        Application.cfc    – basic setup of application vars etc
    rest                   – the location of the controllers, resource descriptors etc
        Dispatcher.cfc     – Dispatcher definition (extends restfulcf.framework.core.Dispatcher)
        controllers        – all the controllers for the sample app
            Worlds.cfc     – controller (extends restfulcf.framework.core.Controller)
        resources          – all resources for the sample app
            World.cfc      – resource definition (extends restfulcf.framework.core.Resource)

The controller file name should be pluralised and CamelCased (although this can be overridden); the resource file name can anything, but should be singular and CamelCased for consistency.

## Controller Actions

The sample controller (`rest/controllers/Worlds.cfc`) gives an example of the six default actions.  The actions available, including an example of the HTTP request required to call that action, are as follows:

* `index`   -- list/index of all worlds (`GET /worlds`)
* `create`: -- create a new world (`POST /worlds`)
* `read`:   -- read a single world (`GET /worlds/:id`)
* `update`: -- update a single world (`PUT /worlds/:id`)
* `delete`: -- delete a single world (`DELETE /worlds/:id`)
* `count`:  -- simple count, instead of listing all and counting (`GET /worlds/count`)

### `index`, `read` and `count` (via the HTTP `GET` method)

The simplest calls that can be made are `GET` requests, as these can be made directly through your browser.  Assuming the setup as described above, you can retrieve a list of all pre-defined `World`s (also known as a "collection" or resources) by simply putting the following into your browser:

    http://localhost/restfulcf/sample/helloworld/public/worlds

This should return you an XML packet similar to the following:

    <?xml version="1.0" encoding="UTF-8"?>
    <worlds type="array">
        <world>
            <created_at type="datetime">{ts '2009-07-13 08:31:45'}</created_at>
            <id type="integer">2</id>
            <name>Goodbye</name>
            <updated_at type="datetime">{ts '2009-07-13 08:31:45'}</updated_at>
        </world>
        <world>
            <created_at type="datetime">{ts '1978-09-22 12:34:56'}</created_at>
            <id type="integer">1</id>
            <name>Hello</name>
            <updated_at type="datetime">{ts '2009-07-13 08:31:45'}</updated_at>
        </world>
    </worlds>

By default, the worlds are returned in alphabetical order by name; to change this, try the following:

    http://localhost/restfulcf/sample/helloworld/public/worlds?order=id

The `index` function in `restfulcf/sample/helloworld/rest/controllers/Worlds.cfc` is setup to use the `sort` function of the `ResourceCollection` that's returned, based on the order given, which means you can sort based on any of the fields.

To read just a single `World` resource, you just add the ID of the world to the end of the `index` URL as follows:

    http://localhost/restfulcf/sample/helloworld/public/worlds/1

You'll then just get the single resource back:

    <world>
        <created_at type="datetime">{ts '1978-09-22 12:34:56'}</created_at>
        <id type="integer">1</id>
        <name>Hello</name>
        <updated_at type="datetime">{ts '2009-07-13 08:31:45'}</updated_at>
    </world>

The default representation of each resource is XML, but you can change this by simple adding the appropriate type of the end of the URL, as follows:

    http://localhost/restfulcf/sample/helloworld/public/worlds/1.txt
    http://localhost/restfulcf/sample/helloworld/public/worlds/1.html
    http://localhost/restfulcf/sample/helloworld/public/worlds/1.pdf

If you request a representation that's not supported by the given resource, the HTTP response status will be `415 Unsupported Media Type`.

If you simply wish to get a count of how many `World`s there are, you can append `/count` to the collection URI:

    http://localhost/restfulcf/sample/helloworld/public/worlds/count

An XML representation of a count will look like the following:

    <worlds>
        <count type="integer">2</count>
    </worlds>

This method is not a standard RESTful, but has been added though the need to perform counts on resources, but not wanting to retrieve thousands of resources via the `index` method, simply to count how many there are.

### `create` (via the HTTP `POST` method)

Creating a new resource is slightly more complicated, in that it requires an HTTP `POST` method.  The example here is using `cURL` to create a new `World` resource:

    curl -d 'name=Another' http://localhost/restfulcf/sample/helloworld/public/worlds

You can provide the properties for new resources either as `GET` or `POST` arguments (using the ColdFusion `URL` or `FORM` scopes), or by sending an XML representation of the resource as the `POST` body.

Assuming that the new `World` was created successfully, the HTTP response status will be `201 Created`; the `Location` headed will include the unique URI to the newly created `World` resource, and the body will be the representation of the resource as if you had `read` it.

If there is a validation error and the resource cannot be created, the response status will be `422 Unprocessable Entity`, and the body will be an array of error messages such as the following (if we provided an empty `name` property when trying to create a new `World`):

    <errors type="array">
        <error>Name must not be empty</error>
    </errors>

### `update` (via the HTTP `PUT` method)

Updating an existing resource is very similar to creating a new one: the properties for the resource are provided in the same way, and on a successful request the appropriate representation of the updated resource is returned as the response body.

An `update` request differs from a `create` in that you must use the HTTP `PUT` method, and use the full URI to the resource, for example:

    curl -X PUT -d 'name=A Different' http://localhost/restfulcf/sample/helloworld/public/worlds/1

If a resource cannot be found, the response status will be `404 Not Found`; on a successful update, the response will be `200 OK`.  Validation errors are handled in the same way as for a `create` request.

### `delete` (via the HTTP `DELETE` method)

The final request type is a `delete`; this is simply an HTTP `DELETE` request to a resource URI:

    curl -X DELETE http://localhost/restfulcf/sample/helloworld/public/worlds/1

The response statuses are the same as for an `update` request (`200 OK` or `404 Not Found` as appropriate).
