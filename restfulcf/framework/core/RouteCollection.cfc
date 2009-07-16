<!--- -->
<fusedoc fuse="restfulcf/framework/core/RouteCollection.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a collection of routes
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="no">

	<cfset variables.routes = {}>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.RouteCollection" output="no" hint="I intialise the routes collection">
		<cfset variables.routes = {}>
		<cfreturn this>
	</cffunction>

	<cffunction name="addRoute" access="public" returntype="void" output="no" hint="Adds a given route to the collection">
		<cfargument name="route" type="restfulcf.framework.core.Route" required="yes" hint="The route to add to the collection">
		<cfif NOT structkeyexists(variables.routes, arguments.route.getVerb())>
			<cfset variables.routes[arguments.route.getVerb()] = []>
		</cfif>
		<cfset arrayappend(variables.routes[arguments.route.getVerb()], arguments.route)>
	</cffunction>

	<cffunction name="findRoute" access="public" returntype="restfulcf.framework.core.Route" output="no" hint="Find a route that matches the given request method and path info">
		<cfargument name="verb" type="string" required="yes" hint="The request method (e.g. GET, POST etc)">
		<cfargument name="path" type="string" required="yes" hint="The request path to find a route for (e.g. /users/1)">
		<cfset var route = "">
		<cfif structkeyexists(variables.routes, arguments.verb)>
			<cfloop array="#variables.routes[arguments.verb]#" index="route">
				<cfif route.matches(arguments.verb, arguments.path)>
					<cfreturn route>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn createobject("component", "restfulcf.framework.core.Route")>
	</cffunction>

	<cffunction name="getRoutes" access="public" returntype="struct" output="no" hint="">
		<cfreturn variables.routes>
	</cffunction>

	<cffunction name="toStruct" access="public" returntype="struct" output="no" hint="Returns a basic structure of this route collection">
		<cfset var rts   = {}>
		<cfset var verb  = "">
		<cfset var route = "">
		<cfloop collection="#variables.routes#" item="verb">
			<cfloop array="#variables.routes[verb]#" index="route">
				<cfset rts[route.getVerb() & " " & route.getURI()] = route.getController() & "##" & route.getMethod()>
			</cfloop>
		</cfloop>
		<cfreturn rts>
	</cffunction>

</cfcomponent>
