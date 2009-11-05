<!--- -->
<fusedoc fuse="restfulcf/sample/helloworld/rest/controllers/Worlds.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am the controller for World resources for the "Hello World" sample app
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="restfulcf.framework.core.Controller" output="no">

	<cffunction name="index" access="public" returntype="restfulcf.framework.core.ResourceCollection" output="no" hint="Index method (GET)">
		<cfargument name="order" type="string"  required="no" default="name" hint="The order to return results in (id, name, created_at)">
		<!--- create a collection to group all the matching worlds together in --->
		<cfset var collection = createobject("component", "restfulcf.framework.core.ResourceCollection").init("worlds")>
		<cfset var world = "">
		<!--- simply loop through all worlds, create a resource for each one and add it to the collection --->
		<cfloop array="#application.worlds#" index="world">
			<!--- we'll use our internal function defined at the bottom of
			      this component to convert the structure to a resource --->
			<cfset collection.add(toResource(world))>
		</cfloop>
		<!--- internal sorting based on the provided field (explicit sorting of a collection
		      instead of using DB ORDER BY clause because we're not using a DB here) --->
		<cfif collection.size() GT 1>
			<!--- have a peek inside the first item in the collection and get the list of "sortable" fields --->
			<cfif NOT listfind(structkeylist(collection.peek().getProperties()), listfirst(arguments.order, " "))>
				<!--- default the order to something we know we have if an unsuitable order has been provided --->
				<cfset arguments.order = "name">
			</cfif>
			<!--- sort based on the given field (using the getter for the property) --->
			<cfset collection.sort("get" & arguments.order)>
		</cfif>
		<!--- cache the response --->
		<cfset arguments['_response'].setCacheStatus(TRUE)>
		<!--- return the sorted collection --->
		<cfreturn collection>
	</cffunction>

	<cffunction name="count" access="public" returntype="any" output="no" hint="Returns a count of worlds">
		<!--- create a ResourceCount instance and populate it with the number of worlds --->
		<cfreturn createobject("component", "restfulcf.framework.core.ResourceCount").init("worlds", arraylen(application.worlds))>
	</cffunction>

	<cffunction name="read" access="public" returntype="any" output="no" hint="Read method (GET)">
		<cfargument name="id" type="numeric" required="yes" hint="The world ID to read">
		<cfset var world = "">
		<!--- find the world --->
		<cfset var pos = findPosition(arguments.id)>
		<cfif pos>
			<!--- get the world as a resource --->
			<cfset world = toResource(application.worlds[pos])>
		<cfelse>
			<!--- we can't find the word: set the response status appropriately --->
			<cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['not_found'])>
		</cfif>
		<cfreturn world>
	</cffunction>

	<cffunction name="create" access="public" returntype="any" output="yes" hint="Create method (POST)">
		<cfargument name="name" type="string" required="yes" hint="The world name">
		<cfset var world = {}>
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
		<!--- still here, so create the new world --->
		<cfset world = {
			id         = getMaxWorldID() + 1,
			name       = arguments.name,
			created_at = NOW(),
			updated_at = NOW()
		}>
		<!--- store the new world in our 'database' --->
		<cfset arrayappend(application.worlds, world)>
		<!--- set the proper response status and URI --->
		<cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['created'])>
		<cfset arguments['_response'].setResponseURI("/worlds/" & world.id)>
		<!--- and return the resource-ified world --->
		<cfreturn toResource(world)>
	</cffunction>

	<cffunction name="update" access="public" returntype="any" output="no" hint="Update method (PUT)">
		<cfargument name="id" type="numeric" required="yes" hint="The world ID to update">
		<cfargument name="name" type="string" required="yes" hint="The world name">
		<cfset var world = {}>
		<!--- find the world to update --->
		<cfset var pos = findPosition(arguments.id)>
		<cfif pos>
			<cfset world = application.worlds[pos]>
		<cfelse>
			<!--- we can't find the word: set the response status appropriately and return --->
			<cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['not_found'])>
			<cfreturn>
		</cfif>
		<!--- validate the name --->
		<cfif NOT len(arguments.name)>
			<cfset arguments['_response'].addError("Name must not be empty")>
		</cfif>
		<!--- if there are any errors, set a fail status and return --->
		<cfif arguments['_response'].hasErrors()>
			<cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['unprocessable_entity'])>
			<cfreturn>
		</cfif>
		<!--- still here, update the world --->
		<cfset world.name = arguments.name>
		<cfset world.updated_at = NOW()>
		<!--- store the new world in our 'database' --->
		<cfset application.worlds[pos] = world>
		<!--- set the proper response status --->
		<cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['ok'])>
		<!--- and return the resource-ified world --->
		<cfreturn toResource(world)>
	</cffunction>

	<cffunction name="delete" access="public" returntype="any" output="no" hint="Delete method (DELETE)">
		<cfargument name="id" type="numeric" required="yes" hint="The world ID to delete">
		<cfset var world = {}>
		<!--- find the world to update --->
		<cfset var pos = findPosition(arguments.id)>
		<cfif NOT pos>
			<!--- we can't find the word: set the response status appropriately and return --->
			<cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['not_found'])>
			<cfreturn>
		</cfif>
		<cfset arraydeleteat(application.worlds, pos)>
		<cfset arguments['_response'].setStatusCode(this.HTTP_STATUS_CODES['ok'])>
	</cffunction>

	<!--- *** (NON-CRUD) HELPER AND UTILITY FUNCTIONS --->

	<cffunction name="toResource" access="private" returntype="restfulcf.framework.core.Resource" output="no" hint="Converts an internally-stored world stucture to a World resource">
		<cfargument name="world" type="struct" required="yes" hint="The structure to convert to a World resource">
		<cfreturn createobject("component", "restfulcf.sample.helloworld.rest.resources.World").init(
			id         = world.id,
			name       = world.name,
			created_at = world.created_at,
			updated_at = world.updated_at
		)>
	</cffunction>

	<cffunction name="findPosition" access="private" returntype="numeric" output="no" hint="Find the array position of the given world ID">
		<cfargument name="id" type="numeric" required="yes" hint="The world ID">
		<cfset var pos = 0>
		<cfset var i = 0>
		<cfloop from="1" to="#arraylen(application.worlds)#" index="i">
			<cfif application.worlds[i].id EQ arguments.id>
				<cfset pos = i>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfreturn pos>
	</cffunction>

	<cffunction name="getMaxWorldID" access="private" returntype="numeric" output="no" hint="Find the maximum world ID">
		<cfset var max_id = 0>
		<cfset var world = "">
		<cfloop array="#application.worlds#" index="world">
			<cfif world.id GT max_id>
				<cfset max_id = world.id>
			</cfif>
		</cfloop>
		<cfreturn max_id>
	</cffunction>

</cfcomponent>
