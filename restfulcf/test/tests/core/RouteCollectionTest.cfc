<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/RouteCollectionTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the route collection component
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset collection = createobject("component", "restfulcf.framework.core.RouteCollection").init()>
	</cffunction>

	<cffunction name="empty_collection_should_return_no_routes">
		<cfset assertTrue(structisempty(collection.getRoutes()))>
	</cffunction>

	<cffunction name="collection_should_correctly_assign_routes_by_verb">
		<cfset var get = createobject("component", "restfulcf.framework.core.Route").init("GET", "x", "x", "x")>
		<cfset var put = createobject("component", "restfulcf.framework.core.Route").init("PUT", "x", "x", "x")>
		<cfset var routes = {}>
		<cfset collection.addRoute(get)>
		<cfset collection.addRoute(put)>
		<cfset assertFalse(structisempty(collection.getRoutes()))>
		<cfset routes = collection.getRoutes()>
		<cfset assertTrue(structkeyexists(routes, "GET") AND isarray(routes['GET']), "GET route was provided to collection but hasn't been returned")>
		<cfset assertTrue(structkeyexists(routes, "PUT") AND isarray(routes['PUT']), "PUT route was provided to collection but hasn't been returned")>
		<cfset assertFalse(structkeyexists(routes, "POST"), "POST route exists in collection when not provided")>
		<cfset assertSame(routes['GET'][1], get, "GET route from collection doesn't match provided route")>
		<cfset assertSame(routes['PUT'][1], put, "PUT route from collection doesn't match provided route")>
	</cffunction>

	<cffunction name="collection_should_find_matching_route">
		<cfset var route = createobject("component", "restfulcf.framework.core.Route").init("GET", "/test/route/:id", "x", "x")>
		<cfset collection.addRoute(route)>
		<cfset collection.addRoute(createobject("component", "restfulcf.framework.core.Route").init("PUT", "/test/route/:id", "x", "x"))>
		<cfset collection.addRoute(createobject("component", "restfulcf.framework.core.Route").init("POST", "/test/route/:id", "x", "x"))>
		<cfset collection.addRoute(createobject("component", "restfulcf.framework.core.Route").init("DELETE", "/test/route/:id", "x", "x"))>
		<cfset assertSame(route, collection.findRoute("GET", "/test/route/1"))>
	</cffunction>

	<cffunction name="collection_should_return_invalid_route_for_unmatched_uri">
		<cfset collection.addRoute(createobject("component", "restfulcf.framework.core.Route").init("GET", "/test/route/:id", "x", "x"))>
		<cfset collection.addRoute(createobject("component", "restfulcf.framework.core.Route").init("PUT", "/test/route/:id", "x", "x"))>
		<cfset assertEquals("INVALID", collection.findRoute("GET", "/fail/route").getVerb())>
		<cfset assertEquals("INVALID", collection.findRoute("POST", "/fail/route").getVerb())>
	</cffunction>

	<cffunction name="collection_should_return_all_routes_as_a_simple_struct">
		<cfset var uris = ["PUT /test/route/:id", "POST /test/route/:id", "DELETE /test/route/:id"]>
		<cfset var uri = "">
		<cfset var routes = {}>
		<cfloop array="#uris#" index="uri">
			<cfset collection.addRoute(createobject("component", "restfulcf.framework.core.Route").init(listfirst(uri, " "), listrest(uri, " "), "test", lcase(listfirst(uri, " "))))>
		</cfloop>
		<cfset routes = collection.toStruct()>
		<cfloop array="#uris#" index="uri">
			<cfif NOT structkeyexists(routes, uri)><cfset fail("Could not find expected route #uri#")></cfif>
			<cfset assertEquals("test##" & lcase(listfirst(uri, " ")), routes[uri])>
		</cfloop>
	</cffunction>

</cfcomponent>
