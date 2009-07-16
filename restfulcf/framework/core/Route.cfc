<!--- -->
<fusedoc fuse="restfulcf/framework/core/Route.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a simple component representing a route
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="no">

	<cfset variables.instance = {
		verb       = "INVALID",
		controller = "",
		method     = "",
		uri        = "/x-invalid-route",
		pattern    = "/x-invalid-route"
	}>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.Route" output="no" hint="I intialise the route">
		<cfargument name="verb" type="string" required="yes" hint="The HTTP method to use (one of GET, POST, PUT, DELETE)">
		<cfargument name="uri" type="string" required="yes" hint="The URI pattern (e.g. '/users/:id')">
		<cfargument name="controller" type="string" required="yes" hint="The controller name">
		<cfargument name="method" type="string" required="yes" hint="The controller method name">
		<cfset setVerb(arguments.verb)>
		<cfset setURI(arguments.uri)>
		<cfset setController(arguments.controller)>
		<cfset setMethod(arguments.method)>
		<cfreturn this>
	</cffunction>

	<cffunction name="getVerb" access="public" returntype="string" output="no" hint="Gets the HTTP method (verb) for this route">
		<cfreturn variables.instance.verb>
	</cffunction>
	<cffunction name="setVerb" access="public" returntype="void" output="no" hint="Gets the HTTP method (verb) for this route">
		<cfargument name="verb" type="string" required="yes" hint="The HTTP method to use (one of GET, POST, PUT, DELETE)">
		<cfif NOT listfind("GET,POST,PUT,DELETE", ucase(arguments.verb))>
			<cfthrow type="coldfusion.tagext.validations.AttributeValueNotFromListException" message="GET, POST, PUT, DELETE">
		</cfif>
		<cfset variables.instance.verb = ucase(arguments.verb)>
	</cffunction>

	<cffunction name="getController" access="public" returntype="string" output="no" hint="Gets the controller name for this route">
		<cfreturn variables.instance.controller>
	</cffunction>
	<cffunction name="setController" access="public" returntype="void" output="no" hint="Sets the controller name for this route">
		<cfargument name="controller" type="string" required="yes" hint="The controller name">
		<cfset variables.instance.controller = arguments.controller>
	</cffunction>

	<cffunction name="getMethod" access="public" returntype="string" output="no" hint="Gets the controller method name for this route">
		<cfreturn variables.instance.method>
	</cffunction>
	<cffunction name="setMethod" access="public" returntype="void" output="no" hint="Sets the controller method name for this route">
		<cfargument name="method" type="string" required="yes" hint="The controller method name">
		<cfset variables.instance.method = arguments.method>
	</cffunction>

	<cffunction name="getURI" access="public" returntype="string" output="no" hint="Gets the URI pattern for this route">
		<cfreturn variables.instance.uri>
	</cffunction>
	<cffunction name="setURI" access="public" returntype="void" output="no" hint="Sets the URI pattern for this route">
		<cfargument name="uri" type="string" required="yes" hint="The URI pattern (e.g. '/users/:id')">
		<cfset variables.instance.uri = arguments.uri>
		<cfset variables.instance.pattern = "^" & rereplace(arguments.uri, ":([[:alnum:]-_]*)", "([^/]+?)", "ALL") & "$">
	</cffunction>

	<cffunction name="matches" access="public" returntype="boolean" output="no" hint="Does this given given match this route?">
		<cfargument name="verb" type="string" required="yes" hint="The HTTP method (verb) for this request">
		<cfargument name="path" type="string" required="yes" hint="The requested path">
		<cfreturn arguments.verb EQ variables.instance.verb AND refind(variables.instance.pattern, arguments.path)>
	</cffunction>

	<cffunction name="getPathVars" access="public" returntype="struct" output="no" hint="Get the path vars for this request.  For example, if the route URI pattern is /users/:id and the requested path is /users/1, this function will return a structure with a single KVP of id=1.">
		<cfargument name="path" type="string" required="yes" hint="The requested path">
		<cfset var vars = {}>
		<cfset var uri_parts = listtoarray(variables.instance.uri, "/")>
		<cfset var i = 0>
		<cfloop from="1" to="#arraylen(uri_parts)#" index="i">
			<cfif left(uri_parts[i], 1) EQ ":">
				<cfset vars[right(uri_parts[i], len(uri_parts[i])-1)] = listgetat(arguments.path, i, "/")>
			</cfif>
		</cfloop>
		<cfreturn vars>
	</cffunction>

	<cffunction name="toStruct" access="public" returntype="struct" output="no" hint="Returns a copy of the routing information for this route">
		<cfset var meta = {
			verb       = variables.instance.verb,
			uri        = variables.instance.uri,
			controller = variables.instance.controller,
			method     = variables.instance.method
		}>
		<cfreturn meta>
	</cffunction>

</cfcomponent>
