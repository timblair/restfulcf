<!--- -->
<fusedoc fuse="restfulcf/framework/core/ResourceCollection.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a resource that contains other resources (effectively an array of resources)
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="restfulcf.framework.core.Resource" output="no">

	<cfset variables.instance.type = "">
	<cfset variables.instance.resources = []>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.ResourceCollection" output="no" hint="I initialise the component">
		<cfargument name="type" type="string" required="yes" hint="The type of resource that the collection holds">
		<cfargument name="resources" type="array" required="no" hint="An optional array of resources which which to populate this collection">
		<cfset variables.instance.type = arguments.type>
		<cfif structkeyexists(arguments, "resources")><cfset variables.instance.resources = arguments.resources></cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="add" access="public" returntype="void" output="no" hint="Adds a resource to the collection">
		<cfargument name="resource" type="restfulcf.framework.core.Resource" required="yes" hint="The resource to add to the collection">
		<cfset arrayappend(variables.instance.resources, arguments.resource)>
	</cffunction>

	<cffunction name="peek" access="public" returntype="restfulcf.framework.core.Resource" output="no" hint="Retrieves a single resource from the collection">
		<cfargument name="position" type="numeric" required="no" hint="The index of the resource to retrieve (default is first)">
		<cfif structkeyexists(arguments, "position")>
			<cfif NOT (arguments.position GTE 1 AND arguments.position LTE arraylen(variables.instance.resources))>
				<cfthrow type="coldfusion.runtime.InvalidArgumentException" message="position" detail="Invalid resource position (no resource exists with this index)">
			</cfif>
		<cfelse>
			<cfset arguments.position = 1>
			<cfif NOT arraylen(variables.instance.resources)>
				<cfthrow type="coldfusion.runtime.InvalidArgumentException" detail="Collection is empty">
			</cfif>
		</cfif>
		<cfreturn variables.instance.resources[arguments.position]>
	</cffunction>

	<cffunction name="size" access="public" returntype="numeric" output="no" hint="Returns the number of resources in the collection">
		<cfreturn arraylen(variables.instance.resources)>
	</cffunction>

	<cffunction name="getResources" access="public" returntype="array" output="no" hint="Returns the internal array of resources">
		<cfreturn variables.instance.resources>
	</cffunction>

	<cffunction name="sort" access="public" returntype="void" output="no" hint="Sorts the collection based on the given key">
		<cfargument name="by" type="string" required="yes" hint="What to sort by: can be a structure key or function name">
		<cfargument name="order" type="string" required="no" default="asc" hint="Sort order: asc/desc">
		<cfset var arrays = createobject("component", "restfulcf.framework.util.Arrays")>
		<cfset variables.instance.resources = arrays.mergeSort(variables.instance.resources, arguments.by)>
		<cfif lcase(arguments.order) EQ "desc"><cfset variables.instance.resources = arrays.switch(variables.instance.resources)></cfif>
	</cffunction>

	<cffunction name="toXML" access="public" returntype="xml" output="no" hint="Returns this resource in XML format">
		<cfset var xml = []>
		<cfset var resource = "">
		<cfloop array="#variables.instance.resources#" index="resource">
			<cfset arrayappend(xml, resource.toXML())>
		</cfloop>
		<cfreturn '<#variables.instance.type# type="array">' & arraytolist(xml, chr(10)) & '</#variables.instance.type#>'>
	</cffunction>

	<cffunction name="toHTML" access="public" returntype="string" output="no" hint="Returns this resource in HTML format">
		<cfset var html = []>
		<cfset var resource = "">
		<cfloop array="#variables.instance.resources#" index="resource">
			<cfset arrayappend(html, resource.toHTML())>
		</cfloop>
		<cfreturn arraytolist(html, chr(10) & "<hr>")>
	</cffunction>

	<cffunction name="toTXT" access="public" returntype="string" output="no" hint="Returns this resource in plain text format">
		<cfset var text = []>
		<cfset var resource = "">
		<cfloop array="#variables.instance.resources#" index="resource">
			<cfset arrayappend(text, resource.toTXT())>
		</cfloop>
		<cfreturn arraytolist(text, chr(10))>
	</cffunction>

	<cffunction name="toJSON" access="public" returntype="string" output="no" hint="Returns this resource in plain text format">
		<cfset var json = []>
		<cfset var resource = "">
		<cfloop array="#variables.instance.resources#" index="resource">
			<cfset arrayappend(json, resource.toJSON())>
		</cfloop>
		<cfreturn "[" & arraytolist(json, ",#chr(10)#") & "]">
	</cffunction>

	<cffunction name="toCSV" access="public" returntype="string" output="no" hint="Returns this resource in CSV format">
		<cfargument name="include_header" type="boolean" required="no" default="TRUE" hint="Should the resource properties be included as the first line?">
		<cfset var csv = []>
		<cfset var resource = "">
		<cfloop array="#variables.instance.resources#" index="resource">
			<cfset arrayappend(csv, resource.toCSV(arguments.include_header))>
			<cfset arguments.include_header = FALSE>
		</cfloop>
		<cfreturn arraytolist(csv, chr(10))>
	</cffunction>

</cfcomponent>
