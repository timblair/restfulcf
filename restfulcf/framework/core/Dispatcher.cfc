<!--- -->
<fusedoc fuse="restfulcf/framework/core/Dispatcher.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am the core dispatcher / engine for the RESTful application
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="no">

	<cfset variables.controllers = {}>
	<cfset variables.routes      = createobject("component", "restfulcf.framework.core.RouteCollection")>
	<cfset variables.inflector   = createobject("component", "restfulcf.framework.util.Inflector")>
	<!--- the controller path should be overridden in the concrete dispatcher --->
	<cfset variables.controller_path = "">
	<!--- default authenticator is empty --->
	<cfset variables.authenticator = createobject("component", "restfulcf.framework.core.Authenticator")>
	<!--- as is the default cache --->
	<cfset variables.cache_enabled = FALSE>
	<cfset variables.cache = createobject("component", "restfulcf.framework.core.cache.EmptyCache")>
	<!--- the default response type, should nothing be specified --->
	<cfset variables.response_type = "xml">
	<!--- response type / MIME type mappings --->
	<cfset variables.response_types = {
		xml  = "application/xml",
		txt  = "text/plain",
		html = "text/html",
		json = "application/json",
		pdf  = "application/pdf"
	}>
	<!--- do we want to translate hyphens to underscores in incoming arguments? --->
	<cfset variables.argument_translation = FALSE>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.Dispatcher" output="no" hint="I initialise this instance of the dispatcher.  Should be overridden to define resources.">
		<cfif len(variables.controller_path) AND right(variables.controller_path, 1) NEQ ".">
			<cfset variables.controller_path = variables.controller_path & ".">
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="dispatch" access="public" returntype="restfulcf.framework.core.Response" output="no" hint="I am the dispatcher for working out which resource we need and in what representation, and going and getting it.">
		<cfargument name="method" type="string" required="yes" hint="The request method (e.g. GET, POST etc)">
		<cfargument name="uri" type="string" required="yes" hint="The resource path (e.g. /users/1)">

		<cfset var route         = "">
		<cfset var request_args  = {}>
		<cfset var response_type = variables.response_type>
		<cfset var resource_path = arguments.uri>
		<cfset var request       = "">
		<cfset var response      = "">

		<!--- authenticate first: no point in doing anything else until this is OK --->
		<cfset var auth_creds = { user = "", pass = "" }>
		<cfset var auth_string = getPageContext().getRequest().getHeader("Authorization")>
		<cfif isdefined("auth_string")>
			<cfset auth_string = tostring(tobinary(listlast(auth_string, " ")))>
			<cfif listlen(auth_string, ":") EQ 2>
				<cfset auth_creds.user = listfirst(auth_string, ":")>
				<cfset auth_creds.pass = listlast(auth_string, ":")>
			</cfif>
		</cfif>
		<cfif NOT variables.authenticator.isAuthenticated(argumentcollection=auth_creds)>
			<cfset response = createobject("component", "restfulcf.framework.core.Response")>
			<cfset response.setStatusCode("401")>
			<cfheader name="WWW-Authenticate" value='Basic realm="#variables.authenticator.getRealm()#"'>
			<cfreturn response>
		</cfif>

		<!--- grab the response format from the resource path --->
		<cfif listlen(resource_path, ".") GT 1>
			<cfset response_type = listlast(resource_path, ".")>
			<cfset resource_path = reverse(listrest(reverse(resource_path), "."))>
		</cfif>

		<!--- find the route that matches the resource path and run the request --->
		<cfset route = variables.routes.findRoute(arguments.method, resource_path)>
		<cfif route.getVerb() EQ "INVALID">
			<cfset response = createobject("component", "restfulcf.framework.core.Response")>
			<cfset response.setStatusCode("404")>
		<cfelseif NOT structkeyexists(variables.response_types, response_type)>
			<cfset response = createobject("component", "restfulcf.framework.core.Response")>
			<cfset response.setStatusCode(getController(route.getController()).HTTP_STATUS_CODES['unsupported_media_type'])>
		<cfelse>
			<cfset request = createobject("component", "restfulcf.framework.core.Request").init(
				dispatcher = this,
				route      = route,
				uri        = resource_path,
				type       = response_type,
				mime       = listfirst(cgi.content_type, ";"),
				arg_trans  = variables.argument_translation
			)>
			<cfset response = request.run()>
			<cfset response.setResponseType(variables.response_types[response_type])>
		</cfif>
		<cfreturn response>
	</cffunction>

	<cffunction name="addResource" access="private" returntype="restfulcf.framework.core.Controller" output="no" hint="I add a controller to the pool">
		<cfargument name="resource" type="string" required="yes" hint="The (unique) name of the resource">
		<cfargument name="nesting" type="any" required="no" hint="If this is a nested resource, specify parent resource names as either a comma-delimited list or an array.  Only relevant if create_default_routes is TRUE.">
		<cfargument name="route_alias" type="string" required="no" hint="The name given to the resource in the route.  Allows for one route like /payments=>Payments, and one /sites/:site_id/payments=>SitePayments">
		<cfargument name="controller" type="string" required="no" hint="An optional controller name to use, if not the default, generated from the resource name">
		<cfargument name="create_default_routes" type="boolean" required="no" default="TRUE" hint="Should default routes be created for this resource">
		<cfargument name="methods" type="string" required="no" hint="A list of methods to include when creating default routes">
		<!--- normalise naming for the resource, and create the controller --->
		<cfset var local = {}>
		<cfset local.resource_name = variables.inflector.variablise(variables.inflector.pluralise(arguments.resource))>
		<!--- make sure we've not already got a resource with this name --->
		<cfif structkeyexists(variables.controllers, local.resource_name)>
			<cfthrow type="restfulcf.framework.Dispatcher.DuplicateResourceException" message="A resource already exists with the name #arguments.resource# (which was normalised to #local.resource_name#).">
		</cfif>
		<!--- allow overriding of the default naming behaviour for controllers --->
		<cfif structkeyexists(arguments, "controller")>
			<cfset local.controller_name = arguments.controller>
		<cfelse>
			<cfset local.controller_name = variables.inflector.CamelCase(variables.inflector.pluralise(arguments.resource))>
		</cfif>
		<cfset local.controller = createobject("component", variables.controller_path & local.controller_name)>
		<!--- cache a reference to the controller --->
		<cfset variables.controllers[local.resource_name] = local.controller>
		<!--- add default routes for this controller --->
		<cfif arguments.create_default_routes>
			<!--- normalise naming for the routing --->
			<cfset local.route_alias = local.resource_name>
			<cfif structkeyexists(arguments, "route_alias")><cfset local.route_alias = variables.inflector.variablise(variables.inflector.pluralise(arguments.route_alias))></cfif>
			<cfset local.route_path = "/" & local.route_alias>
			<!--- work out any nesting (can be provided as an array or a comma-delimited list) --->
			<cfif structkeyexists(arguments, "nesting")>
				<cfif isarray(arguments.nesting)><cfset local.nesting = arguments.nesting><cfelse><cfset local.nesting = arguments.nesting.split(",")></cfif>
				<cfset local.nesting_path = "">
				<cfloop array="#local.nesting#" index="local.nested_resource">
					<cfset local.nested_resource = variables.inflector.variablise(local.nested_resource)>
					<cfset local.nesting_path = local.nesting_path & "/" & variables.inflector.pluralise(local.nested_resource) & "/:" & variables.inflector.singularise(local.nested_resource) & "_id">
				</cfloop>
				<cfset local.route_path = local.nesting_path & local.route_path>
			</cfif>
			<!--- define the route templates --->
			<cfset local.route_templates = [
				{ verb = "GET",    route = "",       method = "index"  },
				{ verb = "POST",   route = "",       method = "create" },
				{ verb = "GET",    route = "/count", method = "count"  },
				{ verb = "GET",    route = "/:id",   method = "read"   },
				{ verb = "PUT",    route = "/:id",   method = "update" },
				{ verb = "DELETE", route = "/:id",   method = "delete" }
			]>
			<!--- create the routes from the template --->
			<cfloop array="#local.route_templates#" index="local.route">
				<!--- only create routes that are specified (unless none are provided), and only build those that have the appropriate methods defined --->
				<cfif (NOT structkeyexists(arguments, "methods") OR listfind(arguments.methods, local.route['method'])) AND structkeyexists(local.controller, local.route['method']) AND iscustomfunction(local.controller[local.route['method']] )>
					<cfset variables.routes.addRoute(createobject("component", "restfulcf.framework.core.Route").init(local.route['verb'], local.route_path & local.route['route'], local.resource_name, local.route['method']))>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn local.controller>
	</cffunction>

	<cffunction name="addResponseType" access="public" returntype="void" output="no" hint="Adds the possibility of a response type to the dispatcher (e.g. permits resources to respond to a given type)">
		<cfargument name="name" type="string" required="yes" hint="The name of the response type (used to match the request format from the request, e.g. /resources/1.[doc])">
		<cfargument name="mime_type" type="string" required="yes" hint="The MIME type string to serve this response up as">
		<cfset variables.response_types[arguments.name] = arguments.mime_type>
	</cffunction>
	<cffunction name="getResponseTypes" access="public" returntype="struct" output="no" hint="Returns a copy of the structure of permitted response types">
		<cfreturn duplicate(variables.response_types)>
	</cffunction>

	<cffunction name="setAuthenticator" access="private" returntype="void" output="no" hint="Sets the authenticator component to use when auth'ing requests">
		<cfargument name="authenticator" type="restfulcf.framework.core.Authenticator" required="yes" hint="The authenticator instance">
		<cfset variables.authenticator = arguments.authenticator>
	</cffunction>

	<cffunction name="setCache" access="private" returntype="void" output="no" hint="Sets the cache component to use when caching responses.  Automatically sets cache_enabled flag to TRUE.">
		<cfargument name="cache" type="restfulcf.framework.core.cache.AbstractCache" required="yes" hint="The cache isntance">
		<cfset variables.cache = arguments.cache>
		<cfset variables.cache_enabled = TRUE>
	</cffunction>
	<cffunction name="getCache" access="public" returntype="restfulcf.framework.core.cache.AbstractCache" output="no" hint="Gets the cache component to use when caching responses">
		<cfreturn variables.cache>
	</cffunction>
	<cffunction name="setCacheEnabled" access="public" returntype="boolean" output="no" hint="Sets if response caching is enabled">
		<cfargument name="enabled" type="boolean" required="no" default="TRUE" hint="Should the cache be enabled?">
		<cfset variables.cache_enabled = NOT NOT arguments.enabled>
	</cffunction>
	<cffunction name="isCacheEnabled" access="public" returntype="boolean" output="no" hint="Is response caching enabled?">
		<cfreturn variables.cache_enabled>
	</cffunction>

	<cffunction name="getController" access="public" returntype="restfulcf.framework.core.Controller" output="no" hint="Returns the controller instance for a given name">
		<cfargument name="name" type="string" required="yes" hint="The controller name to return">
		<cfif structkeyexists(variables.controllers, arguments.name)>
			<cfreturn variables.controllers[arguments.name]>
		</cfif>
		<cfthrow type="ControllerNotFound" message="The controller for resource type #arguments.name# is not registered." detail="Make sure you addResource() from the dispatcher.  The resource name should be pluralised (e.g. users, not user.)">
	</cffunction>
	<cffunction name="getRouteCollection" access="public" returntype="restfulcf.framework.core.RouteCollection" output="no" hint="Returns the routes collection">
		<cfreturn variables.routes>
	</cffunction>

</cfcomponent>
